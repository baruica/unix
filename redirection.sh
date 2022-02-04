#
#   Redirection
#
#   0   stdin   -> keyboard
#   1   stdout  -> screen (shell)
#   2   stderr  -> screen (shell)
#
#    < file     redirects stdin from file; same as 0< file
#   << label    redirects stdin in a special way, essentially forces the input to a command to be the shell's stdin,
#               which is read until there is a line that contains only label; the input in between is called a here document
#               By default, the shell does variable, command, and arithmetic substitutions on the body of the here document.
#   << 'label'  prevents the shell from doing parameter and command substitution
#   << "label"  same
#   <<- label   deletes leading TABs (but not blanks) from the here document and the label line
#
#   n> file     redirects file descriptor n to file (creation)
#   >> file     redirects stdout to file (append)
#   2>>         redirects stderr to file (append)
#   |           redirects the output of one program to the input of another (pipe)
#   >| file     redirects the output of a command to file and overwrite (force), even if the shell's noclobber option is set
#   <> file     use file as both stdin and stdout
#
#    >&n        duplicates stdout to file descriptor n
#   m>&n        same, except that output that would normally go to file descriptor m is sent to file descriptor n instead
#    >&-        closes stdout
#    <&n        duplicates stdin from file descriptor n
#   m<&n        same, except that input that would normally come from file descriptor m comes from file descriptor n instead
#    <&-        closes stdin
#
#   2>file              redirects stderr to file; stdout remains the same
#   (cmd > f1) 2>f2     send stdout to file f1; stderr to file f2
#   cmd | tee file      tee takes its stdin and copies it to stdout and the file(s) given as argument(s)
#

echo Welcome > /dev/pts/tty00       # redirects stdout to the tty00 shell

sort < my_file                      # the result of the sort of my_file is displayed on stdout (shell)
sort < my_file > sorted_file        # the result of the sort of my_file is redirected to sorted_file (overwritten if already exists)

tr -d '\r' < dos.txt > unix.txt     # deletes ASCII carriage-return characters from dos-file.txt to create unix-file.txt

cat my_file 2>error_file            # stderr is redirected to error_file (if my_file doesn't exist)

# directs the stdout (files found) to filelist and redirects stderr (inaccessible files) to a file called no_access
(find / -print > filelist) 2>no_access

# redirects stdout to sorted_file and redirects stderr (if my_file doesn't exist) to stdout (sorted_file)
sort my_file > sorted_file 2>&1     # redirects both stdout and stderr to sorted_file
sort my_file &> sorted_file         # same, bash only preferred form


#
#   here document
#
cat << key_word
key_word
# the here document is displayed on the stdout (shell) and ends with

cat << key_word > my_file
key_word
# the here document is redirected to my_file

cat >> .mailrc << EOF
alias fred frederick@longmachinename.longcompanyname.com
EOF
# the here document ending with EOF is appended to .mailrc


# sends email to all the users telling about a new version of a program
pgmname=$1                                      # program name given as a command line parameter when invoking this script
for user in $(cut -f 1 -d : /etc/passwd)        # gets the first field delimited by : from the file /etc/passwd
do
    # <<- deletes leading TABs (but not blanks) from the here document and the label line, it makes scripts much easier to read
    mail $user <<- EOF
        Dear $user,

        A new version of $pgmname has been installed in $(whence pgmname).

        Regards,
        Your friendly neighborhood sysadmin.
    EOF
done


# if the delimiter is quoted in any fashion, the shell does no processing on the body of the input
i=5
cat << 'END'OF                                              # the delimiter is quoted
This is the value of i: $i                                  # variable reference
Here is a command substitution: $(echo hello, world)        # command substitution
END
# This is the value of i: $i                                # Text comes out verbatim
# Here is a command substitution: $(echo hello, world)


# sends email to the top 10 "disk hogs" on the system, asking them to clean up their home directories
cd /home                                        # Move to top of home directories
du -s * |                                       # Generate raw disk usage
    sort -nr |                                  # Sort numerically, highest numbers first
        sed 10q |                               # Stop after first 10 lines
            while read amount name
            do
                mail -s "disk usage warning" $name <<- EOF

                    Greetings. You are one of the top 10 consumers of disk space on the system.
                    Your home directory uses $amount disk blocks.

                    Please clean up unneeded files, as soon as possible.

                    Thanks,
                    Your friendly neighborhood system administrator.
                    EOF
            done


#
#   exec        to replace the shell with a new program, or to change the shell's own I/O settings
#
#       exec [ program [ arguments ... ] ]
#
#   With arguments, replace the current shell with the named program, passing the arguments on to it.
#   (the shell starts the new program running in its current process)
#
#   With just I/O redirections, change the shell's own file descriptors.
#

# option processing using the shell, but that most of your task is accomplished by some other program
while [ $# -gt 1 ]                              # Loop over arguments
do
    case $1 in                                  # Process options
    -f)
        # code for -f here
    ;;
    -q)
        # code for -q here
    ;;
    *)
        break
    ;;                                          # Nonoption, break loop
    esac
    shift                                       # Move next argument down
done

exec real-app -q "$qargs" -f "$fargs" "$@"      # Run the program
echo real-app failed, get help! 1>&2            # Emergency message
