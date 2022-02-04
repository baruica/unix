# When find produces a list of files, it is often useful to be able to supply that list as arguments to another command.
# Normally, this is done with the shell's command substitution feature, as in this example of searching for the symbol POSIX_OPEN_MAX in system header files:
grep POSIX_OPEN_MAX /dev/null $(find /usr/include -type f | sort)
# /usr/include/limits.h:#define   _POSIX_OPEN_MAX            16

# Whenever you write a program or a command that deals with a list of objects, you should make sure that it behaves properly if the list is empty.
# Because grep reads standard input when it is given no file arguments, we supplied an argument of /dev/null to ensure that it does not hang waiting for terminal input if find produces no output:
# that will not happen here, but it is good to develop defensive programming habits.

# The output from the substituted command can sometimes be lengthy, with the result that a nasty kernel limit on the combined length of a command line and its environment variables is exceeded.
# When that happens, you'll see this instead:
grep POSIX_OPEN_MAX /dev/null $(find /usr/include -type f | sort)
# /usr/local/bin/grep: Argument list too long.

# That limit can be found with getconf:
getconf ARG_MAX             # get system configuration value of ARG_MAX
# 131072


# The solution to the ARG_MAX problem is provided by xargs:
# it takes a list of arguments on standard input, one per line, and feeds them in suitably sized groups (determined by the host's value of ARG_MAX) to another command given as arguments to xargs.
# Here is an example that eliminates the obnoxious "Argument list too long" error:
find /usr/include -type f | xargs grep POSIX_OPEN_MAX /dev/null
# /usr/include/bits/posix1_lim.h:#define  _POSIX_OPEN_MAX       16
# /usr/include/bits/posix1_lim.h:#define  _POSIX_FD_SETSIZE     _POSIX_OPEN_MAX

# Here, the /dev/null argument ensures that grep always sees at least 2 file arguments, causing it to print the filename at the start of each reported match.
# If xargs gets no input filenames, it terminates silently without even invoking its argument program.

# GNU xargs has the -null option to handle the NUL-terminated filename lists produced by GNU find's -print0 option.
# xargs passes each such filename as a complete argument to the command that it runs, without danger of shell (mis)interpretation or newline confusion;
# it is then up to that command to handle its arguments sensibly.

# xargs has options to control where the arguments are substituted, and to limit the number of arguments passed to one invocation of the argument command.
# The GNU version can even run multiple argument processes in parallel.
# However, the simple form shown here suffices most of the time.
