#!/bin/sh -

# Build one or more packages in parallel on one or more build hosts.
#
# Usage:
#       build-all [ --? ]
#                 [ --all "..." ]
#                 [ --cd "..." ]
#                 [ --check "..." ]
#                 [ --configure "..." ]
#                 [ --environment "..." ]
#                 [ --help ]
#                 [ --logdirectory dir ]
#                 [ --on "[user@]host[:dir][,envfile] ..." ]
#                 [ --source "dir ..." ]
#                 [ --userhosts "file(s)" ]
#                 [ --version ]
#                 package(s)
#
# Optional initialization files:
#       $HOME/.build/directories        list of source directories
#       $HOME/.build/userhosts          list of [user@]host[:dir][,envfile]
#
#
# Source:   Classic Shell Scripting     chapter 8.2


## security issues

# we reset the value of the input field separator at each execution of this script
# 3 character string consisting of newline, space and tab
IFS='
    '

# to avoid software of being tricked into executing unintended commands
PATH=/bin:/usr/bin                              # new minimal value
export PATH                                     # ensures that our secure search path is inherited by all subprocesses


## full access for user and group, and read access for other
U_MASK=002
umask $U_MASK


## variables
ALLTARGETS=                                     # programs or make targets to build
altlogdir=                                      # alternative location for log files
altsrcdirs=                                     # alternative location for source files
ALTUSERHOSTS=                                   # file with list of additional hosts
CHECKTARGETS=check                              # make target name to run package test suite
CONFIGUREDIR=.                                  # subdirectory with configure script
CONFIGUREFLAGS=                                 # special flags for configure program
LOGDIR=                                         # local directory to hold log files
userhosts=                                      # additional build hosts named on command line
BUILDHOME=$HOME/.build                          # where build-all's initialization files are found
BUILDBEGIN=./.build/begin
BUILDEND=./.build/end
EXITCODE=0
EXTRAENVIRONMENT=                               # any extra environment variables to pass in
PROGRAM=$(basename $0)                          # remember program name
VERSION=1.0                                     # record program version number
DATEFLAGS="+%Y.%m.%d.%H.%M.%S"                  # timestamp to be used in the build-log filenames
SCPCMD=scp
SSHCMD=ssh
SSHFLAGS=${SSHFLAGS--x}                         # reduce startup overhead by turning it off with the -x option
STRIPCOMMENTS='sed -e s/#.*$//'                 # remove comments in the initialization files
INDENT="awk '{ print \"\t\t\t\" \$0 }'"         # to indent a data stream (for better-looking output)
JOINLINES="tr '\n' '\040'"                      # to replace newlines by spaces
defaultdirectories=$BUILDHOME/directories       # optional initialization files
defaultuserhosts=$BUILDHOME/userhosts
SRCDIRS="$($STRIPCOMMENTS $defaultdirectories 2> /dev/null)"        # list of source directories

# if the user customization file does not exist, STRIPCOMMENTS produces an empty string in SRCDIRS, so it gives it a default value
[ -z "$SRCDIRS" ] && \
    SRCDIRS="
            .
            /usr/local/src
            /usr/local/gnu/src
            $HOME/src
            $HOME/gnu/src
            /tmp
            /usr/tmp
            /var/tmp
            "

