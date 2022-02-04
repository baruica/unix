#!/bin/sh -

# newuids --- print one or more unused UIDs
#
# Usage:
#		newuids [-c N] list-of-ids-file
#		-c N        print N unused UIDs

# Most of the work is done in the inline awk program.
# The first part reads the list of UID numbers into the uidlist array.
# The for loop goes through the array.
# When it finds 2 elements whose values are not adjacent, it steps through and prints the values in between those elements.
# It decrements count each time so that no more than count UID numbers are printed.

count=1							# how many UIDs to print

# parse arguments, let sh issue diagnostics and exit if need be
while getopts "c:" opt
do
	case $opt in
	c)
		count=$OPTARG
	;;
	esac
done

shift $(($OPTIND - 1))

IDFILE=$1

awk -v count=$count '
	BEGIN
	{
		for (i = 1; getline id > 0; i++)
			uidlist[i] = id
		close(idlist)

		totalids = i

		for (i = 2; i <= totalids; i++)
		{
			if (uidlist[i-1] != uidlist[i])
			{
				for (j = uidlist[i-1] + 1; j < uidlist[i]; j++)
				{
					print j
					if (--count == 0)
					exit
				}
			}
		}
	}' $IDFILE
