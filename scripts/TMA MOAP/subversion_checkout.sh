#!/bin/bash
if [ ${1:-notset} = "-help" -o ${1:-notset} = "--help" ]
then
	clear
	cat <<HELP_END
#===============================================================================
#===============================================================================
# Lionel SAURON (Sopra Group)
# 06/11/2005
#===============================================================================
# Execute un checkout pour subversion.
#
# Ce script est lancé par la crontab.
#
#===============================================================================
# Appels :
# - subversion_checkout.sh
#
# Parametres :
#
# Valeurs de retour :
# - 1 : Variable d'environnement non définie
# - 2 : Paramètres incorrects
# - 3 : Problème lors du déroulement de l'action xxx (Code d'erreur yy)
#
# Fichiers :
# - Journal           :
# - Fichier d'entree  :
#
#===============================================================================
#===============================================================================
HELP_END
	exit
fi

#===============================================================================
# Vérification des variables d'environnements (exit 1 si pas definie)
#===============================================================================
#dummy=${TEST:?"Variable non définie !"} >&2
unset dummy

#===============================================================================
# Traitement des parametres d'entree
#===============================================================================

#===============================================================================
# Variables et constantes generales
#===============================================================================
URL_SUBVERSION="file:///tma_moap/programs/subversion_repository"
PATH_PROJETS="/tma_moap/projets"

#===============================================================================
# Fonction de nettoyage
#===============================================================================
clean_project()
{
	for folder in `find "$1"/* -type d -prune 2>/dev/null`
	do
		temp=`basename $folder`

		case `basename $folder` in
		data)
		;;
		log)
		;;
		conf)
			for file in `ls -r1f "$folder"/* 2>/dev/null`
			do
				temp=`basename "$file"`

				# On supprime tout sauf les XXX.conf.php
				if [ $temp == ${temp%\.conf\.php} ]
				then
					rm -f "$file"
				fi

				# Par contre, on supprime les XXX.sample.conf.php
				if [ $temp != ${temp%\.sample\.conf\.php} ]
				then
					rm -f "$file"
				fi
			done
			;;
		*)
			echo "$folder"
			rm -rf "$folder"
		;;
		esac
	done
}

#===============================================================================
#===============================================================================
# Programme principal
#===============================================================================
#===============================================================================

# Checkout de la qualif
clean_project "${PATH_PROJETS}/web-rhel3/qualif/extensweb_trunk"
/tma_moap/programs/subversion/bin/svn export --force "${URL_SUBVERSION}/extensweb/trunk" "${PATH_PROJETS}/web-rhel3/qualif/extensweb_trunk"

clean_project "${PATH_PROJETS}/web-rhel3/qualif/targ_trunk"
/tma_moap/programs/subversion/bin/svn export --force "${URL_SUBVERSION}/targ/trunk" "${PATH_PROJETS}/web-rhel3/qualif/targ_trunk"

clean_project "${PATH_PROJETS}/web-rhel3/qualif/atoutchaudiere_trunk"
/tma_moap/programs/subversion/bin/svn export --force "${URL_SUBVERSION}/atoutchaudiere/trunk" "${PATH_PROJETS}/web-rhel3/qualif/atoutchaudiere_trunk"

exit 0
