#!/bin/bash

#with alpines, ovs commands commented out
#see linux_config.sh and linux_config_with_aplines.sh for other changes
#(those are the predecessors of this script)

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

macvlan_add(){
	SUBNET="$1"
	MACVLAN="$2"
	INT="$3"
	sudo docker network create -d macvlan \
	--subnet=$SUBNET \
	-o parent="$INT".$MACVLAN \
	macvlan_$MACVLAN
	echo "[+]macvlan_$MACVLAN has been added to subnet $SUBNET attached to $INT.."
}

docker_run(){
	NAME="$1"
	IMAGE="$2"
	if [ -z "$3" ] # if no $3 then true
	then
		echo "[+]No 3. argument"
		sudo docker run -itd --name $NAME --cap-add NET_ADMIN $IMAGE
		echo "[+]$NAME container has started from $IMAGE image as NET_ADMIN"
	else 
		sudo docker run -itd --name $NAME --cap-add NET_ADMIN $IMAGE "$3"
		echo "[+]$NAME container has started from $IMAGE image as NET_ADMIN in $3..."
	fi
	echo "[+]Press a button.."
	read Verify
}

docker_network_connect(){
	IP="$1"
	MACVLAN="$2"
	CONTAINER="$3"
	sudo docker network connect --ip $IP $MACVLAN $CONTAINER
	echo "[+]$CONTAINER docker container has connected to $MACVLAN with IP $IP.."
}

docker_exec(){
	# you can add any parameters...
	echo "[+]sudo docker exec $@"
	sudo docker exec "$@"
}

