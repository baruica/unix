#!/bin/ksh
#@(#)#####################################################
#@(#)   Interface eSPACE / ATOM
#@(#)#####################################################
#@(#)
#@(#) Nelson Da Costa - ATOM
#@(#) 30/01/2008 - v4 - refonte complète du script:
#@(#)
#@(#)   utilisation des {} pour toutes les variables
#@(#)   log plus explicite
#@(#)   test d'unicité corrigé
#@(#)   gestion des doublons en utilisant les identifiants
#@(#)   archivage dans le répertoire du jour de la génération du fichier par eSPACE
#@(#)   gestion des fichiers contenant un code inconnu dans l'entête
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
	exit 2
fi
. /home/$(whoami)/.profile


### VARIABLES
DATE=$(date +%y%m%d)

# répertoires locaux
LCHEM_SPC="${INTERFACES}/import/eSPACE"
LCHEM="${LCHEM_SPC}"
LCHEM_ETR="${LCHEM_SPC}/Etranger"
LCHEM_FRA="${LCHEM_SPC}/France"
LEXT="csv"


# fonction qui s'occupe d'archiver le fichier $1 dans le répertoire $2/$3 en tant que $4.${LEXT}
archivage()
{
	# on créer le répertoire d'archivage s'il n'existe pas déjà
	[ ! -d "$2/$3" ] && {
		mkdir -m 775 $2/$3
		echo "$(date +%T) : création du répertoire d'archivage $2/$3" ;}

	# archivage
	cat -s $1 >>$2/$3/$4.${LEXT}
	echo "$(date +%T) :  archivage du fichier $1 dans le fichier $2/$3/$4.${LEXT}"
	chmod 775 $2/$3/$4.${LEXT}

	sleep 2

	[ ! -e "$2/$4.${LEXT}" ] && touch $2/$4.${LEXT}
	if [ $(grep -c "$(awk 'NR==1 { print substr($1,19,12) }' $1)" $2/$4.${LEXT}) -eq 0 ]
	then
		cat -s $1 >>$2/$4.${LEXT}
		echo "$(date +%T) :   $1 mis à dispo dans le fichier $2/$4.${LEXT}"
		chmod 777 $2/$4.${LEXT}
	else											# déjà dispo en import
		if rm -f $1
		then
			echo "$(date +%T) :    suppression du fichier $1 qui avait déjà été concaténé dans $2/$4.${LEXT}"
		fi
	fi
}


while [ $(date +%H) -lt 21 ]
do
	if [ $(ls -1 ${CFT_TEMP}/${ADLESPACE}.* | grep -c "${ADLESPACE}") -gt 0 ]
	then
		for FIC_CFT in $(ls -1 ${CFT_TEMP}/${ADLESPACE}.*)
		do
			if [ -r "${FIC_CFT}" ]
			then
				# date (aammjj) de la première entête du fichier présent dans le répertoire temporaire de CFT
				DATE_CFT=$(awk 'NR==1 { print substr($1,19,6) }' ${FIC_CFT})
				# code du fichier reçu (2ème champs de la 2ème ligne)
				CODE_CFT=$(awk 'NR==2 { FS=";" ; print $2 }' ${FIC_CFT})

				case ${CODE_CFT} in
				CET | VET )
					LCHEM=${LCHEM_ETR}
				;;
				CFT | VFT | REJ | CAO )
					LCHEM=${LCHEM_FRA}
				;;
				*)
					echo "$(date +%T) : !!! le code du fichier ${FIC_CFT} est vide ou inconnu"
					cp ${FIC_CFT} ${LCHEM_SPC}/
					chmod 775 ${LCHEM_SPC}/$(basename ${FIC_CFT})
					mv ${LCHEM_SPC}/$(basename ${FIC_CFT}) ${LCHEM_SPC}/inconnu_${DATE}_$(basename ${FIC_CFT})
					if rm -f ${FIC_CFT}
					then
						echo "$(date +%T) : !!! le fichier ${FIC_CFT} a été déplacé dans ${LCHEM_SPC}/inconnu_${DATE}_$(basename ${FIC_CFT})"
						chmod 775 ${LCHEM_SPC}/inconnu_${DATE}_$(basename ${FIC_CFT})
					else
						echo "$(date +%T) : !!! le fichier ${FIC_CFT} n'a pas pu être déplacé dans ${LCHEM_SPC}/inconnu_${DATE}_$(basename ${FIC_CFT})"
					fi
					continue						# on passe au fichier suivant dans le répertoire temporaire de CFT
				;;
				esac

				# comme les fichiers ne sont pas systématiquement importés le jour de leur arrivé,
				# on archive les fichiers reçus dans le répertoire datant du jour de la génération du fichier par eSPACE (date dans l'identifiant)

				# pour éviter que le grep plante
				# l'accolade fermante doit être après un retour chariot ou un ;
				[ ! -d "${LCHEM}/${DATE_CFT}" ] && {
					mkdir -m 775 ${LCHEM}/${DATE_CFT}
					echo "$(date +%T) : création du répertoire d'archivage ${LCHEM}/${DATE_CFT}" ;}

				if [ -e "${LCHEM}/${DATE_CFT}/${CODE_CFT}.${LEXT}" ]
				then
					if [ -r "${LCHEM}/${DATE_CFT}/${CODE_CFT}.${LEXT}" ]
					then
						if [ $(grep -c "$(awk 'NR==1 { print substr($1,19,12) }' ${FIC_CFT})" ${LCHEM}/${DATE_CFT}/${CODE_CFT}.${LEXT}) -eq 0 ]
						then
							archivage ${FIC_CFT} ${LCHEM} ${DATE_CFT} ${CODE_CFT}
						else						# déjà archivé
							if rm -f ${FIC_CFT}
							then
								echo "$(date +%T) :     suppression du fichier ${FIC_CFT} déjà concaténé dans ${LCHEM}/${DATE_CFT}/${CODE_CFT}.${LEXT}"
							fi
						fi
					else
						echo "$(date +%T) : ${LCHEM}/${DATE_CFT}/${CODE_CFT}.${LEXT} illisible"
					fi
				else
					archivage ${FIC_CFT} ${LCHEM} ${DATE_CFT} ${CODE_CFT}
				fi
			fi
		done
	else											# aucun fichier n'est présent dans le répertoire d'arrivé de CFT
		sleep 120									# on scrute toutes les 120 secondes
	fi
done


echo "##########"
echo "$(date +%d/%m/%y) $(date +%T) : Fin normale du script"
echo "###############"

exit 0
