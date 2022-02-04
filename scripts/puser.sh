#!/bin/sh -

# Show a sorted list of users with their counts of active processes and process names,
# optionally limiting the display to a specified set of users (actually, egrep(1) username patterns).
#
# Usage:
#		puser [ user1 user2 ... ]

# albert		3	-tcsh
#				3	/etc/sshd
#				2	/bin/sh
#				1	/bin/ps
#				1	/usr/bin/ssh
#				1	xload
# daemon		1	/usr/lib/nfs/statd
# root			4	/etc/sshd
#				3	/usr/lib/ssh/sshd
#				3	/usr/sadm/lib/smc/bin/smcboot
#				2	/usr/lib/saf/ttymon
#				1	/etc/init
#				1	/usr/lib/autofs/automountd
#				1	/usr/lib/dmi/dmispd
# ...
# victoria		4	bash
#				2	/usr/bin/ssh
#				2	xterm

IFS='
 	'
PATH=/usr/local/bin:/usr/bin:/bin
export PATH

EGREPFLAGS=
# loop to collect the optional command-line arguments into the EGREPFLAGS variable,
# with the vertical-bar separators that indicate alternation to egrep
while [ $# -gt 0 ]
do
	if [ -z "$EGREPFLAGS" ]
	then
		EGREPFLAGS="$1"
	else
		EGREPFLAGS="$EGREPFLAGS|$1"
	fi
	shift
done

if [ -z "$EGREPFLAGS" ]
then
	EGREPFLAGS="."									# reassign it a match-anything pattern
else
	EGREPFLAGS="^ *($EGREPFLAGS) "					# augment the pattern to match only at the beginning of a line and to require a trailing space,
fi													# to prevent false matches of usernames with common prefixes, such as jon and jones

case "$(uname -s)" in
*BSD | Darwin)
	PSFLAGS="-a -e -o user,ucomm -x"
;;
*)
	PSFLAGS="-e -o user,comm"
;;
esac

ps $PSFLAGS |
#   USER COMMAND
#   root sched
#   root /etc/init
#   root /usr/lib/nfs/nfsd
# ...
#  jones dtfile
# daemon /usr/lib/nfs/statd
# ...
	sed -e 1d |										# deletes the initial header line
		EGREP_OPTIONS= egrep "$EGREPFLAGS" |		# Selects the usernames to be displayed. We clear the EGREP_OPTIONS environment variable to avoid conflicts in its interpretation by different GNU versions of egrep.
			sort -b -k1,1 -k2,2 |					# sorts the data by username and then by process
				uniq -c |							# attaches leading counts of duplicated lines and eliminates duplicates
					sort -b -k2,2 -k1nr,1 -k3,3 |	# sorts the data again, this time by username, then by descending count and finally by process name
						# awk formats the data into neat columns and removes repeated usernames
						awk '{
							user = (LAST == $2) ? " " : $2
							LAST = $2
							printf("%-15s\t%2d\t%s\n", user, $1, $3)
						}'
