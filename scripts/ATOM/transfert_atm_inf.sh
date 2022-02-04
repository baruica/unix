#!/bin/sh
#------------------------------------------------------------------------------------
# @(#) Application               : PRA_SIAM_V1.0
# @(#) Fonction                  : Transfert périodique des données de l'instance ATM_INF
# @(#)
# @(#) SCR-Version               : 2.00
# @(#) Auteur                    : P. FABRE
# @(#) Date de creation          : 02/06/05
# @(#) Commentaires              : Script de transfert par FTP d'un groupe de fichiers contenu dans un repertoire
#------------------------------------------------------------------------------------
# @(#) Modifications             : LBE - 09/11/05 - Ajout de la recuperation d'un fichier image de la source
# @(#)                                           - Generation des commandes FTP a partir du fichier image pour un controle plus stricte
# @(#)                                           - Ajout de variables pour completion des logs d'exploitation
# @(#)                                           - Message d'erreurs explicites pour une intervention rapide
#------------------------------------------------------------------------------------
# La procedure doit transférer un ensemble de fichiers du serveur de production pcyy8ato.pcy.edfgdf.fr
# vers le serveur de secours clay1ato.cla.edfgdf.fr
#
# Le transfert sera effectué par ftp sous le compte infa, par la sous-commande ftp mget.
# Le transfert doit etre programmé dans la crontab Unix de clay1ato.
# Un compte-rendu sur le transfert doit etre inséré  dans un fichier journal (log).
# Aucune vérification particulière sur le transfert n'est pas demandé.
#---------------------------------------------------------------------------------------------------
#
# Pas de lecture des variables utilisateur/mot de passe car un  fichier .netrc est utilisé pour le controle des droits
# Attention : le fichier .netrc doit etre impérativement dans le répertoire $HOME de l'utilisateur
# et il doit etre protégé en rw------- (600) pour que la connexion ftp ne fonctionne pas.
#
# vérification du fait que l'instance ATM_INF est arretée dans cette version de la procédure


## Variables
BASEDIR=/log/infa/ATM_INF                       ## Ajout
DAT=`date +%Y%m%d%H%M%S`
DATEREF=`date +%Y%m%d`                          ## Ajout
FTPREF1=${BASEDIR}/ftp_list.txt_${DATEREF}      ## Ajout
FTPREF2=${BASEDIR}/ftp_ATM_INF.txt_${DATEREF}   ## Ajout
LISTREF=${BASEDIR}/list_ATM_INF_${DATEREF}.txt  ## Ajout
LOGFILE=${BASEDIR}/transferts.log_${DATEREF}    ## Ajout
DETAIL1=${BASEDIR}/detai_ftp1.log_${DATEREF}    ## Ajout
DETAIL2=${BASEDIR}/detai_ftp2.log_${DATEREF}    ## Ajout
DETAIL3=${BASEDIR}/detai_file.log_${DATEREF}    ## Ajout
LIST1=${BASEDIR}/origref.txt_${DATEREF}         ## Ajout
LIST2=${BASEDIR}/destref.txt_${DATEREF}         ## Ajout


## Purge des fichiers datant de plus de 2 semaines
find ${BASEDIR} -type f -name '*.log_*' -mtime +15 -exec rm {} \;
find ${BASEDIR} -type f -name '*.txt_*' -mtime +15 -exec rm {} \;

## Test de presence de l'instance
cd ${BASEDIR}

# Effacement du pr cdent compte-rendu detaille
rm dernier_transfert.log_$DAT

DATEACTION=`date +%Y/%m/%d-%H:%M:%S`    ## Ajout

ps_count=`ps -ef | grep ATM_INF | grep -v 'grep' | grep -v 'pmserver'| wc -l | awk '{ print $1 }'`
if [ $ps_count -gt 1 ]
then
	echo "${DATEACTION} : Instance ATM_INF active - pas de transfert ftp\n" >${LOGFILE}
	exit 0
