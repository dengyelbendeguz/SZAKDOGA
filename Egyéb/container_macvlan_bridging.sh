sudo docker run -itd --name alph1 --cap-add NET_ADMIN alpine:latest
sudo docker run -itd --name alph3 --cap-add NET_ADMIN alpine:latest

#sudo docker network create -d macvlan --subnet=192.168.10.0/24 -o parent=ens160.600 macvlan_600
sudo docker network create -d macvlan --subnet=192.168.10.0/24 -o parent=ens160 macvlan_600
sudo docker network connect --ip 192.168.10.11 macvlan_600 alph1
sudo docker network connect --ip 192.168.10.33 macvlan_600 alph3

#	OTHER TRYS:

#sudo ip link add mymacvlan1 link ens160 type macvlan mode bridge
#sudo ip link add mymacvlan2 link ens160 type macvlan mode bridge
#sudo ifconfig mymacvlan1 up
#sudo ifconfig mymacvlan2 up

#sudo docker network create -d macvlan --subnet=192.168.10.0/24 -o parent=ens160.611 macvlan_611
#sudo docker network create -d macvlan --subnet=192.168.10.0/24 -o parent=ens160.633 macvlan_633	
#sudo docker network connect --ip 192.168.10.11 macvlan_611 alph1
#sudo docker network connect --ip 192.168.10.33 macvlan_633 alph2

#sudo docker exec alph3 ip link add ens160 type dummy
#sudo docker exec alph3 ip link set dev ens160 up
#sudo docker exec alph3 ip link set dev ens160 arp on
#sudo docker exec alph3 ip addr add 192.168.10.33/24 brd 192.168.10.255 dev ens160
#sudo docker exec alph3 ip a


sudo ip link add link enp0s3 name enp0s3.777 type vlan id 777
sudo ip addr add 192.168.0.1/24 brd 192.168.0.255 dev enp0s3.777
sudo ip link set dev enp0s3.777 up

sudo ip link add link enp0s3 name enp0s3.777 type vlan id 777
sudo ip addr add 192.168.0.2/24 brd 192.168.0.255 dev enp0s3.777
sudo ip link set dev enp0s3.777 up




sudo docker run -itd --name alph4 --cap-add NET_ADMIN alpine:latest

sudo docker network create -d macvlan --subnet=192.168.100.0/24 -o parent=enp0s3 macvlan_1001
sudo docker network connect --ip 192.168.100.4 macvlan_1001 

sudo docker run -itd --name alph6 --cap-add NET_ADMIN alpine:latest
sudo docker network create -d macvlan --subnet=192.168.101.0/24 -o parent=enp0s3 macvlan_1003
sudo docker network connect --ip 192.168.101.6 macvlan_1003 alph6