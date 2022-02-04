#
#   Built-in commands are executed by the shell itself, instead of running them through another program.
#   POSIX distinguishes between "special" built-ins and "regular" built-ins.
#

: (colon)               # do nothing (just do expansions of arguments) (source command in bash)
. (dot)                 # read file and execute its contents in current shell
alias                   # set up shorthand for command or command line (interactive use)
bg                      # put job in background (interactive use)
break       (spe)       # exit from surrounding for, while, until or while loop
cd                      # (change directory) to change to the specified directory, if none is specified, it goes to the home directory
command                 # locate built-in and external commands; find a built-in command instead of an identically named function
continue    (spe)       # skip to next iteration of for, while, or until loop
eval        (spe)       # evaluate given text as a shell command
exec        (spe)       # With no arguments, change the shell's open files. With arguments, replace the shell with another program.
exit        (spe)       # exit a shell script, optionally with a specific exit code
export      (spe)       # create environment variables
false                   # do nothing, unsuccessfully
fc                      # work with command history (interactive use)
fg                      # put background job in foreground (interactive use)
getopts                 # process command-line options
jobs                    # list background jobs (interactive use)
kill                    # send signals
newgrp                  # start new shell with new group ID (obsolete)
pwd                     # (print working directory) displays the directory structure of the current directory
read                    # read a line from standard input
readonly    (spe)       # make variables read-only (unassignable)
return      (spe)       # return from surrounding function
set         (spe)       # set options or positional parameters
shift       (spe)       # shift command-line arguments
times       (spe)       # print accumulated user and system CPU times for the shell and its children
trap        (spe)       # set up signal-catching routine
true                    # do nothing, successfully
umask                   # set/show file permission mask
unalias                 # remove alias definitions (interactive use)
unset       (spe)       # remove definitions of variables or functions
wait                    # wait for background job(s) to finish

#
#   The command-search order is:
#       special built-ins first
#       then shell functions
#       then regular built-ins
#       and finally external commands found by searching the directories listed in $PATH.
#   This search order makes it possible to define shell functions that extend or override regular shell built-ins.
#


# cd --- private version of cd to update PS1 when changing directories
cd()
{
    command cd "$@"     # Actually change directory using command to avoid infinite recursion
    x=$(pwd)            # Get current directory name into variable x
    PS1="${x##*/}\$ "   # deletes the longest part between / of the path stored in x, followed by $
}


#
#   command     allows access to built-in versions of commands from functions with the same name as the built-in command
#
#       command [ -p ] program [ arguments ... ]
#
#   -p  when searching for commands, use a default value of $PATH that is guaranteed to find the system's utilities
#
#   command finds the named program by looking for special and regular built-ins, and then searching along $PATH.
#   With the -p option, it uses a default value for $PATH, instead of the current setting.
#
#   When program is a special built-in command, any syntax errors do not abort the shell,
#   and any preceding variable assignments do not remain in effect after the command has finished.
#


#
#   Variable assignment can be specified at the front of a command,
#   and the variable will have that value in the environment of the executed command only,
#   without affecting the variable in the current shell or subsequent commands.
#
PATH=/bin:/usr/bin:/usr/ucb awk '...'
#
#   However, variable assignments specified with special built-in commands remain in effect after the built-in completes
#


#
#   set         to print the names and values of all current shell variables;
#               to set or unset the value of shell options (which change the way that the shell behaves)
#               and to change the values of the positional parameters
#
#       set
#       set -- [ arguments ... ]
#       set [ -short-options ] [ -o long-option ] [ arguments ... ]
#       set [ +short-options ] [ +o long-option ] [ arguments ... ]
#       set -o
#       set +o
#
# With no options or arguments, print the names and values of all shell variables in a form that can later be reread by the shell
# With -- and arguments, replace the positional parameters with the supplied arguments
# With short-form options that begin with a -, or long-form options that begin with -o, enable particular shell options
# With short-form options that begin with a +, or long-form options that begin with +o, disable particular shell options
# A single -o prints the current settings of the shell options "in an unspecified format." ksh93 and bash both print a sorted list
# A single +o prints the current settings of the shell options in a way that they may be later reread by the shell to achieve the same set of option settings
#
# Items marked POSIX are available in both bash and the Korn shell.
# Here's the full set of set options, for both bash and ksh:

#   Short   -o form         Availability        Description
#   -----   -------         ------------        -----------
#   -a      allexport       POSIX               Export all subsequently defined variables.
#   -A                      ksh88, ksh93        Array assignment. set +A does not clear the array.
#   -b      notify          POSIX               Print job completion messages right away, instead of waiting for next prompt. Intended for interactive use.
#   -B      braceexpand     bash                Enable brace expansion. On by default.
#   -C      noclobber       POSIX               Don't allow > redirection to existing files. The >| operator overrides the setting of this option. Intended for interactive use.
#   -e      errexit         POSIX               Exit the shell when a command exits with nonzero status.
#   -f      noglob          POSIX               Disable wildcard expansion.
#   -h      hashall (bash)  POSIX               Locate and remember the location of commands called from function bodies when the function is defined, instead of when the function is executed (XSI).
#           trackall (ksh)
#   -H      histexpand      bash                Enable !-style history expansion. On by default. (it is recommended to disable this feature if you use bash)
#   -k      keyword         bash, ksh88, ksh93  Put all variable assignments into the environment, even those in the middle of a command. This is an obsolete feature and should never be used.
#   -m      monitor         POSIX               Enable job control (on by default). Intended for interactive use.
#   -n      noexec          POSIX               Read commands and check for syntax errors, but don't execute them. Interactive shells are allowed to ignore this option.
#   -p      privileged      bash, ksh88, ksh93  Attempt to function in a more secure mode. The details differ among the shells; see your shell's documentation.
#   -P      physical        bash                Use the physical directory structure for commands that change directory.
#   -s                      ksh88, ksh93        Sort the positional parameters.
#   -t                      bash, ksh88, ksh93  Read and execute one command and then exit. This is obsolete; it is for compatibility with the Bourne shell and should not be used.
#   -u      nounset         POSIX               Treat undefined variables as errors, not as null.
#   -v      verbose         POSIX               Print commands (verbatim) before running them.
#   -x      xTRace          POSIX               Print commands (after expansions) before running them.
#           bgnice          ksh88, ksh93        Automatically lower the priority of all commands run in the background (with &).
#           emacs           bash, ksh88, ksh93  Use emacs-style command-line editing. Intended for interactive use.
#           gmacs           ksh88, ksh93        Use GNU emacs-style command-line editing. Intended for interactive use.
#           history         bash                Enable command history. On by default.
#           ignoreeof       POSIX               Disallow Ctrl-D to exit the shell.
#           markdirs        ksh88, ksh93        Append a / to directories when doing wildcard expansion.
#           nolog           POSIX               Disable command history for function definitions.
#           pipefail        ksh93               Make pipeline exit status be that of the last command that fails, or zero if all OK. ksh93n or newer.
#           posix           bash                Enable full POSIX compliance.
#           vi              POSIX               Use vi-style command-line editing. Intended for interactive use.
#           viraw           ksh88, ksh93        Use vi-style command-line editing. Intended for interactive use. This mode can be slightly more CPU-intensive than set -o vi.
