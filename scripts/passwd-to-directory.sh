#!/bin/sh

# Filter an input stream formatted like /etc/passwd, and output an office directory derived from that data.
#
# Usage:
#		passwd-to-directory < /etc/passwd > office-directory-file
#		ypcat passwd | passwd-to-directory > office-directory-file
#		niscat passwd.org_dir | passwd-to-directory > office-directory-file

umask 077										# Restrict temporary file access to just us

#
#	Unique temporary filenames
#
PERSON=/tmp/pd.key.person.$$					# $$ is the process number
OFFICE=/tmp/pd.key.office.$$
TELEPHONE=/tmp/pd.key.telephone.$$
USER=/tmp/pd.key.user.$$

#
#	When the job terminates, either normally or abnormally, we want the temporary files to be deleted.
#	So we trap the signals that interest us.
#
trap "exit 1"									HUP INT PIPE QUIT TERM			# abnormal
trap "rm -f $PERSON $OFFICE $TELEPHONE $USER"	EXIT							# normal

#
# jones:*:32713:899:Adrian W. Jones/OSD211/555-0123:/home/jones:/bin/ksh
# dorothy:*:123:30:Dorothy Gale/KNS321/555-0044:/home/dorothy:/bin/bash
# toto:*:1027:18:Toto Gale/KNS322/555-0045:/home/toto:/bin/tcsh
# ben:*:301:10:Ben Franklin/OSD212/555-0022:/home/ben:/bin/bash
# jhancock:*:1457:57:John Hancock/SIG435/555-0099:/home/jhancock:/bin/bash
# betsy:*:110:20:Betsy Ross/BMD17/555-0033:/home/betsy:/bin/ksh
# tj:*:60:33:Thomas Jefferson/BMD19/555-0095:/home/tj:/bin/bash
# george:*:692:42:George Washington/BST999/555-0001:/home/george:/bin/tcsh
#
awk -F: '{ print $1 ":" $5 }' > $USER			# jones:Adrian W. Jones/OSD211/555-0123

#
# The script uses = as the separator character for sed's s command, since both slashes and colons appear in the data
#

#
#	the key:person pair file
#
# first strip everything from the first slash to the end of the line
# then match 3 subpatterns:
#	^\([^:]*\)	the username field (e.g., jones)
#	\(.*\)?		text up to a space (e.g., Adrian? W.? ; the ? stands for a space character)
#	\([^? ]*\)	the remaining nonspace text in the record (e.g., Jones)
# so that the replacement text reorders the matches
#
sed	-e 's=/.*=  =' \															# jones:Adrian W. Jones
	-e 's=^\([^:]*\):\(.*\) \([^ ]*\)=\1:\3, \2=' < $USER | sort > $PERSON		# jones:Jones, Adrian W.

#
#	the key:office pair file
#
#	[^/]*/\([^/]*\)/.*$		text/subpattern2/text
#
sed -e 's=^\([^:]*\):[^/]*/\([^/]*\)/.*$=\1:\2=' < $USER | sort > $OFFICE		# jones:OSD211

#
#	the key:telephone pair file
#
#	[^/]*/[^/]*/\([^/]*\)	text/text/subpattern2
#
sed -e 's=^\([^:]*\):[^/]*/[^/]*/\([^/]*\)=\1:\2=' < $USER | sort > $TELEPHONE	# jones:555-0123

#
#	The join operations are done with a 5-stage pipeline, as follows:
#
# 1 Combine the personal information and the office location
# 2 Add the telephone number
# 3 Remove the key (kepp all fields from the 2nd onwards), since it's no longer needed
# 4 Re-sort the data. The data was previously sorted by login name, but now things need to be sorted by personal last name
# 5 reformat the output: print the 1st colon-separated field left-adjusted in a 39-character field, followed by a tab, the 2nd field, another tab and the 3rd field
#
join -t: $PERSON $OFFICE | 														# jones:Adrian W. Jones:OSD211
	join -t: - $TELEPHONE | 													# jones:Adrian W. Jones:OSD211:555-0123
		cut -d: -f 2- | 														# Adrian W. Jones:OSD211:555-0123
			sort -t: -k1,1 -k2,2 -k3,3 | 										# sort by last name
				awk -F: '{ printf("%-39s\t%s\t%s\n", $1, $2, $3) }'				# Jones, Adrian W.                    	OSD211	555-0123

# Franklin, Ben                       	OSD212	555-0022
# Gale, Dorothy                       	KNS321	555-0044
# Gale, Toto                          	KNS322	555-0045
# Hancock, John                       	SIG435	555-0099
# Jefferson, Thomas                   	BMD19	555-0095
# Jones, Adrian W.                    	OSD211	555-0123
# Ross, Betsy                         	BMD17	555-0033
# Washington, George                  	BST999	555-0001
