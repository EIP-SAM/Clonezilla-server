#!/bin/bash

######################################
# Configuration DRBL				 #
# 									 #
# Steven - 05/2016					 #
# 									 #
# Syntaxe: su -c ./Sam-DRBL.sh	     #
# 									 #
# VERSION= "0.2"					 #
######################################


echo "------------------------------------------------"
echo "|             Sam-Solution & DRBL              |"
echo "------------------------------------------------"

if [ $UID -ne '0' ]; then
	echo
	echo "---------------- Installation cancelled -----------------"
        echo "** Reminder: you must be administrator to execute this script (su -c ./Sam-DRBL_Debian8.x.sh) **"
        echo
	exit 1
fi

echo "------------------------------------------------"
echo "|         Configuration script of DRBL         |"
echo "------------------------------------------------"
echo

echo "You must be connected to internet before continuing."

if [[ "$(ping -c 3 8.8.8.8 | grep '100% packet loss' )" != "" ]]; then
    echo "Unable to establish internet connection, please check your connection and run the install script again."
    exit 1
else
    echo "Internet connected, you can continue."
    echo "Are you sure to continue ? [Yes/no]"
    read answer

    if [ ${answer:-no} == 'yes' ] || [ ${answer:-no} == 'YES' ] || [ ${answer:-no} == 'y' ] || [ ${answer:-no} == 'Y' ] || [ "$answer" = "" ]; then

	echo "------------------------------------------------"
	echo "|          Setup of network interface           |"
	echo "------------------------------------------------"
	echo

	echo "Update file interfaces defined in /etc/network/"
	cp Debian_8.x/interfaces /etc/network/
	echo "Ok"
	echo

	echo "Restart network interfaces."
	/etc/init.d/networking restart
	sleep 5 &
	wait %1
	echo "Ok"
	echo
	
	echo "------------------------------------------------"
	echo "|  Preparation for installation of clonezilla  |"
	echo "------------------------------------------------"
	echo
	
	echo "Installation of the key."
	wget -q http://drbl.org/GPG-KEY-DRBL -O- | apt-key add -
	echo

	echo "Update file sources.list defined in /etc/apt/"
	cp Debian_8.x/sources-Debian8.list /etc/apt/
	mv /etc/apt/sources-Debian8.list /etc/apt/sources.list
	echo "Ok"
	echo
	
	echo "Download lists of packages from repository."
	apt-get update
	echo "Done"
	echo 
	
	echo "Installation of Clonezilla."
	apt-get install drbl -y
	echo "Ok"
	echo
	
	echo "------------------------------------------------"
	echo "|                  Setup DRBL                  |"
	echo "------------------------------------------------"

	echo	
	echo "Execution of /usr/sbin/drblsrv -i"
	/usr/sbin/drblsrv -i -n n -c n -g n -o 1
	echo

	echo "Modification of drblpush defined in /usr/sbin/"
	cp Debian_8.x/drblpush /usr/sbin/
	echo "Ok"

	echo	
	echo "Execution of drblpush -c /etc/drbl/Sam-drblpush-Debian8.conf"
	cp Debian_8.x/Sam-drblpush-Debian8.conf /etc/drbl/
	sleep 2 &
	wait %1
	drblpush -c /etc/drbl/Sam-drblpush-Debian8.conf
	echo

	echo "Clonezilla starting..."
	sleep 2
	drbl-ocs -b -l en_US.UTF-8 -y1 -p poweroff select_in_client
	echo

	echo
	echo "------------------- Installation OK -------------------"
	echo "--------- Clients ready to be cloned/restored ---------"
	echo "------ Execution of script Sam-DRBL.sh completed ------"
	echo "--------- I wish you Welcome to Sam-Solution. ---------"
	echo
	
    else
	echo "---------------- Installation cancelled -----------------"
	echo
	exit 0
    fi
fi