## option processing loop
while [ $# -gt 0 ]
do
    case $1 in
    --all | --al | --a | -all | -al | -a )
        shift
        ALLTARGETS="$1"
    ;;
    --cd | -cd )
        shift
        CONFIGUREDIR="$1"
    ;;
    --check | --chec | --che | --ch | -check | -chec | -che | -ch )
        shift
        CHECKTARGETS="$1"
    ;;
    --configure | --configur | --configu | --config | --confi | --conf | --con | --co | \
    -configure | -configur | -configu | -config | -confi | -conf | -con | -co )
        shift
        CONFIGUREFLAGS="$1"
    ;;
    # provides a way to supply one-time settings of configure-time environment variables on the build host,
    # without having to change build configuration files
    --environment | --environmen | --environme | --environm | --environ | --enviro | --envir | --envi | --env | --en | --e | \
    -environment | -environmen | -environme | -environm | -environ | -enviro | -envir | -envi | -env | -en | -e )
        shift
        EXTRAENVIRONMENT="$1"
    ;;
    --help | --hel | --he | --h | '--?' | -help | -hel | -he | -h | '-?' )
        usage_and_exit 0
    ;;
    --logdirectory | --logdirector | --logdirecto | --logdirect | --logdirec | --logdire | --logdir | --logdi | --logd | --log | --lo | --l |
    -logdirectory | -logdirector | -logdirecto | -logdirect | -logdirec | -logdire | -logdir | -logdi | -logd | -log | -lo | -l )
        shift
        altlogdir="$1"                          # names the directory where all the build logs are written, if the default location is not desired
    ;;
    # merely accumulate arguments, so the user can write -s "/this/dir /that/dir" or -s /this/dir -s /that/dir
    --on | --o | -on | -o )
        shift
        userhosts="$userhosts $1"
    ;;
    # merely accumulate arguments, so the user can write -s "/this/dir /that/dir" or -s /this/dir -s /that/dir
    --source | --sourc | --sour | --sou | --so | --s | -source | -sourc | -sour | -sou | -so | -s )
        shift
        altsrcdirs="$altsrcdirs $1"
    ;;
    # also accumulates arguments, but with the additional convenience of checking an alternate directory location
    --userhosts | --userhost | --userhos | --userho | --userh | --user | --use | --us | --u | \
    -userhosts | -userhost | -userhos | -userho | -userh | -user | -use | -us | -u )
        shift
        set_userhosts $1                        # function that checks for an alternate directory location
    ;;
    # displays a version number and exits with a success status code
    --version | --versio | --versi | --vers | --ver | --ve | --v | -version | -versio | -versi | -vers | -ver | -ve | -v )
        version
        exit 0
    ;;
    # catches any unrecognized options and terminates with an error
    -*)
        error "Unrecognized option: $1"
    ;;
    # matches anything but an option name, so it must be a package name, and we leave the option loop
    *)
        break
    ;;
    esac

    shift                                       # discards the just-processed argument, and we continue with the next loop iteration
done

## the mail-client program reports log-file locations
## search for the mail-client program dynamically using a list of potential locations
for MAIL_CLIENT in /bin/mailx /usr/bin/mailx /usr/sbin/mailx /usr/ucb/mailx /bin/mail /usr/bin/mail
do
    [ -x $MAIL_CLIENT ] && break                # if this mail-client program exists and the execute flag is on, break the loop
done
[ -x $MAIL_CLIENT ] || error "Cannot find mail client"

SRCDIRS="$altsrcdirs $SRCDIRS"                  # makes it impossible to replace the default list


## there are 3 potential sources of data for the userhosts list:
# Command-line --on options added their arguments to the userhosts variable
# Command-line --userhosts options added files, each containing zero or more build-host specifications, to the ALTUSERHOSTS variable
# The defaultuserhosts variable contains the name of a file that supplies default build-host specifications,
# to be used only when no command-line options provide them.
# For most invocations of build-all, this file supplies the complete build list

if [ -n "$userhosts" ]                          # the userhosts variable contains data
then
    # the contents of any files recorded in ALTUSERHOSTS must be added to it to obtain the final list
    [ -n "$ALTUSERHOSTS" ] && userhosts="$userhosts $($STRIPCOMMENTS $ALTUSERHOSTS 2> /dev/null)"
else                                            # the userhosts variable is empty, there are still 2 possibilities
    # if ALTUSERHOSTS was set, leave it untouched, otherwise set it to the default file
    [ -z "$ALTUSERHOSTS" ] && ALTUSERHOSTS="$defaultuserhosts"
    # then we assign the contents of the files in ALTUSERHOSTS to the userhosts variable for the final list
    userhosts="$($STRIPCOMMENTS $ALTUSERHOSTS 2> /dev/null)"
fi

# essential sanity check to ensure that we have at least one host
[ -z "$userhosts" ] && usage_and_exit 1


