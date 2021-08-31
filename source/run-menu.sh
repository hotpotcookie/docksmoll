#!/bin/bash
#----------
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"
#----------
main() {
	while :; do
		clear
		docker image ls | awk 'NR!=1' | tr -s ' ' '@' > tmp/image.lst & wait
		docker.exe container ls -a | awk 'NR!=1' | tr -s ' ' '@' > tmp/container.lst & wait
		curdate=$(date +'%D %T %p')

		echo -e "${GREEN}docksmoll 1.1.1${ENDCOLOR}                  $curdate"
		echo -e "-----------------------------------------------------"
		# docker image	
		# docker ps
		if [[ ! -s tmp/image.lst ]]; then
			echo "NO IMAGES HAVE BEEN LOADED"
		else
			cat tmp/image.lst		
		fi
		if [[ ! -s tmp/container.lst ]]; then
			echo "NO CONTAINERS HAVE BEEN CREATED"
		else
			cat tmp/container.lst		
		fi

		echo -e "-----------------------------------------------------"
		echo -e "[1] SEARCH IMAGE | [4] CREATE CONTAINER | [7] START"
		echo -e "[2] PULL IMAGE   | [5] RENAME CONTAINER | [8] STOP"
		echo -e "[3] DROP IMAGE   | [6] DROP CONTAINER   | [9] RESTART"
		echo -e "-----------------------------------------------------"
		while :; do
			echo -en "${YELLOW}>>${ENDCOLOR}"
			read -p " " opt
			case $opt in 
				1) search_img;;	4) create_ctr;;	7) start_ctr;;
				2) pull_img;;	5) rename_ctr;;	8) stop_ctr;;
				3) drop_img;;	6) drop_ctr;;	9) restart_ctr;;
			esac
		done
	done
}

search_img() {
	echo "--"
	read -p ":: ENTER IMAGE KEYWORD" image
	docker search $image
	echo "--"	
}
pull_img() {
	echo "--"
	read -p ":: ENTER IMAGE KEYWORD" image
	docker pull $image
	echo "--"		
}

# db_info=$(mongo --quiet localhost:27017/smolldock --eval 'db.user.find()')
# Docker Command
# ----------------------------------------------------------------------
# - docker search $image                       ## search available image
# - docker pull $image:$tag                    ## download image dengan tag. default latest
# - docker container ls -a                     ## get all container process status
# - docker start/stop/restart $container_id    ## manage container service
# - docker exec -it $container_name /bin/bash  ## getting to container's tty
# - docker info                                ## get additional info
