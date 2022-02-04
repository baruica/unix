#
#   awk         (Aho, Weinberger & Kernighan) is a programming language that consists of pairs of patterns and braced actions.
#
#       awk [ -F fs ] [ -v var=value ... ] 'program'    [ -- ] [ var=value ... ] [ file(s) ]
#       awk [ -F fs ] [ -v var=value ... ] -f cmd_file  [ -- ] [ var=value ... ] [ file(s) ]
#
#   -F  redefines the default field separator
#       Its fs argument is a regular expression that immediately follows the -F, or is supplied as the next argument.
#
#   -f  commands come from a file
#       That option may be repeated, in which case the complete program is the concatenation of the specified program files.
#       This is a convenient way to include libraries of shared awk code.
#
#   -v  sets awk's variables
#       Initializations with -v options must precede any program given directly on the command line;
#       they take effect before the program is started, and before any files are processed.
#
#   --  special option that indicates that there are no further command-line options for awk itself.
#       Any following options are then available to your program.
#
#           Either part of a pattern/action pair may be omitted.
#           If the pattern is omitted, the action is applied to every input record.
#           If the action is omitted, the default action is to print the matching record on standard output.
#           awk views an input stream as a collection of records, each of which can be further subdivided into fields.
#           Normally, a record is a line, and a field is a word of one or more nonwhitespace characters.
#           However, what constitutes a record and a field is entirely under the control of the programmer,
#           and their definitions can even be changed during processing.
#

# the value set with the -F option applies to the first group of files, and the value assigned to FS applies to the second group
awk -F '\t' '{ ... }' first_files FS="[\f\v]" second_files

# processes the list of files twice, once with Pass set to 1 and a second time with it set to 2
awk '{...}' Pass=1 *.tex Pass=2 *.tex


#
#   NUMERIC OPERATORS (in decreasing precedence)
#
# ++ --                     increment and decrement (either prefix or postfix)
# ^ **                      exponentiate (right-associative: a^b^c^d means a^(b^(c^d)), whereas a/b/c/d means ((a/b)/c)/d)
# ! + -                     not, unary plus, unary minus
# * / %                     multiply, divide, remainder
# + -                       add, subtract
# < <= = = <= != > >=       compare
# &&                        logical AND (short-circuit: evaluates its righthand operand only if needed)
# ||                        logical OR (short-circuit: evaluates its righthand operand only if needed)
# ? :                       ternary conditional (a = (u > w) ? x^3 : y^7 is awk's equivalent of if (u > w) then a=x^3 else a=y^7)
#                           If the 1st operand is nonzero (true), the result is the 2nd operand; otherwise, it is the 3rd operand.
#                           Only 1 of the 2nd and 3rd operands is evaluated.
# = += -= *= /= %= ^= **=   assign (right-associative)  a += 2 is awk's equivalent of a = a + 2
#


#
#   BUILT-IN SCALAR VARIABLES
#
#       In the BEGIN action, FILENAME, FNR, NF, and NR are initially undefined; references to them return a null string or zero.
#
# FILENAME      name of the current input file
# FNR           Record Number in the current input File
# FS            Field Separator, treated as a regular expression only when it contains more than one character
#               (default: 1 or more whitespace characters (space or tab), leading and trailing whitespace on the line is ignored)
# NF            Number of Fields in current record
# NR            Record Number in the job
# OFS           Output Field Separator (default: " ")
# ORS           Output Record Separator (default: "\n")
# RS            input Record Separator (regular expression in gawk and mawk only) (default: "\n")
#
echo '  un deux trois  ' | awk -F' ' '{ print NF ":" $0 }'              # default field separator
# 3:  un deux trois

echo '  un deux trois  ' | awk -F'[ ]' '{ print NF ":" $0 }'            # exactly one space as field separator
# 7:  un deux trois
# " ", "un", "deux", "trois", " "

#
#   FIELD REFERENCES
#
# $0            refers to the current record, initially exactly as read from the input stream, and RS is not part of the record
# $1 $2 $NF     field references need not be constant and are converted (by truncation) to integer values if necessary:
#               assuming that k is 3, the values $k, $(1+2), $(27/9), $3.14159 and $3 all refer to the 3rd field


