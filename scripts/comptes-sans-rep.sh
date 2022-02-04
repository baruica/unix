#!/bin/sh

clear
echo "Recherche des comptes sans repertoire"
COMPTES=$(awk -F: '{ print $1 }' /etc/passwd)		# récupère tous les noms de compte
for C in $COMPTES
do
	if [ ! -d "/home/$C" ]
	then
		echo "Compte sans repertoire : $C"
	fi
done
