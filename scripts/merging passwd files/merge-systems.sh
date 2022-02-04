#!/bin/sh

# we use tee to save the result of the sort in a file called merge1, and simultaneously print it on standard output
sort u1.passwd u2.passwd | tee merge1
# abe:x:105:10:Honest Abe Lincoln:/home/abe:/bin/bash
# adm:x:3:4:adm:/var/adm:/sbin/nologin
# adm:x:3:4:adm:/var/adm:/sbin/nologin
# ben:x:201:10:Ben Franklin:/home/ben:/bin/bash
# ben:x:301:10:Ben Franklin:/home/ben:/bin/bash
# betsy:x:1110:10:Betsy Ross:/home/betsy:/bin/bash
# bin:x:1:1:bin:/bin:/sbin/nologin
# bin:x:1:1:bin:/bin:/sbin/nologin
# camus:x:112:10:Albert Camus:/home/camus:/bin/bash
# daemon:x:2:2:daemon:/sbin:/sbin/nologin
# daemon:x:2:2:daemon:/sbin:/sbin/nologin
# dorothy:x:110:10:Dorothy Gale:/home/dorothy:/bin/bash
# george:x:1100:10:George Washington:/home/george:/bin/bash
# jhancock:x:200:10:John Hancock:/home/jhancock:/bin/bash
# jhancock:x:300:10:John Hancock:/home/jhancock:/bin/bash
# root:x:0:0:root:/root:/bin/bash
# root:x:0:0:root:/root:/bin/bash
# tj:x:105:10:Thomas Jefferson:/home/tj:/bin/bash
# tolstoy:x:2076:10:Leo Tolstoy:/home/tolstoy:/bin/bash
# toto:x:110:10:Toto Gale:/home/toto:/bin/bash

# separates the merged file into 3 new files: dupusers, dupids and unique1
awk -f splitout.awk merge1

# Now that we have separated the users by categories, the next task is to create a list of all the UID numbers in use:
awk -F: '{ print $3 }' merge1 | sort -n -u > unique-ids

# We can verify that we have only the unique UID numbers by counting lines in merge1 and unique-ids:
wc -l merge1 unique-ids
#     20 merge1
#     14 unique-ids
#     34 total

# The next step is to write a program that produces unused UIDs.
# By default, the program reads a sorted list of in-use UID numbers and prints the first available UID number.
# However, since we'll be working with multiple users, we'll want it to generate a batch of unused UIDs.
# This is done with the -c option, which provides a count of UIDs to generate.

# We now have to process the dupusers and dupids files.
# The output file lists the username, old UID and new UID numbers, separated by whitespace, one record per line, for further processing.
# For dupusers, the processing is pretty straightforward: the first entry encountered will be the old UID, and the next one will be the new chosen UID.
# (In other words, we arbitrarily decide to use the second, larger UID for all of the user's files.)
# At the same time, we can generate the final /etc/passwd records for the users listed in both files.
rm -f old-new-list

old_ifs=$IFS
IFS=:
while read user pass uid gid fullname homedir shell1
do
	if read user2 pass2 uid2 gid2 fullname2 homedir2 shell2
	then
		if [ "$user" = "$user2" ]
		then
			printf "%s\t%s\t%s\n" $user $uid $uid2 >> old-new-list
			echo "$user:$pass:$uid2:$gid:$fullname:$homedir:$shell1"
		else
			echo $0: out of sync: $user and $user2 >&2
			exit 1
		fi
	else
		echo $0: no duplicate for $user >&2
		exit 1
	fi
done < dupusers > unique2
IFS=$old_ifs


# Similar code applies for the users for whom the UID numbers are the same but the username is different.
# Here too, we opt for simplicity; we give all such users a brand-new, unused UID number.
count=$(wc -l < dupids)							# Total duplicate IDs

# In order to have all the new UID numbers handy, we place them into the positional parameters with set and a command substitution.
set -- $(newuids.sh -c $count unique-ids)		# This is a hack, it'd be better if POSIX sh had arrays:

IFS=:
while read user pass uid gid fullname homedir shel
do
	newuid=$1									# each new UID is retrieved inside the loop by assigning from $1
	shift										# the next one is put in place with a shift

	echo "$user:$pass:$newuid:$gid:$fullname:$homedir:$shel"

	printf "%s\t%s\t%s\n" $user $uid $newuid >> old-new-list
done < dupids > unique3
IFS=$old_ifs


# we have 3 new output files
cat unique2										# those who had 2 UIDs
# ben:x:301:10:Ben Franklin:/home/ben:/bin/bash
# jhancock:x:300:10:John Hancock:/home/jhancock:/bin/bash

cat unique3										# those who get new UIDs
# abe:x:4:10:Honest Abe Lincoln:/home/abe:/bin/bash
# tj:x:5:10:Thomas Jefferson:/home/tj:/bin/bash
# dorothy:x:6:10:Dorothy Gale:/home/dorothy:/bin/bash
# toto:x:7:10:Toto Gale:/home/toto:/bin/bash

cat old-new-list								# list of user-old-new triples
# ben             201     301
# jhancock        200     300
# abe             105     4
# tj              105     5
# dorothy         110     6
# toto            110     7

