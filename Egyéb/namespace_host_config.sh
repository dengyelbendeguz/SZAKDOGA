linux1() {
	echo "Setting up linux1 namespaces (h1, h3)..."
	apt install vlan
	# Új névtér létrehozása:
	ip netns add h1
	ip netns add h3

	# Validálás
	ls /var/run/netns

	# Csatlakoztatás interfészhez
	ip link add h1−eth0 type veth peer name h1−ens192
	ip link set h1−eth0 netns h1
	ip link add h3−eth0 type veth peer name h3−ens192
	ip link set h3−eth0 netns h3

	# Az interfészeket up állapotba állítjuk
	ip link set h1−ens192 up
	ip netns exec h1 ip link set dev lo up
	ip netns exec h1 ip link set dev h1−eth0
	ip netns exec h1 ip address add 192.168.1.3/29 dev h1−eth0
	ip link set h3−ens192 up
	ip netns exec h3 ip link set dev lo up
	ip netns exec h3 ip link set dev h3−eth0
	ip netns exec h3 ip address add 192.168.3.3/29 dev h3−eth0

	# Linux vlan konfigurálás az ens192 interfészre
	modprobe 8021q
	vconfig add ens192 511
	ip link set up ens192.511
	vconfig add ens192 533
	ip link set up ens192.533

	# h*−eth0 − h*−ens192 bridge csatlakoztatása a host vlan interfészéhez
	#ip link add ens192.511 type veth peer name h1−ens192
	#ip link add ens192.511 type veth peer name h1−eth0
	ip link set h1−ens192 netns h1
	#	helyette:
	#	ip link set ens192.511 netns h1
	#ip link add ens192.533 type veth peer name h3−ens192
	ip link set h3−ens192 netns h3
}


$ sudo ip link add macvlan1 link eth0 type macvlan mode bridge
$ sudo ip link add macvlan2 link eth0 type macvlan mode bridge
$ sudo ip netns add net1
$ sudo ip netns add net2
$ sudo ip link set macvlan1 netns net1 # attach net1 to macvlan1
$ sudo ip link set macvlan2 netns net2 # attach net2 to macvlan2



	apt install vlan
	ip netns add h2
	ip netns add h4
	ls /var/run/netns

	# Csatlakoztatás interfészhez
	ip link add h2−eth0 type veth peer name h2−ens192
	ip link set h2−eth0 netns h2
	ip link add h4−eth0 type veth peer name h4−ens192
	ip link set h4−eth0 netns h4

	# Az interfészeket up állapotba állítjuk
	ip link set h2−ens192 up
	ip netns exec h2 ip link set dev h2−eth0 up
	ip netns exec h2 ip address add 192.168.2.3/29 dev h2−eth0
	ip link set h4−ens192 up
	ip netns exec h4 ip link set dev h4−eth0 up
	ip netns exec h4 ip address add 192.168.4.3/29 dev h4−eth0

	# Linux vlan konfigurálás az ens192 interfészre
	modprobe 8021q
	vconfig add ens192 522
	ip link set up ens192.522
	vconfig add ens192 544
	ip link set up ens192.544

	# h*−eth0 − h*−ens192 bridge csatlakoztatása a host vlan interfészéhez
	ip link set h2−ens192 netns ens192.522
	ip link set h4−ens192 netns ens192.544



linux2() {
	echo "Setting up linux2 namespaces (h2, h3ű4)..."
	apt install vlan

	# Új névtér létrehozása:
	ip netns add h2
	ip netns add h4

	# Validálás
	ls /var/run/netns

	# Csatlakoztatás interfészhez
	ip link add h2−eth0 type veth peer name h2−ens192
	ip link set h2−eth0 netns h2
	ip link add h4−eth0 type veth peer name h4−ens192
	ip link set h4−eth0 netns h4

	# Az interfészeket up állapotba állítjuk
	ip link set h2−ens192 up
	ip netns exec h2 ip link set dev lo up
	ip netns exec h2 ip link set dev h2−eth0
	ip netns exec h2 ip address add 192.168.2.3/29 dev h2−eth0
	ip link set h4−ens192 up
	ip netns exec h4 ip link set dev lo up
	ip netns exec h4 ip link set dev h4−eth0
	ip netns exec h4 ip address add 192.168.4.3/29 dev h4−eth0

	# Linux vlan konfigurálás az ens192 interfészre
	modprobe 8021q
	vconfig add ens192 522
	ip link set up ens192.522
	vconfig add ens192 544
	ip link set up ens192.544

	# h*−eth0 − h*−ens192 bridge csatlakoztatása a host vlan interfészéhez
	ip link set h2−ens192 netns ens192.522
	ip link set h4−ens192 netns ens192.544
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
        echo >&2 "$UTIL: unknown command \"$1\" (possible arguments: linux1/linux2)"
        exit 1
        ;;
esac