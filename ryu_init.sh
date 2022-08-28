#!/bin/bash

cp -r * ~/ryu/ryu/app/

ip link add link eth0 name eth0.999 type vlan id 999
ip addr add 172.17.0.20/16 brd 172.17.255.255 dev eth0.999
ip link set dev eth0.999 up
ip route add default via 172.17.0.1

apt update
apt install vim
apt install iputils-ping
apt install net-tools
apt install traceroute
ping -c 1 google.com

python2 -m pip install --upgrade pip==20.3.4
hash -r
pip install networkx