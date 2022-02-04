#!/bin/sh -

# Find all files and directories, and groups of recently modified ones, in a directory tree, creating lists in FILES.* and DIRECTORIES.* at top level.
# filesdirectories requires GNU find for access to the -fprint option,
# which permits multiple output files to be created in one pass through the directory tree,
# producing a tenfold speedup for this script over a version that used multiple invocations of the original Unix find.
#
# Usage:
#		filesdirectories directory


# we reset the value of the input field separator at each execution of this script
# 3 character string consisting of newline, space and tab
IFS='
 	'

PATH=/usr/local/bin:/bin:/usr/bin				# to ensure that GNU find is found first for its -fprint option
export PATH

if [ $# -ne 1 ]									# check for the expected single argument, and otherwise,
then
	echo "Usage: $0 directory" >&2				# print a brief error message on standard error
	exit 1										# and exit with a nonzero status value
fi

umask 077										# ensure file privacy

TMP=${TMPDIR:-/tmp}								# allows the default temporary file directory to be overridden by the TMPDIR environment variable

# initialize TMPFILES to a list of temporary files that collect the output
# These output files contain the names of directories and files in the entire tree (*.all.*),
# as well as the names of those modified in the last day (*.last01.*), last 2 days (*.last02.*) and so on.
TMPFILES="	$TMP/DIRECTORIES.all.$$ $TMP/DIRECTORIES.all.$$.tmp
			$TMP/DIRECTORIES.last01.$$ $TMP/DIRECTORIES.last01.$$.tmp
			$TMP/DIRECTORIES.last02.$$ $TMP/DIRECTORIES.last02.$$.tmp
			$TMP/DIRECTORIES.last07.$$ $TMP/DIRECTORIES.last07.$$.tmp
			$TMP/DIRECTORIES.last14.$$ $TMP/DIRECTORIES.last14.$$.tmp
			$TMP/DIRECTORIES.last31.$$ $TMP/DIRECTORIES.last31.$$.tmp
			$TMP/FILES.all.$$ $TMP/FILES.all.$$.tmp
			$TMP/FILES.last01.$$ $TMP/FILES.last01.$$.tmp
			$TMP/FILES.last02.$$ $TMP/FILES.last02.$$.tmp
			$TMP/FILES.last07.$$ $TMP/FILES.last07.$$.tmp
			$TMP/FILES.last14.$$ $TMP/FILES.last14.$$.tmp
			$TMP/FILES.last31.$$ $TMP/FILES.last31.$$.tmp"

WD=$1											# saves the argument directory name for later use
cd $WD || exit 1								# then the script changes to that directory
# Changing the working directory before running find solves 2 problems:
#
#	If the argument is not a directory, or is but lacks the needed permissions, then the cd command fails and the script terminates immediately with a nonzero exit value.
#
#	If the argument is a symbolic link, cd follows the link to the real location.
#	find does not follow symbolic links unless given extra options, but there is no way to tell it to do so only for the top-level directory.
#	In practice, we do not want filesdirectories to follow links in the directory tree, although it is straightforward to add an option to do so.

# The trap commands ensure that the temporary files are removed when the script terminates:
trap 'exit 1'          HUP INT PIPE QUIT TERM
trap 'rm -f $TMPFILES' EXIT						# the exit status value is preserved across the EXIT trap


# The lines with the -name option match the names of the output files from a previous run,
# and the -true option causes them to be ignored so that they do not clutter the output reports:
find . \
		   -name DIRECTORIES.all -true \
		-o -name 'DIRECTORIES.last[0-9][0-9]' -true \
		-o -name FILES.all -true \
		-o -name 'FILES.last[0-9][0-9]' -true \
		-o -type f          -fprint $TMP/FILES.all.$$ \				# matches all ordinary files and the -fprint option writes their names to $TMP/FILES.all.$$
		# The next 5 lines select files modified in the last 31, 14, 7, 2 and 1 days (the -type f selector is still in effect),
		# and the -fprint option writes their names to the indicated temporary files:
		-a       -mtime -31 -fprint $TMP/FILES.last31.$$ \
		-a       -mtime -14 -fprint $TMP/FILES.last14.$$ \
		-a       -mtime  -7 -fprint $TMP/FILES.last07.$$ \
		-a       -mtime  -2 -fprint $TMP/FILES.last02.$$ \
		-a       -mtime  -1 -fprint $TMP/FILES.last01.$$ \
		# The tests are made in order from oldest to newest because each set of files is a subset of the previous ones, reducing the work at each step.
		# Thus, a 10-day-old file will pass the first 2 -mtime tests, but will fail the next 3, so it will be included only in the FILES.last31.$$ and FILES.last14.$$ files.
		-o -type d          -fprint $TMP/DIRECTORIES.all.$$ \		# matches directories, and the -fprint option writes their names to $TMP/DIRECTORIES.all.$$
		# The final 5 lines match subsets of directories (the -type d selector still applies) and write their names
		-a       -mtime -31 -fprint $TMP/DIRECTORIES.last31.$$ \
		-a       -mtime -14 -fprint $TMP/DIRECTORIES.last14.$$ \
		-a       -mtime  -7 -fprint $TMP/DIRECTORIES.last07.$$ \
		-a       -mtime  -2 -fprint $TMP/DIRECTORIES.last02.$$ \
		-a       -mtime  -1 -fprint $TMP/DIRECTORIES.last01.$$


# When the find command finishes, its preliminary reports are available in the temporary files, but they have not yet been sorted.
# The script then finishes the job with a loop over the report files:
for i in FILES.all FILES.last31 FILES.last14 FILES.last07 FILES.last02 FILES.last01
		DIRECTORIES.all DIRECTORIES.last31 DIRECTORIES.last14 DIRECTORIES.last07 DIRECTORIES.last02 DIRECTORIES.last01
do
	# sed replaces the prefix ./ in each report line with the user-specified directory name so that the output files contain full, rather than relative, pathnames
	# sort orders the results from sed into a temporary file named by the input filename suffixed with .tmp
	sed -e "s=^[.]/=$WD/=" -e "s=^[.]$=$WD=" $TMP/$i.$$ | LC_ALL=C sort > $TMP/$i.$$.tmp

	# cmp silently checks whether the report file differs from that of a previous run, and if so, replaces the old one
	cmp -s $TMP/$i.$$.tmp $i || mv $TMP/$i.$$.tmp $i
	# otherwise, the temporary file is left for cleanup by the trap handler
done