# The final password file is created by merging the 3 unique? files.
# While cat would do the trick, it'd be nice to merge them in UID order:
sort -k 3 -t : -n unique[123] > final.password
# The wildcard unique[123] expands to the 3 filenames unique1, unique2 and unique3.

# Here is the final, sorted result:
cat final.password
# root:x:0:0:root:/root:/bin/bash
# bin:x:1:1:bin:/bin:/sbin/nologin
# daemon:x:2:2:daemon:/sbin:/sbin/nologin
# adm:x:3:4:adm:/var/adm:/sbin/nologin
# abe:x:4:10:Honest Abe Lincoln:/home/abe:/bin/bash
# tj:x:5:10:Thomas Jefferson:/home/tj:/bin/bash
# dorothy:x:6:10:Dorothy Gale:/home/dorothy:/bin/bash
# toto:x:7:10:Toto Gale:/home/toto:/bin/bash
# camus:x:112:10:Albert Camus:/home/camus:/bin/bash
# jhancock:x:300:10:John Hancock:/home/jhancock:/bin/bash
# ben:x:301:10:Ben Franklin:/home/ben:/bin/bash
# george:x:1100:10:George Washington:/home/george:/bin/bash
# betsy:x:1110:10:Betsy Ross:/home/betsy:/bin/bash
# tolstoy:x:2076:10:Leo Tolstoy:/home/tolstoy:/bin/bash


#
#	changing file ownership
#
while read user old new
do
	cd /home/$user								# change to user's directory
	chown -R $new .								# recursively change ownership
done < old-new-list
# The idea is to change to the user's home directory and recursively chown everything to the new UID number.
# However, this isn't enough.
# It's possible for users to have files in places outside their home directory.

# For example, consider 2 users, ben and jhancock, working on a joint project in /home/ben/declaration:
cd /home/ben/declaration
ls -l draft*
# -rw-r--r--    1 ben       fathers    2102 Jul  3 16:00 draft10
# -rw-r--r--    1 jhancock  fathers    2191 Jul  3 17:09 draft.final

# If we just did the recursive chown, both files would end up belonging to ben.

# Thus, the only way to be sure that all files are changed correctly everywhere is to do things the hard way, using find, starting from the root directory.
# The most obvious way to accomplish our goal is to run chown from find, like so:
find / -user $user -exec chown $newuid '{  }' \;

# However, using find this way is very expensive, since it creates a new chown process for every file or directory.
# Instead, we combine find and xargs:
find / -user $user -print | xargs chown $newuid				# regular version
find / -user $user -print0 | xargs --null chown $newuid		# if you have the GNU utilities
# This runs the same exhaustive file search, this time printing the name of every file and directory on the system belonging to whatever user is named by $user.
# This list is then piped to xargs, which runs chown on as many files as possible, changing the ownership to the UID in $newuid.

# Now, consider a case where the old-new-list file contained something like this:
# juser           25      10
# mrwizard        10      30

# There is an ordering problem here.
# If we change all of juser's files to have the UID 10 before we change the ownership on mrwizard's files, all of juser's files will end up being owned by mrwizard!
# This can be solved with the Unix tsort program, which does topological sorting.
# (Topological sorting imposes a complete ordering on partially ordered data.)
# For our purposes, we need to feed the data to tsort in the order new UID, old UID:
tsort << EOF
30 10
10 25
EOF
# 30
# 10
# 25

# The output tells us that 10 must be changed to 30 before 25 can be changed to 10.

# However, we have managed to avoid this problem entirely!
cat dupids
# abe:x:105:10:Honest Abe Lincoln:/home/abe:/bin/bash
# tj:x:105:10:Thomas Jefferson:/home/tj:/bin/bash
# dorothy:x:110:10:Dorothy Gale:/home/dorothy:/bin/bash
# toto:x:110:10:Toto Gale:/home/toto:/bin/bash

# We gave all of these users brand-new UIDs:
cat final.passwd
# ...
# abe:x:4:10:Honest Abe Lincoln:/home/abe:/bin/bash
# tj:x:5:10:Thomas Jefferson:/home/tj:/bin/bash
# dorothy:x:6:10:Dorothy Gale:/home/dorothy:/bin/bash
# toto:x:7:10:Toto Gale:/home/toto:/bin/bash
# ...

# By giving them UID numbers that we know are not in use anywhere, we don't have to worry about ordering our find commands.

# We have chosen to write the list of commands into a file, chown_files, that can be executed separately in the background.
while read user old new
do
	echo "find / -user $user -print | xargs chown $new"
done < old-new-list > chown_files

chmod +x chown_files

rm merge1 unique[123] dupusers dupids unique-ids old-new-list

cat chown_files
# find / -user ben -print | xargs chown 301
# find / -user jhancock -print | xargs chown 300
# find / -user abe -print | xargs chown 4
# find / -user tj -print | xargs chown 5
# find / -user dorothy -print | xargs chown 6
# find / -user toto -print | xargs chown 7


# We're safe, as long as we run these commands separately on each system, before we put the new /etc/passwd file in place on each system.
# Remember that originally, abe and dorothy were only on u1, and that tj and toto were only on u2.
# Thus, when chown-files runs on u1 with the original /etc/passwd in place, find will never find tj's or toto's files, since those users don't exist:
find / -user toto -print
# find: invalid argument 'toto' to '-user'
