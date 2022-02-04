#! /bin/sh -

#					En attente
#						|
#						V
#	En erreur  <--- En cours   ---> A stopper
#						|				|
#						V				V
#					Terminée		Stoppée

# 1. on cherche les requetes 'En cours' qui ont un PID invalide
# 2. en fonction de la valeur de TTPHP_QUOTA_REQUETE.NB_JOURS_RETENTION, on archive les requetes dans la table TTPHP_REQUETE_HISTO
# 3. appel de LanceRequete.sh
# 4. on kill les requetes qui ont un statut 'A stopper'
# 5. on supprime les fichiers générés par les requetes 'En erreur' ou 'Stoppée'

# REMARQUES:
# les requetes SQL contenant des chaines entre ' ' doivent etre placées dans des variables et non directement dans le here-doc du sqlplus


# Execution du .profile de l'utilisateur courant pour recuperer les variables d'environnement
if [ ! -r "/home/$(whoami)/.profile" ]
then
	echo "$(date +%y%m%d) $(date +%T) [erreur] Problème de chargement du profile $(whoami)"
	exit 2
fi
. /home/$(whoami)/.profile


cmd_sqlplus="sqlplus -s ${REPIMMO_USER}/${REPIMMO_PASS}@${REPIMMO_SID}"
LOG="${TRACES}/oracle/$(basename $0 .sh)_$(date +"%Y-%m-%d").log"
TMP="${TRACES}/oracle/$(basename $0 .sh)_$(date +"%Y-%m-%d").tmp"
SEPARATEUR="§"
RETOUR_UPDATE=0
EXT_ARCHIVE=".gz"


# fonction par laquelle passent toutes les requetes d'update
# le script se termine si l'execution de la requete ne renvoi pas un code retour 0
updateREQ()
{
	echo "$(date +%T) - [trace] updateREQ() $1" >> $LOG

	RETOUR_UPDATE=0
	TENTATIVES=1

	# on fait plusieures tentatives au cas ou la table/base n'est pas accessible au moment de l'execution de la requete
	while [ $TENTATIVES -le 3 ]
	do
		echo "$(date +%T) - [trace]   tentative numero $TENTATIVES" >> $LOG

		$cmd_sqlplus <<- EOF
		WHENEVER SQLERROR EXIT 1
		WHENEVER OSERROR EXIT 2
		SET ECHO OFF
		SET FEEDBACK OFF
		SET HEADING OFF
		SET LINESIZE 32767
		SET PAGESIZE 0
		$1;
		COMMIT;
		EXIT
EOF

		RETOUR_UPDATE=$?

		if [ $RETOUR_UPDATE -eq 0 ]
		then
			break
		else
			[ $RETOUR_UPDATE -eq 1 ] && echo "$(date +%T) - [erreur]    erreur SQL, update KO" >> $LOG
			[ $RETOUR_UPDATE -eq 2 ] && echo "$(date +%T) - [erreur]    erreur OS, update KO" >> $LOG
			[ $RETOUR_UPDATE -gt 2 ] && echo "$(date +%T) - [erreur]    erreur inconnue, update KO" >> $LOG
			TENTATIVES=$(expr $TENTATIVES + 1)
			[ $TENTATIVES -eq 3 ] && break
			echo "$(date +%T) - [erreur]    encore $(expr 3 - ${TENTATIVES}) tentatives" >> $LOG
		fi
	done

	echo "$(date +%T) - [trace] fin updateREQ() avec code retour $RETOUR_UPDATE" >> $LOG
	[ $RETOUR_UPDATE -ne 0 ] && exit $RETOUR_UPDATE
}



# on cherche les requetes 'En cours' qui ont un PID invalide
REQ_REQUETES_ERREUR="SELECT ID_REQUETE || '${SEPARATEUR}' || PID as e FROM TTPHP_REQUETE WHERE STATUT = 'En cours' AND PID IS NOT NULL"

echo "$(date +%T) - [trace] $REQ_REQUETES_ERREUR" >> $LOG

$cmd_sqlplus <<- EOF
SET FEEDBACK OFF
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SPOOL $TMP
${REQ_REQUETES_ERREUR};
SPOOL OFF
EXIT
EOF

cat $TMP >> $LOG

