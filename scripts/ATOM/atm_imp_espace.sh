#!/bin/ksh
#@(#)#####################################################
#@(#)   Interface eSPACE / ATOM
#@(#)#####################################################
#@(#)
#@(#) Nelson Da Costa - ATOM
#@(#) 30/01/2008 - v4 - refonte compl�te du script:
#@(#)
#@(#)   utilisation des {} pour toutes les variables
#@(#)   log plus explicite
#@(#)   test d'unicit� corrig�
#@(#)   gestion des doublons en utilisant les identifiants
#@(#)   archivage dans le r�pertoire du jour de la g�n�ration du fichier par eSPACE
#@(#)   gestion des fichiers contenant un code inconnu dans l'ent�te
#@(#)#####################################################

# unicit� du lancement
sleep 2
UNI=$(ps -ef | grep -c "$0")
UNI=$(expr ${UNI} - 1)
if [ ${UNI} -gt 1 ]
then
	echo "$(date +%d/%m/%y) $(date +%T) - $0 est d�j� en cours d'execution"
	exit ${UNI}
else
	echo "###############"
	echo "$(date +%d/%m/%y) $(date +%T) : D�marrage du script"
	echo "##########"
fi

# Execution du .profile de l'utilisateur courant pour recuperer les variables d'environnement
if [ ! -r "/home/$(whoami)/.profile" ]
then
	echo "$(date +%y%m%d) $(date +%T) !!! Probl�me de chargement: fichier profile $(whoami) introuvable"
	exit 2
fi
. /home/$(whoami)/.profile


### VARIABLES
DATE=$(date +%y%m%d)

# r�pertoires locaux
LCHEM_SPC="${INTERFACES}/import/eSPACE"
LCHEM="${LCHEM_SPC}"
LCHEM_ETR="${LCHEM_SPC}/Etranger"
LCHEM_FRA="${LCHEM_SPC}/France"
LEXT="csv"


# fonction qui s'occupe d'archiver le fichier $1 dans le r�pertoire $2/$3 en tant que $4.${LEXT}
archivage()
{
	# on cr�er le r�pertoire d'archivage s'il n'existe pas d�j�
	[ ! -d "$2/$3" ] && {
		mkdir -m 775 $2/$3
		echo "$(date +%T) : cr�ation du r�pertoire d'archivage $2/$3" ;}

	# archivage
	cat -s $1 >>$2/$3/$4.${LEXT}
	echo "$(date +%T) :  archivage du fichier $1 dans le fichier $2/$3/$4.${LEXT}"
	chmod 775 $2/$3/$4.${LEXT}

	sleep 2

	[ ! -e "$2/$4.${LEXT}" ] && touch $2/$4.${LEXT}
	if [ $(grep -c "$(awk 'NR==1 { print substr($1,19,12) }' $1)" $2/$4.${LEXT}) -eq 0 ]
	then
		cat -s $1 >>$2/$4.${LEXT}
		echo "$(date +%T) :   $1 mis � dispo dans le fichier $2/$4.${LEXT}"
		chmod 777 $2/$4.${LEXT}
	else											# d�j� dispo en import
		if rm -f $1
		then
			echo "$(date +%T) :    suppression du fichier $1 qui avait d�j� �t� concat�n� dans $2/$4.${LEXT}"
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
				# date (aammjj) de la premi�re ent�te du fichier pr�sent dans le r�pertoire temporaire de CFT
				DATE_CFT=$(awk 'NR==1 { print substr($1,19,6) }' ${FIC_CFT})
				# code du fichier re�u (2�me champs de la 2�me ligne)
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
						echo "$(date +%T) : !!! le fichier ${FIC_CFT} a �t� d�plac� dans ${LCHEM_SPC}/inconnu_${DATE}_$(basename ${FIC_CFT})"
						chmod 775 ${LCHEM_SPC}/inconnu_${DATE}_$(basename ${FIC_CFT})
					else
						echo "$(date +%T) : !!! le fichier ${FIC_CFT} n'a pas pu �tre d�plac� dans ${LCHEM_SPC}/inconnu_${DATE}_$(basename ${FIC_CFT})"
					fi
					continue						# on passe au fichier suivant dans le r�pertoire temporaire de CFT
				;;
				esac

				# comme les fichiers ne sont pas syst�matiquement import�s le jour de leur arriv�,
				# on archive les fichiers re�us dans le r�pertoire datant du jour de la g�n�ration du fichier par eSPACE (date dans l'identifiant)

				# pour �viter que le grep plante
				# l'accolade fermante doit �tre apr�s un retour chariot ou un ;
				[ ! -d "${LCHEM}/${DATE_CFT}" ] && {
					mkdir -m 775 ${LCHEM}/${DATE_CFT}
					echo "$(date +%T) : cr�ation du r�pertoire d'archivage ${LCHEM}/${DATE_CFT}" ;}

				if [ -e "${LCHEM}/${DATE_CFT}/${CODE_CFT}.${LEXT}" ]
				then
					if [ -r "${LCHEM}/${DATE_CFT}/${CODE_CFT}.${LEXT}" ]
					then
						if [ $(grep -c "$(awk 'NR==1 { print substr($1,19,12) }' ${FIC_CFT})" ${LCHEM}/${DATE_CFT}/${CODE_CFT}.${LEXT}) -eq 0 ]
						then
							archivage ${FIC_CFT} ${LCHEM} ${DATE_CFT} ${CODE_CFT}
						else						# d�j� archiv�
							if rm -f ${FIC_CFT}
							then
								echo "$(date +%T) :     suppression du fichier ${FIC_CFT} d�j� concat�n� dans ${LCHEM}/${DATE_CFT}/${CODE_CFT}.${LEXT}"
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
	else											# aucun fichier n'est pr�sent dans le r�pertoire d'arriv� de CFT
		sleep 120									# on scrute toutes les 120 secondes
	fi
done


echo "##########"
echo "$(date +%d/%m/%y) $(date +%T) : Fin normale du script"
echo "###############"

exit 0
