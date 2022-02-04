#!/bin/sh

# Unix spell treats a first argument of '+file' as providing a personal spelling list.
# Let's do that too.

# aspell wants its dictionaries to be in a compiled binary format.
# To use aspell, we instead resort to the fgrep program, which can match multiple strings provided in a file.
# We add the -v option, which causes fgrep to print lines that do not match.

mydict=cat
case $1 in
+?*)
	mydict=${1#+}					# strip off leading +
	mydict="fgrep -v -f $mydict"
	shift
;;
esac

# aspell -l mimics the standard Unix spell program, roughly.
cat "$@" | aspell -l --mode=none | sort -u | eval $mydict
