# While pipes eliminate much of the need for them, temporary files are still sometimes required.
# Unlike some operating systems, Unix has no notion of scratch files that are somehow magically removed when they are no longer needed.
# Instead, it provides two special directories, /tmp and /var/tmp (/usr/tmp on older systems),
# where such files are normally stored so that they do not clutter ordinary directories in the event that they are not cleaned up.
# On most systems, /tmp is cleared when the system boots, but /var/tmp must survive reboots because some text editors place backup files there to allow data recovery after a system crash.


# Shared directories, or multiple running instances of the same program, bring the possibility of filename collisions.
# The traditional solution in shell scripts is to use the process ID, available in the shell variable $$, to form part of temporary filenames.
# To deal with the possibility of a full temporary filesystem, it is also conventional to allow the directory name to be overridden by an environment variable, traditionally called TMPDIR.
# In addition, you should use a trap command to request deletion of temporary files on job completion.

# a common shell-script preamble is:
umask 077                                                       # remove access for all but user
TMPFILE=${TMPDIR-/tmp}/myprog.$$                                # generate a temporary filename
trap 'rm -f $TMPFILE' EXIT                                      # remove temporary file on completion


# Filenames like /tmp/myprog.$$ have a problem: they are readily guessable.
# An attacker only needs to list the directory a few times while the target is running to figure out what temporary files are being used.
# By creating a suitably named file in advance, the attacker might be able to get your program to fail, or to read forged data, or to set the file permissions to allow the attacker to read the file.

# To deal with this security issue, filenames must be unpredictable.
# BSD and GNU/Linux systems have the mktemp command for creating names of temporary files that are hard to guess.
# While the underlying mktemp( ) library call is standardized by POSIX, the mktemp command is not.
# If your system lacks mktemp, install a portable version derived from OpenBSD.


#
#   mktemp      takes an optional filename template containing a string of trailing X characters, preferably at least a dozen of them.
#               It replaces them with an alphanumeric string derived from random numbers and the process ID,
#               creates the file with no access for group and other, and prints the filename on standard output.
#
#   -d  requests the creation of a temporary directory
#   -t  mktemp then uses whatever directory the environment variable TMPDIR specifies, or else /tmp
#
TMPFILE=$(mktemp /tmp/myprog.XXXXXXXXXXXX) || exit 1            # make unique temporary file
ls -l $TMPFILE                                                  # list the temporary file
# -rw-------  1 jones devel 0 Mar 17 07:30 /tmp/myprog.hJmNZbq25727

# The process ID, 25727, is visible at the end of the filename, but the rest of the suffix is unpredictable.
# The conditional exit command ensures that we terminate immediately with an error if the temporary file cannot be created, or if mktemp is not available.

# The newest version of mktemp allows the template to be omitted; it then uses a default of /tmp/tmp.XXXXXXXXXX.
# However, older versions require the template, so avoid that shortcut in your shell scripts.


# To eliminate the need to hardcode a directory name, use the -t option:
SCRATCHDIR=$(mktemp -d -t myprog.XXXXXXXXXXXX) || exit 1        # create temporary directory
ls -lFd $SCRATCHDIR                                             # list the directory itself
# drwx------  2 jones devel 512 Mar 17 07:38 /tmp/myprog.HStsWoEi6373/

# Since that directory has no access for group and other, an attacker cannot even find out the names of files that you subsequently put there, but still might be able to guess them if your script is publicly readable.
# However, because the directory is not listable, an unprivileged attacker cannot confirm the guesses.


# Some systems provide 2 random pseudodevices: /dev/random and /dev/urandom.
# These are currently available only on BSD systems, GNU/Linux, IBM AIX 5.2, Mac OS X and Sun Solaris 9, with 2 third-party implementations and retrofits available for earlier Solaris versions.
# These devices serve as never-empty streams of random bytes: such a data source is needed in many cryptographic and security applications.
# The distinction between the 2 devices is that /dev/random may block until sufficient randomness has been gathered from the system so that it can guarantee high-quality random data.
# By contrast, /dev/urandom never blocks, but then its data may be somewhat less random (but still good enough to pass many statistical tests of randomness).
# Because these devices are shared resources, it is easy to mount a denial-of-service attack against the blocking /dev/random pseudodevice simply by reading it and discarding the data.

time dd count=1 ibs=1024 if=/dev/random > /dev/null             # read 1KB of random bytes
# 0+1 records in
# 0+1 records out
# 0.000u 0.020s 0:04.62 0.4%      0+0k 0+0io 86pf+0w

time dd count=1024 ibs=1024 if=/dev/urandom > /dev/null         # read 1MB of random bytes
# 1024+0 records in
# 2048+0 records out
# 0.000u 0.660s 0:00.66 100.0%    0+0k 0+0io 86pf+0w

# The more that /dev/random is read, the slower it responds.

# These pseudodevices provide an alternative to mktemp for generating hard-to-guess temporary filenames:
TMPFILE=/tmp/secret.$(cat /dev/urandom | od -x | tr -d ' ' | head -n 1)
echo $TMPFILE                                                   # show the random filename
# /tmp/secret.00000003024d462705664c043c04410e570492e

# we read a binary byte stream from /dev/urandom, convert it to hexadecimal with od, strip spaces with tr and stop after collecting one line.
# Since od converts 16 bytes per output line, this gives us a sample of 16 x 8 = 128 random bits for the suffix, or 2^128possible suffixes.
# If that filename is created in a directory that is listable only by its owner, there is effectively no chance of its being guessed by an attacker.
