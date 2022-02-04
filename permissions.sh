#
#   chmod       (change mode) to change file or directory permissions
#
#       chmod [ options ] mode file(s)
#
#   -f  force changes if possible (and don't complain if they fail)
#   -R  apply changes recursively through directories
#
# ABSOLUTE PERMISSIONS
#
#   0   --- 000 none
#   1   --x 001 execute only
#   2   -w- 010 write only
#   3   -wx 011 write and execute
#   4   r-- 100 read only
#   5   r-x 101 read and execute
#   6   rw- 110 read and write
#   7   rwe 111 read, write and execute
#
# SYMBOLIC FORM
#
#   u user (owner)              + add           r read
#   g group                     - delete        w write
#   o other (everyone else)     = set           x execute
#   a all 3                                     - none
#
chmod a+r some_file             # allows everyone to read announcements
chmod go-w some_file            # not to let anyone exept the user change the file
chmod ug=x some_file            # the only right the user and the group have is execute


# A set of default permissions is always applied to newly created files: they are controlled by the umask command,
# which sets the default when given an argument, and otherwise shows the default.
# The umask value is 3 octal digits that represent permissions to be taken away:
# a common value is 077, which says that the user is given all permissions (read, write, execute), and group and other have them all taken away.
# The result is that access to newly created files is restricted to just the user who owns them.
umask                           # show the current permission mask
# 002
touch foo                       # create an empty file
ls -l foo                       # list information about the file
# -rw-rw-r--    1 jones    devel           0 2002-09-21 16:16 foo
rm foo                          # delete the file
ls -l foo                       # list information about the file again
# ls: foo: No such file or directory

# Initially, the permission mask is 002, meaning that write permission should be removed for other.
# The touch command simply updates the last-write timestamp of a file, creating it if necessary.
# The ls -l command is a common idiom for asking for a verbose file listing.
# It reports a file type of - (ordinary file), and a permission string of rw-rw-r-- (that is, read-write permission for user and group, and read permission for other).

# When we re-create the file after changing the mask to 023, to remove write access from the group and write and execute access from other,
# we see that the permission string is reported as rw-r--r--, with write permissions for group and other removed as expected:
umask 023                       # reset the permission mask
touch foo                       # create an empty file
ls -l foo                       # list information about the file
# -rw-r--r--    1 jones    devel           0 2002-09-21 16:16 foo


# Files don't normally have the execute permission, unless they are intended to be executable programs or scripts.
# Linkers automatically add execute permission to such programs, but for scripts, you have to use chmod yourself.

# When we copy a file that already has execute permissions, the permissions are preserved, unless the umask value causes them to be taken away:
umask                           # show the current permission mask
# 023
rm -f foo                       # delete any existing file
cp /bin/pwd foo                 # make a copy of a system command
ls -l /bin/pwd foo              # list information about the files
# -rwxr-xr-x    1 root     root        10428 2001-07-23 10:23 /bin/pwd
# -rwxr-xr--    1 jones    devel       10428 2002-09-21 16:37 foo

# The resulting permission string rwxr-xr-- reflects the loss of privileges: group lost write access, and other lost both write and execute access.

# Finally, we use the symbolic form of an argument to chmod to add execute permission for all:
chmod a+x foo                   # add execute permission for all
ls -l foo                       # list verbose file information
# -rwxr-xr-x    1 jones    devel       10428 2002-09-21 16:37 foo

# The resulting permission string is then rwxr-xr-x, so user, group and other have execute access.
# Notice that the permission mask did not affect the chmod operation: the mask is relevant only at file-creation time.
# The copied file behaves exactly like the original pwd command:
/bin/pwd                        # try the system version
# /tmp
pwd                             # and the shell built-in version
# /tmp
./foo                           # and our copy of the system version
# /tmp
file foo /bin/pwd               # ask for information about these files
# foo:      ELF 32-bit LSB executable, Intel 80386, version 1, dynamically linked (uses shared libs), stripped
# /bin/pwd: ELF 32-bit LSB executable, Intel 80386, version 1, dynamically linked (uses shared libs), stripped

