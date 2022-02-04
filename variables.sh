NUMERO=1234
COMPTE=lavc01
NOM="Claire Lavoie"                         # guillemets nécessaires car la chaine contient un espace
NOM='Claire Lavoie'
NOM='Claire Lavoie'

VAR="toto"
VAR="toto " "est grand"
# toto est grand


# Assign values to 3 variables (last is null)
u=up
d=down
blank=

echo ${u}root
# uproot

echo ${u-$d}                                # display value of u or d; since u is set, it's printed
# up

echo ${tmp-'date'}                          # if tmp is not set, the date command is executed
# Mon Aug 30 11:15:23 EDT 2004

echo ${blank="no data"}                     # blank is set, so it is printed
# (a blank line)


#
#   readonly    makes variables unmodifiable
#
#       readonly name[=word] ...    POSIX variable-assignment form
#       readonly -p                 print the name of the command and the names and values of all read-only variables
#
hours_per_day=24
seconds_per_hour=3600
readonly hours_per_day seconds_per_hour days_per_week=7     # POSIX variable-assignment form


#
#   export      modifies or prints the environment
#
#       export name[=word] ...      POSIX variable-assignment form
#       export -p                   print the name of the command and the names and values of all exported variables
#
PATH=$PATH:/usr/local/bin
export PATH

export PATH=$PATH:/usr/local/bin            # or use the POSIX variable-assignment form


#
#   Variables may be added to a program's environment without permanently affecting the environment of the shell or subsequent commands
#
PATH=/bin:/usr/bin awk '...' file1 file2    # just prefix the assignment to the command name and arguments


#
#   env         may be used to remove variables from a program's environment, or to temporarily change environment variable values
#
#       env [ -i ] [ var=value ... ] [ command_name [ arguments ... ] ]
#
#   -i  ignore the inherited environment, using only the variables and values given on the command line
#
#   With no command_name, print the names and values of all variables in the environment.
#   Otherwise, use the variable assignments on the command line to modify the inherited environment, before invoking command_name.
#


#
#   unset       removes variables and functions from the running shell
#
#       unset [ -v ] variable ...
#       unset -f function ...
#
#   -f  unset (remove) the named functions
#   -v  unset (remove) the named variables. This is the default action with no options.
#
unset var_name
unset first second third

who_is_on()
{
    who | awk '{ print $1 }' | sort -u      # Generate sorted list of users
}

unset -f who_is_on


${var}          # use value of var; braces are optional if var is separated from the following text
                # They are required for array variables, and in ksh93 if a variable name contains periods.

#
#   SUBSTITUTION OPERATORS
#
#
#   To return a default value if the variable is undefined
#
${var:-default} # if var exists and isn't null, return its value; otherwise, return default

#
#   To set a variable to a default value if it is undefined
#
${var:=default} # if var exists and isn't null, return its value; otherwise, set it to default and then return its value

#
#   To catch errors that result from variables being undefined
#
${var:?msg}     # if var exists and isn't null, return its value; otherwise, print "var: msg" and exit (if not interactive)
                # if msg isn't supplied, prints the default message "parameter null or not set"
#
#   To test for the existence of a variable
#
${var:+newval}  # if var exists and isn't null, return its value; otherwise, return null


#
#   PATTERN-MATCHING OPERATORS
#
#   POSIX standardized these additional operators for doing pattern matching and text removal on variable values.
#   Their classic use is in stripping off components of pathnames, such as directory prefixes and filename suffixes.
#
path=/home/tolstoy/mem/long.file.name

