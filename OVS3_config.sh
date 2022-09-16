# set managemenet network and controller
ip addr add 172.16.0.4/28 dev eth0
ip link set eth0 up
ovs-vsctl set port eth0 tag=400
ovs-vsctl set-controller br0 tcp:172.16.0.10

# set vlans to other ovs
# eth* interface goes to ovs*, where "*" is the id of ovs

ip addr add 172.16.13.3/29 dev eth1
ip link set eth1 up
ovs-vsctl set port eth1 tag=313

ip addr add 172.16.34.2/29 dev eth4
ip link set eth4 up
ovs-vsctl set port eth4 tag=334

# VPCS connection
ip addr add 192.168.3.2/29 dev eth5
ip link set eth5 up
ovs-vsctl set port eth5 tag=533

# verify
ovs-vsctl show
ping 172.16.0.10 -c 2
ping 192.168.3.3 -c 2