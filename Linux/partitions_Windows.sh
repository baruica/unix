#!/bin/bash

#
#	Cr�ation d'un point de montage
#
sudo mkdir <point de montage>
# o� <point de montage> correspond � l'emplacement et au nom du r�pertoire servant de point de montage.
# Ainsi, vous pouvez placer un point de montage o� vous voulez dans votre arborescence.

# Il est possible de faire appara�tre automatiquement un lien vers vos partitions Windows sur votre bureau,
# dans le poste de travail et dans le menu "Raccourcis" du tableau de bord.
# Pour ce faire, le ou les points de montage doivent se trouver dans le r�pertoire /media.
sudo mkdir /media/windows
sudo mkdir /media/documents
sudo mkdir /media/mediatheque


#
# Lister les partitions actives de vos disques
#
sudo fdisk -l


# Les partitions � monter automatiquement sont renseign�es dans le fichier /etc/fstab.
# Vous pouvez ouvrir ce fichier avec un logiciel d'�dition de texte simple, comme gEdit (sous Ubuntu).
# Si vous pr�f�rez l'aust�rit� du terminal ou si vous ne disposez pas d'un environnement graphique,
# vous pourriez aussi utiliser Nano, qui est un logiciel en console, basique mais facile d'utilisation.

# Pour modifier le fichier /etc/fstab, vous avez besoin d'acqu�rir les droits d'administration.
# Vous ouvrirez donc votre logiciel d'�dition de texte en faisant pr�c�der votre commande, dans un terminal,
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
#	Ajouter une partition de syst�me de fichiers NTFS
#
# Pour ajouter une partition dont le syst�me de fichiers est le NTFS,
# il vous suffit d'ajouter une instruction � la fin de votre fichier /etc/fstab, sous la forme suivante:

# Partitions Windows - NTFS
/dev/hda1	/media/windows	ntfs	ro,user,auto,gid=100,nls=utf8,umask=002	0	0

# ntfs indique que le syst�me de fichiers de votre partition est le NTFS.
# Viennent ensuite les options de montage, qui donnent certaines qualifications � votre partition:
#	* L'option ro indique que vous souhaitez acc�der � cette partition en lecture seule (read-only).
#	* user permet � n'importe quel utilisateur de monter ou d�monter cette partition, donc pas seulement le super-utilisateur. Vous pouvez l'omettre si vous ne d�sirez pas ce comportement.
#	* auto est l'option indiquant que la partition doit �tre mont�e automatiquement au d�marrage.
#	* gid=100 assignera l'ensemble des fichiers au groupe dont le gid est 100.
#     Sous Ubuntu, le gid 100 correspond au groupe users, auquel tous les utilisateurs font normalement partie.
#     Si vous omettez cette option, tous les fichiers seront assign�s au groupe 0, soit root (le super-utilisateur).
#	* nls=utf8 permet l'utilisation du jeu de carat�re UTF8 sur les partitions.
#	* L'option umask=002 donnera les droits d'acc�s, sur l'ensemble des r�pertoires et fichiers, en lecture et en �criture � tous, de m�me qu'en ex�cution au propri�taire du fichier.
#     (L'umask se calcule de la fa�on suivante: 777 - umask = 777 - 002 = 775, soit rwxrwxr-x.
#     Toutefois, cette option n'a aucun effet au niveau de l'�criture dans les fichiers et r�pertoires, car la partition est mont�e en lecture seule: personne ne peut donc y �crire.
