#
#   Saving shell state
#
# An apparent oversight in the POSIX standard is that there's no defined way to save function definitions for later restoration!
# Here's how to save the shell's state into a file, for both bash and ksh93:
{
    set +o                      # option settings
    (shopt -p) 2>/dev/null      # bash-specific options, subshell silences ksh
    set                         # variables and values
    export -p                   # exported variables
    readonly -p                 # read-only variables
    trap                        # trap settings
    typeset -f                  # function definitions (not POSIX)
} > /tmp/shell_state



#
#   echo is not portable
#
# The echo command may only be used portably for the simplest of uses,
# and various options and/or escape sequences may or may not be available (the POSIX standard notwithstanding).
#
# In ksh93, the built-in version of echo attempts to emulate whatever external version of echo would be found in $PATH.
# The reason behind this is compatibility: on any given Unix system, when the Korn shell executes a Bourne shell script for that system,
# it should behave identically to the original Bourne shell.
#
# In bash, on the other hand, the built-in version behaves the same across Unix systems.
# The rationale is consistency: a bash script should behave the same, no matter what Unix variant it's running on.
# Thus, for complete portability, echo should be avoided, and printf is still the best bet.



#
#   OPTIND can be a local variable
#
# ksh93 gives functions defined with the function keyword a local copy of OPTIND.
# The idea is that functions can be much more like separate scripts,
# using getopts to process their arguments in the same way a script does, without affecting the parent's option processing.



#
#   ${var:?message} may not exit
#
# The ${var:?message} variable expansion checks if var is set.
# If it isn't, the shell prints message and exits.
# However, when the shell is interactive, the behavior varies, since it's not always correct for an interactive shell to just blindly exit, possibly logging the user out.
# Given the following script, named x.sh:
echo ${somevar:?somevar is not set}
echo still running
# bash and ksh93 behave as follow:
#   Command         Message printed     Subsequent command run
#   bash x.sh       Yes                 No
#   ksh93 x.sh      Yes                 No
#   bash$ . x.sh    Yes                 Yes
#   ksh93$ . x.sh   Yes                 No

# This implies that if you know that a script will be executed with the dot command,
# you should ensure that it exits after using the ${var:?message} construct.



#
#   Missing loop items in a for loop
#
for i in $a $b $c
do
    # do something
done
# If all 3 variables are empty, there are no values to loop over, so the shell silently does nothing.
# It's as if the loop had been written:
for i in                        # nothing!
do
    # do something
done

# However, for most versions of the Bourne shell, actually writing a for loop that way would produce a syntax error.
# The 2001 POSIX standard made an empty loop valid when entered directly.

# The current versions of both ksh93 and bash accept an empty for loop as just shown, and silently do nothing.
# As this is a recent feature, older versions of both shells, as well as the original Bourne shell, are likely to produce an error message.



#
#   DEBUG traps behave differently
#
# Both ksh88 and ksh93 provide a special DEBUG trap for shell debugging and tracing.
# In ksh88, the traps on DEBUG happen after each command is executed.
# In ksh93, the traps on DEBUG happen before each command. So far so good.
# More confusing is that earlier versions of bash follow the ksh88 behavior, whereas the current versions follow that of ksh93.



#
#   shopt       is used to centralize control of shell options as they're added to bash,
#               instead of proliferating set options or shell variables.
#
#       shopt [ -pqsu ] [ -o ] [ option-name ... ]
#
#   -o  Limit options to those that can be set with set -o.
#   -p  Print output in a form suitable for rereading.
#   -q  Quiet mode. The exit status indicates if the option is set. With multiple options, the status is zero if they are all enabled, nonzero otherwise.
#   -s  Set (enable) the given option.
#   -u  Unset (disable) the given option.
#
#   For -s and -u without named options, the display lists those options which are set or unset, respectively.
#

