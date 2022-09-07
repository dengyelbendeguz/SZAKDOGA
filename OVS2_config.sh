# set managemenet network and controller
ip addr add 172.16.0.3/28 dev eth0
ip link set eth0 up
ovs-vsctl set port eth0 tag=400
ovs-vsctl set-controller br0 tcp:172.16.0.10

# set vlans to other ovs
# eth* interface goes to ovs*, where "*" is the id of ovs

ip addr add 172.16.12.3/29 dev eth1
ip link set eth1 up
ovs-vsctl set port eth1 tag=312

ip addr add 172.16.24.2/29 dev eth4
ip link set eth4 up
ovs-vsctl set port eth4 tag=324

# OVS link to Routers
ip addr add 10.0.32.2/30 dev eth7
ip link set eth7 up
ovs-vsctl set port eth7 tag=223

# verify
ovs-vsctl show