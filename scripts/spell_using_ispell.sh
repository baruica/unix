#!/bin/sh

# Unix spell treats a first argument of '+file' as providing a personal spelling list.
# Let's do that too.

# This works by simply looking for a first argument that begins with +, saving it in a variable, stripping off the + character, and then prepending the -p option.
# This is then passed on to the ispell invocation.

mydict=
case $1 in
+?*)
	mydict=${1#+}			# strip off leading +
	mydict="-p $mydict"
	shift
;;
esac

cat "$@" | ispell -l $mydict | sort -u
