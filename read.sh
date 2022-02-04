#
#   read        to read information into one or more shell variables
#
#       read [ -r ] variable
#
#   -r  Raw read. Don't interpret backslash at end-of-line as meaning line continuation.
#
#   Lines are read from standard input and split as via shell field splitting (using $IFS).
#   The first word is assigned to the first variable, the second to the second, and so on.
#   If there are more words than variables, all the trailing words are assigned to the last variable.
#   read exits with a failure value upon encountering end-of-file.
#
#   If an input line ends with a backslash, read discards the backslash and newline, and continues reading data from the next line.
#   The -r option forces read to treat a final backslash literally.
#
x=abc
printf "x is now '%s'. Enter new value: " $x
read x
# x is now 'abc'. Enter new value: PDQ
echo $x
# PDQ


# read values into multiple variables at one time
printf "Enter name, rank, serial number: "
read name rank serno


# The assignment to IFS causes read to use : as the field separator, without affecting the value of IFS for use in the loop body.
# It changes the value of IFS only in the environment inherited by read.
# read exits with a nonzero exit status when it encounters the end of the input file. This terminates the while loop
while IFS=: read user pass uid gid fullname homedir some_shell
do
    # Process each user's line
done < /etc/passwd                          # necessary so that read sees subsequent lines each time around the loop


# copy a directory tree
find /home/tolstoy -type d -print |         # Find all directories
    sed 's;/home/tolstoy/;/home/lt/;' |     # Change name, note use of semicolon delimiter
        sed 's/^/mkdir /' |                 # Insert mkdir command
            sh -x                           # Execute, with shell tracing
# However, it can be done easily, and more naturally from a shell programmer's point of view, with a loop:
find /home/tolstoy -type d -print |         # Find all directories
    sed 's;/home/tolstoy/;/home/lt/;' |     # Change name, note use of semicolon delimiter
        while read newdir                   # Read new directory name
        do
            mkdir $newdir                   # Make new directory
        done


# \ tells read to continue reading from the next input line
printf "Enter name, rank, serial number: "
read name rank serno
# Enter name, rank, serial number: Jones \
# Major \
# 123-45-6789

printf "Name: %s, Rank: %s, Serial number: %s\n" $name $rank $serno
# Name: Jones, Rank: Major, Serial number: 123-45-6789

read -r name rank serno                     # -r forces read not to take \ as a special character
# tolstoy \                     Only 2 fields provided

echo $name $rank $serno
# tolstoy \                     $serno is empty