## loop over packages
for p in "$@"
do
    find_package "$p"                           # locate the package archive in the source directory list
    if [ -z "$PARFILE" ]                        # PARFILE is a global variable that stores the find_package function's results
    then
        warning "Cannot find package file $p"
        continue                                # continue to the next package
    fi

    LOGDIR="$altlogdir"
    # a log directory was not supplied, or was but is not a directory or is not writable
    if [ -z "$LOGDIR" -o ! -d "$LOGDIR" -o ! -w "$LOGDIR" ]
    then
        # attempt to create a subdirectory named logs underneath the directory where the package archive was found
        for LOGDIR in "$(dirname $PARFILE)/logs/$p" $BUILDHOME/logs/$p /usr/tmp /var/tmp /tmp
        do
            [ -d "$LOGDIR" ] || mkdir -p "$LOGDIR" 2> /dev/null         # the directory cannot be found
            [ -d "$LOGDIR" -a -w "$LOGDIR" ] && break                   # the directory is not writable
        done
    fi

    msg="Check build logs for $p in $(hostname):$LOGDIR"
    echo "$msg"                                                         # tell the user where the logs are created
    echo "$msg" | $MAIL_CLIENT -s "$msg" $USER 2> /dev/null             # record that location in email as well

    # loop over the remote hosts to start building the current package on each of them in parallel
    for u in $userhosts
    do
        build_one $u
    done
done

[ $EXITCODE -gt 125 ] && EXITCODE=125           # user exit-code values are limited to the range 0 through 125
exit $EXITCODE                                  # returns to the parent process with an explicit exit status


# prints a short help message on standard output, using a here document instead of a series of echo statements
usage()
{
    cat <<- EOF
    Usage:  $PROGRAM [ --? ]
                     [ --all "..." ]
                     [ --cd "..." ]
                     [ --check "..." ]
                     [ --configure "..." ]
                     [ --environment "..." ]
                     [ --help ]
                     [ --logdirectory dir ]
                     [ --on "[user@]host[:dir][,envfile] ..." ]
                     [ --source "dir ..." ]
                     [ --userhosts "file(s)" ]
                     [ --version ]
                     package(s)
EOF
}

# calls usage, and then exits with the status code supplied as its argument
usage_and_exit()
{
    usage
    exit $1
}

# version displays the version number on standard output
version()
{
    echo "$PROGRAM version $VERSION"
}

# displays its arguments on stderr, follows them with the usage message, and then terminates the program with a failure status code
error()
{
    echo "$@" 1>&2
    usage_and_exit 1
}

# displays its arguments on standard error, increments the warning count in EXITCODE, and returns:
warning()
{
    echo "$@" 1>&2
    EXITCODE=$(expr $EXITCODE + 1)
}

# loops over the source directories, looking for the package archive
#
# Usage:
#       find_package package-x.y.z
find_package()
{
    base=$(echo "$1" | sed -e 's/[-_][.]*[0-9].*$//')                   # strips the version number from the package name
    PAR=
    PARFILE=
    for srcdir in $SRCDIRS
    do
        [ "$srcdir" = "." ] && srcdir="$(pwd)"
        for subdir in "$base" ""
        do
            # NB: update package setting in build_one() if this list changes
            find_file $srcdir/$subdir/$1.tar.gz     "tar xfz"   && return
            find_file $srcdir/$subdir/$1.tar.Z      "tar xfz"   && return
            find_file $srcdir/$subdir/$1.tar        "tar xf"    && return
            find_file $srcdir/$subdir/$1.tar.bz2    "tar xfj"   && return
            find_file $srcdir/$subdir/$1.tgz        "tar xfz"   && return
            find_file $srcdir/$subdir/$1.zip        "unzip -q"  && return
            find_file $srcdir/$subdir/$1.jar        "jar xf"    && return
        done
    done
}

# essentially just a readability and existence test for the package archive file
# returns 0 (success) if found, 1 (failure) if not found
#
# Usage:
#       find_file file program-and-args
find_file()
{
    if [ -r "$1" ]
    then
        PAR="$2"                                # Program and arguments to use for extraction
        PARFILE="$1"                            # Actual file to extract source from
        return 0
    else
        return 1
    fi
}

# Provides the convenience of allowing userhosts files to be specified with explicit paths,
# possibly relative to the current directory, or found in the $BUILDHOME initialization directory.
# Makes it convenient to create sets of build hosts grouped by compiler, platform, or package,
# in order to accommodate packages that are known to build only in certain limited environments.
#
# Usage:
#       set_userhosts file(s)
set_userhosts()
{
    for u in "$@"
    do
        if [ -r "$u" ]
        then
            ALTUSERHOSTS="$ALTUSERHOSTS $u"
        elif [ -r "$BUILDHOME/$u" ]
        then
            ALTUSERHOSTS="$ALTUSERHOSTS $BUILDHOME/$u"
        else
            error "File not found: $u"
        fi
    done
}

