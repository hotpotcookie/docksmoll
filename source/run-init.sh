#!/bin/bash
#----------
echo "[dsmoll]: checking required package ..."
check_mongodb=$(dpkg-query -l | grep "mongo")
check_docker=$(dpkg-query -l | grep "docker")

if [[ ! "$check_mongodb" ]]; then
	read -p "[dsmoll]: mongodb not found. Install now (y/n) " opt
	if [[ "$opt" == "y" || "$opt" == "Y" ]]; then
		bash run-auto-installer.sh
	fi
else
	echo "[dsmoll]: setting up mongodb ..."	
fi