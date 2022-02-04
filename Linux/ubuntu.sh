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
# Lorsque vous t�l�chargez des paquets .deb, ceux-ci sont sauvegard�s dans le r�pertoire /var/cache/apt/archives.
# Ces paquets sont inutiles, ils pourraient uniquement �tre utilis�s pour r�installer l'application sans connexion internet.
# Avec le temps ce r�pertoire peut atteindre une taille assez cons�quente, il est donc judicieux de le vider r�guli�rement.
sudo apt-get autoclean
# L'option autoclean permet de supprimer les copies des paquets d�sinstall�s


#
#	Supprimer les fichiers de langue inutiles
#
# Pour cette astuce il est n�cessaire d'installer le paquet localepurge.
sudo apt-get install localepurge
# Localepurge est un script qui r�cup�re l'espace sur le disque gaspill� par des fichiers de locales et des pages de manuel localis�es non n�cessaires.
# Il sera automatiquement invoqu� � chaque installation avec apt.
localepurge
