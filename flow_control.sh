#
#   Every command, be it built-in, shell function, or external, returns a small integer value to the program that invoked it when it exits.
#   This is known as the program's exit status.
#   There are a number of ways to use a program's exit status when programming with the shell.
#

#
#   POSIX exit statuses
#
#   0           Command exited successfully.
#   > 0         Failure during redirection or word expansion (tilde, variable, command and arithmetic expansions, as well as word splitting).
#   1-125       Command exited unsuccessfully. The meanings of particular exit values are defined by each individual command.
#   126         Command found, but file was not executable.
#   127         Command not found.
#   > 128       Command died due to receiving a signal
#


#
#   exit        returns an exit status from a shell script to the script's caller
#
#       exit [exit-status]      exits with the exit-status status
#
#               The default exit-status used if none is supplied is the exit status of the last command executed ($?).
#


#
#   NOT         !
#
if ! grep pattern myfile > /dev/null
then
    # pattern is not there
fi

#
#   AND         &&  (shell operator) recommended
#               -a  (test operator)
#
if grep pattern1 myfile && grep pattern2 myfile
then
    # myfile contains both patterns
fi

#
#   OR          ||  (shell operator) recommended
#               -o  ( test operator)
#
if grep pattern1 myfile || grep pattern2 myfile
then
    # one or the other is present
fi


#
#   test        To test conditions in shell scripts, returning results via the exit status.
#
#       test expression
#       [ expression ]      brackets are typed literally, and must be separated from the enclosed expression by whitespace
#

#
#   File conditions
#
#   -d file     file exists and is a directory
#   -e file     file exists
#   -f file     file exists and is a regular file
#   -h file     file exists and is a symbolic link
#   -L file     file exists and is a symbolic link (same as -h)
#   -G file     file exists and its group is the effective group ID
#   -O file     file exists and its owner is the effective user ID
#   -r file     file exists and is readable
#   -s file     file exists and is not empty
#   -t n        file descriptor n points to a terminal
#   -w file     file exists and is writable
#   -x file     file exists and is executable, or file is a directory that can be searched
#   f1 -ef f2   files f1 and f2 are linked (refer to same file)
#   f1 -nt f2   file f1 is newer than f2
#   f1 -ot f2   file f1 is older than f2
#

#
#   String conditions
#
#   string      string is not null
#   -n string   string is non-null
#   -z string   string is null
#   s1 = s2     s1 and s2 are identical. s2 can be a wildcard pattern. Quote s2 to treat it literally. (ksh)
#   s1 == s2    s1 and s2 are identical. s2 can be a wildcard pattern. Quote s2 to treat it literally. Preferred over = (bash, ksh93)
#   s1 != s2    s1 and s2 are not identical. s2 can be a wildcard pattern. Quote s2 to treat it literally
#   s1 =~ s2    s1 matches extended regular expression s2. Quote s2 to keep the shell from expanding embedded shell metacharacters (bash)
#   s1 < s2     ASCII value of s1 precedes that of s2. (Valid only within [[ ]] construct.)
#   s1 > s2     ASCII value of s1 follows that of s2.  (Valid only within [[ ]] construct.)
#

#
#   Integer comparisons
#
#   n1 -eq n2   n1 and n2 are equal
#   n1 -ne n2   n1 and n2 are not equal
#   n1 -lt n2   n1 is less than n2
#   n1 -gt n2   n1 is greater than n2
#   n1 -le n2   n1 is less than or equal to n2
#   n1 -ge n2   n1 is greater than or equal to n2
#

while [ $# -gt 0 ]                  # while there are arguments...
while [ -n "$1" ]                   # while there are non-empty arguments...
if [ $count -lt 10 ]                # if $count is less than 10...
if [ -d "RCS" ]                     # if the RCS directory exists...
if [ "$answer" != "y" ]             # if the answer is not y...
if [ ! -r "$1" -o ! -f "$1" ]       # if the first argument is not a readable file or a regular file...


#
# There is a difference between using -a and -o, which are test operators, and && and ||, which are shell operators.
#
# 2 conditions, 1 test command: test evaluates both conditions
if [ -n "$str" -a -f "$file" ]

# 2 commands, short-circuit evaluation: the shell runs the first test command, and runs the second one only if the first one was successful
if [ -n "$str" ] && [ -f "$file" ]

# Syntax error: && is a shell operator, so it terminates the first test command.
# This command will complain that there is no terminating ] character and exits with a failure value.
# Even if test were to exit successfully, the subsequent check would fail, since the shell (most likely) would not find a command named -f.
if [ -n "$str" && -f "$file" ]


# For portability, the POSIX standard recommends the use of shell-level tests for multiple conditions, instead of the -a and -o operators.
if [ -f "$file" ] && ! [ -w "$file" ]
then
    # $file exists and is a regular file, but is not writable
    echo $0: $file is not writable, giving up. >&2
    exit 1
fi


#
#   if then elif else fi
#
if [ "$NUMBER" = "3" ]
then
    echo "Is equal to three"
elif [ "$NUMBER" = "4" ]
then
    echo "Is equal to four"
else
    echo "Is equal to neither three or four"
fi


#
#   case
#
echo "Enter a number from 1 to 3 : \c"
read $NUMBER
case $NUMBER in
1)
    echo "one"
