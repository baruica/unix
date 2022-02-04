#! /bin/sh -

# Execution du .profile de l'utilisateur courant pour recuperer les variables d'environnement
if [ ! -r "/home/$(whoami)/.profile" ]
then
	echo "$(date +%y%m%d) $(date +%T) [erreur] Problème de chargement du profile $(whoami)"
	exit 2
fi
. /home/$(whoami)/.profile


cmd_sqlplus="sqlplus -s /nolog 1>/dev/null 2>/dev/null ${REPIMMO_USER}/${REPIMMO_PASS}@${REPIMMO_SID}"
FICLOG="$TRACES/oracle/$(basename $0 .sh)_$(date '+%Y%m%d%H%M%S').log"
FICTMP="$TRACES/oracle/$(basename $0 .sh)_$(date '+%Y%m%d%H%M%S').tmp"
RETOUR_REQUETE=0



# Validation des parametres

echo "$(date +%T) - [trace] Validation des parametres d entree" >> ${FICLOG}

REQUETE="SELECT COUNT(*) FROM ${1} WHERE 1=2"

$cmd_sqlplus <<- EOF
  WHENEVER SQLERROR EXIT 1
  WHENEVER OSERROR EXIT 2
  SET ECHO OFF
  SET FEEDBACK OFF
  SET HEADING OFF
  SET LINESIZE 32767
  SET PAGESIZE 0
  ${REQUETE};
  EXIT
EOF
RETOUR_REQUETE=$?
if [ ${RETOUR_REQUETE} -ne 0 ]
then
	[ ${RETOUR_REQUETE} -eq 1 ] && echo "$(date +%T) - [erreur]    La table ${1} n existe pas" >> ${FICLOG}
	[ ${RETOUR_REQUETE} -eq 2 ] && echo "$(date +%T) - [erreur]    erreur OS, update KO" >> ${FICLOG}
	[ ${RETOUR_REQUETE} -gt 2 ] && echo "$(date +%T) - [erreur]    erreur inconnue, update KO" >> ${FICLOG}
	exit 1
fi

REQUETE="SELECT PCK_BACKUP.FCT_IS_DATE ( ${2} , 'YYYYMMDD' ) FROM DUAL"
$cmd_sqlplus <<- EOF
  WHENEVER SQLERROR EXIT 1
  WHENEVER OSERROR EXIT 2
  SET ECHO OFF
  SET FEEDBACK OFF
  SET HEADING OFF
  SET LINESIZE 32767
  SET PAGESIZE 0
  ${REQUETE};
  EXIT
EOF
RETOUR_REQUETE=$?
if [ ${RETOUR_REQUETE} -ne 0 ]
then
	[ ${RETOUR_REQUETE} -eq 1 ] && echo "$(date +%T) - [erreur]    La date ${2} n'est pas valide et/ou n'est pas au format YYYYMMDD" >> ${FICLOG}
	[ ${RETOUR_REQUETE} -eq 2 ] && echo "$(date +%T) - [erreur]    erreur OS, update KO" >> ${FICLOG}
	[ ${RETOUR_REQUETE} -gt 2 ] && echo "$(date +%T) - [erreur]    erreur inconnue, update KO" >> ${FICLOG}
	exit 1
fi

REQUETE="SELECT COUNT(*) FROM ${1}_${2} WHERE 1=2"
$cmd_sqlplus <<- EOF
  WHENEVER SQLERROR EXIT 1
  WHENEVER OSERROR EXIT 2
  SET ECHO OFF
  SET FEEDBACK OFF
  SET HEADING OFF
  SET LINESIZE 32767
  SET PAGESIZE 0
  ${REQUETE};
  EXIT
EOF
RETOUR_REQUETE=$?
if [ ${RETOUR_REQUETE} -eq 0 ]
then
	[ ${RETOUR_REQUETE} -eq 1 ] && echo "$(date +%T) - [erreur]    La table ${1} n existe pas" >> ${FICLOG}
	[ ${RETOUR_REQUETE} -eq 2 ] && echo "$(date +%T) - [erreur]    erreur OS, update KO" >> ${FICLOG}
	[ ${RETOUR_REQUETE} -gt 2 ] && echo "$(date +%T) - [erreur]    erreur inconnue, update KO" >> ${FICLOG}
	exit 1
fi



REQUETES="Create TABLE ${1}_${2} TABLESPACE TAB_REPIMMO_N2_BACKUP COMPRESS PCTFREE 1 as SELECT * FROM ${1}"

echo "$(date +%T) - [trace] ${REQUETES}" >> ${FICLOG}

$cmd_sqlplus <<- EOF
  WHENEVER SQLERROR EXIT 1
  WHENEVER OSERROR EXIT 2
  SET ECHO OFF
  SET FEEDBACK OFF
  SET HEADING OFF
  SET LINESIZE 32767
  SET PAGESIZE 0
  ${REQUETES};
  EXIT
EOF

RETOUR_REQUETE=$?

if [ ${RETOUR_REQUETE} -eq 0 ]
then
	echo "$(date +%T) - [trace] Table cree" >> ${FICLOG}
else
	[ ${RETOUR_REQUETE} -eq 1 ] && echo "$(date +%T) - [erreur]    PB avec les parametres d entree" >> ${FICLOG}
	[ ${RETOUR_REQUETE} -eq 2 ] && echo "$(date +%T) - [erreur]    erreur OS, update KO" >> ${FICLOG}
	[ ${RETOUR_REQUETE} -gt 2 ] && echo "$(date +%T) - [erreur]    erreur inconnue, update KO" >> ${FICLOG}
fi

echo "$(date +%T) - [trace] Calcul de stat sur la table cree" >> ${FICLOG}



echo "$(date +%T) - [trace] fin normale" >> ${FICLOG}

echo "Table Backup ${1}_${2} crée"

exit 0