#
#   options for bash version 3.0
#
#
#   cdable_vars
#       When an argument to cd isn't a directory, bash treats it as a variable name, whose value is the target directory.
#   cdspell
#       If a cd to a directory fails, bash attempts several minor spelling corrections to see if it can find the real directory.
#       If it finds a correction, it prints the name and changes to the computed directory.
#       This option works only in interactive shells.
#   checkhash
#       As bash finds commands after a path search, it stores the path search results in a hash table, to speed up subsequent executions of the same command.
#       The second time a command is executed, bash runs the command as stored in the hash table, on the assumption that it's still there.
#       With this option, bash verifies that a filename stored in its hash table really exists before trying to execute it.
#       If it's not found, bash does a regular path search.
#   checkwinsize
#       After each command, bash checks the window size, and updates the LINES and COLUMNS variables when the window size changes.
#   cmdhist
#       bash stores all lines of a multiline command in the history file. This makes it possible to reedit multiline commands.
#   dotglob
#       bash includes files whose names begin with . (dot) in the results of filename expansion.
#   execfail
#       bash does not exit if it cannot execute the command given to the exec built-in command.
#       In any case, interactive shells do not exit if exec fails.
#   expand_aliases
#       bash expands aliases. This is the default for interactive shells.
#   extdebug
#       bash enables behavior needed for debuggers:
#           - declare -F displays the source file name and line number for each function name argument.
#           - When a command run by the DEBUG trap fails, the next command is skipped.
#           - When a command run by the DEBUG trap inside a shell function or script sourced with . (dot) or source fails, the shell simulates a call to return.
#           - The array variable BASH_ARGC is set.
#             Each element holds the number of arguments for the corresponding function or dot-script invocation.
#             Similarly, the BASH_ARGV array variable is set.
#             Each element is one of the arguments passed to a function or dot-script.
#             BASH_ARGV functions as a stack, with values being pushed on at each call.
#             Thus, the last element is the last argument to the most recent function or script invocation.
#           - Function tracing is enabled.
#             Command substitutions, shell functions and subshells invoked via (...) inherit the DEBUG and RETURN traps.
#             (The RETURN trap is run when a return is executed, or a script run with . [dot] or source finishes.)
#           - Error tracing is enabled.
#             Command substitutions, shell functions, and subshells invoked via (...) inherit the ERROR trap.
#   extglob
#       bash does extended pattern matching similar to that of ksh88.
#   extquote
#       bash allows $'...' and $"..." within ${variable} expansions inside double quotes.
#   failglob
#       When a pattern does not match filenames bash produces an error.
#   force_fignore
#       When doing completion, bash ignores words matching the list of suffixes in FIGNORE, even if such words are the only possible completions.
#   gnu_errfmt
#       bash prints error messages in the standard GNU format.
#   histappend
#       bash appends commands to the file named by the HISTFILE variable, instead of overwriting the file.
#   histreedit
#       When a history substitution fails, if the readline library is being used, bash allows you to reedit the failed substitution.
#   histverify
#       With readline, bash loads the result of a history substitution into the editing buffer for further changing.
#   hostcomplete
#       bash performs hostname completion with readline on words containing an @ character. This is on by default.
#   huponexit
#       bash sends SIGHUP to all jobs when an interactive login shell exits.
#   interactive_comments
#       bash treats # as starting a comment for interactive shells. This is on by default.
#   lithist
#       When used together with the cmdhist option, bash saves multiline commands in the history with embedded newlines, rather than semicolons.
#   login_shell
#       bash sets this option when it is started as a login shell. It cannot be changed.
#   mailwarn
#       bash prints the message "The mail in mailfile has been read" when the access time has changed on a file that bash is checking for mail.
#   no_empty_cmd_completion
#       bash does not search $PATH when command completion is attempted on an empty line.
#   nocaseglob
#       bash ignores case when doing filename matching.
#   nullglob
#       bash causes patterns that don't match any files to become the null string, instead of standing for themselves.
#       This null string is then removed from further command-line processing; in effect, a pattern that doesn't match anything disappears from the command line.
#   progcomp
#       This option enables the programmable completion features. See the bash(1) manpage for details. It is on by default.
#   promptvars
#       bash performs variable and parameter expansion on the value of the various prompt strings. This is on by default.
#   restricted_shell
#       bash sets this to true when functioning as a restricted shell. This option cannot be changed.
#       Startup files can query this option to decide how to behave.
#   shift_verbose
#       bash prints a message if the count for a shift command is more than the number of positional parameters left.
#   sourcepath
#       bash uses $PATH to find files for the source and . (dot) commands. This is on by default.
#       If turned off, you must use a full or relative pathname to find the file.
#   xpg_echo
#       bash's built-in echo processes backslash escape sequences.



