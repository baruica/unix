# Shell pattern matching is not powerful enough to match files recursively through an entire file tree,
# and ls and stat provide no way to select files other than by shell patterns.
# Fortunately, Unix provides some other tools that go beyond those commands.


#
#   locate      first introduced in Berkeley Unix, was reimplemented for the GNU findutils package.
#               locate uses a compressed database of all of the filenames in the filesystem to quickly find filenames that match shell-like wildcard patterns,
#               without having to search a possibly huge directory tree.
#               The database is created by updatedb in a suitably privileged job, usually run nightly via cron.
#
locate gcc-3.3.tar                      # find the gcc-3.3 release
# /home/gnu/src/gcc/gcc-3.3.tar-lst
# /home/gnu/src/gcc/gcc-3.3.tar.gz

# In the absence of wildcard patterns, locate reports files that contain the argument as a substring.

# Because locate's output can be voluminous, it is often piped into a pager, such as less, or a search filter, such as grep:
locate gcc-3.3 | fgrep .tar.gz          # find gcc-3.3, but report only its distribution archives
# /home/gnu/src/gcc/gcc-3.3.tar.gz

# Wildcard patterns must be protected from shell expansion so that locate can handle them itself:
locate '*gcc-3.3*.tar*'                 # find gcc-3.3 using wildcard matching inside locate
# ...
# /home/gnu/src/gcc/gcc-3.3.tar.gz
# /home/gnu/src/gcc/gcc-3.3.1.tar.gz
# /home/gnu/src/gcc/gcc-3.3.2.tar.gz
# /home/gnu/src/gcc/gcc-3.3.3.tar.gz
# ...


#
#   type        Occasionally, you may want to know the filesystem location of a command that you invoke without a path.
#               The Bourne-shell family type command does the job.
#
type gcc                                # Where is gcc?
# gcc is /usr/local/bin/gcc
type type                               # What is type?
# type is an exported alias for whence -v
type newgcc                             # What is newgcc?
# newgcc is an alias for /usr/local/test/bin/gcc
type mypwd                              # What is mypwd?
# mypwd is a function
type foobar                             # What is this (nonexistent) command?
# foobar not found

# Notice that type is an internal shell command, so it knows about aliases and functions as well.


#
#   find        Find files matching specified name patterns, or having given attributes.
#               find descends into directory trees, finding all files in those trees.
#               It then applies selectors defined by its command-line options to choose files for further action, normally printing their names or producing an ls-like verbose listing.
#               Because of find's default directory descent, it potentially can take a long time to run in a large filesystem.
#               find's output is not sorted.
#               find has additional options that can be used to carry out arbitrary actions on the selected files. (dangerous)
#
#       find [ files-or-directories ] [ options ]
#
#   -atime n        select files with access times of n days
#   -ctime n        select files with inode-change times of n days
#   -mtime n        select files with modification times of n days
#                   If unsigned, it means exactly that many days old.
#                   If negative, it means less than that absolute value.
#                   With a plus sign, it means more than that value.
#   -exec           to execute a command each time it finds something
#   -follow         follow symbolic links (can be used to find broken links)
#   -group g        select files in group g (a name or numeric group ID)
#   -links n        select files with n hard links
#                   If it is unsigned, it selects only files having that many hard links.
#                   If it is negative, only files with fewer than that many (in absolute value) links are selected.
#                   If it has a plus sign, then only files with more than that many links are selected.
#   -ls             produce a listing similar to the ls long form (ls -liRs), rather than just filenames
#   -name           to specify the name of the file to search for
#   -name 'pattern' select files matching the shell wildcard pattern (quoted to protect it from shell interpretation)
#   -newer file     selects only files modified more recently than the specified file
#   -ok             same as -exec only that it asks for confirmation to execute the command
#   -perm mask      select files matching the specified octal permission mask, optionally signed
#                   When the mask is unsigned, an exact match on the permissions is required.
#                   If it is negative, then all of the bits set are required to match.
#                   If it has a plus sign, then at least one of the bits set must match.
#   -print          tells find to output on the screen
#   -prune          do not descend recursively into directory trees
#   -size n         select files of size n. By default, the size is in 512-byte blocks,
#                   although many find implementations permit the number to be suffixed by c for characters (bytes) or k for kilobytes.
#                   If the number is unsigned, then only files of exactly that size match.
#                   If it is negative, then only files smaller than that (absolute) size match.
#                   Otherwise, with a plus sign, only files bigger than that size match.
#   -type t         select files of type t: d (directory), f (file) or l (symbolic link). There are letters for other file types, but they are not needed often.
#   -user u         select files owned by user u (a name or numeric user ID)
#
ls                                      # verify that we have an empty directory
mkdir -p sub/sub1                       # create a directory tree
touch one two .uno .dos                 # create some empty top-level files
touch sub/three sub/sub1/four           # create some empty files deeper in the tree
find                                    # find everything from here down
# .
# ./sub
# ./sub/sub1
# ./sub/sub1/four
# ./sub/three
# ./one
# ./two
# ./.uno
# ./.dos

