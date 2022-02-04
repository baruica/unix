#!/bin/bash

df -Th				# list the disk space usage

sudo fdisk -l		# list the partition tables


#
#	stay in root mode
#
# Instead of having to constantly type in 'sudo' every time you need to make an admin change, you can use one of these commands to act as root.
#
sudo -s -H			# to switch to full root mode

sudo -s				# to switch to using root mode, but still act as your user account


#
#	install 7-Zip
#
sudo apt-get install p7zip


#
#	Supprimer les paquets temporaires ou partiels
#
# Lorsque vous téléchargez des paquets .deb, ceux-ci sont sauvegardés dans le répertoire /var/cache/apt/archives.
# Ces paquets sont inutiles, ils pourraient uniquement être utilisés pour réinstaller l'application sans connexion internet.
# Avec le temps ce répertoire peut atteindre une taille assez conséquente, il est donc judicieux de le vider régulièrement.
sudo apt-get autoclean
# L'option autoclean permet de supprimer les copies des paquets désinstallés


#
#	Supprimer les fichiers de langue inutiles
#
# Pour cette astuce il est nécessaire d'installer le paquet localepurge.
sudo apt-get install localepurge
# Localepurge est un script qui récupère l'espace sur le disque gaspillé par des fichiers de locales et des pages de manuel localisées non nécessaires.
# Il sera automatiquement invoqué à chaque installation avec apt.
localepurge