#
#   Common Extensions
#
# Both bash and ksh93 support a large number of extensions over the POSIX shell.

#
#       The select loop
#
# bash and ksh share the select loop, which allows you to generate simple menus easily.
# The syntax is:
select name [in list]
do
    statements that can use $name ...
done
# This is the same syntax as the regular for loop except for the keyword select.
# And like for, you can omit the in list and it will default to "$@"; i.e., the list of quoted command-line arguments.

# Here is what select does:
#   1) Generate a menu of each item in list, formatted with numbers for each choice
#   2) Print the value of PS3 as a prompt and waits for the user to enter a number
#   3) Store the selected choice in the variable name and the selected number in the built-in variable REPLY
#   4) Execute the statements in the body
#   5) Repeat the process forever

# Suppose you need to know how to set the TERM variable correctly for a timesharing system using different kinds of video display terminals.
# You don't have terminals hardwired to your computer; instead, your users communicate through a terminal server.
# Although the telnet protocol can pass the TERM environment variable, the terminal server isn't smart enough to do so.
# This means, among other things, that the tty (serial device) number does not determine the type of terminal.

# Therefore, you have no choice but to prompt the user for a terminal type at login time.
# To do this, you can put the following code in /etc/profile (assume you have a fixed set of known terminal types):
PS3='terminal? '
select term in gl35a t2000 s531 vt99
do
    if [ -n "$term" ]           # check if term is non-null
    then
        TERM=$term
        echo "TERM is $TERM"
        export TERM
        break
    else
        echo 'invalid.'         # prints an error message and repeats the prompt (but not the menu)
    fi
done
# 1) gl35a
# 2) t2000
# 3) s531
# 4) vt99
# terminal?

# We can refine our solution by making the menu more user friendly so that the user doesn't have to know the terminfo name of the terminal.
# We do this by using quoted character strings as menu items, and then using case to determine the terminfo name.
echo 'Select your terminal type:'
PS3='terminal? '
select term in \
    'Givalt GL35a' \
    'Tsoris T-2000' \
    'Shande 531' \
    'Vey VT99'
do
    case $REPLY in
    1)
        TERM=gl35a
    ;;
    2)
        TERM=t2000
    ;;
    3)
        TERM=s531
    ;;
    4)
        TERM=vt99
    ;;
    *)
        echo 'invalid.'
    ;;
    esac
    if [[ -n $term ]]
    then
        echo "TERM is $TERM"
        export TERM
        break
    fi
done
# Select your terminal type:
# 1) Givalt GL35a
# 2) Tsoris T-2000
# 3) Shande 531
# 4) Vey VT99
# terminal?

# The variable TMOUT (time out) can affect the select statement.
# Before the select loop, set it to some number of seconds n, and if nothing is entered within that amount of time, the select will exit.


#
#       [[ ]]   Extended test facility
#
# ksh introduced the extended test facility, delineated by [[ and ]].
# These are shell keywords, special to the syntax of the shell, and not a command.
# Recent versions of bash have adopted this special facility as well.

# [[...]] differs from the regular test and [...] commands in that word expansion and pattern expansion (wildcarding) are not done.
# This means that quoting is much less necessary.
# In effect, the contents of [[...]] form a separate sublanguage, which makes it easier to use.
# Most of the operators are the same as for test.

