#!/bin/sh -

# Search for one or more ordinary files or file patterns on a search path defined by a specified environment variable.
#
# The output on standard output is normally either the full path to the first instance of each file found on the search path,
# or "filename: not found" on standard error.
#
# The exit code is 0 if all files are found,
# and otherwise a nonzero value equal to the number of files not found (subject to the shell exit code limit of 125).
#
# Usage:
#		pathfind [--all] [--?] [--help] [--version] envvar pattern(s)
#
# With the --all option, every directory in the path is searched, instead of stopping with the first one found.
#
# Source:	Classic Shell Scripting		chapter 8.1


## security issues

# we reset the value of the input field separator at each execution of this script
# 3 character string consisting of newline, space and tab
IFS='
 	'

# to avoid software of being tricked into executing unintended commands
OLDPATH="$PATH"					# stores the current path for later use
PATH=/bin:/usr/bin				# new minimal value
export PATH						# ensures that our secure search path is inherited by all subprocesses


# prints its arguments on standard error, and then calls a function
error()
{
	echo "$@" 1>&2
	usage_and_exit 1
}

# writes a brief message showing the expected way to use the program, and returns to its caller
usage()
{
	echo "Usage: $PROGRAM [--all] [--?] [--help] [--version] envvar pattern(s)"
}

# produces the usage message, and then exits with a status code given by its single argument
usage_and_exit()
{
	usage
	exit $1
}

# displays the program version number on standard output, and returns to its caller
version()
{
	echo "$PROGRAM version $VERSION"
}

# prints its arguments on stderr, increments EXITCODE by 1 to track the number of warnings issued, and returns to its caller
warning()
{
	echo "$@" 1>&2
	EXITCODE=$(expr $EXITCODE + 1)
}


## variable initialization
all=no							# option choice
envvar=							# user-provided environment variable name
EXITCODE=0						# exit code
PROGRAM=$(basename $0)			# program name
VERSION=1.0						# program version number

## typical command-line argument parsing
while [ $# -gt 0 ]
do
	case $1 in
	--all | --al | --a | -all | -al | -a )
		all=yes
	;;
	--help | --hel | --he | --h | '--?' | -help | -hel | -he | -h | '-?' )
		usage_and_exit 0		# exit with a success status
	;;
	--version | --versio | --versi | --vers | --ver | --ve | --v | -version | -versio | -versi | -vers | -ver | -ve | -v )
		version
		exit 0
	;;
	-*)
		error "Unrecognized option: $1"
	;;
	*)
		break
	;;
	esac

	shift
done

## remaining arguments
envvar="$1"						# the first remaining in the argument list is the environment variable name
[ $# -gt 0 ] && shift			# if at least one argument (a file name to search) remains, we discard the first argument (envvar)
# it is possible that the user-supplied environment variable is PATH
# the x prevents the expansion of the variable from being confused with a test option, if that expansion starts with a hyphen
[ "x$envvar" = "xPATH" ] && envvar=OLDPATH

# '${'"$envvar"'}' is expanded only to the name of the path given as argument
# eval then first expands $(MYPATH) (MYPATH being the name of the path given by the user) to the actual path stored in it
# tr receives the echo of that path and turns colons into whitespaces
# errors are silenced by being sent to /dev/null
dirpath=$(eval echo '${'"$envvar"'}' 2> /dev/null | tr : ' ' )


## sanity checks for error conditions
if [ -z "$envvar" ]											# the string stored in envvar is null
then
	error Environment variable missing or empty
elif [ "x$dirpath" = "x$envvar" ]							# the name of the path cannot be the path itself
then
	error "Broken sh on this platform: cannot expand $envvar"
elif [ -z "$dirpath" ]										# the string stored in dirpath is null
then
	error Empty directory search path
elif [ $# -eq 0 ]											# no arguments have been passed at the command line
then
	exit 0													# if there is nothing to do, there is nothing to report but success
fi


## look for every requested match in every directory in the search path
for pattern in "$@"
do
	result=													# will remain empty if no matches are found
	for dir in $dirpath
	do
		for patfile in $dir/$pattern
		do
			if [ -f "$patfile" ]							# $patfile exists and is a regular file
			then
				result="$patfile"
				echo $result								# report to the standard output
				[ "$all" = "no" ] && break 2				# if we only report the first one, exits to the outer loop (2 levels up)
			fi
		done
	done
	[ -z "$result" ] && warning "$pattern: not found"		# if the the expansion $result is empty, report the missing file
done


[ $EXITCODE -gt 125 ] && EXITCODE=125						# user exit-code values are limited to the range 0 through 125
exit $EXITCODE												# returns to the parent process with an explicit exit status
