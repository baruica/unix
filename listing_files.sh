#
# The echo command provides one simple way to list files that match a pattern:
#
echo /bin/*sh                       # show shells in /bin
# /bin/ash /bin/bash /bin/bsh /bin/csh /bin/ksh /bin/sh /bin/tcsh /bin/zsh


#
#   ls          (list) list the contents of file directories
#
#   files with an execute status (x), such as programs, are marked with an * (asterisk)
#
#   -a  shows all files, including hidden files
#   -d  print information about directories themselves, rather than about files that they contain
#   -F  mark certain file types with special suffix characters (puts a / after each directory name)
#   -i  show inode numbers
#   -l  list in long form, with type, protection, owner, group, byte count, last modification time and filename
#       type can be: plain file (-), directory (d) or symbolic link (l or /)
#   -L  follow symbolic links, listing the files that they point to
#   -r  reverse the default sort order
#   -R  list recursively, descending into each subdirectory

ls /bin/*sh | cat                   # show shells in output pipe
# /bin/ash
# /bin/bash
# /bin/bsh
# /bin/csh
# /bin/ksh
# /bin/sh
# /bin/tcsh
# /bin/zsh

ls /bin/*sh                         # show shells in 80-character terminal window
# /bin/ash  /bin/bash  /bin/bsh  /bin/csh  /bin/ksh  /bin/sh  /bin/tcsh  /bin/zsh

ls /bin/*sh                         # show shells in 40-character terminal window
# /bin/ash   /bin/csh  /bin/tcsh
# /bin/bash  /bin/ksh  /bin/zsh
# /bin/bsh   /bin/sh


ls this-file-does-not-exist         # try to list a nonexistent file
# ls: this-file-does-not-exist: No such file or directory
echo $?                             # show the ls exit code
# 1


# Without an argument, echo displays only an empty line, but ls instead lists the contents of the current directory.
mkdir sample                        # make a new directory
cd sample                           # change directory to it
touch one two three                 # create empty files
echo *                              # echo matching files
# one three two
ls *                                # list matching files
# one  three  two
echo                                # echo without arguments
#                                     this output line is empty
ls                                  # list current directory
# one  three  two


# Filenames that begin with a dot are hidden from normal shell pattern matching.
mkdir hidden                        # make a new directory
cd hidden                           # change directory to it
touch .uno .dos .tres               # create 3 hidden empty files
echo *                              # echo matching files
# *                                   nothing matched
ls                                  # list nonhidden files
#                                     this output line is empty
ls *                                # list matching files
# ls: *: No such file or directory

# When no files match a pattern, the shell leaves the pattern as the argument:
# here, echo saw an asterisk and printed it, whereas ls tried to find a file named * and reported its failure to do so.

# If we now supply a pattern that matches the leading dot, we can see further differences:
echo .*                             # echo hidden files
# . .. .dos .tres .uno
ls .*                               # list hidden files
# .dos  .tres  .uno
# .:
# ..:
# hidden  one  three  two             this is the contents of the parent directory (..)

# Unix directories always contain the special entries .. (parent directory) and . (current directory), and the shell passed all of the matches to both programs.
# echo merely reports them, but ls does something more: when a command-line argument is a directory, it lists the contents of that directory.


# You can print information about a directory itself, instead of its contents, with the -d option:
ls -d .*                            # list hidden files, but without directory contents
# .  ..  .dos  .tres  .uno
ls -d ../*                          # list parent files, but without directory contents
# ../hidden  ../one  ../three  ../two

ls -a                               # list all files, including hidden ones
# .  ..  .dos  .tres  .uno


ls -l /bin/*sh                      # list shells in /bin
# -rwxr-xr-x  1 root root 110048 Jul 17  2002 /bin/ash
# -rwxr-xr-x  1 root root 626124 Apr  9  2003 /bin/bash
# lrwxrwxrwx  1 root root      3 May 11  2003 /bin/bsh -> ash
# lrwxrwxrwx  1 root root      4 May 11  2003 /bin/csh -> tcsh
# -rwxr-xr-x  1 root root 206642 Jun 28  2002 /bin/ksh
# lrwxrwxrwx  1 root root      4 Aug  1  2003 /bin/sh -> bash
# -rwxr-xr-x  1 root root 365432 Aug  8  2002 /bin/tcsh
# -rwxr-xr-x  2 root root 463680 Jun 28  2002 /bin/zsh

# The second column contains the link counts:
# here, only /bin/zsh has a hard link to another file, but that other file is not shown in the output because its name does not match the argument pattern.

# Columns 6, 7 an 8 report the last-modification timestamp.
# In the historical form shown here, a month, day and year are used for files older than 6 months,
# and otherwise, the year is replaced by a time of day:
ls -l /usr/local/bin/ksh                                        # list a recent file
# -rwxrwxr-x  1 jones devel 879740 Feb 23 07:33 /usr/local/bin/ksh


#
# However, in modern implementations of ls, the timestamp is locale-dependent, and may take fewer columns.
#
# Here are tests with 2 different versions of ls on GNU/Linux:
LC_TIME=de_CH /usr/local/bin/ls -l /bin/tcsh        # list timestamp in Swiss-German locale
# -rwxr-xr-x  1 root root 365432 2002-08-08 02:34 /bin/tcsh
LC_TIME=fr_BE /bin/ls -l /bin/tcsh                  # list timestamp in Belgian-French locale
# -rwxr-xr-x    1 root     root       365432 ao€  8  2002 /bin/tcsh
# Although the timestamps are supposedly internationalized, this system shows its English roots with its bad French report of the date le 8 ao€t 2002.

# The GNU version permits display of full time precision; this example from an SGI IRIX system shows microsecond granularity:
/usr/local/bin/ls -l --full-time /bin/tcsh          # show high-resolution timestamp
# -r-xr-xr-x  1 root sys 425756 1999-11-04 13:08:46.282188000 -0700 /bin/tcsh


#
# For portable shell scripting, limit yourself to the more common options and set the environment variable LC_TIME to reduce locale variations.
#
