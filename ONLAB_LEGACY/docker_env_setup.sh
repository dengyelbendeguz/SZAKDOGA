#!/bin/bash

# downloads docker, sets it up, pulls images (for starting the enviromnment use docker_env_start.sh)

# Docker install
docker_install() {
# Docker repository
	echo "[+]Init docker..."
	sudo apt-get update

	sudo apt-get install \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg-agent \
		software-properties-common

	# Add Docker’s official GPG key:
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

	# Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88, by searching for the last 8 characters of the fingerprint.
	sudo apt-key fingerprint 0EBFCD88

#	pub   rsa4096 2017-02-22 [SCEA]
#	      9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
#	uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
#	sub   rsa4096 2017-02-22 [S]
	
	sudo add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
	stable"

#	Install Docker Engine
	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io
}

docker_init(){
	if ! command -v docker &> /dev/null; then
		echo "[+]Installing Docker..."
		docker_install
		echo "[+]Docker has installed.. Press a button[]"
		read Verify
	else
		echo "[+]Docker has installed already"
		echo "[+]Press a button.."
		read Verify
	fi
}

# Linux 1 config 
linux1() {
	echo "[+]Initialize Linux 1..."	
	docker_init
	INT="$1"
# 	Verify
	echo "[+]Is everything okay? If not press Ctrl+C.. (Press enter) "
	read Verify

#	Ryu
	echo "[+]Pull Ryu controller from osrg/run"
	#ÁLLJ A JÓ MAPPÁBAN!!! (ahol a Dockerfile és a másolandó állomány van)
	sudo docker build . -t my_ryu
	echo "[+]Ryu has been pulled. Everything is okay?"
	read Verify
	
#	Alpine
	echo "[+]Pull alpine image from alpine:latest"
	sudo docker pull alpine:latest
	echo "[+]Alpine has been pulled. Everything is okay?"
	read Verify
	
#	OVS
	echo "[+]Pull ovs container from socketplane/openvswitch"
	sudo docker pull socketplane/openvswitch
	echo "[+]OVS has been pulled. Everything is okay?"
	read Verify	

#	Verify
	echo "[+]Docker images:"
	sudo docker images
	echo "[+]All docker containers (sudo docker ps -a):"
	sudo docker ps -a
	echo "[+]Docker network:"
	sudo docker network ls
	read Verify
}

# Linux 2 config
linux2() {
	echo "[+]Initialize Linux 2..."
	docker_init
	INT="$1"
# 	Verify
	echo "[+]Is everything okay? If not press Ctrl+C.. (Press enter) "
	read Verify

#	Alpine
	echo "[+]Pull alpine image from alpine:latest"
	sudo docker pull alpine:latest
	echo "[+]Alpine has been pulled. Everything is okay?"
	read Verify

#	OVS
	echo "[+]Pull ovs container from socketplane/openvswitch"
	sudo docker pull socketplane/openvswitch
	echo "[+]OVS has been pulled. Everything is okay?"
	read Verify	

#	Verify
	echo "[+]Docker images:"
	sudo docker images
	echo "[+]All docker containers (sudo docker ps -a):"
	sudo docker ps -a
	echo "[+]Docker network:"
	sudo docker network ls
	read Verify
}

usage() {
    cat << EOF
${UTIL}: Helps my diploma project to execute configs easier
usage: ${UTIL} COMMAND

Commands:
  linux1 [interface]			configure my Linux 1
					Details: ...
  linux2 [interface]			configure my Linux 2
 
Options:
  -h, --help        display this help message.
EOF
}

INT="$2"

if [ -z "$INT"] 
then
	INT="ens160"
fi

case $1 in
	"linux1")
		shift
		linux1 "$INT"
		exit 0
		;;
	"linux2")
		shift
		linux2 "$INT"
		exit 0
		;;	
	-h | --help)
		shift
		usage
		exit 0
		;;	
    *)
        echo >&2 "$UTIL: unknown command \"$1\" (use --help for help)"
        exit 1
        ;;
esac