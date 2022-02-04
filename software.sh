#
#   RUNNING OTHER PEOPLE'S PROGRAMS
#
~tracy/bin/pornotopia                               # csh
/usr/tracy/bin/pornotopia                           # sh, bash, ksh

# creates a link from the home directory
ln ~tracy/bin/pornotopia bin/pornotopia

# using a symbolic link if the accounts are on different file systems or disks
ln -s ~tracy/bin/pornotopia bin/pornotopia


#
#   Aliases (bash, ksh and csh)
#
alias dobudget='/usr/tracy/bin/pornotopia'          # bash and ksh
alias dobudget '/usr/tracy/bin/pornotopia'          # csh
alias sortnprint='sort -r bigfile | pr -2 | lpr'
alias mroe=more
unalias mroe                                        # deletes mroe


#
#   whence      prints either the pathname of a command if the command is a script or executable program,
#               or the command's name if it is anything else
#
#   -v  to get the exact source of a command
#
whence cd
# cd

whence -v cd
# cd is a shell builtin

whence function
# function

whence -v function
# function is a keyword

whence man
# /usr/bin/man

whence -v man
# man is /usr/bin/man

whence ll
# ls -l

whence -v ll
# ll is an alias for ls -l


#
#   PACKAGED FILES
#
compress myfile
uncompress myfile.Z

gzip myfile
gunzip myfile.gz

#
#   tar         (tape archive)
#
#   -c  create
#   -f  file (usually followed by the file)
#   -v  verbose mode
#   -x  extract
#
tar xvf really_cool_ed_unix_v4.3.tar                # extracts in verbose mode the file

# to make a tape backup in Linux (/dev/rft0 being the tape unit)
tar cvf /dev/rft0 *                                 # creates a tar file containing all the files in your directory, in verbose mode

tar xvf /dev/rft0 "somedir/*"                       # to restore a tape archive
