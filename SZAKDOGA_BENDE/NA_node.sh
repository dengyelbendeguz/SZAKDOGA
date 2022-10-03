apt update
apt install iproute2 # for ip a command
apt install sshpass

# acquire IP address
nano /etc/network/interfaces
auto eth0
iface eth0 inet dhcp
============================
nano ansible.cfg
[defaults]
inventory = ./myhosts
host_key_checking = false
timeout = 15
deprecation_warnings=False
============================
nano myhosts
[routers]
R1
R2
R3
R4
Ryu
============================
nano /etc/hosts
#append:
192.168.122.11 R1
192.168.122.22 R2
192.168.122.33 R3
192.168.122.44 R4
192.168.122.111 Ryu
============================
#NA Appliance Verification:
ip a
cat ansible.cfg
cat myhosts
cat /etc/hosts
ansible --list-hosts all
ansible --list-hosts routers
ping R1 -c 2
ping R2 -c 2
ping R3 -c 2
ping R4 -c 2
ping Ryu -c 2
ansible R1 -m raw -a "show ip interface brief" -u cisco -k
ansible Ryu -m raw -a "ifconfig eth0" -u root -k