# Linux 1 config 
linux1() {
	echo "[+]Initialize Linux 1..."	
	docker_init
	INT="$1"
# 	Verify
	echo "[+]Is everything okay? If not press Ctrl+C.. (Press enter) "
	read Verify

# OVS1 docker network interface
	echo "[+]Install OVS1 docker network interfaces: macvlan211, macvlan213, macvlan312, macvlan313, macvlan400, macvlan511"
#	macvlan211
	macvlan_add 10.0.11.0/30 211 "$INT"
#	macvlan213
	macvlan_add 10.0.31.0/30 213 "$INT"
#	macvlan312
	macvlan_add 172.16.12.0/29 312 "$INT"	
#	macvlan313
	macvlan_add 172.16.13.0/29 313 "$INT"	
#	macvlan400
	macvlan_add 172.16.0.0/28 400 "$INT"
#	macvlan511
	macvlan_add 192.168.1.0/29 511 "$INT"

# OVS3 docker network interface
	echo "[+]Install OVS3 docker network interfaces: macvlan334, macvlan533"
#	macvlan334
	macvlan_add 172.16.34.0/29 334 "$INT"
#	macvlan533
	macvlan_add 192.168.3.0/29 533 "$INT"

# Ryu
	echo "[+]Run Ryu controller from osrg/run and connect to macvlan400"
	#ÁLLJ A JÓ MAPPÁBAN!!! (ahol a Dockerfile és a másolandó állomány van)
	sudo docker build . -t my_ryu
	docker_run vController my_ryu:latest /bin/bash
	docker_network_connect 172.16.0.10 macvlan_400 vController
	echo "[+]Ryu has started. Everything is okay?"
	read Verify
	
# Alpines
	echo "[+]Run alp1 and connect to macvlan511"
	docker_run alp1 alpine:latest
	docker_network_connect 192.168.1.3 macvlan_511 alp1
	echo "[+]alp1 has started. Everything is okay?"
	read Verify
	
	echo "[+]Run alp3 and connect to macvlan533"
	docker_run alp3 alpine:latest
	docker_network_connect 192.168.3.3 macvlan_533 alp3
	echo "[+]alp3 has started. Everything is okay?"
	read Verify
	

# OVS1 container
	echo "[+]Run ovs1 container from socketplane/openvswitch as NET_ADMIN."
	docker_run ovs1 socketplane/openvswitch
	echo "[+]OVS1 has started. Everything is okay?"
	read Verify
	echo "[+]Connect OVS1 interfaces"
	docker_network_connect 10.0.11.2 macvlan_211 ovs1
	docker_network_connect 10.0.31.2 macvlan_213 ovs1
	docker_network_connect 172.16.12.2 macvlan_312 ovs1
	docker_network_connect 172.16.13.2 macvlan_313 ovs1
	docker_network_connect 172.16.0.2 macvlan_400 ovs1
	docker_network_connect 192.168.1.2 macvlan_511 ovs1
	echo "[+]OVS1 has connected to networks. Everything is okay?"
	read Verify

# OVS3 container
	echo "[+]Run ovs3 container from socketplane/openvswitch as NET_ADMIN."
	docker_run ovs3 socketplane/openvswitch
	echo "[+]Connect OVS3 interfaces"
	docker_network_connect 172.16.13.3 macvlan_313 ovs3
	docker_network_connect 172.16.34.2 macvlan_334 ovs3
	docker_network_connect 172.16.0.4 macvlan_400 ovs3
	docker_network_connect 192.168.3.2 macvlan_533 ovs3
	echo "[+]OVS3 has connected to networks. Everything is okay?"
	read Verify
	
	sudo docker network ls
	read Verify

# OVS1 br config
#	echo "[+]Configure OVS1 bridge (ovs-br1)"
	# docker_exec ovs1 /usr/share/openvswitch/scripts/ovs-ctl start
#	docker_exec ovs1 ovs-vsctl add-br ovs-br1
#	docker_exec ovs1 ifconfig ovs-br1 up
#	Verify:
#	docker_exec ovs1 ovs-vsctl show
	
#	docker_exec ovs1 ovs-vsctl add-port ovs-br1 eth1 tag=211
#	docker_exec ovs1 ovs-vsctl add-port ovs-br1 eth3 tag=213
#	docker_exec ovs1 ovs-vsctl add-port ovs-br1 eth2 tag=312
#	docker_exec ovs1 ovs-vsctl add-port ovs-br1 eth4 tag=511
#	docker_exec ovs1 ovs-vsctl add-port ovs-br1 eth5 tag=313
#	docker_exec ovs1 ovs-vsctl add-port ovs-br1 eth6 tag=400
	
#	docker_exec ovs1 ovs-vsctl set-controller ovs-br1 tcp:172.16.0.10
	
#	Verify:	
#	docker_exec ovs1 ovs-vsctl show

#	read Verify

# OVS3 br config
#	echo "[+]Configure OVS3 bridge (ovs-br3)"
	# docker_exec ovs3 /usr/share/openvswitch/scripts/ovs-ctl start
#	docker_exec ovs3 ovs-vsctl add-br ovs-br3

#	docker_exec ovs3 ifconfig ovs-br3 up
	
#	Verify:
#	docker_exec ovs3 ovs-vsctl show
	
#	docker_exec ovs3 ovs-vsctl add-port ovs-br3 eth1 tag=313
#	docker_exec ovs3 ovs-vsctl add-port ovs-br3 eth2 tag=334
#	docker_exec ovs3 ovs-vsctl add-port ovs-br3 eth3 tag=533
#	docker_exec ovs3 ovs-vsctl add-port ovs-br3 eth4 tag=400

#	docker_exec ovs3 ovs-vsctl set-controller ovs-br3 tcp:172.16.0.10

#	Verify:	
#	docker_exec ovs3 ovs-vsctl show

#	read Verify	
}

