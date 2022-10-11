# managmenmet lan (vlan 400)
ip addr add 172.16.0.10/28 dev eth0
ip link set eth0 up

# link to internet
ip addr add 192.168.122.111/24 dev eth1
ip link set eth1 up
ip route add default via 192.168.122.1

# itt dns állíttása kézzel:
# https://support.nordvpn.com/Connectivity/Linux/1134945702/Change-your-DNS-servers-on-Linux.htm
echo nameserver 8.8.8.8 > /etc/resolv.conf

# initial setup and downloading neccesary tools
apt update -y
# apt -y install vim
apt -y install nano
apt -y install iputils-ping
apt -y install net-tools
apt -y install traceroute
ping -c 1 google.com

python2 -m pip install --upgrade pip==20.3.4
hash -r
pip install networkx

# SSH
# https://phoenixnap.com/kb/ssh-permission-denied-publickey
apt -y install openssh-server
# service ssh start
# service ssh status
# a jelszót meg kell változtatni 1x kézzel,pl:
#   passwd
#   gns3
#   gns3
# és kézzel módosítani a /etc/ssh/sshd_config filet (egy jó példa file a repóban: sshd_config.good):
#   PermitRootLogin yes
#   PasswordAuthentication yes
# cp /etc/ssh/sshd_config /gns3volumes/ryu_code/sshd_config.good
# végül felmásolni a szűkséges fileokat