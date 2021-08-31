#!/bin/bash
#----------
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"
#----------
apt-get update & wait; echo -e "----------------------------------------- ${GREEN}(installing dependencies)${ENDCOLOR}"
apt install build-essential apt-transport-https ca-certificates curl software-properties-common & wait; echo "----------------------------------------- ${GREEN}(adding gpg key)${ENDCOLOR}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - & wait; echo "----------------------------------------- ${GREEN}(adding docker to apt lists)${ENDCOLOR}"
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" & wait; echo "----------------------------------------- ${GREEN}(updating apt)${ENDCOLOR}"
apt-get update & wait; echo "----------------------------------------- ${GREEN}(updating apt cache)${ENDCOLOR}"
apt-cache policy docker-ce & wait; echo "----------------------------------------- ${GREEN}(installing docker)${ENDCOLOR}"
apt-get install docker-ce & wait; echo "-----------------------------------------"
echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: finishing up ..."