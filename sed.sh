#
#   sed         (stream editor) mostly used to make simple string substitutions
#
#       sed [ -n ] 'editing command' [ file ... ]
#       sed [ -n ] -e 'editing command' ... [ file ... ]
#       sed [ -n ] -f script-file ... [ file ... ]
#
#   -e 'editing_cmd'    Use editing_cmd on the input data. -e must be used when there are multiple commands.
#   -f script-file      Read editing commands from script-file. This is useful when there are many commands to execute.
#   -n                  Modifies sed's default behavior, it does not print the final contents of the pattern space when it's done.
#                       Instead, lines must be printed explicitly with the p command.
#
#   Sub-commands
#
#   d   Deletes the pattern space and then starts the next cycle
#   D   Deletes the initial segment of the pattern space through the first new-line character and then starts the next cycle
#   g   Replaces the contents of the pattern space with the contents of the hold space
#   G   Appends the contents of the hold space to the pattern space
#   h   Replaces the contents of the hold space with the contents of the pattern space
#   H   Appends the contents of the pattern space to the hold space
#   p   Writes the pattern space to standard output
#   P   Writes the initial segment of the pattern space through the first new-line character to standard output
#   q   Branches to the end of the script. It does not start a new cycle
#

#
#   SEPARATORS
#
# sed uses / characters to delimit patterns to search for.
# To use a different character than / to delimit patterns to search for, the character must be preceded by \
#
sed 's/:.*//' /etc/passwd                                   # substitute everything after the first colon with nothing (NUL)
sort -u                                                     # sort list and remove duplicates

sed -e 's:/usr/local:/usr:g' mylist.txt                     # globally substitutes /usr/local for /usr, using : as the regular expression separator

grep tolstoy /etc/passwd                                    # gives the same result as
sed -n '\:tolstoy: s;;Tolstoy;p' /etc/passwd                # : delimits the pattern to search for, and ; act as delimiters for the s command

# When working with filenames, it is common to use punctuation characters for the delimiter (; : ,) instead of /
# Script that creates a copy of the directory structure in /home/tolstoy in /home/lt
find /home/tolstoy -type d -print                           # prints a list of all directories under /home/tolstoy
sed 's;/home/tolstoy/;/home/lt/;'                           # change the name of the top directory, at each line, note use of semicolon delimiter
sed 's/^/mkdir /'                                           # insert mkdir command at the beginning of every line generated by find
sh -x                                                       # feed the stream of commands as input to the shell, with shell tracing

# converts a UNIX file (\n at the end of each line) to a DOS file (\r\n at the end of each file)
sed -e 's/$/\r/' unix.txt > dos.txt                         # substitutes the end of the line ($) by a carriage return \r
# converts a DOS file (\r\n) into a UNIX file (\n)
sed -e 's/.$//' dos.txt > unix.txt                          # substitutes the last character on the line by nothing


#
#   PATTERN SPACE (the buffer that holds the current line being worked on)
#      HOLD SPACE (a temporary buffer)
#
#   1!G     executed from line 2, appends the contents of the hold space to the pattern space
#   h       executed first on line 1, tells sed to copy the contents of the pattern space to the hold space
#   $!d     executed until the last but one line, deletes the line currently in the pattern space,
#           so it doesn't get printed after all the commands are executed for this line
#
sed -e '1!G;h;$!d' forward.txt > backward.txt               # reverses lines of a file containing foo\n\bar\n\oni\n

# sed understands backreferences and may be used in the replacement text
echo /home/tolstoy/ | sed 's;\(/home\)/tolstoy/;\1/lt/;'    # /home/lt/

#
#   &
#
# in the replacement text means "substitute at this point the entire text matched by the regular expression"
#
mv atlga.xml atlga.xml.old                                  # backup copy
sed 's/Atlanta/&, the capital of the South/' < atlga.xml.old > atlga.xml    # Atlanta, the capital of the South

#
#   global option
#
echo Tolstoy reads well. Tolstoy writes well. > example.txt
sed 's/Tolstoy/Camus/' < example.txt                        # substitute only the first match           Camus reads well. Tolstoy writes well.
sed 's/Tolstoy/Camus/g' < example.txt                       # global substitution                       Camus reads well. Camus writes well.
sed 's/Tolstoy/Camus/2' < example.txt                       # substitute only the second occurence      Tolstoy reads well. Camus writes well.

#
#   REGION NUMBERS
#
# say we have a file that contains the following text:
# foo bar oni
# eeny meeny miny
# larry curly moe
# jimmy the weasel
#
# we refer to each parentheses-delimited region by typing \x, where x is the number of the region
sed -e 's/\(.*\) \(.*\) \(.*\)/Victor \1-\2 Von \3/' my_file.txt
# Victor foo-bar Von oni
# Victor eeny-meeny Von miny
# Victor larry-curly Von moe
# Victor jimmy-the Von weasel

