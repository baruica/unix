#
#   sort        Sort input lines into an order determined by the key field and datatype options, and the locale.
#
#       sort [ option(s) ] [ file(s) ]
#
#   -b          ignore leading spaces and tabs at the begining of the line
#   -d          use dictionary order, only alphanumerics and whitespace are significant
#   -f          fold letters implicitly to a common lettercase so that sorting is case-insensitive
#   -i          ignore nonprintable characters
#   -k          define the sort key field
#   -n          compare fields as integer numbers (numerical order)
#   -o outfile  write output to the specified file instead of to standard output
#   -r          reverse the sorting order to descending, rather than the default ascending
#   -t char     use the single character char as the default field separator, instead of the default of whitespace
#   -u          unique records only: discard all but the first record in a group with equal keys
#
sort honors.students                    # the sort is displayed on screen
sort honors.students > students.sorted  # the sort is writen to a file called students.sorted
ls | sort -r                            # -r reverses the listing of files
sort -n order.numbers                   # -n tells UNIX to sort numbers and not in alphabetical order
ls | sort -r | lp                       # prints a reversed listing

#
#   Fields and characters within fields are numbered starting from 1.
#   If only one field number is specified, the sort key begins at the start of that field, and continues to the end of the record (not the end of the field).
#   If a comma-separated pair of field numbers is given, the sort key starts at the beginning of the first field, and finishes at the end of the second field.
#   With a dotted character position, comparison begins (first of a number pair) or ends (2nd of a number pair) at that character position:
#   -k2.4,5.6 compares starting with the 4th character of the 2nd field and ending with the 6th character of the 5th field
#
sort -t: -k1,1 /etc/passwd              # sort by username
# bin:x:1:1:bin:/bin:/sbin/nologin
# chico:x:12501:1000:Chico Marx:/home/chico:/bin/bash
# daemon:x:2:2:daemon:/sbin:/sbin/nologin
# groucho:x:12503:2000:Groucho Marx:/home/groucho:/bin/sh
# gummo:x:12504:3000:Gummo Marx:/home/gummo:/usr/local/bin/ksh93
# harpo:x:12502:1000:Harpo Marx:/home/harpo:/bin/ksh
# root:x:0:0:root:/root:/bin/bash
# zeppo:x:12505:1000:Zeppo Marx:/home/zeppo:/bin/zsh

#
#   For more control, add a modifier letter in the field selector to define the type of data in the field and the sorting order.
#
sort -t: -k3nr /etc/passwd              # sort by descending (numerical reverse) UID
# zeppo:x:12505:1000:Zeppo Marx:/home/zeppo:/bin/zsh
# gummo:x:12504:3000:Gummo Marx:/home/gummo:/usr/local/bin/ksh93
# groucho:x:12503:2000:Groucho Marx:/home/groucho:/bin/sh
# harpo:x:12502:1000:Harpo Marx:/home/harpo:/bin/ksh
# chico:x:12501:1000:Chico Marx:/home/chico:/bin/bash
# daemon:x:2:2:daemon:/sbin:/sbin/nologin
# bin:x:1:1:bin:/bin:/sbin/nologin
# root:x:0:0:root:/root:/bin/bash

sort -t: -k4n -k3n /etc/passwd          # sort by GID (because 3 users share the same GID) and UID
# root:x:0:0:root:/root:/bin/bash
# bin:x:1:1:bin:/bin:/sbin/nologin
# daemon:x:2:2:daemon:/sbin:/sbin/nologin
# chico:x:12501:1000:Chico Marx:/home/chico:/bin/bash
# harpo:x:12502:1000:Harpo Marx:/home/harpo:/bin/ksh
# zeppo:x:12505:1000:Zeppo Marx:/home/zeppo:/bin/zsh
# groucho:x:12503:2000:Groucho Marx:/home/groucho:/bin/sh
# gummo:x:12504:3000:Gummo Marx:/home/gummo:/usr/local/bin/ksh93

sort -t: -k4n -u /etc/passwd            # sort by unique GID
# root:x:0:0:root:/root:/bin/bash
# bin:x:1:1:bin:/bin:/sbin/nologin
# daemon:x:2:2:daemon:/sbin:/sbin/nologin
# chico:x:12501:1000:Chico Marx:/home/chico:/bin/bash
# groucho:x:12503:2000:Groucho Marx:/home/groucho:/bin/sh
# gummo:x:12504:3000:Gummo Marx:/home/gummo:/usr/local/bin/ksh93
