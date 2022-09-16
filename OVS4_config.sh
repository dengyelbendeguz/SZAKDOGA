# set managemenet network and controller
ip addr add 172.16.0.5/28 dev eth0
ip link set eth0 up
ovs-vsctl set port eth0 tag=400
ovs-vsctl set-controller br0 tcp:172.16.0.10

# set vlans to other ovs
# eth* interface goes to ovs*, where "*" is the id of ovs

ip addr add 172.16.24.3/29 dev eth2
ip link set eth2 up
ovs-vsctl set port eth2 tag=324

ip addr add 172.16.34.3/29 dev eth3
ip link set eth3 up
ovs-vsctl set port eth3 tag=334

# VPCS connection
ip addr add 192.168.4.2/29 dev eth5
ip link set eth5 up
ovs-vsctl set port eth5 tag=544

# verify
ovs-vsctl show
ping 172.16.0.10 -c 2
ping 192.168.4.3 -c 2