#!/bin/bash
#----------
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[36m"
ENDCOLOR="\e[0m"
#----------
## MAIN METHOD
main() {
	while :; do
		clear
		docker image ls | awk 'NR!=1' | tr -s ' ' '@' > tmp/image.lst & wait
		docker container ls -a | awk 'NR!=1' | tr -s ' ' '@' > tmp/container.lst & wait
		curdate=$(date +'%D %T %p')
		echo -e "${YELLOW}docksmoll 1.1.1${ENDCOLOR}                  $curdate"
		echo -e "-----------------------------------------------------"
		body_img=$(sudo docker images -a --format "table {{.Repository}}:{{.Tag}}\t| {{.ID}} | {{.Size}}" | awk 'NR!=1')
		body_ctr=$(sudo docker container ls -a --format "table {{.Names}} ({{.Image}})\t| {{.ID}} | {{.Status}}" | awk 'NR!=1')
		# docker image -a
		# docker ps
		if [[ ! -s tmp/image.lst ]]; then
			echo "NO IMAGES HAVE BEEN LOADED"
		else
			echo -e "${GREEN}AVAILABLE IMAGES${ENDCOLOR}\n-----------------------------------------------------"
			echo -e "$body_img"; echo "-----------------------------------------------------"; fi
		if [[ ! -s tmp/container.lst ]]; then
			echo "NO CONTAINERS HAVE BEEN CREATED"
		else
			echo -e "${GREEN}CREATED CONTAINERS${ENDCOLOR}\n-----------------------------------------------------"
			echo -e "$body_ctr"; echo "-----------------------------------------------------"; fi

		echo -e "${BLUE}[1]${ENDCOLOR} SEARCH IMAGE | ${BLUE}[4]${ENDCOLOR} CREATE CONTAINER | ${BLUE}[7]${ENDCOLOR} START"
		echo -e "${BLUE}[2]${ENDCOLOR} PULL IMAGE   | ${BLUE}[5]${ENDCOLOR} RENAME CONTAINER | ${BLUE}[8]${ENDCOLOR} STOP"
		echo -e "${BLUE}[3]${ENDCOLOR} DROP IMAGE   | ${BLUE}[6]${ENDCOLOR} DROP CONTAINER   | ${BLUE}[9]${ENDCOLOR} RESTART"
		echo -e "-----------------------------------------------------"
		echo -e "${BLUE}[N]${ENDCOLOR} NEW COMMIT   | ${BLUE}[T]${ENDCOLOR} CREATE IMAGE TAG | ${BLUE}[P]${ENDCOLOR} PUSH"
		echo -e "${BLUE}[S]${ENDCOLOR} JOIN SHELL   | ${BLUE}[C]${ENDCOLOR} CLEAR SCREEN     | ${BLUE}[E]${ENDCOLOR} EXIT   "
		echo -e "-----------------------------------------------------"
		while :; do
			echo -en "${YELLOW}>>${ENDCOLOR}"
			read -p " " opt
			case $opt in
				1) search_img;;	4) create_ctr;;	7) start_ctr;;
				2) pull_img;;	5) rename_ctr;;	8) stop_ctr;;
				3) drop_img;;	6) drop_ctr;;	9) restart_ctr;;
				"S") join_shell;; "C") break;; "E") exit 0;;
			esac
		done
	done
}