for r in $(cat $TMP)
do
	PID_REQ=$(echo $r | awk -F'§' '{ printf "%s", $2 }')

	# ce PID n'existe plus
	if [ $(ps -fu `whoami` | awk '{ print $2 }' | grep -c "${PID_REQ}") -lt 1 ]
	then
		ID_REQ=$(echo $r | awk -F'§' '{ printf "%s", $1 }')
		echo "$(date +%T) - [trace] le PID $PID_REQ de la requete $ID_REQ est invalide" >> $LOG

		updateREQ "UPDATE TTPHP_REQUETE SET STATUT = CASE WHEN STATUT = 'En cours' THEN 'En erreur' END, DATE_FIN = '', PID = '' WHERE ID_REQUETE = $ID_REQ"
	fi
done



# en fonction de la valeur de TTPHP_QUOTA_REQUETE.NB_JOURS_RETENTION, on archive les requetes dans la table TTPHP_REQUETE_HISTO
REQ_HISTO="INSERT INTO TTPHP_REQUETE_HISTO (
	TTPHP_REQUETE_HISTO.DATE_CREATION,
	TTPHP_REQUETE_HISTO.DATE_DEB,
	TTPHP_REQUETE_HISTO.DATE_FIN,
	TTPHP_REQUETE_HISTO.EMAIL,
	TTPHP_REQUETE_HISTO.FICHIER,
	TTPHP_REQUETE_HISTO.ID_REQUETE,
	TTPHP_REQUETE_HISTO.POIDS,
	TTPHP_REQUETE_HISTO.REQUETE_SQL1,
	TTPHP_REQUETE_HISTO.REQUETE_SQL2,
	TTPHP_REQUETE_HISTO.REQUETE_SQL3,
	TTPHP_REQUETE_HISTO.REQUETE_SQL4,
	TTPHP_REQUETE_HISTO.REQUETE_SQL5,
	TTPHP_REQUETE_HISTO.REQUETE_SQL6,
	TTPHP_REQUETE_HISTO.REQUETE_SQL7,
	TTPHP_REQUETE_HISTO.REQUETE_SQL8,
	TTPHP_REQUETE_HISTO.REQUETE_SQL9,
	TTPHP_REQUETE_HISTO.REQUETE_SQL10,
	TTPHP_REQUETE_HISTO.REQUETE_SQL11,
	TTPHP_REQUETE_HISTO.REQUETE_SQL12,
	TTPHP_REQUETE_HISTO.SCENARIO,
	TTPHP_REQUETE_HISTO.STATUT
)
(
	SELECT
		TTPHP_REQUETE.DATE_CREATION,
		TTPHP_REQUETE.DATE_DEB,
		TTPHP_REQUETE.DATE_FIN,
		TTPHP_REQUETE.EMAIL,
		TTPHP_REQUETE.FICHIER,
		TTPHP_REQUETE.ID_REQUETE,
		TTPHP_REQUETE.POIDS,
		TTPHP_REQUETE.REQUETE_SQL1,
		TTPHP_REQUETE.REQUETE_SQL2,
		TTPHP_REQUETE.REQUETE_SQL3,
		TTPHP_REQUETE.REQUETE_SQL4,
		TTPHP_REQUETE.REQUETE_SQL5,
		TTPHP_REQUETE.REQUETE_SQL6,
		TTPHP_REQUETE.REQUETE_SQL7,
		TTPHP_REQUETE.REQUETE_SQL8,
		TTPHP_REQUETE.REQUETE_SQL9,
		TTPHP_REQUETE.REQUETE_SQL10,
		TTPHP_REQUETE.REQUETE_SQL11,
		TTPHP_REQUETE.REQUETE_SQL12,
		TTPHP_REQUETE.SCENARIO,
		TTPHP_REQUETE.STATUT
	FROM TTPHP_REQUETE
	WHERE ( (SYSDATE - DATE_CREATION) > (SELECT TTPHP_QUOTA_REQUETE.NB_JOURS_RETENTION FROM TTPHP_QUOTA_REQUETE) )
)"

REQ_DEL="DELETE FROM TTPHP_REQUETE WHERE ( (SYSDATE - DATE_CREATION) > (SELECT TTPHP_QUOTA_REQUETE.NB_JOURS_RETENTION FROM TTPHP_QUOTA_REQUETE) )"