#
#   Extended test operators
#
#   Operator            bash/ksh only   True if
#   --------            -------------   -----------
#   -a file                             file exists. (Obsolete. -e is preferred.)
#   -b file                             file is a block device file.
#   -c file                             file is a character device file.
#   -C file             ksh             file is a contiguous file. (Not for most Unix versions.)
#   -d file                             file is a directory.
#   -e file                             file exists.
#   -f file                             file is a regular file.
#   -g file                             file has its setgid bit set.
#   -G file                             file's group ID is the same as the effective group ID of the shell.
#   -h file                             file is a symbolic link.
#   -k file                             file has its sticky bit set.
#   -l file             ksh             file is a symbolic link. (Works only on systems where /bin/test -l tests for symbolic links.)
#   -L file                             file is a symbolic link.
#   -n string                           string is non-null.
#   -N file             bash            file was modified since it was last read.
#   -o option                           option is set.
#   -O file                             file is owned by the shell's effective user ID.
#   -p file                             file is a pipe or named pipe (FIFO file).
#   -r file                             file is readable.
#   -s file                             file is not empty.
#   -S file                             file is a socket.
#   -t n                                file descriptor n points to a terminal.
#   -u file                             file has its setuid bit set.
#   -w file                             file is writable.
#   -x file                             file is executable, or is a directory that can be searched.
#   -z string                           string is null.
#   fileA -nt fileB                     fileA is newer than fileB, or fileB does not exist.
#   fileA -ot fileB                     fileA is older than fileB, or fileB does not exist.
#   fileA -ef fileB                     fileA and fileB point to the same file.
#   string = pattern    ksh             string matches pattern (which can contain wildcards). Obsolete; = = is preferred.
#   string == pattern                   string matches pattern (which can contain wildcards).
#   string != pattern                   string does not match pattern.
#   stringA < stringB                   stringA comes before stringB in dictionary order.
#   stringA > stringB                   stringA comes after stringB in dictionary order.
#   exprA -eq exprB                     Arithmetic expressions exprA and exprB are equal.
#   exprA -ne exprB                     Arithmetic expressions exprA and exprB are not equal.
#   exprA -lt exprB                     exprA is less than exprB.
#   exprA -gt exprB                     exprA is greater than exprB.
#   exprA -le exprB                     exprA is less than or equal to exprB.
#   exprA -ge exprB                     exprA is greater than or equal to exprB.

# The operators can be logically combined with && (AND) and || (OR) and grouped with parentheses.
# They may also be negated with !.
# When used with filenames of the form /dev/fd/n, they test the corresponding attribute of open file descriptor n.

# The operators -eq, -ne, -lt, -le, -gt and -ge are considered obsolete in ksh93; the let command or ((...)) should be used instead.


#
#       Extended Pattern Matching
#
# ksh88 introduced additional pattern-matching facilities that give the shell power roughly equivalent to awk and egrep extended regular expressions.
# With the extglob option enabled, bash also supports these operators. (They're always enabled in ksh.)

#   ksh/bash            egrep/awk       Meaning
#   --------            ---------       -------
#   *(exp)              exp*            0 or more occurrences of exp
#   +(exp)              exp+            1 or more occurrences of exp
#   ?(exp)              exp?            0 or 1 occurrences of exp
#   @(exp1|exp2|...)    exp1|exp2|...   exp1 or exp2 or ...
#   !(exp)              (none)          Anything that doesn't match exp

# The notations for shell regular expressions and standard regular expressions are very similar, but they're not identical.
# Because the shell would interpret an expression like dave|fred|bob as a pipeline of commands, you must use @(dave|fred|bob) for alternates by themselves.
@(dave|fred|bob)                # matches dave, fred or bob
*(dave|fred|bob)                # means 0 or more occurrences of dave, fred or bob. This expression matches strings like the null string dave, davedave, fred, bobfred, bobbobdavefredbobfred, etc.
+(dave|fred|bob)                # matches any of the above except the null string
?(dave|fred|bob)                # matches the null string dave, fred or bob
!(dave|fred|bob)                # matches anything except dave, fred or bob

