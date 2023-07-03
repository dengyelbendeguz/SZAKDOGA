# init
echo -e "\n[+] Updating... \n"
apt-get update -y
apt-get upgrade -y
echo -e "\n[+] Installing required packages \n"
apt-get install -y gcc
apt-get install -y make
apt-get install -y unzip

# install java 11
echo -e "\n[+] Installing Java11 \n"
apt install -y openjdk-11-jdk
cat >> /etc/environment <<EOL
JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
JRE_HOME=/usr/lib/jvm/java-11-openjdk-amd64/jre
EOL
apt-get -y install curl
apt-get -y install iproute2
apt-get -y install wget

# install onos
echo -e "\n[+] Installing ONOS \n"
mkdir /opt
cd /opt
wget -c https://repo1.maven.org/maven2/org/onosproject/onos-releases/2.7.0/onos-2.7.0.tar.gz
tar xzf onos-2.7.0.tar.gz
mv onos-2.7.0 onos

#download OSPF
echo -e "\n[+] Downloading OSPF module \n"
wget -c https://github.com/nickadlakha/isis_ospf/archive/refs/heads/master.zip
unzip master.zip
echo -e "\n[+] Building OSPF module \n"
cd isis_ospf-master/
make debug

echo -e "\n[+] Starting ONOS \n"
/opt/onos/bin/onos-service start