${var#pattern}  # If the pattern matches the beginning of var's value, delete the shortest part that matches and return the rest
${path#/*/}     # tolstoy/mem/long.file.name

${var##pattern} # If the pattern matches the beginning of var's value, delete the longest part that matches and return the rest
${path##/*/}    # long.file.name

${var%pattern}  # If the pattern matches the end of var's value, delete the shortest part that matches and return the rest
${path%.*}      # /home/tolstoy/mem/long.file

${var%%pattern} # If the pattern matches the end of var's value, delete the longest part that matches and return the rest
${path%%.*}     # /home/tolstoy/mem/long


#
#   STRING-LENGTH OPERATOR
#
${#var}                                     # returns the length in characters of the value of $var
x=supercalifragilisticexpialidocious        # a famous word with amazing properties
echo "There are ${#x} characters in $x"
# There are 34 characters in supercalifragilisticexpialidocious


#
#   POSITIONAL PARAMETERS
#
#   They represent a shell script's command-line arguments or a function's arguments within shell functions.
#
echo first arg is $1
echo tenth arg is ${10}
filename=${1:-/dev/tty}                     # value-testing and pattern-matching operators can be applied to positional parameters


#
#   POSIX built-in shell variables
#
$#              # total number of arguments passed to the shell script or function
$*              # represents all the command-line arguments at once
$@              # same
"$*"            # Represents all the command-line arguments as a single string ("$1 $2...")
                # the values are separated by the first character of $IFS
"$@"            # Represents all the command-line arguments as separate, individual strings ("$1" "$2" ...)
                # preserves any whitespace embedded within each argument
$- (hyphen)     # string representing the currently enabled shell options
$?              # Exit status of previous command
$$              # Process ID of shell process
$0 (zero)       # The name of the shell program
$!              # Process ID of last background command. Use this to save process ID numbers for later use with the wait command
$ENV            # Used only by interactive shells upon invocation; the value of $ENV is parameter-expanded
                # The result should be a full pathname for a file to be read and executed at startup. This is an XSI requirement
$HOME           # Home (login) directory
$IFS            # Internal Field Separator; i.e., the list of characters that act as word separators
                # Normally set to space, tab, and newline
$LANG           # Default name of current locale; overridden by the other LC_* variables
$LC_ALL         # Name of current locale; overrides LANG and the other LC_* variables
$LC_COLLATE     # Name of current locale for character collation (sorting) purposes
$LC_CTYPE       # Name of current locale for character class determination during pattern matching
$LC_MESSAGES    # Name of current language for output messages
$LINENO         # Line number in script or function of the line that just ran
$NLSPATH        # The location of message catalogs for messages in the language given by $LC_MESSAGES (XSI)
$PATH           # Search path for commands
$PPID           # Process ID of parent process
$PS1            # Primary command prompt string. Default is "$ "
$PS2            # Prompt string for line continuations. Default is "> "
$PS4            # Prompt string for execution tracing with set -x. Default is "+ "
$PWD            # Current working directory (set by cd)

#
#   bash and ksh automatically set these additional variables:
#
$_              # Temporary variable; initialized to pathname of script or program being executed.
                # Later, stores the last argument of previous command.
                # Also stores name of matching MAIL file during mail checks.
$HISTCMD        # The history number of the current command
$LINENO         # Current line number within the script or function
$OLDPWD         # Previous working directory (set by cd)
$OPTARG         # Name of last option processed by getopts
$OPTIND         # Numerical index of OPTARG
$RANDOM[=n]     # Generate a new random number with each reference; start with integer n, if given
$REPLY          # Default reply, used by select and read
$SECONDS[=n]    # Number of seconds since the shell was started, or, if n is given, number of seconds + n since the shell started


#
#   shift       "loops off" positional parameters from the list, starting at the left
#               Upon executing shift, the original value of $1 is gone forever, replaced by the old value of $2.
#               The value of $2, in turn, becomes the old value of $3, and so on.
#               The value of $# is decreased by one.
#               shift takes an optional argument, which is a count of how many arguments to shift off the list.
#
set -- hello "hi there" greetings           # when set is invoked without options, it sets the value of the positional parameters
echo there are $# total arguments           # there are 3 total arguments

for i in $*                                 # loop over arguments individually
do
    echo i is $i
done
# i is hello
# i is hi                                   note that embedded whitespace was lost
# i is there
# i is greetings

for i in $@                                 # without quotes, $* and $@ are the same
do
    echo i is $i
done
# i is hello
# i is hi
# i is there
# i is greetings

for i in "$*"                               # with quotes, $* is one string
do
    echo i is $i
done
# i is hello hi there greetings

for i in "$@"                               # with quotes, $@ preserves exact argument values
do
    echo i is $i
done
# i is hello
# i is hi there
# i is greetings

shift                                       # loop off the 1st argument
echo there are now $# arguments             # there are now 2 arguments

for i in "$@"
do
    echo i is $i
done
# i is hi there
# i is greetings


#
#   bash and ksh93 arithmetic operators
#
#   Although some of these are (or contain) special characters, there is no need to backslash-escape them,
#   because they are within the $((...)) syntax (the shell's arithmetic substitution).
#   This syntax acts like double quotes, except that an embedded double quote need not be escaped.
#
# Operator      Meaning                                                 Associativity
# --------      -------                                                 -------------
# ++ --         Increment and decrement, prefix and postfix             left to right
# + - ! ~       Unary plus and minus; logical and bitwise negation      right to left
# **            Exponentiation                                          right to left   (ksh93m and newer. Left-associative in bash versions prior to 3.1)
# * / %         Multiplication, division and remainder                  left to right
# + -           Addition and subtraction                                left to right
# << >>         Bit-shift left and right                                left to right
# < <= > >=     Comparisons                                             left to right
# = = !=        Equal and not equal                                     left to right
# &             Bitwise AND                                             left to right
# ^             Bitwise Exclusive OR                                    left to right
# |             Bitwise OR                                              left to right
# &&            Logical AND (short-circuit)                             left to right
# ||            Logical OR  (short-circuit)                             left to right
# ?:            Conditional expression                                  right to left
# = += -= *= /= %= &= ^= <<= >>= |=     Assignment operators            right to left
# ,             Sequential evaluation                                   left to right
#
# Parentheses can be used to group subexpressions.
# The arithmetic expression syntax (like C) supports relational operators as "truth values" of 1 for true and 0 for false.
$((3 > 2))                      # has the value 1
$(( (3 > 2) || (4 <= 1) ))      # also has the value 1, since at least one of the 2 subexpressions is true
$((x += 2))                     # adds 2 to x and stores the result back in x

i=5
echo $((i++)) $i                # 5 6   postfix: returns the variable's old value as the result of the expression and then increments the variable
echo $((++i)) $i                # 7 7    prefix: increments the variable first, and then returns the new value
