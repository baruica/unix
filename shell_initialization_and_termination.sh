# In order to support user customization, shells read certain specified files on startup, and for some shells, also on termination.
# Each shell has different conventions.
# If you write shell scripts that are intended to be used by others, you cannot rely on startup customizations.

# Shell behavior depends on whether it is a login shell.
# When you sit at a terminal and enter a username and password in response to a prompt from the computer, you get a login shell.
# Similarly, when you use ssh hostname, you get a login shell.

# However, if you run a shell by name,
# or implicitly as the command interpreter named in the initial #! line in a script,
# or create a new workstation terminal window,
# or run a command in a remote shell with, for example, ssh hostname command-then that shell is not a login shell.

# The shell determines whether it is a login shell by examining the value of $0.
# If the value begins with a hyphen, then the shell is a login shell; otherwise, it is not.
echo $0                 # display shell name
# -ksh                    this is a login shell

# The hyphen does not imply that there is a file named /bin/-ksh.
# It just means that the parent process set the zeroth argument that way when it ran the exec() system call to start the shell.


#
#   sh startup
#
# When it is a login shell, the Bourne shell does the equivalent of:
[ -r /etc/profile ] && . /etc/profile           # try to read /etc/profile
[ -r $HOME/.profile ] && . $HOME/.profile       # try to read $HOME/.profile
# That is, it potentially reads 2 startup files in the context of the current shell, but does not require that either exist.
# Notice that the home-directory file is a dot file (hidden), but the system-wide one in /etc is not.

# The system shell-startup file created by local management might look something like this:
cat /etc/profile                                # show system shell startup file
PATH=/usr/local/bin:$PATH                       # add /usr/local/bin to start of system path
export PATH                                     # make it known to child processes
umask 022                                       # remove write permission for group and other

# A typical $HOME/.profile file could then modify the local system's default login environment with commands like this:
cat $HOME/.profile                              # show personal shell startup file
PATH=$PATH:$HOME/bin                            # add personal bin directory to end of system path
export PATH                                     # make it known to child processes
alias rm='rm -i'                                # ask for confirmation of file deletions
umask 077                                       # remove all access for group and other

# When a child shell is subsequently created, it inherits the parent's environment strings, including PATH.
# It also inherits the current working directory and the current file-permission mask, both of which are recorded in the process-specific data inside the kernel.
# However, it does not inherit other customizations, such as command abbreviations made with the alias command, or variables that were not exported.

# The Bourne shell provides no way to automatically read a startup file when the shell is not a login shell, so aliases are of limited use.
# Since remote command execution also does not create a login shell, you cannot even expect PATH to be set to your accustomed value: it may be as simple as /bin:/usr/bin.

# On exit, the Bourne shell does not read a standard termination file, but you can set a trap to make it do so.
# For example, if you put this statement in $HOME/.profile:
trap '. $HOME/.logout' EXIT
# then the $HOME/.logout script can do any cleanup actions that you need, such as wiping the screen with the clear command.
# However, since there can be only one trap for any given signal, the trap will be lost if it is overridden later in the session:
# there is thus no way to guarantee that a termination script will be executed.
# For nonlogin shells, each script or session that needs exit handling has to set an explicit EXIT trap, and that too cannot be guaranteed to be in effect on exit.

# These limitations, the lack of support for command history, and in some older implementations, job control, make the Bourne shell undesirable as a login shell for most interactive users.
# On most commercial Unix systems, it therefore tends to be chosen just for root and other system-administration accounts that are used interactively only for brief sessions.
# Nevertheless, the Bourne shell is the shell expected by portable shell scripts.


#
#   ksh startup
#
# Like the Bourne shell, the Korn shell, ksh, reads /etc/profile and $HOME/.profile, if they exist and are readable, when it starts as a login shell.

# When ksh93 starts as an interactive shell (either login or nonlogin), it then does the equivalent of:
[ -n "$ENV" ] && eval . "$ENV"                  # try to read $ENV

# ksh88 does the $ENV processing unconditionally, for all shells.

# The eval command first evaluates its arguments so that any variables there are expanded, and then executes the resulting string as a command.
# The effect is that the file named by ENV is read and executed in the context of the current shell.
# The PATH directories are not searched for the file, so ENV should generally specify an absolute pathname.

# The ENV feature solves the problem that the Bourne shell has in setting up private aliases for child shell sessions.
# However, it does not solve the customization problem for nonlogin remote sessions: their shells never read any initialization files.

# Like the Bourne shell, a noninteractive ksh93 shell does not read any startup scripts, nor does it read any termination scripts just before it exits,
# unless you issue a suitable trap command. (even a noninteractive ksh88 reads and executes the $ENV file at startup)


#
#   bash startup and termination
#
# While GNU bash is often used as a login shell in its own right, it can also masquerade as the Bourne shell when it is invoked with the name sh.
# On GNU/Linux systems, /bin/sh is invariably a symbolic link to /bin/bash.

# When bash is a login shell, on startup it does the equivalent of:
[ -r /etc/profile ] && . /etc/profile           # try to read the system-wide file (the same as for the Bourne shell)
if [ -r $HOME/.bash_profile ]                   # try 3 more possibilities
then
    . $HOME/.bash_profile
elif [ -r $HOME/.bash_login ]                   # bash-specific initializations
then
    . $HOME/.bash_login
elif [ -r $HOME/.profile ]                      # bash-specific initializations
then
    . $HOME/.profile                            # otherwise, bash falls back to reading your personal Bourne-shell startup file
fi

# On exit, a bash login shell effectively does this:
[ -r $HOME/.bash_logout ] && . $HOME/.bash_logout           # try to read a termination script

# Unlike the Bourne shell, bash reads an initialization file on startup when it is an interactive nonlogin shell:
[ -r $HOME/.bashrc ] && . $HOME/.bashrc                     # try to read $HOME/.bashrc
# In this case, login-shell startup files are not read.

# When bash is used noninteractively, instead of reading a .bashrc file or login-shell startup files,
# it reads a file defined by the BASH_ENV variable:
[ -r "$BASH_ENV" ] && eval . "$BASH_ENV"                    # try to read BASH_ENV
# As with ksh, the PATH directories are not searched for this file.

# Notice the difference: the Korn shell's ENV variable is used only for nonlogin interactive shells,
# whereas bash's BASH_ENV is used only for noninteractive shells.

# To clarify the startup-file processing order, we fitted each of them with an echo command. A login session then looks like this:
login                                           # start a new login session
# login: bones
# Password:                                     # echo suppressed to hide password
# DEBUG: This is /etc/profile
# DEBUG: This is /home/bones/.bash_profile
exit                                            # terminate the session
# logout
# DEBUG: This is /home/bones/.bash_logout

# An interactive session invokes only a single file:
bash                                            # start an interactive session
# DEBUG: This is /home/bones/.bashrc
exit                                            # terminate the session
# exit

# A noninteractive session normally does not invoke any file:
echo pwd | bash                                 # run a command under bash
# /home/bones

# However, it will if the BASH_ENV value points to a startup file:
echo pwd | BASH_ENV=$HOME/.bashenv bash         # run a command under bash
# DEBUG: This is /home/bones/.bashenv
# /home/bones