#
#   ARRAYS
#
#       awk allows array indices to be arbitrary numeric or string expressions.
#       Arrays in awk require neither declaration nor allocation: array storage grows automatically as new elements are referenced.
#
telephone["Alice"]  = "555-0134"
telephone["Bob"]    = "555-0135"
telephone["Carol"]  = "555-0136"
telephone["Don"]    = "555-0141"


#
#   COMMAND-LINE ARGUMENTS
#
#       awk makes the command-line arguments available via the built-in variables
#           ARGC (argument count) and
#           ARGV (argument vector, or argument values)
#

# showargs.awk
#   BEGIN {
#       print "ARGC = ", ARGC
#       for (k = 0; k < ARGC; k++)
#           print "ARGV[" k "] = [" ARGV[k] "]"
#   }

awk -v One=1 -v Two=2 -f showargs.awk Three=3 file1 Four=4 file2 file3
# ARGC = 6
# ARGV[0] = [awk]
# ARGV[1] = [Three=3]
# ARGV[2] = [file1]
# ARGV[3] = [Four=4]
# ARGV[4] = [file2]
# ARGV[5] = [file3]

awk 'BEGIN { for (k = 0; k < ARGC; k++) print "ARGV[" k "] = [" ARGV[k] "]" }' a b c
# ARGV[0] = [awk]
# ARGV[1] = [a]
# ARGV[2] = [b]
# ARGV[3] = [c]

# Whether a directory path in the program name is visible or not is implementation-dependent
/usr/local/bin/gawk 'BEGIN { print ARGV[0] }'                           # gawk
/usr/local/bin/mawk 'BEGIN { print ARGV[0] }'                           # mawk
/usr/local/bin/nawk 'BEGIN { print ARGV[0] }'                           # /usr/local/bin/nawk


#
#   ENVIRON
#
#       awk provides access to all of the environment variables as entries in the built-in array ENVIRON.
#       ENVIRON should be considered as a read-only array.
#
awk 'BEGIN { print ENVIRON["HOME"]; print ENVIRON["USER"] }'
# /home/jones
# jones


#
#   PATTERNS
#
#       Patterns are constructed from string and/or numeric expressions:
#       when they evaluate to nonzero (true) for the current input record, the associated action is executed.
#       If a pattern is a bare regular expression, then it means to match the entire input record against that expression,
#       as if you had written $0 ~ /regexp/ instead of just /regexp/.
#
NF = 0                                                                  # Select empty records (records with no fields)
NF > 3                                                                  # Select records with more than 3 fields
NR < 5                                                                  # Select records 1 through 4
(FNR = 3) && (FILENAME ~ /[.][ch]$/)                                    # Select record 3 in C source files
$1 ~ /jones/                                                            # Select records with "jones" in field 1
/[Xx][Mm][Ll]/                                                          # Select records containing "XML", ignoring lettercase
$0 ~ /[Xx][Mm][Ll]/                                                     # Same as preceding selection

#
#       awk allows for range expressions
#       2 expressions separated by a comma select records from one matching the left expression up to,
#       and including, the record that matches the right expression
#
(FNR = 3), (FNR = 10)                                                   # Select records 3 through 10 in each input file
/<[Hh][Tt][Mm][Ll]>/, /<\/[Hh][Tt][Mm][Ll]>/                            # Select body of an HTML document
/[aeiouy][aeiouy]/, /[^aeiouy][^aeiouy]/                                # Select from 2 vowels to 2 nonvowels


#
#   ACTIONS
#
#       print
#
#           a bare print means to print the current input record ($0) on standard output,
#           followed by the value of the output record separator, ORS, which is by default a single newline character
#
awk '{ print $1 }'                                                      # print 1st field (no pattern)
awk '{ print $2, $5 }'                                                  # print 2nd and 5th fields (no pattern)
awk '{ print $1, $NF }'                                                 # print 1st and last fields (no pattern)
awk 'NF > 0 { print $0 }'                                               # print non-empty records (pattern and action)
awk 'NF > 0'                                                            # same (no action, default is to print)
awk '{ print $NF }' my_file                                             # print the last field of each record

awk -F: '{ print $1, $5 }' /etc/passwd                                  # camus Albert Camus
awk -F: -v 'OFS=**' '{ print $1, $5 }' /etc/passwd                      # camus**Albert Camus
awk -F: '{ print "User", $1, "is really", $5 }' /etc/passwd             # User camus is really Albert Camus

