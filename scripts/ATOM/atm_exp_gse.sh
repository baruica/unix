#!/bin/ksh
#@(#)#####################################################
#@(#)   ATOM - Interface GTM / GSE
#@(#)#####################################################
#@(#)
#@(#) Guillaume AUDE - SI Gestion - ATOM
#@(#) 03-03-2004 - v 2.2.1
#@(#)
#@(#) Transfert du fichier atmgse00.txt généré par GTM vers le GSE.
#@(#)
#@(#)#####################################################

# unicité du lancement
sleep 2
UNI=$(ps -ef | grep -c "$0")
UNI=$(expr $UNI - 1)
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


# VARIABLES
LCHEM="$INTERFACES/export/GSE"			# chemin du fichier à transferer
LSAV="atmgse.00"						# nom du fichier de sauvegarde
LSAV1="atmgse.01"						# nom du fichier de sauvegarde

LOGFILE="Termine.Log"

#DRAPPL="F4C0000GGSEJOURV"				# Test GSE
DRAPPL="F4C0000MGSEJOURX"				# Production GSE

DATE=$(date +%y%m%d)					# date du jour (AAMMJJ)

[ ! -d "${LCHEM}/${DATE}" ] && mkdir -m 775 ${LCHEM}/${DATE}


while [ $(date +%H%M) -lt 2200 ]
do
	if [ -r "${LCHEM}/${LOGFILE}" ]
	then
		echo "$(date +%T) : fichier ${LOGFILE} prêt"
		rm -f ${LCHEM}/${LOGFILE}
		if [ $? -eq 0 ]
		then
			echo "$(date +%T) : fichier ${LOGFILE} effacé"
		else
			echo "$(date +%T) : !!! erreur lors de la suppression du fichier ${LOGFILE}"
		fi

		LIST=$(ls -1 ${LCHEM} | grep -E "(gsefi|gsetr)")
		case $? in
		0)
			for FIC in ${LIST}
			do
				if [ ! -e "${LCHEM}/${LSAV}" ]
				then
					cat -s ${LCHEM}/${FIC} >${LCHEM}/${LSAV}
					echo "${DATE} $(date +%T) - fichier ${LCHEM}/${FIC} concaténé au nouveau fichier ${LCHEM}/${LSAV}"
					chmod 777 ${LCHEM}/${LSAV}
					if [ $? -eq 0 ]
					then
						echo "${DATE} $(date +%T) - droits sur le fichier ${LCHEM}/${LSAV} changés en 777 par le user $(whoami)"
					else
						echo "${DATE} $(date +%T) - !!! erreur lors du changement des droits en 777 sur le fichier ${LCHEM}/${LSAV} par le user $(whoami)"
					fi
					mv ${LCHEM}/${FIC} ${LCHEM}/${DATE}
				else
					if [ -w "${LCHEM}/${LSAV}" ]
					then
						cat -s ${LCHEM}/${FIC} >>${LCHEM}/${LSAV}
						echo "${DATE} $(date +%T) - fichier ${FIC} concaténé au fichier existant ${LCHEM}/${LSAV}"
						mv ${LCHEM}/${FIC} ${LCHEM}/${DATE}
					fi
				fi
			done
			mv ${LCHEM}/${LSAV} ${LCHEM}/${DATE}
			### ENVOI CFT
			IDENVOI="AT$(date +%H%M%S)"
			CFTUTIL SEND IDF=${CFT_IDF_GSE}, PART=${CFT_PART_GSE_A}, FNAME=${LCHEM}/${DATE}/${LSAV}, PARM=COMPTEURCOM, RAPPL=${DRAPPL}, SAPPL=${CFT_IDF_GSE}, SUSER=${IDENVOI}${CFT_IDF_GSE}, FRECFM=F, FLRECL=301, NIDF=${CFT_NIDF_MSG_NON}
			echo "$(date +%T) : envoi du fichier ${LCHEM}/${DATE}/${LSAV} - id ${IDENVOI}"
		;;
		1)
			echo "${DATE} $(date +%T) - Aucun fichier gse?????.txt présent dans ${LCHEM}"
		;;
		*)

		;;
		esac
	fi
	sleep 60
done

echo "##########"
echo "$(date +%d/%m/%y) $(date +%T) : Fin normale du script"
echo "###############"

exit 0
