#!/bin/ksh
#@(#)#####################################################
#@(#)   ATOM - Interface Cashpooler - SWIFTnet
#@(#)#####################################################
#@(#)
#@(#) Isaias DE MELO - SI Gestion - ATOM
#@(#) 21-05-2007 - v 1.0.0
#@(#)
#@(#) Traitement des fichiers Cashpooler générés par ATOM
#@(#)
#@(#)#####################################################
#@(#) NDC - 04/01/2008 : quelques modifs dans les logs
#@(#)#####################################################

# unicité du lancement
sleep 2
UNI=$(ps -ef | grep -c "$0")
UNI=$(expr $UNI - 1)
if [ $UNI -gt 1 ]
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
	exit 2
fi
. /home/$(whoami)/.profile


### VARIABLES
DATE=$(date +%y%m%d)

# chemin de scrutation du fichier a envoyer
LCHEM="$INTERFACES/export/Cashpooler"

# extension des fichiers à traiter
LEXT=".TXT"


# VERIFICATION DE LA PRESENCE DES FICHIERS
while [ 1 -ne 2 ]
do
### NEW Recherche l'existence de fichier(s) à traiter
	# nom du fichier généré par ATOM
	LFIC=$(ls -1 $LCHEM | grep -E "^(IS|VT|VS)[0-9][0-9]"${LEXT}$ | head -1)
	if [ ! -f "${LCHEM}/${LFIC}" ] || [ ! -w "${LCHEM}/${LFIC}" ]
	then
		## aucun fichier on attend 1 minute
		sleep 60
	else
### creation du repertoire d'archivage
		[ ! -d "${LCHEM}/${DATE}" ] && mkdir -m 777 ${LCHEM}/${DATE}
		echo "$(date +%T) : création du répertoire du jour: ${LCHEM}/${DATE}"

		echo "############# $(date +%T) : début traitement fichier $LFIC #############"

		LIGNORECORD=$(grep "No records selected" ${LCHEM}/${LFIC} | awk 'END { print NR }')
		if [ $LIGNORECORD -gt 0 ]
		then
			echo "$(date +%T) : fichier sans enregistrement: ${LCHEM}/${LFIC}"
		else
			TYPEFIC=$(echo "$LFIC" | cut -c 1-2)

			CPTARC=$(ls -1 ${LCHEM}/${DATE} | grep ^${TYPEFIC}"[0-9][0-9]"${LEXT}$ | tail -1 | cut -c3-4)
			if [ -n "$CPTARC" ]
			then
				CPTARC=$(expr $CPTARC + 1)
			else
				CPTARC="00"
			fi

			LONGCPTARC=$(echo "$CPTARC" | awk '{ print length($0) }')
			case $LONGCPTARC in
			1)
				CPTARC="0"$CPTARC
			;;
			*)
				CPTARC=$CPTARC
			;;
			esac

			DFIC=${TYPEFIC}${CPTARC}${LEXT}
			cp -f ${LCHEM}/${LFIC} ${LCHEM}/${DATE}/${DFIC}
			if [ $? -eq 0 ]
			then
				echo "$(date +%T) : archivage du fichier en entrée: ${LCHEM}/${LFIC} copié dans ${LCHEM}/${DATE}"
				chmod 775 ${LCHEM}/${DATE}/${DFIC}

				## identifiant unique d'envoi
				sleep 2
				jour=$(date +%d)
				heure=$(date +%H)
				minute=$(date +%M)
				seconde=$(date +%S)
				ident=$((jour * 86400 + heure * 3600 + minute * 60 + seconde))
				typeset -R6 idmois="000000$(echo 16o${ident}p | dc)"
				IDENVOI="AT$idmois"

				TIME=$(date +%H%M%S)

				# les VG sont considérés comme des VS pour eSPACE
				case $TYPEFIC in
				"VG")
					DIDF="ATOSPCVS"
				;;
				*)
					DIDF="ATOSPC$TYPEFIC"
				;;
				esac

				# envoi du fichier
				echo "$(date +%T) : envoi CFT vers SWIFTnet du fichier ${LCHEM}/${DATE}/${DFIC}"
				CFTUTIL SEND IDF=${DIDF}, NIDF=R2MFS, PART=${CFT_PART_ESPACE}, SAPPL=${ADLATOM}${APPLATOM}, RAPPL=${ADLESPACE}${DIDF}, SUSER=${IDENVOI}${DIDF}, RUSER=${DIDF}, FRECFM=V, FTYPE=O, FLRECL=1000, FNAME=${LCHEM}/${DATE}/${DFIC}, PARM=${TYPEFIC}.${DATE}.${TIME}.${CPTARC}
				echo "$(date +%T) : envoi CFT: IDF=${DIDF}, NIDF=R2MFS, PART=${CFT_PART_ESPACE}, SAPPL=${ADLATOM}${APPLATOM}, RAPPL=${ADLESPACE}${DIDF}, SUSER=$IDENVOI${DIDF}, RUSER=${DIDF}, FRECFM=V, FTYPE=O, FLRECL=1000, FNAME=${LCHEM}/${DATE}/${DFIC}, PARM=${TYPEFIC}.${DATE}.${TIME}.${CPTARC}"
			else
				echo "$(date +%T) : erreur pendant la copie de ${LCHEM}/${LFIC} dans ${LCHEM}/${DATE}"
				rm ${LCHEM}/${DATE}/${DFIC}
				sleep 10
				continue
			fi
		fi
		# suppression du fichier venant d'etre traité
		rm -f ${LCHEM}/${LFIC}
		echo "$(date +%T) : fin de traitement du fichier: suppression du fichier $LFIC"
	fi

### test sur l'heure pour arret
	[ $(date +%H%M) -gt 2100 ] && exit 0
done

echo "$(date +%T) : FIN du script"

exit 0