# As with the shell-level echo and printf, awk's print statement automatically supplies a final newline,
# whereas with the printf statement you must supply it yourself, using the \n escape sequence.
awk -F: '{ printf "User %s is really %s\n", $1, $5 }' /etc/passwd       # same using awk's version of printf

echo 'one two three four' | awk '{ print $1, $2, $3 }'                  # one two three
echo 'one two three four' | awk '{ OFS="..."; print $1, $2, $3 }'       # one...two...three
echo 'one two three four' | awk '{ OFS="\n"; print $1, $2, $3 }'
# one
# two
# three

# Changing OFS without assigning any field does not alter $0
echo 'one two three four' | awk '{ OFS="\n"; print $0 }'                # one two three four

# However, if we change OFS, and we assign at least one of the fields (even if we do not change its value),
# then we force reassembly of the record with the new field separator
echo 'one two three four' | awk '{ OFS="\n"; $1=$1; print $0 }'
# one
# two
# three
# four


#
#   BEGIN
#
#       The action associated with BEGIN is performed just once,
#       before any command-line files or ordinary command-line assignments are processed,
#       but after any leading -v option assignments have been done.
#       It is normally used to handle any special initialization tasks required by the program.
#
awk 'BEGIN { FS=":" ; OFS="**" } { print $1, $5 }' /etc/passwd          # camus**Albert Camus

#
#   END
#
#       The END action is performed just once, after all of the input data has been processed.
#       It is normally used to produce summary reports or to perform cleanup actions.
#
awk 'END { print NR }' my_file                                          # prints the number of records (lines)



# awk's version of the UNIX wc (word count) utility
awk '{ C+=length($0) + 1; W+=NF } END { print NR, W, C }'
# The character count in C is updated at each record to count the record length, plus the newline that is the default RS
# The word count in W accumulates the number of fields


# Reports the sum of the n-th column in tables with whitespace-separated columns
awk -v COLUMN=n '{ sum+=$COLUMN } END { print sum }' files


# A minor tweak instead reports the average of column n
awk -v COLUMN=n '{ sum+=$COLUMN } END { print sum / NR }' files


# Prints the running total for expense files whose records contain a description and an amount in the last field
awk '{ sum+=$NF; print $0, sum }' expense_files


# To swap the second and third columns in a four-column table, assuming tab separators, use any of these
awk -F'\t' -v OFS='\t' '{ print $1, $3, $2, $4 }' old > new
awk 'BEGIN { FS=OFS="\t" } { print $1, $3, $2, $4 }' old > new
awk -F'\t' '{ print $1 "\t" $3 "\t" $2 "\t" $4 }' old > new


# To convert column separators from tab to ampersand, use either of these
awk 'BEGIN { FS="\t"; OFS="&" } { $1 = $1; print }' files


# Both of these pipelines eliminate duplicate lines (records for awk) from a sorted stream
sort files | uniq
sort files | awk 'Last != $0 { print } { Last = $0 }'
# print the current record ($0) if it's different from the last one, and set the last one to the current


# To convert carriage-return/newline line terminators to newline terminators, use one of these
sed -e 's/\r$//' files
sed -e 's/^M$//' files                                                  # ^M represents a literal Ctrl-M (carriage return)
# we need either gawk or mawk because nawk and POSIX awk do not support more than a single character in RS
mawk 'BEGIN { RS="\r\n" } { print }' files


# To convert single-spaced text lines to double-spaced lines, use any of these
sed -e 's/$/\n/' files
awk 'BEGIN { ORS="\n\n" } { print }' files
awk 'BEGIN { ORS="\n\n" } 1' files
awk '{ print $0 "\n" }' files
awk '{ print; print "" }' files


# Conversion of double-spaced lines to single spacing is equally easy
gawk 'BEGIN { RS="\n *\n" } { print }' files


# Strip angle-bracketed markup tags from HTML documents, treat the tags as record separators
mawk 'BEGIN { ORS=" "; RS="<[^<>]*>" } { print }' *.html


# Extracts all of the titles from a collection of XML documents, and print them, one title per line, with surrounding markup
mawk -v ORS=' ' -v RS='[ \n]' '/<title *>/, /<\/title *>/' *.xml | sed -e 's@</title *> *@&\n@g'
# ...
# <title>Enough awk to Be Dangerous</title>
# <title>Freely available awk versions</title>
# <title>The awk Command Line</title>
# ...