# It is worth emphasizing again that shell regular expressions can still contain standard shell wildcards.
# Thus, the shell wildcard ? (match any single character) is the equivalent of . (dot) in egrep or awk,
# and the shell's character set operator [...] is the same as in those utilities.
+([[:digit:]])                  # matches a number: i.e., one or more digits
# The shell wildcard character * is equivalent to the shell regular expression *(?).
# You can even nest the regular expressions:
+([[:digit:]]|!([[:upper:]]))   # matches one or more digits or nonuppercase letters

# 2 egrep and awk regexp operators do not have equivalents in the shell:
#   The beginning- and end-of-line operators  ^ and $   (they are implied as always being there, surround a pattern with * characters to disable this)
#   The beginning- and end-of-word operators \< and \>
ls
# biff  bob  frederick  shishkabob
shopt -s extglob                # enable extended pattern matching (bash)
echo @(dave|fred|bob)           # files that match only dave, fred or bob
# bob
echo *@(dave|fred|bob)*         # add wildcard characters to disable the implied beginning- and end-of-line operators ^ and $
# bob frederick shishkabob


#
#       Brace Expansion
#
# Brace expansion is a feature borrowed from the Berkeley C shell, csh. It is supported by both ksh and bash.
# It's a way of saving typing when you have strings that are prefixes or suffixes of each other.
ls
# cpp-args.c  cpp-lex.c  cpp-lox.c  cpp-parse.c

vi cpp-{args,lex,parse}.c       # the shell expands this into vi cpp-args.c cpp-lex.c cpp-parse.c

echo cpp-{args,l{e,o}x,parse}.c                                 # brace substitutions may be nested
# cpp-args.c cpp-lex.c cpp-lox.c cpp-parse.c


#
#       Process Substitution
#
# Process substitution allows you to open multiple process streams and feed them into a single program for processing.
awk '...' <(generate_data) <(generate_more_data)                # note that the parentheses are part of the syntax; you type them literally
# Here, generate_data and generate_more_data represent arbitrary commands, including pipelines, that produce streams of data.
# The awk program processes each stream in turn, not realizing that the data is coming from multiple sources.

# Process substitution may also be used for output, particularly when combined with the tee program, which sends its input to multiple output files and to stdout:
generate_data | tee  >(sort | uniq > sorted_data) \             # use tee to send the data to a pipeline that sorts and saves the data,
                     >(mail -s 'raw data' joe) \                # send the data to the mail program for user joe
                     > raw_data                                 # and redirect the original data into a file
# Process substitution, combined with tee, frees you from the straight "one input, one output" paradigm of traditional Unix pipes,
# letting you split data into multiple output streams, and coalesce multiple input data streams into one.

# Process substitution is available only on Unix systems that support the /dev/fd/n special files for named access to already open file descriptors.
# Most modern Unix systems, including GNU/Linux, support this feature.
# As with brace expansion, it is enabled by default when ksh93 is compiled from source code. bash always enables it.


#
#       Indexed Arrays
#
# Both ksh93 and bash provide an indexed array facility that, while useful, is much more limited than analogous features in conventional programming languages.
# In particular, indexed arrays can be only one-dimensional (i.e., no arrays of arrays).
# Indexes start at 0.
# Furthermore, they may be any arithmetic expression: the shells automatically evaluate the expression to yield the index.

# There are 3 ways to assign values to elements of an array.
# The first is the most intuitive: you can use the standard shell variable assignment syntax with the array index in brackets ([ ]):
nicknames[2]=bob
nicknames[3]=eddy
# puts the values bob and eddy into the elements of the array nicknames with indices 2 and 3, respectively.
# As with regular shell variables, values assigned to array elements are treated as character strings.

