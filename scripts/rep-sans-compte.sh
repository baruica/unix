#!/bin/sh

clear
echo "Recherche des repertoires sans compte"
REP=$(ls /home)
for R in $REP
do
	if [ ! "$(grep "^$R" /etc/passwd)" ]
	then
		echo "Repertoire sans compte : $R"
	fi
done