;;
2)
    echo "two"
;;
3|4|7)                      # multiple patterns separated by | (or)
    echo "three, four or seven"
;;
*)                          # the use of a default pattern is typical but not required
    echo "*** ERROR ***  The number is neither 1, 2, 3, 4 or 7"
;;
esac


#
#   for
#
REP=$(ls)
for FICHIER in $REP         # The "in list" part is optional. When omitted, the shell loops over the command-line args (for i in "$@")
do
    if [ -d $FICHIER ]
    then
        echo "Répertoire : $FICHIER"
    else
        echo "Fichier    : $FICHIER"
    fi
done


#
#   while       continues to loop as long as the condition exited successfully
#
for NOM in $LISTE
do
    mailx -s 'Envoi collectif' $NOM < invitation
    while $(ps -ef | grep 'mailx') > /dev/null      # tant qu'il y a une ligne contenant mailx dans la liste des processus
    do
        sleep 60
    done
done


#
#   until       loops as long as the condition exits unsuccessfully
#
REP="/ATOM/nels/temp"
cd $REP
until [ "$REP" = "/ATOM" ]
do
    if [ "$(pwd)" = "$REP" ]
    then
        cd ..
        rm -r $REP
        REP=$(pwd)
    fi
done

# wait for specified user to log in, check every 30 seconds
printf "Enter username: "
read user
until who | grep "$user" > /dev/null
do
    sleep 30
done


#
#   break       used to leave a loop
#
break [nbr]                 # nbr indicates how many enclosing loops should be broken out of


#
#   continue    used to start the next iteration of a loop early, before reaching the bottom of a loop's body
#
continue [nbr]              # nbr indicates how many enclosing loops should be continued


# wait for specified user to log in, check every 30 seconds
printf "Enter username: "
read user
while true
do
    if who | grep "$user" > /dev/null
    then
        break
    fi
    sleep 30
done


#
#   Simple option processing
#
somefile=                   # set flag vars to empty
verbose=
quiet=
long=
while [ $# -gt 0 ]          # Loop until no args left
do
    case $1 in              # Check first arg
    -f)
        somefile=$2
        shift               # Shift off "-f" so that shift at end gets value in $2
    ;;
    -v)
        verbose=true
        quiet=
    ;;
    -q)
        quiet=true
        verbose=
    ;;
    -l)
        long=true
    ;;
    --)
        shift               # By convention,  -  -  ends options
        break
    ;;
    -*)
        echo $0: $1: unrecognized option >&2
    ;;
    *)
        break               # Nonoption argument, break while loop
    ;;
    esac
    shift                   # Set up for next iteration
done


#
#   getopts     (get options) simplifies argument processing, and makes it possible for shell scripts to easily adhere to POSIX argument processing conventions
#
#       getopts option_spec variable [ arguments ... ]
#
#               option_spec describes options and their arguments
#               For each valid option, set variable to the option letter.
#               If the option has an argument, the argument value is placed in OPTARG.
#               At the end of processing, OPTIND is set to the number of the first non-option argument
#
#   The first argument is a string listing valid option letters.
#   If an option letter is followed by a colon, then that option requires an argument, which is stored in OPTARG.
#   The variable OPTIND contains the index of the next argument to be processed. The shell initializes this variable to 1.
#   The second argument is a variable name.
#   This variable is updated each time getopts is called; its value is the found option letter.
#   When getopts finds an invalid option, it sets the variable to a question mark character.
#

# set flag vars to empty
somefile=
verbose=
quiet=
long=
# leading colon tels getopts not to print any error messages,
# to set the variable to a question mark
# and to store the invalid option letter that was provided into OPTARG
while getopts :f:vql opt
do
    case $opt in            # test is only on the option letter; the leading minus is removed
    f)
        somefile=$OPTARG
    ;;
    v)
        verbose=true
        quiet=
    ;;
    q)
        quiet=true
        verbose=
    ;;
    l)
        long=true
    ;;
    '?')
        echo "$0: invalid option -$OPTARG" >&2
        echo "Usage: $0 [-f file] [-vql] [files ...]" >&2
        exit 1
    ;;
    esac
done
shift $((OPTIND - 1))       # Remove options, leave arguments using arithmetic substitution