# The second way to assign values to an array is with a variant of the set statement:
set -A aname val1 val2 ...      # bash doesn't support set -A
# creates the array aname (if it doesn't already exist) and assigns val1 to aname[0], val2 to aname[1], etc.

# The third (recommended) way is to use the compound assignment form:
aname=(val1 val2 val3)

# To extract a value from an array, use the syntax:
${aname[i]}

${nicknames[2]}                 # has the value bob

# The index i can be an arithmetic expression.
${nicknames[*]}                 # all elements separated by spaces
${nicknames[@]}                 # same
$nicknames                      # same as ${nicknames[0]}

echo "${nicknames[*]}"
# bob eddy

nicknames[9]=pete
nicknames[31]=ralph
echo "${nicknames[*]}"
# bob eddy pete ralph

# You can preserve whatever whitespace you put in your array elements by using "${aname[@]}" (with the double quotes) rather than ${aname[*]},
# just as you can with "$@" rather than $* or "$*".

# how many elements nicknames has defined:
${#nicknames[*]}                # 4
${#nicknames[@]}                # same

# We can eliminate the entire case construct by taking advantage of the fact that the select construct stores the user's number choice in the variable REPLY.
termnames=(gl35a t2000 s531 vt99)           # store all of the possibilities for TERM in an array, in an order that corresponds to the items in the select menu
echo 'Select your terminal type:'
PS3='terminal? '
select term in \
    'Givalt GL35a' \
    'Tsoris T-2000' \
    'Shande 531' \
    'Vey VT99'
do
    if [[ -n $term ]]
    then
        TERM=${termnames[REPLY-1]}          # then use REPLY to index the array
        echo "TERM is $TERM"
        export TERM
        break
    fi
done


#
#       Additional tilde expansions
#
# POSIX specifies plain
#   ~       as being equivalent to $HOME
#   ~user   as being user's home directory
# bash and ksh93 allow you to use
#   ~+      as short for $PWD (the current working directory)
#   ~-      as short for $OLDPWD (the previous working directory)


#
#       Arithmetic commands
#
# POSIX specifies the $((...)) notation for arithmetic expansion, and doesn't provide any other mechanism for arithmetic operations.
# However, both bash and ksh93 provide 2 notations for doing arithmetic directly, not as an expansion:
let "x = 5 + y"                 # the let command, requires quoting
((x = 5 + y))                   # no leading $, automatic quoting inside double parentheses

# It's not clear why POSIX standardizes only arithmetic expansion.
# Perhaps it's because you can achieve essentially the same affect by using the : (do-nothing) command and arithmetic expansion:
: $((x = 5 + y))                # almost the same as let or ((...))
x=$((5 + y))                    # similar, no spaces allowed around the =

# One difference is that let and ((...)) have an exit status: 0 for a true value and 1 for a false value.
# This lets you use them in if and while statements:
while ((x != 42))
do
    ... whatever ...
done


#
#       Arithmetic for loop
#
# Both bash and ksh93 support the arithmetic for loop, which is similar to the for loop in awk, C and C++.
for ((init; condition; increment))
do
    loop body
done
# Each one of init, condition and increment can be shell arithmetic expressions, exactly the same as would appear inside $((...)).
# The use of ((...)) in the for loop is purposely similar to the arithmetic evaluation syntax.

# Use the arithmetic for loop when you need to do something a fixed number of times:
for ((i = 1; i <= limit; i += 1))
do
    whatever needs doing
done


#
#       Additional arithmetic operators
#
# POSIX specifies the list of operators that are allowed inside arithmetic expansion with $((...)).
# Both bash and ksh93 support additional operators, to provide full compatibility with C.
# In particular, both allow ++ and -- to increment and decrement by one.
# Both the prefix and postfix forms are allowed. (According to POSIX, ++ and -- are optional.)
# Both shells accept the comma operator, which lets you perform multiple operations in one expression.
# Also, as an extension over and above C, both shells accept ** for exponentiation.


#
#       Optional matching parentheses for case statements
#
# The $(...) syntax for command substitution is standardized by POSIX.
# It was introduced in ksh88 and is also supported in bash.
# ksh88 had a problem with case statements inside $(...).
# In particular, the closing right parenthesis used for each case pattern could terminate the entire command substitution.
# To get around this, ksh88 required that case patterns be enclosed in matching parentheses when inside a command substitution:
some_cmd $( ...
    case $var in
    ( foo | bar )
        some other cmd
    ;;
    ( stuff | junk )
        yet another cmd
    ;;
    esac
    ...)
# ksh93, bash and POSIX allow an optional open parenthesis on case selectors, but do not require it.
# Thus, ksh93 is smarter than ksh88, which required the open parenthesis inside $(...).


#
#       Printing traps with trap -p
#
# According to POSIX, an unadorned trap command prints out the state of the shell's traps,
# in a form that can be reread by the shell later to restore the same traps.
trap -p                         # print out the traps in both bash and ksh93


#
#       Here strings with <<<
#
# It's common to use echo to generate a single line of input for further processing:
echo $myvar1 $mvar2 | tr ... | ...
# Both bash and ksh93 support a notation we term here strings, taken from the Unix version of the rc shell.
# Here strings use <<< followed by a string.
# The string becomes the standaed input to the associated command, with the shell automatically supplying a final newline:
tr ... <<< "$myvar1 $myvar2" | ...
# This potentially saves the creation of an extra process and is also notationally clear.


#
#       Extended string notation
#
# Both bash and ksh93 support a special string notation that understands the usual set of C-like (or echo-like) escape sequences.
# The notation consists of a $ in front of a single-quoted string.
# Such strings behave like regular single-quoted strings, but the shell interprets escape sequences inside the string.
echo $'A\tB'                    # A, tab, B
# A B

echo $'A\nB'                    # A, newline, B
# A
# B


#
#   bash and ksh93 arithmetic operators
#
#   Although some of these are (or contain) special characters, there is no need to backslash-escape them,
#   because they are within the $((...)) syntax (the shell's arithmetic substitution).
#   This syntax acts like double quotes, except that an embedded double quote need not be escaped.
#
# Operator      Meaning                                             Associativity
# --------      -------                                             -------------
# ++ --         Increment and decrement, prefix and postfix         left to right
# + - ! ~       Unary plus and minus; logical and bitwise negation  right to left
# **            Exponentiation                                      right to left   (ksh93m and newer. Left-associative in bash versions prior to 3.1)
# * / %         Multiplication, division and remainder              left to right
# + -           Addition and subtraction                            left to right
# << >>         Bit-shift left and right                            left to right
# <<= >>=       Comparisons                                         left to right
# == !=         Equal and not equal                                 left to right
# &             Bitwise AND                                         left to right
# ^             Bitwise Exclusive OR                                left to right
# |             Bitwise OR                                          left to right
# &&            Logical AND (short-circuit)                         left to right
# ||            Logical OR  (short-circuit)                         left to right
# ?:            Conditional expression                              right to left
# = += -= *= /= %= &= ^= <<= >>= |=     Assignment operators        right to left
# ,             Sequential evaluation                               left to right
#
# Parentheses can be used to group subexpressions.
# The arithmetic expression syntax (like C) supports relational operators as "truth values" of 1 for true and 0 for false.
$((3 > 2))                      # has the value 1
$(( (3 > 2) || (4 <= 1) ))      # also has the value 1, since at least one of the 2 subexpressions is true
$((x += 2))                     # adds 2 to x and stores the result back in x

i=5
echo $((i++)) $i                # 5 6   postfix: returns the variable's old value as the result of the expression and then increments the variable
echo $((++i)) $i                # 7 7    prefix: increments the variable first, and then returns the new value