# il est important de ne pas faire le COMMIT entre les INSERT et les DELETE car en cas de probleme, oracle fera un rollback propre
$cmd_sqlplus <<- EOF
WHENEVER SQLERROR EXIT 1
WHENEVER OSERROR EXIT 2
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET LINESIZE 32767
SET PAGESIZE 0
${REQ_HISTO};
${REQ_DEL};
COMMIT;
EXIT
EOF



# appel de LanceRequete.sh
POIDS_MAX=$($cmd_sqlplus <<- EOF
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET LINESIZE 32767
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SELECT QUOTA_MAX as n FROM TTPHP_QUOTA_REQUETE;
EXIT
EOF
)

REQ_SOM_POIDS_ENCOURS="SELECT SUM(POIDS) as n FROM TTPHP_REQUETE WHERE STATUT = 'En cours'"
echo "$(date +%T) - [trace] $REQ_SOM_POIDS_ENCOURS" >> $LOG

SOM_POIDS_ENCOURS=$($cmd_sqlplus <<- EOF
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET LINESIZE 32767
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
${REQ_SOM_POIDS_ENCOURS};
EXIT
EOF
)

POIDS_RESTANT=$(expr ${POIDS_MAX:=0} - ${SOM_POIDS_ENCOURS:=0})

# le + 0 n'est la que pour l'esthétisme de la log, sans lui plusieurs espaces sont présents entre les parenthèses
echo "$(date +%T) - [trace] poids restant initial: poids max ($(expr ${POIDS_MAX} + 0)) - somme poids en cours (${SOM_POIDS_ENCOURS:=0}) = ${POIDS_RESTANT:=0}" >> $LOG

rm ${TMP} || echo "$(date +%T) - [erreur] erreur lors de la suppression de ${TMP}" >> $LOG


# liste des requetes en attente
FLAG_CHARGEMENT=$($cmd_sqlplus <<- EOF
SET FEEDBACK OFF
SET LINESIZE 32767
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SELECT FLAG_CHARGEMENT FROM TTPHP_QUOTA_REQUETE;
EXIT
EOF
)

echo "$(date +%T) - [trace] Flag chargement (${FLAG_CHARGEMENT})" >> $LOG

# on ne lance de nouvelles requetes que si il n'y a pas de chargement en cours
if [ "${FLAG_CHARGEMENT}" = "N" ]
then
	REQ_REQUETES_ATTENTE="SELECT ID_REQUETE || '${SEPARATEUR}' || POIDS as a FROM TTPHP_REQUETE WHERE STATUT = 'En attente' AND DATE_CREATION < SYSDATE ORDER BY DATE_CREATION ASC"
	echo "$(date +%T) - [trace] ${REQ_REQUETES_ATTENTE}" >> $LOG

	$cmd_sqlplus <<- EOF
	SET FEEDBACK OFF
	SET LINESIZE 32767
	SET PAGESIZE 0
	SET TRIM ON
	SET TRIMSPOOL ON
	SPOOL ${TMP}
	${REQ_REQUETES_ATTENTE};
	SPOOL OFF
	EXIT
EOF

	cat ${TMP} >> $LOG

	for r in $(cat ${TMP})
	do
		ID_REQ=$(echo ${r} | awk -F'§' '{ printf "%s", $1 }')
		POIDS_REQ=$(echo ${r} | awk -F'§' '{ printf "%s", $2 }')

		if [ ${POIDS_REQ:=0} -le ${POIDS_RESTANT:=0} ]
		then
			echo "$(date +%T) - [trace] la requete ${ID_REQ} a un poids inférieur ou égal à ${POIDS_RESTANT} (${POIDS_REQ})" >> $LOG
			POIDS_RESTANT=$(expr ${POIDS_RESTANT:=0} - ${POIDS_REQ:=0})
			echo "$(date +%T) - [trace] le nouveau poids restant est ${POIDS_RESTANT}" >> $LOG

			SCENARIO_REQ=$($cmd_sqlplus <<- EOF
			SET FEEDBACK OFF
			SET PAGESIZE 0
			SET TRIM ON
			SET TRIMSPOOL ON
			select scenario as s from ttphp_requete where id_requete = ${ID_REQ};
			EXIT
EOF
			)

			if [ $(echo ${SCENARIO_REQ} | grep -c "condor") -gt 0 ]
			then
				echo "$(date +%T) - [trace] LanceRequeteCondor.sh ${ID_REQ} &" >> $LOG
				${APPLI}/scripts/LanceRequeteCondor.sh ${ID_REQ} &
			else
				echo "$(date +%T) - [trace] LanceRequete.sh ${ID_REQ} &" >> $LOG
				${APPLI}/scripts/LanceRequete.sh ${ID_REQ} &
			fi
		else
			echo "$(date +%T) - [trace] la requete ${ID_REQ} a un poids supérieur à ${POIDS_RESTANT} (${POIDS_REQ}), on sort de la boucle" >> $LOG
			break
		fi
	done

	rm ${TMP} || echo "$(date +%T) - [erreur] erreur lors de la suppression de ${TMP}" >> $LOG
