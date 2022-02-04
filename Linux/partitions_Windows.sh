#!/bin/bash

#
#	Création d'un point de montage
#
sudo mkdir <point de montage>
# où <point de montage> correspond à l'emplacement et au nom du répertoire servant de point de montage.
# Ainsi, vous pouvez placer un point de montage où vous voulez dans votre arborescence.

# Il est possible de faire apparaître automatiquement un lien vers vos partitions Windows sur votre bureau,
# dans le poste de travail et dans le menu "Raccourcis" du tableau de bord.
# Pour ce faire, le ou les points de montage doivent se trouver dans le répertoire /media.
sudo mkdir /media/windows
sudo mkdir /media/documents
sudo mkdir /media/mediatheque


#
# Lister les partitions actives de vos disques
#
sudo fdisk -l


# Les partitions à monter automatiquement sont renseignées dans le fichier /etc/fstab.
# Vous pouvez ouvrir ce fichier avec un logiciel d'édition de texte simple, comme gEdit (sous Ubuntu).
# Si vous préférez l'austérité du terminal ou si vous ne disposez pas d'un environnement graphique,
# vous pourriez aussi utiliser Nano, qui est un logiciel en console, basique mais facile d'utilisation.

# Pour modifier le fichier /etc/fstab, vous avez besoin d'acquérir les droits d'administration.
# Vous ouvrirez donc votre logiciel d'édition de texte en faisant précéder votre commande, dans un terminal,
# par "sudo" dans le cas d'applications en mode console ou par "gksudo" ou "kdesu" pour les applications graphiques.

# faire une copie de sauvegarde avant la modification
sudo cp /etc/fstab /etc/fstab_sauvegarde

# Ensuite Alt+F2 puis :
gksudo gedit /etc/fstab				# Ubuntu
# ou
kdesu kwrite /etc/fstab				# Kubuntu
# ou
gksudo mousepad /etc/fstab			# Xubuntu
# ou
sudo nano /etc/fstab


#
#	Ajouter une partition de système de fichiers NTFS
#
# Pour ajouter une partition dont le système de fichiers est le NTFS,
# il vous suffit d'ajouter une instruction à la fin de votre fichier /etc/fstab, sous la forme suivante:

# Partitions Windows - NTFS
/dev/hda1	/media/windows	ntfs	ro,user,auto,gid=100,nls=utf8,umask=002	0	0

# ntfs indique que le système de fichiers de votre partition est le NTFS.
# Viennent ensuite les options de montage, qui donnent certaines qualifications à votre partition:
#	* L'option ro indique que vous souhaitez accéder à cette partition en lecture seule (read-only).
#	* user permet à n'importe quel utilisateur de monter ou démonter cette partition, donc pas seulement le super-utilisateur. Vous pouvez l'omettre si vous ne désirez pas ce comportement.
#	* auto est l'option indiquant que la partition doit être montée automatiquement au démarrage.
#	* gid=100 assignera l'ensemble des fichiers au groupe dont le gid est 100.
#     Sous Ubuntu, le gid 100 correspond au groupe users, auquel tous les utilisateurs font normalement partie.
#     Si vous omettez cette option, tous les fichiers seront assignés au groupe 0, soit root (le super-utilisateur).
#	* nls=utf8 permet l'utilisation du jeu de caratère UTF8 sur les partitions.
#	* L'option umask=002 donnera les droits d'accès, sur l'ensemble des répertoires et fichiers, en lecture et en écriture à tous, de même qu'en exécution au propriétaire du fichier.
#     (L'umask se calcule de la façon suivante: 777 - umask = 777 - 002 = 775, soit rwxrwxr-x.
#     Toutefois, cette option n'a aucun effet au niveau de l'écriture dans les fichiers et répertoires, car la partition est montée en lecture seule: personne ne peut donc y écrire.
