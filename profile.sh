# sh uses the startup file .profile in your home directory.
# There may also be a system-wide startup file, e.g. /etc/profile.
# If so, the system-wide one will be sourced (executed) before your local one.

#
#   to add a new bin directory to use your own shell scripts as commands, the directory must be added to the search path
#
# to see what the current search path is
echo $path                          # csh
echo $PATH                          # sh, bash or ksh

# to set the path as the current path plus the bin subdirectory of your home directory
set path=($path ~/bin)              # csh
export PATH=$PATH:$HOME/bin         # sh, bash or ksh

# if the command still doesn't work, we have to tell UNIX to rebuild the list of commands it can access
hash scriptname
# or if that doesn't work either
rehash                              # csh

export PATH=/usr/bin:/usr/ucb:/usr/local/bin:.

PS1="{$(hostname) $(whoami)}"       # set the prompt, default is "$"

# functions
ls()
{
    /bin/ls -sbF "$@"
}

ll()
{
    ls -al "$@"
}

# Set the terminal type
stty erase ^H                       # set Control-H to be the erase key
eval $(tset -Q -s -m ':?xterm')     # prompt for the terminal type, assume xterm

umask 077
