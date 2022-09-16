# set managemenet network and controller
ip addr add 172.16.0.2/28 dev eth0
ip link set eth0 up
ovs-vsctl set port eth0 tag=400
ovs-vsctl set-controller br0 tcp:172.16.0.10

# set vlans to other ovs
# eth* interface goes to ovs*, where "*" is the id of ovs

ip addr add 172.16.12.2/29 dev eth2
ip link set eth2 up
ovs-vsctl set port eth2 tag=312

ip addr add 172.16.13.2/29 dev eth3
ip link set eth3 up
ovs-vsctl set port eth3 tag=313

# OVS link to Routers
ip addr add 10.0.11.2/30 dev eth6
ip link set eth6 up
#ovs-vsctl set port eth6 tag=211

ip addr add 10.0.31.2/30 dev eth7
ip link set eth7 up
#ovs-vsctl set port eth7 tag=213

# VPCS connection
ip addr add 192.168.1.2/29 dev eth5
ip link set eth5 up
ovs-vsctl set port eth5 tag=511

# verify
ovs-vsctl show
ping 172.16.0.10 -c 2
ping 192.168.1.3 -c 2