#!/bin/sh

# C compiler script with option processing

# initialize option-related variables
do_link=true
debug=""
link_libs="-l c"
exefile=""
opt=false

# process command-line options
while getopts ":cgl:o:O" opt			# arguments -l and -o will take options
do
	case $opt in
	c)
		do_link=false
	;;
	g)
		debug="-g"
	;;
	l)	# -l can be used more than once
		link_libs="$link_libs -l $OPTARG"
	;;
	o)
		exefile="-o $OPTARG"
	;;
	O)
		opt=true
	;;
	\?)
		echo 'usage: occ [-cgO] [-l lib] [-o file] files...'
		return 1
	;;
	esac
done
shift $(($OPTIND - 1))					# POSIX shell arithmetic substitution

# process the input files
objfiles=""
for filename in "$@"
do
	case $filename in
	*.c)
		objname=${filename%.c}.o
		ccom $debug $filename $objname
		if [[ $opt = true ]]
		then
			optimize $objname
		fi
	;;
	*.s)
		objname=${filename%.s}.o
		as $filename $objname
	;;
	*.o)
		objname=$filename
	;;
	*)
		echo "error: $filename is not a source or object file."
		return 1
	;;
	esac
	objfiles="$objfiles $objname"
done

if [[ $do_link = true ]]
then
	ld $exefile $link_libs $objfiles
fi