fi



# on kill les requetes qui ont un statut 'A stopper'
REQ_REQUETES_STOP_ERR="SELECT ID_REQUETE || '${SEPARATEUR}' || PID as n FROM TTPHP_REQUETE WHERE STATUT = 'A stopper'"
echo "$(date +%T) - [trace] ${REQ_REQUETES_STOP_ERR}" >> $LOG

$cmd_sqlplus <<- EOF
SET FEEDBACK OFF
SET LINESIZE 32767
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SPOOL ${TMP}
${REQ_REQUETES_STOP_ERR};
SPOOL OFF
EXIT
EOF

cat ${TMP} >> $LOG

for r in $(cat ${TMP})
do
	ID_REQ=$(echo ${r} | awk -F'§' '{ printf "%s", $1 }')
	PID_REQ=$(echo ${r} | awk -F'§' '{ printf "%s", $2 }')

	if [ "${ID_REQ}" != "" ]
	then
		if [ "${PID_REQ}" != "" ]
		then
			if [ $(ps -fu `whoami` | awk '{ print $2 }' | grep -c "${PID_REQ}") -eq 1 ]
			then
				kill -9 ${PID_REQ}
				if [ $? -eq 0 ]
				then
					echo "$(date +%T) - [trace] requete ${ID_REQ} - kill -9 ${PID_REQ}" >> $LOG
				else
					echo "$(date +%T) - [erreur] requete ${ID_REQ} - erreur lors du kill -9 ${PID_REQ}" >> $LOG
				fi
			else
				echo "$(date +%T) - [erreur] requete ${ID_REQ} - PID ${PID_REQ} invalide" >> $LOG
			fi
		else
			echo "$(date +%T) - [erreur] la requete ${ID_REQ} n'a pas de PID" >> $LOG
		fi
	else
		echo "$(date +%T) - [erreur] requete sans ID" >> $LOG
		break
	fi

	updateREQ "UPDATE TTPHP_REQUETE SET STATUT = 'Stoppée' WHERE ID_REQUETE = ${ID_REQ} AND STATUT = 'A stopper'"
done

rm ${TMP} || echo "$(date +%T) - [erreur] erreur lors de la suppression de ${TMP}" >> $LOG


# on supprime les fichiers générés par les requetes 'En erreur' ou 'Stoppée'
REQ_FIC_SUP="SELECT FICHIER as b FROM TTPHP_REQUETE WHERE STATUT IN ('En erreur', 'Stoppée')"
echo "$(date +%T) - [trace] ${REQ_FIC_SUP}" >> $LOG

$cmd_sqlplus <<- EOF
SET FEEDBACK OFF
SET LINESIZE 32767
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SPOOL ${TMP}
${REQ_FIC_SUP};
SPOOL OFF
EXIT
EOF

for f in $(echo ${TMP})
do
	if [ -e "${FICHIERS}/fichiers/${f}${EXT_ARCHIVE}" ]
	then
		rm ${FICHIERS}/fichiers/${f}${EXT_ARCHIVE}
		if [ $? -eq 0 ]
		then
			echo "$(date +%T) - [trace] ${FICHIERS}/fichiers/${f}${EXT_ARCHIVE} supprimé" >> $LOG
		else
			echo "$(date +%T) - [erreur] erreur lors de la suppresion du fichier ${FICHIERS}/fichiers/${f}${EXT_ARCHIVE}" >> $LOG
		fi
	fi
done


rm ${TMP} || echo "$(date +%T) - [erreur] erreur lors de la suppression de ${TMP}" >> $LOG


echo "$(date +%T) - [trace] fin normale" >> $LOG

exit 0
