#
#   mkdir       (make directory) creates one or more new directories specified by the Directory parameter.
#
#       mkdir [ -m Mode ] [ -p ] Directory ...
#
#   Each new directory contains the standard entries . (dot) and .. (dot-dot).
#   You can specify the permissions for the new directories with the -m Mode flag.
#   You can use the umask subroutine to set the default mode for the mkdir command.
#   Note: To make a new directory you must have write permission in the parent directory.
#   The mkdir command ignores any Directory parameter that names an existing directory. No error is issued.
#
#   -m Mode     Sets the permission bits for the newly-created directories to the value specified by the Mode variable.
#               The Mode variable takes the same values as the Mode parameter for the chmod command, either in symbolic or numeric form.
#
#   -p          Creates missing intermediate path name directories.
#               If the -p flag is not specified, the parent directory of each-newly created directory must already exist.
#               Intermediate directories are created through the automatic invocation of the following mkdir commands:
mkdir -p -m $(umask -S),u+wx $(dirname Directory) && mkdir [-m Mode] Directory
#               where the [-m Mode] represents any option supplied with your original invocation of the mkdir command.
#
mkdir temp                                      # creates a new directory called temp in the current working directory
mkdir -m 755 /home/demo/sub1/Test               # creates a new directory called Test with rwxr-xr-x permissions in the previously created /home/demo/sub1 directory
mkdir -p /home/demo/sub2/Test                   # creates a new directory called Test with default permissions in the /home/demo/sub2 directory
#  The -p flag creates the /home, /home/demo, and /home/demo/sub2 directories if they do not already exist.

mkdir -p temp/unix/wiley temp/unix/oreilly temp/unix/sams


#
#   cp          (copy)
#
#       cp old_pathname new_pathname
#
#   -i  (interactive) asks you before overwriting an existing file
#
cp budget.jan budget.feb                        # creates a copy of budget.jan, named budget.feb, replacing it if it already exists
cp -i budget.jan budget.feb                     # checks if budget.feb already exists and asks what to do
cp ../john/ch1 ../john/ch2 work                 # makes a copy of ch1 and ch2 into the subdirectory work

cd /users
cp -R john/work mike/work                       # copies everything in john's work directory to a NEW subdirectory in mike's home directory


#
#   mv          (move) renames or moves files or directories (mv overwrites existing files)
#
#       mv old_name new_name        renaming
#       mv file_name dir_name       moving
#
mv sues-04-budget /Budget/Year2004
mv -i bugdet.march budget.march                 # renames bugdet.march to budget.march if no such named file exists
# if a directory Finance already exists, UNIX moves the first-named directory (Budget)
# to become a subdirectory of the existing directory Finance, /Budget moves to become /Finance/Budget
mv Budget Finance


#
#   rm          (remove) deletes (unlinks) files
#
#       rm file_name(s)
#
#   -f  Does not prompt before removing a write-protected file.
#       Does not display an error message or return error status if a specified file does not exist.
#
rm *.old chap5                                  # deletes all the files ending with .old and the file chap5
rm -i some_file                                 # UNIX asks for confirmation to delete some_file
rm -r mydir                                     # deletes mydir and everything in it

#
#   rmdir       (remove directory) deletes empty directories
#
#       rmdir dir_name(s)
#
#   -r  recursive removal of directories and everything in them
#
rmdir -r /usr/mike/project2


#
#   ln          (link)
#               a single file can have more than one name (link), in different directories
#               UNIX considers all names to be equally important links to the file
#               to link a file that is on a different file system or disk, we have to create a symbolic link
#               UNIX doesn't consider symbolic links to be the file's real name because it has a different inode number
#
#       ln file_name new_name       to link 1 file
#       ln files target_dir         to link more than 1 file
#
ln /usr/mike/book/chapters.list bookchapters    # creates a new link to chapters.list called bookchapters
ln /usr/mike/book/* /usr/nels/book              # ln uses the same names the files currently have when it makes the new links
ln -s /usr/mike/recipe.list mikes.recipes       # creates a symbolic link


#
#   man         (manual)
#
#       man cmd
#
man ps                                          # shows the documentation about the command ps
info ps                                         # same in Linux


#
#   history
#
history 8                                       # shows the last 8 commands in
history | more                                  # shows all the commands, screen by screen


#
#   basename    prints the last component of a pathname, optionally removing a suffix
#
basename /ATOM/atom.list
# atom.listing

basename /ATOM/atom.list .list
# atom (suffix removed)

#
#   dirname     strips all characters in its argument from the final slash onward, recovering a directory path from a full pathname,
#               and reports the result on standard output.
#               Like basename, dirname treats its argument as a simple text string, without checking for its existence in the filesystem.
#
dirname /usr/local/bin/nawk
# path/usr/local/bin

# if the argument does not contain a slash, dirname produces a dot representing the current directory
dirname whimsical-name
# .


#
#   INFORMATION ABOUT USERS
#
who                 # who identifies the users currently logged in
# atom        pts/0       May  4 15:22    (163.114.11.165)

whoami
# atom

#
#   id          displays the system identifications of a specified user
#
id                  # shows which group the current user is in
# uid=4491(atom) gid=3200(cft) groups=0(system),1000(dba)

#
#   finger      shows even more user information. Same as the f command.
#
finger -q nels      # shows information about nels at a local host in short form
finger @host        # shows information about all the users currently logged in to host
finger nels@host    # shows information about user nels logged in to host

#
#   rwho        shows which users are logged in to hosts on the local network
#
rwho
rwho -a             # includes all users. Without -a, users whose sessions are idle an hour or more are not included in the report


#
#   su          (switch user) allows to change the user ID associated with a session
#
su                  # runs a subshell with the effective user ID and privileges of the root user
su jim              # runs a subshell with the effective user ID and privileges of Jim
su - jim            # runs a subshell using Jim's login environment


#
#   mount       instructs the OS to make a file system available for use at a specified location (mount point)
#
mount               # without arguments, any user can see a list of the mounted file systems
