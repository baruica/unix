#
#   ` `         (backquotes)
#
vi `grep -l ifdef *.c`                      # edit files found by grep

for i in `cd /old/code/dir ; echo *.c`      # Loop over the generated list of files in /old/code/dir
do
    diff -c /old/code/dir/$i $i | more      # Compare old version to new in pager program
done

#
#   The backquoted form is the historical method for command substitution,
#   and is supported by POSIX because so many shell scripts exist that use it.
#   However, all but the most simplest uses become complicated quickly.
#   In particular, embedded command substitutions and/or the use of double quotes require careful escaping with the backslash character:
#
echo outer `echo inner1 \`echo inner2\` inner1` outer                       # outer inner1 inner2 inner1 outer
# echo inner2 is executed. Its output (inner2) in placed into the next command to be executed
# echo inner1 inner2 inner1 is executed. Its output (inner1 inner2 inner3) is placed into the next command to be executed
# Finally, echo outer inner1 inner2 inner1 outer is executed

echo "outer +`echo inner -\`echo \"nested quote\" here\`- inner`+ outer"    # outer +inner -nested quote here- inner+ outer

# Nesting back-quote command substitutions requires escaping the enclosed `...` as follows:
echo `echo \`echo Hi\``
# or
echo $(echo $(echo Hi))


#
#   $( )        Command substitution, equivalent but prefered to the backquotes
#
egrep '(yes|no)' `cat list`                 # specify a list of files to search
egrep '(yes|no)' $(cat list)                # POSIX version of previous
egrep '(yes|no)' $(< list)                  # faster, not in POSIX

echo outer $(echo inner1 $(echo inner2) inner1) outer                       # outer inner1 inner2 inner1 outer

echo "outer +$(echo inner -$(echo "nested quote" here)- inner)+ outer"      # outer +inner -nested quote here- inner+ outer

for i in $(cd /old/code/dir ; echo *.c)     # Loop over the generated list of files in /old/code/dir
do
    diff -c /old/code/dir/$i $i             # Compare old version to new
done | more                                 # Run all results through pager program


# head --- print first n lines
#
# Usage:
#       head -N file
count=$(echo $1 | sed 's/^-//')             # substitute the leading minus by nothing (strip it)
shift                                       # move $1 out of the way
sed ${count}q "$@"                          # head -N file ends up executing sed Nq file