# Notice that we invoked foo with a directory prefix: for security reasons, it is never a good idea to include the current directory in the PATH list.
# If you must have it there, at least put it last!

# Here is what happens if you remove the execute permission, and then try to run the program:
chmod a-x foo                   # remove execute permission for all
ls -l foo                       # list verbose file information
# -rw-r--r--    1 jones    devel       10428 2002-09-21 16:37 foo
./foo                           # try to run the program
# bash: ./foo: Permission denied

# That is, it is not the ability of a file to function as an executable program,
# but rather, its possession of execute permission that determines whether it can be run as a command.
# This is an important safety feature in Unix.

# Here is what happens when you give execute permission to a file that doesn't deserve it:
umask 002                       # remove default for world write permission
rm -f foo                       # delete any existing file
echo 'Hello, world' > foo       # create a one-line file
chmod a+x foo                   # make it executable
ls -l foo                       # show our changes
# -rwxrwxr-x    1 jones    devel          13 2002-09-21 16:51 foo
./foo                           # try to run the program
# ./foo: line 1: Hello,: command not found
echo $?                         # display the exit status code
# 127


# When permissions are checked, the order is user, then group, then other.
# The first of these to which the process belongs determines which set of permission bits is used.
# Thus, it is possible to have a file that belongs to you, but which you cannot read, even though fellow group members, and everyone else on your system, can:
echo 'This is a secret' > top_secret        # create one-line file
chmod 044 top_secret            # remove all but read for group and other
ls -l                           # show our changes
# ----r--r--    1 jones    devel          17 2002-10-11 14:59 top_secret
cat top_secret                  # try to display file
# cat: top_secret: Permission denied
chmod u+r top_secret            # allow owner to read file
ls -l                           # show our changes
# -r--r--r--    1 jones    devel          17 2002-10-11 14:59 top_secret
cat top_secret                  # this time, display works!
# This is a secret


# All Unix filesystems contain additional permission bits, called set-user-ID, set-group-ID and sticky bits.
# For compatibility with older systems, and to avoid increasing the already large line length,
# ls does not show these permissions with 3 extra permission characters, but instead, changes the letter x to other letters.
# For the details, see the chmod(1), chmod(2), and ls(1) manual pages.
# For security reasons, shell scripts should never have the set-user-ID or set-group-ID permission bits set:
# an astonishing number of subtle security holes have been found in such scripts.



#
#   Remember that a directory is nothing more than a list of files.
#   Creating a file in a directory, renaming a file or deleting a file from a directory requires changing this list;
#   therefore, you need write access to the directory to create or delete a file.
#

# Read access for a directory means that you can list its contents with, for example, ls.
# Write access means that you can create or delete files in the directory, even though you cannot write the directory file yourself:
# that privilege is reserved for the operating system in order to preserve filesystem integrity.
# Execute access means that you can access files and subdirectories in the directory (subject, of course, to their own permissions);
# in particular, you can follow a pathname through that directory.
umask                           # show the current permission mask
# 022
mkdir testdir                   # create a subdirectory
ls -Fld testdir                 # show the directory permissions
# drwxr-xr-x  2 jones devel 512 Jul 31 13:34 testdir/
touch testdir/the-file          # create an empty file there
ls -l testdir                   # list the directory contents verbosely
# -rw-r--r--  1 jones devel 0 Jul 31 13:34 testdir/the-file

# So far, this is just normal behavior. Now remove read access, but leave execute access:
chmod a-r testdir               # remove directory read access for all
ls -lFd testdir                 # show the directory permissions
# d-wx--x--x  2 jones devel 512 Jan 31 16:39 testdir/
ls -l testdir                   # try to list the directory contents verbosely
# ls: testdir: Permission denied
ls -l testdir/the-file          # list the file itself
# -rw-r--r--  1 jones devel 0 Jul 31 13:34 test/the-file

