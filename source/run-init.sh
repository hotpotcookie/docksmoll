#!/bin/bash
#----------
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"
#----------
echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: checking required package ..."
check_docker=$(dpkg-query -l | grep "docker")
check_wsl=$(cat /proc/version | grep -E "Microsoft|WSL")
if [[ ! -d "tmp/" ]]; then
	mkdir tmp
fi
touch tmp/container.lst
touch tmp/image.lst
#----------
if [[ ! "$check_docker" && ! "$check_wsl" ]]; then
	echo -en "${YELLOW}[dsmoll]${ENDCOLOR}"
	read -p ": docker not found. Install now (y/n): " opt
	if [[ "$opt" == "y" || "$opt" == "Y" ]]; then
		echo -e "----------------------------------------------------- ${GREEN}(updating apt)${ENDCOLOR}"			
		bash source/run-auto-installer.sh & wait; sleep 3s
		bash source/run-menu.sh
	else
		echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: exitting ..."
		exit 0
	fi
else
	if [[ "$check_wsl" ]]; then
		echo -en "${YELLOW}[dsmoll]${ENDCOLOR}"
		read -p ": specify the docker.exe path: " command
		echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: running docker service ..."; sleep 3s
		bash source/run-menu.sh "$command"
		exit 0		
	fi	
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: running docker service ..."; sleep 3s
	bash source/run-menu.sh
	exit 0
fi
#----------
