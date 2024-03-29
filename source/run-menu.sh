#!/bin/bash
#----------
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[36m"
PURPLE="\e[35m"
ENDCOLOR="\e[0m"
#----------
check_wsl=$(cat /proc/version | grep -E "Microsoft|WSL")
if [[ "$1" ]]; then
	docker_="$1"
else
	docker_=$(which docker)	
fi
#----------
## MAIN METHOD
main() {
	while :; do
		clear
		"$docker_" image ls | awk 'NR!=1' | tr -s ' ' '@' > tmp/image.lst & wait
		"$docker_" container ls -a | awk 'NR!=1' | tr -s ' ' '@' > tmp/container.lst & wait
		curdate=$(date +'%D %T %p')
		echo -e "${GREEN}docksmoll 1.1.1${ENDCOLOR}                  $curdate"
		echo -e "-----------------------------------------------------"
		echo -e "${GREEN}command${ENDCOLOR}: $docker_"				
		echo -e "-----------------------------------------------------"		
		body_img=$(sudo "$docker_" image ls --format "table {{.Repository}}:{{.Tag}}\t| {{.ID}} | {{.Size}}" | awk 'NR!=1')
		body_ctr=$(sudo "$docker_" container ls -a --format "table {{.Names}} ({{.Image}})\t| {{.ID}} | {{.Status}}" | awk 'NR!=1')
		echo -e "$body_ctr" > tmp/container.stat		
		#----------

		#----------
		if [[ ! -s tmp/image.lst ]]; then
			echo "NO IMAGES HAVE BEEN LOADED"
		else
			echo -e "${YELLOW}AVAILABLE IMAGES${ENDCOLOR}\n-----------------------------------------------------"
			echo -e "$body_img"; echo "-----------------------------------------------------"; fi
		if [[ ! -s tmp/container.lst ]]; then
			echo "NO CONTAINERS HAVE BEEN CREATED"
			echo "-----------------------------------------------------";			
		else
			echo -e "${YELLOW}CREATED CONTAINERS${ENDCOLOR}\n-----------------------------------------------------"
			while IFS= read -r line; do
				if [[ "$line" == *"Up"* ]]; then
					echo -e "${GREEN}[+]${ENDCOLOR} $line"
				else
					echo -e "${RED}[x]${ENDCOLOR} $line"
				fi
			done < tmp/container.stat		
			echo "-----------------------------------------------------"; fi

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
				"N") new_commit;; "T") create_tag;; "P") push_img;;
				"S") join_shell;; "C") break;; "E") exit 0;;
			esac
		done
	done
}