else
	echo "${DATEACTION} : Instance ATM_INF non presente : rafraichissement de PRA lancee\n" >${LOGFILE}
fi


## Rapatriement de la liste de reference pour les fichiers ATM_INF
## Si la liste de reference n'est pas disponible : suivre la procedure du DEX
## La procedure est rappele dans la log du script
## Si la liste de reference est ok : des get singuliers par fichier avec une comparaison des volumes est effectué

DATEACTION=`date +%Y/%m/%d-%H:%M:%S`    ## Ajout

echo "binary" >${FTPREF1}
echo "get ${LISTREF} ${LISTREF}" >>${FTPREF1}
echo "bye" >>${FTPREF1}

ftp -vi pcyy8ato.pcy.edfgdf.fr <${FTPREF1} >${DETAIL1}

RC=`grep "Transfer complete" ${DETAIL1} | wc -l`

if [[ ${RC} -eq 1 ]]
then
	echo "${DATEACTION} : FTP reussi pour ${LISTREF}\n" >>${LOGFILE}

	NBFILE=`cat ${LISTREF} | wc -l`

	echo "binary" >${FTPREF2}

	for i in `awk '{ print $1 }' ${LISTREF}`
	do
		echo "get $i $i" >>${FTPREF2}
	done

	echo "bye" >>${FTPREF2}

	DATEACTION=`date +%Y/%m/%d-%H:%M:%S`    ## Ajout

	echo "${DATEACTION} : Lancement du FTP pour recuperation des fichiers " >>${LOGFILE}

	ftp -vi pcyy8ato.pcy.edfgdf.fr <${FTPREF2} >${DETAIL2}

	DATEACTION=`date +%Y/%m/%d-%H:%M:%S`    ## Ajout

	RC=`grep "Transfer complete" ${DETAIL2} | wc -l`


	## Controle du ftp
	if [[ ${RC} = ${NBFILE} ]]
	then
		echo "${DATEACTION} : FTP fichier ATM_INF : termine sans erreur\n" >>${LOGFILE}
	else
		echo "${DATEACTION} : #ECHEC# FTP fichier ATM_INF : #ECHEC# \n" >>${LOGFILE}
		exit 98
	fi

	## Controle des fichiers recus par rapport aux originaux sur la taille
	find /appli/*/ATM_INF -type f -ls | awk '{ print $11" "$7 }' | sort -u >${LIST2}
	awk '{ print $1" "$2 }' ${LISTREF} | sort -u  >${LIST1}

	DATEACTION=`date +%Y/%m/%d-%H:%M:%S`    ## Ajout

	diff ${LIST1} ${LIST2} >${DETAIL3}

	if [[ $? -eq 0 ]]
	then
		echo "${DATEACTION} : Fichiers recus coherents \n" >>${LOGFILE}
	else
		## Si le fichier de ref n'est pas present l'ancienne technique est prise en compte
		echo "${DATEACTION} : #ECHEC# incoherence voir ${DETAIL3} #ECHEC# \n" >>${LOGFILE}
	fi
else
	echo "${DATEACTION} : #ECHEC# FTP non reussi pour ${LISTREF} #ECHEC# \n" >>${LOGFILE}
	echo "${DATEACTION} : La copie est en echec \n " >>${LOGFILE}
	echo "CONSIGNES DE RELANCE : " >>${LOGFILE}
	echo "    PCYY8ATO sous le compte infa " >>${LOGFILE}
	echo "    lancer /home/infa/scripts/liste_transfert_ATM_INF.ksh\n" >>${LOGFILE}
	echo "ENSUITE " >>${LOGFILE}
	echo "    PCYY3ATO sous le compte infa " >>${LOGFILE}
	echo "    lancer /home/infa/scripts/transfert_atm_inf.sh \n " >>${LOGFILE}
	echo "    Vérifier a nouveau la log de transfert\n" >>${LOGFILE}

	exit 99
fi

exit 0
