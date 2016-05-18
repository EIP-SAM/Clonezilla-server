#!/bin/bash
#Configuration DRBL
#Script v1.0
#Steven


echo "------------------------------------------------"
echo "|             Sam-Solution & DRBL              |"
echo "------------------------------------------------"

if [ $UID == '0' ]; then
	if [ $SUDO_USER == "" ]; then
	    $SUDO_USER = $USER
	fi
	echo
else
    {
	echo
	echo "---------------- Installation annulée -----------------"
        echo "** Rappel: Vous devez éxécuter ce script en root (sudo ./Sam-DRBL.sh) **"
        echo
	exit 1
        }
fi


echo "------------------------------------------------"
echo "|         Script de configuration DRBL         |"
echo "------------------------------------------------"
echo

echo "Vous devez être connecté à internet avant de poursuivre :"

#if [[ "$(ping -c 3 37.61.54.158 | grep '100% packet loss' )" != "" ]]; then
if [[ "$(ping -c 3 8.8.8.8 | grep '100% packet loss' )" != "" ]]; then
    echo "Nous n'avons pas pu établir de connexion internet"
    echo "Veuillez vérifier votre connexion internet et relancer le script d'installation"
    exit 1
else
    echo "Connexion à internet valide, vous pouvez continuer."
    echo "Êtes-vous sûr de vouloir continuer ? [yes/no]"
    read answer

    if [ ${answer:-no} == 'yes' ]; then

	echo "------------------------------------------------"
	echo "|      Préparation des interfaces réseaux      |"
	echo "------------------------------------------------"
	echo

	echo "Mise à jour du fichier interfaces défini dans /etc/network/"
	cp interfaces /etc/network/
	echo "Ok"
	echo

	#Debian
	echo "Redémarrage des interfaces réseaux."
	/etc/init.d/networking restart
	sleep 10 &
	wait %1
	echo "Ok"
	echo

	#Ubuntu
	#echo "Redémarrage des interfaces réseaux."
	#service network-manager restart
	#sleep 10 &
	#wait %1
	#echo "Ok"
	#echo
	
	echo "------------------------------------------------"
	echo "|  Préparation à l’installation de clonezilla  |"
	echo "------------------------------------------------"
	echo
	
	echo "Installation de la clé."
	wget -q http://drbl.org/GPG-KEY-DRBL -O- | apt-key add -
	echo
	
	echo "Mise à jour du fichier sources.list définit dans /etc/apt/"
	cp sources.list /etc/apt/
	echo "Ok"
	echo
	
	echo "Téléchargement des listes de paquets à partir des repositories."
	apt-get update
	echo "Done"
	echo 
	
	echo "Installation de Clonezilla."
	apt-get install drbl -y
	echo "Ok"
	echo
	
	echo "------------------------------------------------"
	echo "|                  Setup DRBL                  |"
	echo "------------------------------------------------"

	echo	
	echo" Exécution de /usr/sbin/drblsrv -i"
	/usr/sbin/drblsrv -i -n n -c n -g n -o 1
	echo

	echo	
	echo "Exécution de drblpush -c /etc/drbl/Sam-drblpush-Debian8.conf"
	cp Sam-drblpush-Debian8.conf /etc/drbl/Sam-drblpush-Debian8.conf
	sleep 2 &
	wait %2
	drblpush -c /etc/drbl/Sam-drblpush-Debian8.conf
	echo

	echo "Clonezilla starting..."
	sleep 2
	#Ubuntu/Debian
	drbl-ocs -b -l en_US.UTF-8 -y1 -p poweroff select_in_client
	echo

	echo
	echo "------------------- Installation OK -------------------"
	echo "-------- Clients prêts à être clonés/restaurés --------"
	echo "------ Éxécution du script Sam-DRBL.sh terminée -------"
	echo "--- Je vous souhaite la bienvenue chez Sam-Solution ---"
	echo
	
    else
	echo "---------------- Installation annulée -----------------"
	echo
	exit 0
    fi
fi
