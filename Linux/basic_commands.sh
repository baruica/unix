#!/bin/bash

ls
ls -a                       # pour voir les fichiers cach�s
ls -l
ls -l monfich               # donne les caract�ristiques d'un seul fichier
ls --color                  # pour diff�rencier les diff�rentes sortes de fichiers
# Vous voulez que, durant cette session, votre � ls � soit toujours en couleurs:
alias ls=$(ls --color)
# Vous voulez que votre alias soit activ� pour toutes les sessions ? Ins�rez-le dans /etc/bashrc.

cd
cd -                        # pour aller au r�pertoire pr�c�dent

pwd

cp fich_src fich_cible
mv                          # d�place ou renomme (mv ancienfichier nouveaufichier)
touch -m 05041020 fich      # change la date de fich: attribue le 4 Mai � 10 h 20 � votre fichier

mkdir
rm
rm -rf monrep               # efface un r�pertoire plein
rmdir                       # enl�ve un r�pertoire vide

vi                          # �dite ou cr�e un fichier texte

find                        #
whereis                     # recherche de fichier
locate                      # s'appuie sur une base de donn�es situ�e dans /var/lib/slocate/slocate.db

grep                        # recherche de cha�ne dans les fichiers

chown                       # changement de propri�taire
chmod                       # changement des autorisations � un fichier
umask

tar                         # pour (d�s)archiver
gzip                        # pour (d�)zipper
bzip2                       # quand c'est zipp� en bz2
ln -s fichiercible lien     # cr�e un lien symbolique
cat                         # qui envoie quelque chose vers quelque part (l'�cran par d�faut)

man                         # manuel
man 5 mtools
info

who                         # les utilisateurs actuellement connect�s
whoami