#
# Usage:
#       build_one [user@]host[:build-directory][,envfile]
build_one()
{
    # the $HOME/.build/userhosts initialization file requires:
    #   the username on the remote host (if different from that on the initiating host)
    #   the hostname itself (mandatory)
    #   the name of the existing directory on the remote host where the build should take place
    #   and possibly additional environment variable settings specific to this build
    #
    # ex:   jones@freebsd.example.com:/local/build,$HOME/.build/c99

    arg="$(eval echo $1)"                                       # expand env vars

    userhost="$(echo $arg | sed -e 's/:.*$//')"                 # remove colon and everything after it

    user="$(echo $userhost | sed -e s'/@.*$//')"                # extract username
    [ "$user" = "$userhost" ] && user=$USER                     # use $USER if empty

    host="$(echo $userhost | sed -e s'/^[^@]*@//')"             # extract host part

    envfile="$(echo $arg | sed -e 's/^[^,]*,//')"               # name of env vars file
    [ "$envfile" = "$arg" ] && envfile=/dev/null

    builddir="$(echo $arg | sed -e s'/^.*://' -e 's/,.*//')"    # build directory
    [ "$builddir" = "$arg" ] && builddir=/tmp

    parbase=$(basename $PARFILE)                                # save the bare filename (e.g., gawk-3.1.4.tar.gz)

    # should support for new archive formats ever be added to find_package, these editor patterns need to be updated as well
    package="$(echo $parbase | sed -e 's/[.]jar$//' \
                                   -e 's/[.]tar[.]bz2$//' \
                                   -e 's/[.]tar[.]gz$//' \
                                   -e 's/[.]tar[.]Z$//' \
                                   -e 's/[.]tar$//' \
                                   -e 's/[.]tgz$//' \
                                   -e 's/[.]zip$//')"

    echo $SSHCMD $SSHFLAGS $userhost "test -f $PARFILE"         # feedback to the user
    if $SSHCMD $SSHFLAGS $userhost "test -f $PARFILE"           # the archive file can already be seen on the system
    then
        # the parbaselocal variable serves to distinguish between a temporary copy of the archive file and a preexisting one
        parbaselocal=$PARFILE
    else
        parbaselocal=$parbase
        echo $SCPCMD $PARFILE $userhost:$builddir               # feedback to the user in case the remote copy fails or hangs
        $SCPCMD $PARFILE $userhost:$builddir                    # copy the archive file to the build directory on the remote host
    fi

    # log files are named with the package, remote host, and a timestamp with one-second resolution
    sleep 1                                                     # to guarantee unique log filename
    now="$(date $DATEFLAGS)"
    logfile="$package.$host.$now.log"

    # The second argument to ssh is a long string delimited by double quotes, inside that string
    # variables prefixed with a dollar sign are expanded in the context of the script, and need not be known on the remote host.
    #
    # Shells in the Bourne-shell family use the dot command to execute commands in the current shell,
    # whereas shells in the C-shell family use the source command.
    # Some shells, including the POSIX one, abort execution of the dot command if the specified file does not exist.
    # This makes simple code like . $BUILDBEGIN || true fail, despite the use of the true command at the end of the conditional.
    # We therefore also need a file-existence test, and we have to handle the source command as well.
    # Because bash and zsh recognize both the dot command and the source command,
    # we must do this in a single complex command that relies on the equal precedence of the Boolean operators.
    #
    # Record extra information in the build logs, carefully formatted for better log-file readability.
    #
    # The script reports before and after dates to calculate how long the build took.
    # These are obtained on the remote host, which might be in a different time zone, or suffer from clock skew,
    # and it may be important later to match timestamps of installed files with entries in the build logs.
    # There is no portable way to use echo to generate a partial line, so we use printf.
    #
    # Record operating system and GNU compiler version information.
    #
    # additional information
    #
    # Report on the available space before and after the build.
    #
    # configure and make can be influenced by environment variables, so we finish off the log-file header with a sorted list of them
    # The env command in the middle stage of the pipeline ensures that the script works properly with all shells, including the C-shell family.
    #
    # Set the permission mask on the remote system, as we did on the local one.
    #
    # The archive file is already resident in the build directory, so we change to that directory, exiting with an error if cd fails.
    #
    # Remove any old archive tree.
    # We use an absolute path for rm because these commands are executed in the context of an interactive shell,
    # and some sites have that command aliased to include the interactive option, -i
    #
    # Unpack the archive. It is important to realize that $PAR is expanded on the initiating host, but run on the remote host.
    #
    # If the archive was copied to the remote host, then parbaselocal and parbase have identical values,
    # and since the package archive file is no longer needed on the remote host, we remove it.
    #
    # We are ready to change to the package directory and start the build.
    # For software packages that follow the widely used GNU Project conventions, that directory is the top-level package directory.
    # Unfortunately, some packages bury the build directory deeper in the file-tree, among them, the widely used Tcl and Tk tools.
    # The command-line -cd option supplies a relative path to the build directory that is saved in CONFIGUREDIR,
    # overriding its default value of dot (the current directory).
    # We therefore need both the package variable and the CONFIGUREDIR variable to change to the build directory,
    # and if that fails, we exit with an error.
    #
    # Many packages now come with configure scripts, so we test for one, and if it is found,
    # we execute it with any additional environment variables supplied by envfile.
    # The time command prefix reports the time for configure to run.
    # We also pass on any additional flags supplied by a -configure option.
    # Most packages do not require such flags, but some of the more complex ones often do.
    #
    # The actual build and validation of the package, again with a nice time prefix,
    # and make arguments supplied by -all and -check options (or their defaults)
    #
    # Final reports for the log files.
    #
    # As with the $BUILDBEGIN script,
    # the $BUILDEND script under the home directory provides for any final additional log-file reporting, but true ensures success.
    #
    nice $SSHCMD $SSHFLAGS $userhost "
        echo '=  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  = ' ;
        [ -f $BUILDBEGIN && . $BUILDBEGIN ] || [ -f $BUILDBEGIN && source $BUILDBEGIN ] || true ;

        echo 'Package:                  $package' ;
        echo 'Archive:                  $PARFILE' ;
        echo 'Date:                     $now' ;
        echo 'Local user:               $USER' ;
        echo 'Local host:               $(hostname)' ;
        echo 'Local log directory:      $LOGDIR' ;
        echo 'Local log file:           $logfile' ;
        echo 'Remote user:              $user' ;
        echo 'Remote host:              $host' ;
        echo 'Remote directory:         $builddir' ;

        printf 'Remote date:            ' ;
        date $DATEFLAGS ;

        printf 'Remote uname:           ' ;
        uname -a || true ;
        printf 'Remote gcc version:     ' ;
        gcc --version | head -n 1 || echo ;
        printf 'Remote g++ version:     ' ;
        g++ --version | head -n 1 || echo ;

        echo 'Configure environment:    $($STRIPCOMMENTS $envfile | $JOINLINES)' ;
        echo 'Extra environment:        $EXTRAENVIRONMENT' ;
        echo 'Configure directory:      $CONFIGUREDIR' ;
        echo 'Configure flags:          $CONFIGUREFLAGS' ;
        echo 'Make all targets:         $ALLTARGETS' ;
        echo 'Make check targets:       $CHECKTARGETS' ;

        echo 'Disk free report for $builddir/$package:' ;
        df $builddir | $INDENT ;

        echo 'Environment:' ;
        env | env LC_ALL=C sort | $INDENT ;
        echo '=  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  = ' ;

        umask $UMASK ;

        cd $builddir || exit 1 ;

        /bin/rm -rf $builddir/$package ;

        $PAR $parbaselocal ;

        [ "$parbase" = "$parbaselocal" ] && /bin/rm -f $parbase ;

        cd $package/$CONFIGUREDIR || exit 1 ;

        [ -f configure ] && \
            chmod a+x configure && \
                env $($STRIPCOMMENTS $envfile | $JOINLINES) \
                    $EXTRAENVIRONMENT \
                        nice time ./configure $CONFIGUREFLAGS ;

        nice time make $ALLTARGETS && nice time make $CHECKTARGETS ;

        echo '=  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  = ' ;
        echo 'Disk free report for $builddir/$package:' ;
        df $builddir | $INDENT ;
        printf 'Remote date:            ' ;
        date $DATEFLAGS ;

        cd ;
        [ -f $BUILDEND && . $BUILDEND ] || [ -f $BUILDEND && source $BUILDEND ] || true ;
        echo '=  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  = ' ;

    " < /dev/null > "$LOGDIR/$logfile" 2>&1 &
    # close off the list of remote commands and the function body,
    # redirect both standard output and standard error to the log file, and importantly,
    # run the remote commands in the background so that execution can immediately continue in the inner loop of the main body.
    # The remote shell's input is redirected to the null device so it does not hang waiting for user input.
}
