# For a previously nonexistent file, here are equivalent ways of doing the same thing:
cat /dev/null > some-file                                   # copy empty file to some-file
printf "" > some-file                                       # print empty string to some-file

cat /dev/null >> some-file                                  # append empty file to some-file
printf "" >> some-file                                      # append empty string to some-file

touch some-file                                             # update timestamp of some-file

# However, if the file exists already, the first 2 truncate the file to a zero size,
# whereas the last 3 effectively do nothing more than update its last-modification time.
# Clearly, the safe way to do that job is with touch, because typing > when you meant >> would inadvertently destroy the file contents.


#
#   touch       can be used to create empty files
#
#   -a  to change the last-access time
#   -d  (GNU touch only) to avoid the POSIX requirement that states that the century only has 2 digits
#   -m  touch changes a file's last-modification time (default behavior)
#   -r  to copy the timestamp of a reference file (older systems did not have the -r option, but all current versions support it and POSIX requires it.)
#   -t  Takes a following argument of the form [[CC]YY]MMDDhhmm[.SS],
#       where the century, year within the century, and seconds are optional,
#       the month of the year is in the range 01 through 12,
#       the day of the month is in the range 01 through 31,
#       and the time zone is your local one.
#

# touch is sometimes used in shell scripts to create empty files: their existence and possibly their timestamps, but not their contents, are significant.
# A common example is a lock file to indicate that a program is already running, and that a second instance should not be started.
# Another use is to record a file timestamp for later comparison with other files.

touch -t 197607040000.00 US-bicentennial                    # create a birthday file
ls -l US-bicentennial                                       # list the file
# -rw-rw-r--  1 jones devel 0 Jul  4  1976 US-bicentennial

# touch also has the -r option:
touch -r US-bicentennial birthday                           # copy timestamp to the new birthday file
ls -l birthday                                              # list the new file
# -rw-rw-r--  1 jones devel 0 Jul  4  1976 birthday


# For the time-of-day clock, the Unix epoch starts at zero at 00:00:00 UTC on January 1, 1970.
# Most current systems have a signed 32-bit time-of-day counter that increments once a second, and allows representation of dates from late 1901 to early 2038; when the timer overflows in 2038, it will wrap back to 1901.
# Fortunately, some recent systems have switched to a 64-bit counter: even with microsecond granularity, it can span more than a half-million years!

touch -t 178907140000.00 first-Bastille-day                 # create a file for the French Republic
# touch: invalid date format '178907140000.00'                a 32-bit counter is clearly inadequate

touch -t 178907140000.00 first-Bastille-day                 # try again on system with 64-bit counter
ls -l first-Bastille-day                                    # it worked
# -rw-rw-r--  1 jones devel 0 1789-07-14 00:00 first-Bastille-day

# Future dates on systems with 64-bit time-of-day clocks may still be artificially restricted by touch,
# but that is just a software limit imposed by the shortsighted POSIX requirement that the century have 2 digits:
touch -t 999912312359.59 end-of-9999                        # this works
ls -l end-of-9999
# -rw-rw-r--  1 jones devel 0 9999-12-31 23:59 end-of-9999

touch -t 1000001010000.00 start-of-10000                    # this fails
# touch: invalid date format '1000001010000.00'

# Fortunately, GNU touch provides another option that avoids the POSIX restriction:
touch -d '10000000-01-01 00:00:00' start-of-10000000        # into the next millionenium!
ls -l start-of-10000000
# -rw-rw-r--  1 jones devel 0 10000000-01-01 00:00 start-of-10000000
