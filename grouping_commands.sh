#
#   (cmd1 ; cmd2)       A subshell is a group of commands enclosed in parentheses, the commands are run in a different process.
#
(date ; who ; pwd) > logfile

# first creates a tar archive of the current directory, sending it to standard output
# then the archive is passed on to the subshell commands, where it is extracted to /newdir
# the shell (script) running this pipeline has not changed its directory
tar -cf - . | (cd /newdir; tar -xpf -)


#
#   {cmd1 ; cmd2 ; }    A code block is conceptually similar to a subshell, but it does not create a new process.
#                       The closing brace must be put after a newline or after a semicolon.
#
cd /some/directory || {                             # Start code block
    echo could not change to /some/directory! >&2   # What went wrong
    echo you lose! >&2                              # Snide remark
    exit 1                                          # Terminate whole script because a code block shares state with the script
}                                                   # End of the block