find | LC_ALL=C sort                    # set LC_ALL to get the traditional (ASCII) sort order, since modern sort implementations are locale-aware
# .
# ./.dos
# ./.uno
# ./one
# ./sub
# ./sub/sub1
# ./sub/sub1/four
# ./sub/three
# ./two

find -ls                                # find files, and use ls-style output
# 1451550    4 drwxr-xr--   3 jones    devel     4096 Sep 26 09:40 .
# 1663219    4 drwxrwxr-x   3 jones    devel     4096 Sep 26 09:40 ./sub
# 1663220    4 drwxrwxr-x   2 jones    devel     4096 Sep 26 09:40 ./sub/sub1
# 1663222    0 -rw-rw-r--   1 jones    devel        0 Sep 26 09:40 ./sub/sub1/four
# 1663221    0 -rw-rw-r--   1 jones    devel        0 Sep 26 09:40 ./sub/three
# 1451546    0 -rw-rw-r--   1 jones    devel        0 Sep 26 09:40 ./one
# 1451547    0 -rw-rw-r--   1 jones    devel        0 Sep 26 09:40 ./two
# 1451548    0 -rw-rw-r--   1 jones    devel        0 Sep 26 09:40 ./.uno
# 1451549    0 -rw-rw-r--   1 jones    devel        0 Sep 26 09:40 ./.dos

find -ls | sort -k11                    # find files, and sort by filename (11th column)
# 1451550    4 drwxr-xr--   3 jones    devel     4096 Sep 26 09:40 .
# 1451549    0 -rw-rw-r--   1 jones    devel        0 Sep 26 09:40 ./.dos
# 1451548    0 -rw-rw-r--   1 jones    devel        0 Sep 26 09:40 ./.uno
# 1451546    0 -rw-rw-r--   1 jones    devel        0 Sep 26 09:40 ./one
# 1663219    4 drwxrwxr-x   3 jones    devel     4096 Sep 26 09:40 ./sub
# 1663220    4 drwxrwxr-x   2 jones    devel     4096 Sep 26 09:40 ./sub/sub1
# 1663222    0 -rw-rw-r--   1 jones    devel        0 Sep 26 09:40 ./sub/sub1/four
# 1663221    0 -rw-rw-r--   1 jones    devel        0 Sep 26 09:40 ./sub/three
# 1451547    0 -rw-rw-r--   1 jones    devel        0 Sep 26 09:40 ./two

# For comparison, here is how ls displays the same file metadata:
ls -liRs *                              # show ls recursive verbose output
# 752964     0 -rw-rw-r--   1 jones    devel        0 2003-09-26 09:40 one
# 752965     0 -rw-rw-r--   1 jones    devel        0 2003-09-26 09:40 two
# sub:
# total 4
# 752963     4 drwxrwxr-x   2 jones    devel     4096 2003-09-26 09:40 sub1
# 752968     0 -rw-rw-r--   1 jones    devel        0 2003-09-26 09:40 three
# sub/sub1:
# total 0
# 752969     0 -rw-rw-r--   1 jones    devel        0 2003-09-26 09:40 four

find 'o*'                               # find files in this directory starting with "o"
# one
find sub                                # find files in directory sub
# sub
# sub/sub1
# sub/sub1/four
# sub/three

find -prune                             # find without looking inside this directory
# .
find . -prune                           # another way to do the same thing
# .
find * -prune                           # find files in this directory
# one
# sub
# two
ls -d *                                 # fist files, but not directory contents
# one  sub  two

# Notice that a missing file or directory argument is equivalent to the current directory, so the first 2 simply report that directory.
# However, the asterisk matches every nonhidden file, so the third find works like ls -d, except that it shows one file per line.


find $HOME/. ! -user $USER              # start at my home directory and list all files that do not belong to me
                                        # use $HOME/. rather than just $HOME so that the command also works if $HOME is a symbolic link

