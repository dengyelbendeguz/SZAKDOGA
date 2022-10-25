#! /bin/bash

### WORK IN PROGRESS ###
#   Script to initialize Ryu controller and OpenVSwitches already running in GNS3
#   uses telnet to connect to locally ran controller and switches, then
#   - on switches: runs OVS*_config.sh
#   - on controller: runs RYU_config.sh and copies ryu_ospf_cs.py to ryu/ryu/app folder

echo "Confirm ports!"
read -n 1 -s -r -p "Press any key to confirm"

#RYU
echo "[+] Initializing Ryu"
{
  echo "/./../gns3volumes/ryu_code/RYU_config.sh";
  echo "cp ../gns3volumes/ryu_code/ryu_ospf_cs.py ../ryu/ryu/app/ryu_ospf_cs.py";
  echo "cp ../gns3volumes/ryu_code/sshd_config.good ../etc/ssh/sshd_config";
  sleep 20;
} | telnet localhost 5046

#OVS1
echo "[+] Initializing OVS1"
{ echo "/gns3volumes/init_script/OVS*"; sleep 5; } | telnet localhost 5014

#OVS2
echo "[+] Initializing OVS2"
{ echo "/gns3volumes/init_script/OVS*"; sleep 5; } | telnet localhost 5017

#OVS3
echo "[+] Initializing OVS3"
{ echo "/gns3volumes/init_script/OVS*"; sleep 5; } | telnet localhost 5032

#OVS4
echo "[+] Initializing OVS4"
{ echo "/gns3volumes/init_script/OVS*"; sleep 5; } | telnet localhost 5034