## SUB ACTION
search_img() {
	echo "--"
	read -p ":: ENTER IMAGE NAME: " image
	header=$(docker search --format "table {{.Name}} ({{.StarCount}})\t| {{.IsAutomated}}\t| {{.IsOfficial}}" $image | awk 'NR==1')
	body=$(docker search --format "table {{.Name}} ({{.StarCount}})\t| {{.IsAutomated}}\t| {{.IsOfficial}}" $image | awk 'NR!=1')
	header_len=$(echo "$header" | wc -c); header_len=$((--header_len))
	for i in $(seq 1 $header_len); do echo -n "-" ;done; echo ""
	echo -e "${GREEN}$header${ENDCOLOR}"
	for i in $(seq 1 $header_len); do echo -n "-" ;done; echo ""
	echo "$body"
	for i in $(seq 1 $header_len); do echo -n "-" ;done; echo ""
	echo " "
}
pull_img() {
	echo "--"
	read -p ":: ENTER IMAGE NAME: " image
	echo "--"
	docker pull $image
	echo " "
}
drop_img() {
	echo "--"
	read -p ":: ENTER IMAGE NAME: " image
	read -p ":: RE-ENTER IMAGE NAME: " image2
	echo "--"
	check_ref=$(docker container ls -a | grep "$image")
	if [[ "$image" == "$image2" ]]; then
		if [[ "$image" && "$image" != "\n" && "$image" == " " ]]; then
			echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: image $image have reference(s) to existing container"
			echo -en "${YELLOW}[dsmoll]${ENDCOLOR}: force remove image ? (y):"
			read -p " " opt
			if [[ "$opt" == "y" || "$opt" == "Y" ]]; then
				docker rmi -f $image
				docker image prune -f
			fi
		else
			docker rmi $image
			docker image prune -f
		fi
	fi
	echo " "
}
create_ctr() {
	echo "--"
	read -p ":: ENTER IMAGE NAME: " image
	read -p ":: ENTER CONTAINER NAME: " container
	read -p ":: CHOOSE INTERPRETER: " interpreter
	echo "--"
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: container have been created ..."
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: initiating shell ...\n--"
	docker run -it --name "$container" $image $interpreter
	echo " "
}
rename_ctr() {
	echo "--"
	read -p ":: ENTER CONTAINER NAME: " container
	read -p ":: ENTER NEW CONTAINER NAME: " container2
	echo "--"
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: renaming a container: $container > $container2"; docker rename "$container" "$container2"
	echo " "
}
drop_ctr() {
	echo "--"
	read -p ":: ENTER CONTAINER NAME: " container
	read -p ":: RE-ENTER CONTAINER NAME: " container2
	echo "--"
	if [[ "$container" == "$container2" ]]; then
		echo -en "${YELLOW}[dsmoll]${ENDCOLOR}: deleting a container: "; docker rm "$container"
	fi
	echo " "
}
start_ctr() {
	echo "--"
	read -p ":: ENTER CONTAINER ID: " container
	echo "--"
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: running a container ..."
	echo -en "${YELLOW}[dsmoll]${ENDCOLOR}: container id: "
	docker start "$container"
	echo " "
}
stop_ctr() {
	echo "--"
	read -p ":: ENTER CONTAINER ID: " container
	echo "--"
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: stopping a container ..."
	echo -en "${YELLOW}[dsmoll]${ENDCOLOR}: container id: "
	docker stop "$container"
	echo " "
}
restart_ctr() {
	echo "--"
	read -p ":: ENTER CONTAINER ID: " container
	echo "--"
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: restarting a container ..."
	echo -en "${YELLOW}[dsmoll]${ENDCOLOR}: container id: "
	docker restart "$container"
	echo " "
}
join_shell() {
	echo "--"
	read -p ":: ENTER CONTAINER NAME: " container
	read -p ":: CHOOSE INTERPRETER: " interpreter
	echo "--"
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: initiating shell ...\n--"
	docker exec -it "$container" "$interpreter"
	echo " "
}

## RUN MAIN METHOD
main

# db_info=$(mongo --quiet localhost:27017/smolldock --eval db.user.find())
# Docker Command
# ----------------------------------------------------------------------
# - docker search $image                       ## search available image
# - docker pull $image:$tag                    ## download image dengan tag. default latest
# - docker container ls -a                     ## get all container process status
# - docker run -it --name $container $image    ## create container + run init
# - docker start/stop/restart $container_id    ## manage container service
# - docker exec -it $container_name /bin/bash  ## getting to container's tty
# - docker info                                ## get additional info
# ----------------------------------------------------------------------
# ~ ubuntu (12696)
#	docker search $image | awk 'NR!=1' | tr -s ' ' '@' > tmp/search_img.lst
#	while read -r line; do
#		range_deli=$(echo "$line" | tr -cd '@' | wc -c)
#		range_deli=$((--range_deli))
#		img_name=$(echo $line | cut -d '@' -f 1)
#		echo "$range_deli $img_name"
#	done < "tmp/search_img.lst"
# docker fitur
# - commit
#	$ docker commit $container $image:$tag
# - tag
#	$ docker tag $image-id $image:$tag
# - login & push
#	$ docker login --username $username --password -$password 2> tmp/auth-suppress.info
#	$ if [[ ! $(cat tmp/auth-suppress.info | grep "Error") ]]
#	$ docker push