## SUB ACTION
search_img() {
	echo "--"
	read -p ":: ENTER IMAGE NAME: " image
	header=$("$docker_" search --format "table {{.Name}} ({{.StarCount}})\t| {{.IsAutomated}}\t| {{.IsOfficial}}" $image | awk 'NR==1')
	body=$("$docker_" search --format "table {{.Name}} ({{.StarCount}})\t| {{.IsAutomated}}\t| {{.IsOfficial}}" $image | awk 'NR!=1')
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
	"$docker_" pull $image
	echo " "
}
drop_img() {
	echo "--"
	read -p ":: ENTER IMAGE NAME: " image
	read -p ":: RE-ENTER IMAGE NAME: " image2
	echo "--"
	check_ref=$("$docker_" container ls -a | grep "$image")
	if [[ "$image" == "$image2" ]]; then
		if [[ "$image" && "$image" != "\n" && "$image" == " " ]]; then
			echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: image $image have reference(s) to existing container"
			echo -en "${YELLOW}[dsmoll]${ENDCOLOR}: force remove image ? (y):"
			read -p " " opt
			if [[ "$opt" == "y" || "$opt" == "Y" ]]; then
				"$docker_" rmi -f $image
				"$docker_" image prune -f
			fi
		else
			"$docker_" rmi $image
			"$docker_" image prune -f
		fi
	fi
	echo " "
}
create_ctr() {
	echo "--"
	read -p ":: ENTER IMAGE NAME: " image
	read -p ":: ENTER CONTAINER NAME: " container
	read -p ":: CHOOSE INTERPRETER: " interpreter
	read -p ":: PUBLISH SPECIFIC PORTS: " port
	echo "--"
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: container have been created ..."
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: initiating shell ...\n--"
	if [[ -z "$port" ]]; then
		"$docker_" run --hostname "$container" -it --privileged --cap-add=SYS_ADMIN -e "TERM=xterm-256color" --name "$container" $image $interpreter				
	else
		"$docker_" run -d -p "$port":"$port" --hostname "$container" -it --privileged --cap-add=SYS_ADMIN -e "TERM=xterm-256color" --name "$container" $image $interpreter		
	fi
	echo " "
}
rename_ctr() {
	echo "--"
	read -p ":: ENTER CONTAINER NAME: " container
	read -p ":: ENTER NEW CONTAINER NAME: " container2
	echo "--"
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: renaming a container: $container > $container2"; "$docker_" rename "$container" "$container2"
	echo " "
}
drop_ctr() {
	echo "--"
	read -p ":: ENTER CONTAINER NAME: " container
	read -p ":: RE-ENTER CONTAINER NAME: " container2
	echo "--"
	if [[ "$container" == "$container2" ]]; then
		echo -en "${YELLOW}[dsmoll]${ENDCOLOR}: deleting a container: "; "$docker_" rm "$container"
	fi
	echo " "
}
start_ctr() {
	echo "--"
	read -p ":: ENTER CONTAINER ID: " container
	echo "--"
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: running a container ..."
	echo -en "${YELLOW}[dsmoll]${ENDCOLOR}: container id: "
	"$docker_" start "$container"
	echo " "
}
stop_ctr() {
	echo "--"
	read -p ":: ENTER CONTAINER ID: " container
	echo "--"
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: stopping a container ..."
	echo -en "${YELLOW}[dsmoll]${ENDCOLOR}: container id: "
	"$docker_" stop "$container"
	echo " "
}
restart_ctr() {
	echo "--"
	read -p ":: ENTER CONTAINER ID: " container
	echo "--"
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: restarting a container ..."
	echo -en "${YELLOW}[dsmoll]${ENDCOLOR}: container id: "
	"$docker_" restart "$container"
	echo " "
}
join_shell() {
	echo "--"
	read -p ":: ENTER CONTAINER NAME: " container
	read -p ":: CHOOSE INTERPRETER: " interpreter
	echo "--"
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: initiating shell ...\n--"
	"$docker_" exec -it "$container" "$interpreter"
	echo " "
}
new_commit() {
	echo "--"
	read -p ":: ENTER CONTAINER NAME: " container
	read -p ":: ENTER IMAGE NAME: " image
	read -p ":: CHOOSE TAG VERSION: " tag
	echo "--"
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: writing image ...\n--"
	"$docker_" commit "$container" "$image":"$tag"
	echo " "
}
create_tag() {
	echo "--"
	read -p ":: ENTER IMAGE ID: " image_id
	read -p ":: ENTER NEW IMAGE NAME: " image
	read -p ":: CHOOSE TAG VERSION: " tag
	echo "--"
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: creating new tag ...\n--"
	"$docker_" tag "$image_id" "$image":"$tag"
	echo " "
}
push_img() {
	echo "--"
	echo -e "${YELLOW}[dsmoll]${ENDCOLOR}: verifying account for Docker.hub ...\n--"
	read -p ":: ENTER USERNAME: " username
	read -sp ":: ENTER PASSWORD: " password
	echo -e "\n--"
	"$docker_" login --username "$username" --password "$password" 2> tmp/auth-suppress.info
	get_status=$(cat tmp/auth-suppress.info | grep "Error")
	if [[ ! "$get_status" ]]; then
		echo "--"
		read -p ":: ENTER IMAGE NAME: " image
		read -p ":: CHOOSE TAG VERSION: " tag
		echo "--"
		"$docker_" push "$image":"$tag"
		echo " "
	else
		echo -e "Authentication failed\n"
	fi
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
