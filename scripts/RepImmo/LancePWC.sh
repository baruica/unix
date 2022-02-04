#! /bin/sh -

typeset svRepCur
typeset -i nvCodeRetour

# Lancement du Workflow en parametre
if [ ! -r "/home/$(whoami)/.profile" ]
then
	echo "$(date +%y%m%d) $(date +%T) !!! Problème de chargement: fichier profile $(whoami) introuvable"
	exit 2
fi
. /home/$(whoami)/.profile

svRepCur=$(pwd)

cd $INFACMD
$INFACMD/pmcmd startworkflow -sv $PWC_SERVICE -d $PWC_DOMAIN -u $PWC_USER -p $PWC_PASSWORD -wait $1
nvCodeRetour=$?

cd $svRepCur

exit $nvCodeRetour
