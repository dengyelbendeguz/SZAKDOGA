#! /bin/bash

linux1() {

ip link set dev ens160 up
ip link add link ens160 name ens160.999 type vlan id 999
ip addr add 10.255.255.111/24 brd 10.255.255.255 dev ens160.999
ip link set dev ens160.999 up
ip route add default via 10.255.255.1

echo "Testing internet and name server:"
ping -c 1 google.com

echo "Vlan 999 setup for linux1 is complete"
}

linux2() {

ip link set dev ens160 up
ip link add link ens160 name ens160.999 type vlan id 999
ip addr add 10.255.255.222/24 brd 10.255.255.255 dev ens160.999
ip link set dev ens160.999 up
ip route add default via 10.255.255.1

echo "Testing internet and name server:"
ping -c 1 google.com

echo "Vlan 999 setup for linux2 is complete"
}

case $1 in
	"linux1")
		shift
		linux1
		exit 0
		;;
	"linux2")
		shift
		linux2
		exit 0
		;;	
    *)
        echo >&2 "$UTIL: unknown command \"$1\" (possible arguments: linux1, linux2)"
        exit 1
        ;;
esac