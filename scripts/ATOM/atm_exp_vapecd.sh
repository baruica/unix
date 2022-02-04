#!/bin/ksh
#@(#)#####################################################
#@(#)   ATOM - Interface VAPECD / GTM
#@(#)#####################################################
#@(#)
#@(#) Guillaume AUDE - SI Gestion - ATOM
#@(#) 03-03-2004 - v 2.2.1
#@(#)
#@(#) Envoi du fichier VAPECD/compta.csv au GSE.
#@(#)
#@(#) !!! Ce script est lancé par la CRONTAB à 12h30
#@(#)
#@(#)#####################################################

# unicité du lancement
sleep 2
UNI=$(ps -ef | grep -c "$0")
UNI=$(expr ${UNI} - 1)
if [ ${UNI} -gt 1 ]
then
	echo "$(date +%d/%m/%y) $(date +%T) - $0 est déjà en cours d'execution"
	exit ${UNI}
else
	echo "###############"
	echo "$(date +%d/%m/%y) $(date +%T) : Démarrage du script"
	echo "##########"
fi

# Execution du .profile de l'utilisateur courant pour recuperer les variables d'environnement
if [ ! -r "/home/$(whoami)/.profile" ]
then
	echo "$(date +%y%m%d) $(date +%T) !!! Problème de chargement: fichier profile $(whoami) introuvable"
	exit 4
fi
. /home/$(whoami)/.profile


# DECLARATION DE VARIABLES
DATE=$(date +%y%m%d)

LCHEM="${INTERFACES}/import/VAPECD"			# chemin du fichier à transferer
# nom des fichiers à detecter
LFIC="compta.csv"

# Recette ATOM
#DPART="PCY3ATOI"
#DRAPPL="FII0001AATM01010"
# Dev GSE
#DRAPPL="F4C0000GGSEJOURV"
# Prod GSE
DRAPPL="F4C0000MGSEJOURX"


### PRESENCE DU FICHIER A TRANSFERER
if [ ! -r "${LCHEM}/${LFIC}" ]
then
	echo "##########"
	echo "$(date +%d/%m/%y) $(date +%T) : Fin script anormale car ${LCHEM}/${LFIC} est absent"
	echo "###############"
	exit 2
fi

### ARCHIVAGE DU FICHIER compta.csv
echo "$(date +%T) : création du répertoire ${LCHEM}/${DATE}"
[ ! -d "${LCHEM}/${DATE}" ] && mkdir -m 777 ${LCHEM}/${DATE}
HEURE=$(date +%H%M)
echo "$(date +%T) : création du répertoire ${LCHEM}/${DATE}/${HEURE}"
[ ! -d "${LCHEM}/${DATE}/${HEURE}" ] && mkdir -m 777 ${LCHEM}/${DATE}/${HEURE}

mv ${LCHEM}/${LFIC} ${LCHEM}/${DATE}
if [ $? -ne 0 ]
then
	echo "$(date +%T) : !!! Problème de déplacement du fichier ${LCHEM}/${LFIC} dans ${LCHEM}/${DATE}"
	exit 5
fi
chmod 777 ${LCHEM}/${DATE}/${LFIC}

cp ${LCHEM}/${DATE}/${LFIC} ${LCHEM}/${DATE}/${HEURE}
if [ $? -ne 0 ]
then
	echo "$(date +%T) : !!! Problème de copie du fichier ${LCHEM}/${DATE}/${LFIC} dans ${LCHEM}/${DATE}/${HEURE}"
	exit 5
fi
chmod 775 ${LCHEM}/${DATE}/${HEURE}/${LFIC}


IDENVOI="AT$(date +%H%M%S)"

# envoi CFT
CFTUTIL SEND IDF=${CFT_IDF_VAPECD}, PART=${CFT_PART_GSE_A}, FNAME=${LCHEM}/${DATE}/${LFIC}, PARM=CPTDIFFSEL, RAPPL=${DRAPPL}, SAPPL=${CFT_IDF_VAPECD}, SUSER=${IDENVOI}${CFT_IDF_VAPECD}, FRECFM=F, FLRECL=301, NIDF=${CFT_NIDF_MSG_NON}

echo "$(date +%T) : envoi du fichier realise avec les elements suivants"
echo "IDF=${CFT_IDF_VAPECD}, PART=${CFT_PART_GSE_A}, FNAME=${LCHEM}/${DATE}/${LFIC}, PARM=CPTDIFFSEL, RAPPL=${DRAPPL}, SAPPL=${CFT_IDF_VAPECD}, SUSER=${IDENVOI}${CFT_IDF_VAPECD}, FRECFM=F, FLRECL=301, NIDF=${CFT_NIDF_MSG_NON}"

### EFFACEMENT DES .dat
rm -f ${LCHEM}/*.dat
if [ $? -ne 0 ]
then
	echo "$(date +%T) : !!! Erreur lors de la suppression des fichiers ${LCHEM}/*.dat"
else
	echo "$(date +%T) : suppression des fichiers ${LCHEM}/*.dat"
fi

echo "##########"
echo "$(date +%d/%m/%y) $(date +%T) : Fin normale du script"
echo "###############"

exit 0
