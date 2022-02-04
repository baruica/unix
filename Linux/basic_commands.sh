#!/bin/bash

ls
ls -a                       # pour voir les fichiers cachés
ls -l
ls -l monfich               # donne les caractéristiques d'un seul fichier
ls --color                  # pour différencier les différentes sortes de fichiers
# Vous voulez que, durant cette session, votre « ls » soit toujours en couleurs:
alias ls=$(ls --color)
# Vous voulez que votre alias soit activé pour toutes les sessions ? Insérez-le dans /etc/bashrc.

cd
cd -                        # pour aller au répertoire précédent

pwd

cp fich_src fich_cible
mv                          # déplace ou renomme (mv ancienfichier nouveaufichier)
touch -m 05041020 fich      # change la date de fich: attribue le 4 Mai à 10 h 20 à votre fichier

mkdir
rm
rm -rf monrep               # efface un répertoire plein
rmdir                       # enlève un répertoire vide

vi                          # édite ou crée un fichier texte

find                        #
whereis                     # recherche de fichier
locate                      # s'appuie sur une base de données située dans /var/lib/slocate/slocate.db

grep                        # recherche de chaîne dans les fichiers

chown                       # changement de propriétaire
chmod                       # changement des autorisations à un fichier
umask

tar                         # pour (dés)archiver
gzip                        # pour (dé)zipper
bzip2                       # quand c'est zippé en bz2
ln -s fichiercible lien     # crée un lien symbolique
cat                         # qui envoie quelque chose vers quelque part (l'écran par défaut)

man                         # manuel
man 5 mtools
info

who                         # les utilisateurs actuellement connectés
whoami
