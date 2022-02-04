#! /bin/sh -

# Execution du .profile de l'utilisateur courant pour recuperer les variables d'environnement
if [ ! -r "/home/$(whoami)/.profile" ]
then
    echo "$(date +%y%m%d) $(date +%T) [erreur] Problème de chargement du profile $(whoami)"
    exit 2
fi
. /home/$(whoami)/.profile


ID_REQ=$1
LOG="${TRACES}/oracle/$(basename $0 .sh)_$(date +"%Y-%m-%d")_ID_REQ(${ID_REQ}).log"
cmd_sqlplus="sqlplus -s ${REPIMMO_USER}/${REPIMMO_PASS}@${REPIMMO_SID}"
RETOUR_UPDATE=0
NB_CHAMPS_SQL=20
EXT_ARCHIVE='.gz'


updateREQ()
{
    echo "$(date +%T) - [trace] updateREQ() $1" >> $LOG

    RETOUR_UPDATE=0
    TENTATIVES=1

    while [ ${TENTATIVES} -le 3 ]
    do
        echo "$(date +%T) - [trace]   tentative numero ${TENTATIVES}" >> $LOG

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
            TENTATIVES=$(expr ${TENTATIVES} + 1)
            if [ ${TENTATIVES} -eq 3 ]
            then
                break
            else
                echo "$(date +%T) - [erreur]    encore $(expr 3 - ${TENTATIVES}) tentatives" >> $LOG
            fi
        fi
    done

    echo "$(date +%T) - [trace] fin updateREQ() avec code retour ${RETOUR_UPDATE}" >> $LOG
    [ $RETOUR_UPDATE -ne 0 ] && exit $RETOUR_UPDATE
}



updateREQ "UPDATE TTPHP_REQUETE SET STATUT = CASE WHEN STATUT = 'En attente' THEN 'En cours' END, DATE_DEB = SYSDATE, PID = $$ WHERE ID_REQUETE = $ID_REQ"


FIC_TEMP="${TRACES}/oracle/${ID_REQ}.tmp"
FIC_SQL="${TRACES}/oracle/${ID_REQ}.sql"
CHAMPS_SQL=1

# oracle n'accepte pas les lignes qui ont plus de 2500 caracteres (code erreur SP2-0027)
# 48000 / 2500 = 19.2 soit 20 colonnes pour stocker la requete
# le découpage fait par le PHP ne tronque pas les mots
while [ ${CHAMPS_SQL} -le ${NB_CHAMPS_SQL} ]
do
    $cmd_sqlplus 1>/dev/null 2>/dev/null <<- EOF >> $FIC_TEMP
    SET ECHO OFF
    SET FEEDBACK OFF
    SET HEADING OFF
    SET LINESIZE 32767
    SET PAGESIZE 0
    SET TRIM ON
    SET TRIMSPOOL ON
    SELECT REQUETE_SQL${CHAMPS_SQL} FROM TTPHP_REQUETE WHERE ID_REQUETE = ${ID_REQ};
    EXIT
EOF

    CHAMPS_SQL=$(expr $CHAMPS_SQL + 1)
done

# on supprime d'éventuelles lignes vide
sed '/^$/d' $FIC_TEMP > $FIC_SQL
rm $FIC_TEMP

cat $FIC_SQL >> $LOG

FIC_REQ="${FICHIERS_REQUETES}/$($cmd_sqlplus <<- EOF
SET FEEDBACK OFF
SET PAGESIZE 0
SET TRIM ON
SELECT FICHIER as f FROM TTPHP_REQUETE WHERE ID_REQUETE = ${ID_REQ};
EXIT
EOF
)"

$cmd_sqlplus 1>/dev/null 2>/dev/null <<- EOF
WHENEVER SQLERROR EXIT 1
WHENEVER OSERROR EXIT 2
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET LINESIZE 32767
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SPOOL $FIC_REQ
$(cat ${FIC_SQL});
SPOOL OFF
EXIT
EOF

RETOUR_SQL=$?

#rm ${FIC_SQL}

if [ $RETOUR_SQL -eq 0 ]
then
    [ -r "${FIC_REQ}${EXT_ARCHIVE}" ] && mv ${FIC_REQ}${EXT_ARCHIVE} ${FIC_REQ}${EXT_ARCHIVE}_$(date)
    gzip $FIC_REQ
    if [ $? -eq 0 ]
    then
        echo "$(date +%T) - [trace] $FIC_REQ compressé" >> $LOG
    else
        echo "$(date +%T) - [erreur] erreur lors de la compression de $FIC_REQ" >> $LOG
    fi

    updateREQ "UPDATE TTPHP_REQUETE SET STATUT = CASE WHEN STATUT = 'En cours' THEN 'Terminée' END, DATE_FIN = SYSDATE, PID = '' WHERE ID_REQUETE = ${ID_REQ}"
else
    [ $RETOUR_SQL -eq 1 ] && echo "$(date +%T) - [erreur] erreur SQL, update KO" >> $LOG
    [ $RETOUR_SQL -eq 2 ] && echo "$(date +%T) - [erreur] erreur OS, update KO" >> $LOG
    [ $RETOUR_SQL -gt 2 ] && echo "$(date +%T) - [erreur] erreur inconnue, update KO" >> $LOG
    rm $FIC_REQ || echo "$(date +%T) - [erreur] erreur lors de la suppresion de $FIC_REQ" >> $LOG

    updateREQ "UPDATE TTPHP_REQUETE SET STATUT = CASE WHEN STATUT = 'En cours' THEN 'En erreur' END, DATE_FIN = '', PID = '' WHERE ID_REQUETE = $ID_REQ"
fi


echo "$(date +%T) - [trace] fin normale" >> $LOG

exit 0
