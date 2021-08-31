#!/bin/bash
#----------
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"
#----------
while :; do
	clear
	docker image ls | awk 'NR!=1' | tr -s ' ' '@' > tmp/image.lst
	curdate=$(date +'%D %T %p')

	echo -e "${GREEN}docksmoll 1.1.1${ENDCOLOR}                  $curdate"
	echo -e "-----------------------------------------------------"
	# docker ps
	# docker image
	cat tmp/image.lst
	echo -e "-----------------------------------------------------"
	echo -e "[1] SEARCH IMAGE | [4] CREATE CONTAINER | [7] START"
	echo -e "[2] PULL IMAGE   | [5] RENAME CONTAINER | [8] STOP"
	echo -e "[3] DROP IMAGE   | [6] DROP CONTAINER   | [9] RESTART"
	echo -e "-----------------------------------------------------"
	while :; do
		echo -en "${YELLOW}>>${ENDCOLOR}"
		read -p " "
	done
done

# db_info=$(mongo --quiet localhost:27017/smolldock --eval 'db.user.find()')
# Docker Command
# ----------------------------------------------------------------------
# - docker search $image                       ## search available image
# - docker pull $image:$tag                    ## download image dengan tag. default latest
# - docker container ls -a                     ## get all container process status
# - docker start/stop/restart $container_id    ## manage container service
# - docker exec -it $container_name /bin/bash  ## getting to container's tty
# - docker info                                ## get additional info
