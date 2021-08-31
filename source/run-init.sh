#!/bin/bash
#----------
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"
#----------
echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: checking required package ..."
check_docker=$(dpkg-query -l | grep "docker")

if [[ ! "$check_docker" ]]; then
	echo -en "${YELLOW}[dsmoll]${ENDCOLOR}"
	read -p ": docker not found. Install now (y/n): " opt
	if [[ "$opt" == "y" || "$opt" == "Y" ]]; then
		echo -e "----------------------------------------- ${GREEN}(updating apt)${ENDCOLOR}"			
		bash source/run-auto-installer.sh & wait; sleep 5s
		bash source/run-menu.sh
	else
		echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: exitting ..."
		exit 0
	fi
else
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: running docker service ..."	
	bash source/run-menu.sh
fi