# Linux 2 config
linux2() {
	echo "[+]Initialize Linux 2..."
	docker_init
	INT="$1"

# OVS2 docker network interface
	echo "[+]Install OVS2 docker network interfaces: macvlan223, macvlan312, macvlan324, macvlan400, macvlan522"
#	Macvlan223
	macvlan_add 10.0.32.0/30 223 "$INT"
#	Macvlan312
	macvlan_add 172.16.12.0/29 312 "$INT"
#	Macvlan324
	macvlan_add 172.16.24.0/29 324 "$INT"		
#	Macvlan400
	macvlan_add 172.16.0.0/28 400 "$INT"	
#	Macvlan522
	macvlan_add 192.168.2.0/29 522 "$INT"
	echo "[+]macvlans for ovs2 has added. Everything is okay?"
	read Verify
	
# OVS4 docker network interface
	echo "[+]Install OVS4 docker network interfaces: macvlan334, macvlan544"
#	macvlan334
	macvlan_add 172.16.34.0/29 334 "$INT"
#	Macvlan544
	macvlan_add 192.168.4.0/29 544 "$INT"
	echo "[+]macvlans for ovs4 has added. Everything is okay?"
	read Verify

# Alpines
	echo "[+]Run alp2 and connect to macvlan522"
	docker_run alp2 alpine:latest
	docker_network_connect 192.168.2.3 macvlan_522 alp2
	echo "[+]alp2 has started. Everything is okay?"
	read Verify
	
	echo "[+]Run alp4 and connect to macvlan544"
	docker_run alp4 alpine:latest
	docker_network_connect 192.168.4.3 macvlan_544 alp4
	echo "[+]alp4 has started. Everything is okay?"
	read Verify

#OVS2 container
	echo "[+]Run ovs2 container from socketplane/openvswitch as NET_ADMIN."
	docker_run ovs2 socketplane/openvswitch
	echo "[+]Connect OVS2 interfaces"
	docker_network_connect 10.0.32.2 macvlan_223 ovs2
	docker_network_connect 172.16.12.3 macvlan_312 ovs2
	docker_network_connect 172.16.24.2 macvlan_324 ovs2
	docker_network_connect 172.16.0.3 macvlan_400 ovs2
	docker_network_connect 192.168.2.2 macvlan_522 ovs2

# OVS4 container
	echo "[+]Run ovs4 container from socketplane/openvswitch as NET_ADMIN and connect interfaces"
	docker_run ovs4 socketplane/openvswitch
	echo "[+]Connect OVS4 interfaces"
	docker_network_connect 172.16.24.3 macvlan_324 ovs4
	docker_network_connect 172.16.34.3 macvlan_334 ovs4
	docker_network_connect 172.16.0.5 macvlan_400 ovs4
	docker_network_connect 192.168.4.2 macvlan_544 ovs4
	
	sudo docker network ls
	read Verify

# OVS2 br config
#	echo "[+]Configure OVS2 bridge (ovs-br1)"
#	docker_exec ovs2 /usr/share/openvswitch/scripts/ovs-ctl start
#	docker_exec ovs2 ovs-vsctl add-br ovs-br2

#	docker_exec ovs2 ifconfig ovs-br2 up

#	Verify:       
#	docker_exec ovs2 ovs-vsctl show
#	read Verify
				   
#	docker_exec ovs2 ovs-vsctl add-port ovs-br2 eth1 tag=223
#	docker_exec ovs2 ovs-vsctl add-port ovs-br2 eth3 tag=522
#	docker_exec ovs2 ovs-vsctl add-port ovs-br2 eth2 tag=312
#	docker_exec ovs2 ovs-vsctl add-port ovs-br2 eth4 tag=324
#	docker_exec ovs2 ovs-vsctl add-port ovs-br2 eth5 tag=400
#	docker_exec ovs2 ovs-vsctl add-port ovs-br2 eth6
				   
#	docker_exec ovs2 ovs-vsctl set-controller ovs-br2 tcp:172.16.0.10
	
#	Verify:	
#	docker_exec ovs2 ovs-vsctl show

# OVS4 br config
#	echo "[+]Configure OVS4 bridge (ovs-br4)"
#	docker_exec ovs4 /usr/share/openvswitch/scripts/ovs-ctl start
#	docker_exec ovs4 ovs-vsctl add-br ovs-br4

#	docker_exec ovs4 ifconfig ovs-br4 up
	
#	Verify:
#	docker_exec ovs4 ovs-vsctl show
#	read Verify
	
#	docker_exec ovs4 ovs-vsctl add-port ovs-br4 eth1 tag=324
#	docker_exec ovs4 ovs-vsctl add-port ovs-br4 eth2 tag=334
#	docker_exec ovs4 ovs-vsctl add-port ovs-br4 eth3 tag=544
#	docker_exec ovs4 ovs-vsctl add-port ovs-br4 eth4 tag=400

#	docker_exec ovs4 ovs-vsctl set-controller ovs-br4 tcp:172.16.0.10
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