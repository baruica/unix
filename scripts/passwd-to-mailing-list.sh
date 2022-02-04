#!/bin/sh

# passwd-to-mailing-list
#
# Generate a mailing list of all users of a particular shell.
#
# Usage:
#		passwd-to-mailing-list < /etc/passwd
#		ypcat passwd | passwd-to-mailing-list
#		niscat passwd.org_dir | passwd-to-mailing-list

rm -f /tmp/*.mailing-list																# remove previous lists

while IFS=: read user password uid gid name home the_shell								# Read from standard input
do
	the_shell=${the_shell:-/bin/sh}														# Empty the_shell field means /bin/sh
	# substitutes the leading / character and each subsequent / to a hyphen
	myfile="/tmp/$(echo $the_shell | sed -e 's;^/;;' -e 's;/;-;g').mailing-list"		# /tmp/bin-bash.mailing-list
	echo $user, >> $myfile						# produces a comma separated file containing the list of users to mail
done