#   Option          Meaning
#   ------          -------
#   -perm -002      find files writable by other
#   -perm -444      find files readable by everyone
# ! -perm -444      find files not readable by everyone
#   -perm 444       find files with exact permissions r--r--r--
#   -perm +007      find files accessible by other
# ! -perm +007      find files not accessible by other


find $HOME/. -size +1024k               # finds all files in your login tree that are bigger than 1MB
find . -size 0                          # finds all files in the current directory tree that are empty


ls                                      # show that we have an empty directory
ln -s one two                           # create a soft (symbolic) link to a nonexistent file
file two                                # diagnose this file
# two: broken symbolic link to one
find .                                  # find all files
# .
# ./two
find . -type l                          # find soft links only
# ./two
find . -type l -follow                  # find soft links and try to follow them
# find: cannot follow symbolic link ./two: No such file or directory


find . -links +1                        # find files with hard links


find . -mtime -7                        # find files modified in the last week

# If you need finer granularity than a day, you can create an empty file with
touch -t date_time timestampfile
# and then use that file with the -newer option.
# If you want to find files older than that file, negate the selector:
find ! -newer timestampfile


find . -size +0 -a -size -10            # find nonempty files smaller than 10 blocks (5120 bytes)
find . -size 0 -o -atime +365           # find files that are empty OR unread in the past year



find . -name tiramisu -print                                # prints (on screen) the full name and the directory name
find /usr/bob -name tiramisu -print
find /usr/bob /usr/linda -name tiramisu -print
find ~bob ~linda -name tiramisu -print                      # equivalent in bash or csh
find / -name "budget*" -print                               # searches from root (the entire disk) for files that start with budget
find / -name "Budget*" -type d -print                       # searches the entire drive for directories starting with Budget
find . -name "report*" -exec lpr {} ";"                     # prints every file beginning with report
ssh xuxa "find ~dave -name stuffed-squid -print"            # specify that Dave's file is on a machine called xuxa



# script to (begin to) convert HTML to XHTML using html2xhtml.sed
cd top-level-web-site-directory
find . -name '*.html' -type f |                             # find all HTML files
    while read file                                         # read filename into variable
    do
        echo $file                                          # print progress
        mv $file $file.save                                 # save a backup copy
        sed -f $HOME/html2xhtml.sed < $file.save > $file    # make the change
    done



#
#   FINDING PROBLEM FILES
#
# Filenames containing special characters, such as newline, can present difficulties.
# GNU find has the -print0 option to display filenames as NUL-terminated strings.
# Since pathnames can legally contain any character except NUL, this option provides a way to produce lists of filenames that can be parsed unambiguously.

# It is hard to parse such lists with typical Unix tools, most of which assume line-oriented text input.
# However, in a compiled language with byte-at-a-time input, such as C, C++ or Java, it is straightforward to write a program to diagnose the presence of problematic filenames in your filesystem.
# Sometimes they get there by simple programmer error, but other times, they are put there by attackers who try to hide their presence by disguising filenames.

# For example, suppose that you did a directory listing and got output like this:
ls
#  .   ..

# At first glance, this seems innocuous, since we know that empty directories always contain 2 special hidden dotted files for the current and parent directory.
# However, notice that we did not use the -a option, so we should not have seen any hidden files, and also, there appears to be a space before the first dot in the output.
# Something is just not right! Let's apply find and od to investigate further:
find -print0 | od -ab                                       # convert NUL-terminated filenames to octal and ASCII
# 0000000   . nul   .   /  sp   . nul   .   /  sp   .   . nul   .   /   .
#         056 000 056 057 040 056 000 056 057 040 056 056 000 056 057 056
# 0000020  nl nul   .   /   .   .  sp   .   .  sp   .   .  sp   .  sp  nl
#         012 000 056 057 056 056 040 056 056 040 056 056 040 056 040 012
# 0000040  nl  nl  sp  sp nul
#         012 012 040 040 000
# 0000045

# We can make this somewhat more readable with the help of tr, turning spaces into S, newlines into N, and NULs into newline:
find -print0 | tr ' \n\0' 'SN\n'                            # make problem characters visible as S and N
# .
# ./S.
# ./S..
# ./.N
# ./..S..S..S.SNNNSS

# Now we can see what is going on:
# we have the normal dot directory,
# then a file named space-dot,
# another named space-dot-dot,
# yet another named dot-newline,
# and finally one named dot-dot-space-dot-dot-space-dot-dot-space-dot-space-newline-newline-newline-space-space.
# Unless someone was practicing Morse code in your filesystem, these files look awfully suspicious, and you should investigate them further before you get rid of them.
