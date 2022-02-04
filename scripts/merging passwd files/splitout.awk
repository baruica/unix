#!/bin/awk -f

# separates the merged file into 3 new files: dupusers, dupids and unique1

#  $1   $2    $3  $4   $5         $6     $7
# user:passwd:uid:gid:long name:homedir:shell

# The program works by keeping a copy of each input line in 2 arrays.
# The first is indexed by username, the second by UID number.
# The first time a record is seen, the username and UID number have not been stored in either array, so a copy of the line is saved in both.
# When an exact duplicate record (the username and UID are identical) is seen, nothing is done with it, since we already have the information.
# If the username has been seen but the UID is new, both records are written to the dupusers file, and the copy of the first record in the uid array is removed, since we don't need it.
# Similar logic applies to records where the UID has been seen before but the username doesn't match.
# When the END rule is executed, all the records remaining in the name array represent unique records.
# They are written to the unique1 file, and then all the files are closed.
# remove_uid_by_name( ) and remove_name_by_uid( ) are awk functions.
# These 2 functions remove unneeded information from the uid and name arrays, respectively.


BEGIN { FS = ":" }

# if a duplicate appears, decide the disposition
{
	if ($1 in name)
	{
		if ($3 in uid)
			;								# name and uid identical, do nothing
		else
		{
			print name[$1] > "dupusers"
			print $0 > "dupusers"
			delete name[$1]

			remove_uid_by_name($1)			# remove saved entry with same name but different uid
		}
	}
	else if ($3 in uid)
	{
		# we know $1 is not in name, so save duplicate ID records
		print uid[$3] > "dupids"
		print $0 > "dupids"
		delete uid[$3]

		remove_name_by_uid($3)				# remove saved entry with same uid but different name
	}
	else
		name[$1] = uid[$3] = $0				# first time this record was seen
}

END
{
	for (i in name)
		print name[i] > "unique1"

	close("unique1")
	close("dupusers")
	close("dupids")
}

function remove_uid_by_name(n, i, f)
{
	for (i in uid)
	{
		split(uid[i], f, ":")
		if (f[1] == n)
		{
			delete uid[i]
			break
		}
	}
}

function remove_name_by_uid(id, i, f)
{
	for (i in name)
	{
		split(name[i], f, ":")
		if (f[3] == id)
		{
			delete name[i]
			break
		}
	}
}