# The second ls failed because of the lack of read permission, but execute permission allowed the third ls to succeed.
# In particular, this shows that removing read permission from a directory cannot prevent access to a file contained therein, if its filename is already known.

# Here is what happens when we remove execute access, without restoring read access:
chmod a-x testdir               # remove directory execute access for all
ls -lFd testdir                 # list the directory
# d-w-------  3 jones devel 512 Jul 31 13:34 test/
ls -l testdir                   # try to list the directory contents verbosely
# ls: testdir: Permission denied
ls -l testdir/the-file          # try to list the file
# ls: testdir/the-file: Permission denied
cd testdir                      # try to change to the directory
# testdir: Permission denied.

# The directory tree has been effectively cut off from view by any user, except root.

# Finally, restore read access, but not execute access, and repeat the experiment:
chmod a+r testdir               # add directory read access for all
ls -lFd testdir                 # show the directory permissions
# drw-r--r--  2 jones devel 512 Jul 31 13:34 testdir/
ls -l testdir                   # try to list the directory contents
# ls: testdir/the-file: Permission denied
# total 0
ls -l testdir/the-file          # try to list the file
# ls: testdir/the-file: Permission denied
cd testdir                      # try to change to the directory
# testdir: Permission denied.

# Lack of execute access on the directory has blocked attempts to see its contents, or to make it the current working directory.

# When the sticky bit is set on a directory, files contained therein can be removed only by their owner, or by the owner of the directory.
# This feature is often used for publicly writable directories - notably, /tmp, /var/tmp (formerly called /usr/tmp),
# and incoming mail directories-to prevent users from deleting files that do not belong to them.

# On some systems, when the set-group-ID bit is set on a directory, the group ID of newly created files is set to the group of the directory, rather than to the group of their owner.
# Regrettably, this permission bit is not handled the same on all systems.
# On some, its behavior depends on how the filesystem is mounted, so you should check the manual pages for the mount command for the details on your system.
# The set-group-ID bit is useful when several users share write access to a directory for a collaborative project.
# They are then given membership in a special group created for that project, and the group of the project directory is set to that group.

# Some systems use a combination of the set-group-ID bit being set and the group-execute bit being clear to request mandatory locking.


# Why is there a distinction between reading the directory, and passing through it to a subdirectory?
# The answer is simple: it makes it possible for a file subtree to be visible even though its parent directories are not.
# A common example today is a user's web tree.
# The home directory might typically have permissions rwx--x--x to prevent group and other from listing its contents, or examining its files,
# but the web tree starting at, say, $HOME/public_html, including its subdirectories, would be given access rwxr-xr-x,
# and files within it would have at least rw-r--r-- permissions.



#
#   umask       displays or sets the file mode creation mask
#
#       umask [ -S ] [ Mask ]
#
#   If the Mask parameter is not specified, the umask command displays to standard output the file mode creation mask of the current shell environment.
#   If you specify the Mask parameter using a three-digit octal number or symbolic code, the umask command sets the file creation mask of the current shell execution environment.
#   The bits set in the file creation mask are used to clear the corresponding bits requested by an application or command when creating a file.
#
#   -S  produces symbolic output (u=rwx,g=rwx,o=rx)
#
umask a=rx,ug+w                 # to set the mode mask so that subsequently created files have their S_IWOTH bit cleared
# or
umask 002

umask -S                        # to produce symbolic output
# u=rwx,g=rwx,o=rx

umask g-w                       # to set the mode mask so that subsequently created files have their S_IWGRP and S_IWOTH bits cleared




chown john chapter6             # changes the owner

chgrp acctg billing.list        # changes the group associated to billing.list to the group acctg

mkgroup mygroup

groups                          # in Linux and BSD, you can be in several groups at a time
