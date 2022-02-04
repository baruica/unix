#
#   telnet
#
telnet pumpkin              # tries to connect to the distant machine pumpkin
logout                      # if it doesn't let go, Ctrl-] then type quit


#
#   ssh         (secure shell)
#
ssh pumpkin                 # connect to the distant machine pumpkin, assuming the username is the same on both local and distant systems
ssh nels@pumpkin            # the remote username is different from the local system's
ssh xuxa "find ~dave -name stuffed-squid -print"    # remote command that specifies that Dave's file is on a machine called xuxa
~.                          # to escape

#
#   rsh         (remote shell)
#
rsh pumpkin                 # connect to the distant machine pumpkin, assuming the username is the same on both local and distant systems
rsh -l nels pumpkin         # the remote username is different from the local system's


#
#   scp         (secure copy)   encrypts the file and passphrase
#   rcp         (remote copy)
#
#   scp hostname:pathname   appart from this syntax, scp and rcp can be used in the same way as cp
#
scp pumpkin:my_file pumpkinfile                     # makes a local copy of the remote file my_file and call it pumpkinfile
scp pumpkinfile pumpkin:my_file                     # makes a remote copy of the local file pumpkinfile and call it my_file
scp "giraffe:food/lunch/*" .                        # makes a local copy of all the remote files in the lunch directory

# scp uses the same username rules as does ssh
scp nels@pumpkin:my_file pumpkinfile                # if your username on the other system is different from that on your own system
scp pumpkin:~tracy/some_file tracyfile              # makes a local copy of tracy's remote some_file and call it tracyfile

# -r for recursive
scp -r pumpkin:projectdir .                         # makes a local copy of the remote directory projectdir to the current directory
# makes a local copy of tracy's remote projectdir giving a username and call it tracy-project
scp -r steph@pumpkin:~tracy/projectdir tracy-project
scp -r projectdir pumpkin:squashproject             # makes a remote copy of projectdir and call it squashproject

ssh pumpkin ls -l squashproject                     # just to check that the remote copy worked


#
#   ftp         (file transfer protocol) is more flexible and secure than rcp (but much less secure than scp)
#
ftp ftp.iecc.com            # connects to the host called ftp.iecc.com

# at the ftp prompt

# there are 2 modes: ascii (text) and binary (everything else)
binary                      # Tells ftp to copy the following file(s) without translation. It preserves pictures, sound, or other data.
ascii                       # Transfers plain text files, translating data if needed.
                            # For instance, during transfers between a Windows system (which adds CTRL-M to the end of each line of text)
                            # and a UNIX system (which doesn't), an ascii-mode transfer removes or adds those characters as needed.

help                        # gives a list of all commands; help ftp_cmd gives a one-line summary of the command ftp_cmd

# get file_name     Copies the file file_name from the remote computer to your local computer.
                            # If you give a second argument, the local copy will have that name.
get some_file               # makes a local copy of a remote file
get rose1 rose1.gif         # makes a local copy of rose1 and calls it rose1.gif

# mget file_names   Copies the named files (you can use wildcards) from remote to local
                            # multiple get, asking each time if you want it, Ctrl+C or delete to stop mget
mget ru*                    # makes a local copy of all files starting with ru

prompt                      # a "toggle" command that turns prompting on or off during transfers with the mget and mput commands
mget 01x2*                  # prompting is now off so no confirmation will be asked at each transfer

# put file_name     Copies the file file_name from your local computer to the remote computer.
                            # If you give a second argument, the remote copy will have that name.
put another_file            # makes a remote copy of a local file
put my_file                 # makes a remote copy of the local file my_file with the same name
put my_file new_name        # makes a remote copy of the local file my_file and calls it new_name

# mput file_names   Copies the named files (you can use wildcards) from local to remote
mput uu*                    # makes a remote copy of each local file starting with uu

dir                         # lists the files in the current directory (similar to the shell's ls)
cd temp                     # same as the shell's cd command
cdup                        # changes to the next higher directory
lcd                         # (local change directory) to change the working directory on the local machine
del some_file               # to delete some_file
mdelete *avi                # works just like mput and mget
mkdir newdir                # same as the shell's command

quit                        # ends the ftp session and takes you back to a shell prompt
