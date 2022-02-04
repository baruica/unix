#!/bin/sh

# script qui produit une liste de tous les fichiers qui sont des scripts du Bourne Shell (sh) dans le r�pertoire courant

REP=$(ls)
echo "Scripts :\c"

for FICHIER in $REP
do
	if [ ! -d $FICHIER ]			# pas un r�pertoire
	then
		if [ "$(head -1 $FICHIER | grep '^#!/bin/sh')" ]
		then
			echo " $FICHIER\c"
		fi
	fi
done

echo "."