#
#   MORE THAN 1 COMMAND
#
# each command is executed in order, line by line
#
sed -e 's/foo/bar/g' -e 's/chicken/cow/g' my_file.xml > my_file2.xml
sed -n -e '=;p' my_file.txt                                 # using semicolons (;) prints (p) with the line numbers (=)
sed -n -e '=' -e 'p' my_file.txt                            # equivalent using -e option

# the best way is to put your commands in a separate file
cat fixup.sed
s/foo/bar/g
s/chicken/cow/g
s/draft animal/horse/g

sed -f fixup.sed file1.xml > file2.xml                      # -f to specify the file containing the commands

# to specify multiple commands that will apply to a single address, enter your sed commands in a file and use { } to group them
1,20{
    s/[Ll]inux/GNU\/Linux/g
    s/samba/Samba/g
    s/posix/POSIX/g
} # multiple commands applied to lines 1 to 20 inclusive

1,/^END/{
    s/[Ll]inux/GNU\/Linux/g
    s/samba/Samba/g
    s/posix/POSIX/g
    p
} # applied from the lines starting at 1 and up to a line beginning with END or until the end of file if END is not found

#
# POSIX allows you to separate commands on the same line with a semicolon (;)
#
sed 's/foo/bar/g ; s/chicken/cow/g' my_file.xml > my_file2.xml

#
#   ADDRESSES
#
# By default, sed applies every editing command to every input line.
# It is possible to restrict the lines to which a command applies by prefixing the command with an address.
#

#
# $ indicates the last line of input
#
sed -n '$p' "$1"                                            # prints the last line of a file passed as an argument to the script and referenced by $1

#
# line numbers
#
sed -e '1d' /etc/services                                   # deletes the first line of the /etc/services file from the output stream

#
# ranges can be specified by separating addresses with a comma (,)
#
sed -n '10,42p' foo.xml                                     # print only lines 10-42
sed -e '4,7s/enchantment/entrapment/g' file3.txt            # globally substitutes enchantment by entrapment on lines 4 to 7 inclusive
# starting with lines matching foo, and continuing through lines matching bar, replace all occurrences of baz with quux
sed '/foo/,/bar/ s/baz/quux/g'                              # the use of 2 regular expressions separated by commas is termed a range expression

#
# negated regular expressions   are useful to apply a command to all lines that don't match a particular pattern.
#                               you specify this by adding an ! character after a regular expression to look for
#
sed -e '/used/!s/new/used/g' some_file                      # change new to used on lines not matching used


echo Tolstoy is worldly | sed 's/Tolstoy/Camus/'            # Camus writes well (using a fixed string as a replacement pattern)
echo Tolstoy is worldly | sed 's/T.*y/Camus/'               # Camus (the regular expression matched the longest leftmost y in wordly
echo Tolstoy is worldly | sed 's/T[[:alpha:]]*y/Camus/'     # Camus is worldly (no spaces are matched)



sed -e '/^#/d' /etc/services | more                         # to view the contents of your /etc/services file, deleting the comments

sed -n -e '/BEGIN/,/END/p' /my/dir/f1 | more                # prints a block of text starting with BEGIN and ending with END
sed -n -e '/main[[:space:]]*(/,/^}/p' source.c | more       # prints main function: main, space or tab, ( and ending with }

# globally substitutes hills for mountains but only on blocks of text beginning with a blank line (^$),
# and ending with a line beginning with the three characters 'END' (^END), inclusive
sed -e '/^$/,/^END/s/hills/mountains/g' my_file3.txt

sed -e 's/<.*>//g' my_file.html                             # globally substitutes all the lines with any number of characters between <>, with an empty string
#
# beacause it finds the longest leftmost match on a line
#   <b>This</b> is what <b>I</b> meant.
# becomes
#    meant.
# instead of
#   This is what I meant
#
# globally substitutes a < followed by any number of non > ([^>]), and ending with >, with an empty string
sed -e 's/<[^>]*>//g' my_file.html                          # this one finds the shortest match

# substitutes whatever was matched by .* (the largest group of zero or more characters on the line, or the entire line) with ralph said:
sed -e 's/.*/ralph said: &/' origmsg.txt                    # & tells sed to insert the entire matched regular expression

#
#   INSERT a line after the current line, INSERT a line before the current line, or replace the current line in the pattern space
#
i\
This line will be inserted before each line
# produces
This line will be inserted before each line
line 1 here
This line will be inserted before each line
line 2 here
This line will be inserted before each line
line 3 here
This line will be inserted before each line
line 4 here
# to insert multiple lines, use backslash \
i\
insert this line\
and this one\
and this one\
and, uh, this one too.

#
#   APPEND inserts a line or lines after the current line in the pattern space
#
a\
insert this line after each line. Thanks! :)

#
#   CHANGE replaces the current line in the pattern space
#
c\
You are history, original line! Muhahaha!
#
#   Because the append, insert, and change line commands need to be entered on multiple lines,
#   you'll want to type them in to text sed scripts and tell sed to source them by using the '-f' option.
#   Using the other methods to pass commands to sed will result in problems.
#