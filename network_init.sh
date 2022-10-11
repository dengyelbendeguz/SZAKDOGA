#! /bin/bash

### WORK IN PROGRESS ###
#   Script to initialize Ryu controller and OpenVSwitches already running in GNS3
#   uses telnet to connect to locally ran controller and switches, then
#   - on switches: runs OVS*_config.sh
#   - on controller: runs RYU_config.sh and copies ryu_ospf_cs.py to ryu/ryu/app folder

echo "Confirm ports:"
echo "RYU   5019"
echo "OVS1  5021"
echo "OVS2  5023"
echo "OVS3  5025"
echo "OVS4  5027"
read -n 1 -s -r -p "Press any key to confirm"

#RYU
echo "[+] Initializing Ryu"
{
  echo "/./../gns3volumes/ryu_code/RYU_config.sh";
  echo "cp /gns3volumes/ryu_code/ryu_ospf_cs.py ~/ryu/ryu/app/ryu_ospf_cs.py";
  sleep 20;
} | telnet localhost 5019

#OVS1
echo "[+] Initializing OVS1"
{ echo "/gns3volumes/init_script/OVS*"; sleep 5; } | telnet localhost 5021

#OVS2
echo "[+] Initializing OVS2"
{ echo "/gns3volumes/init_script/OVS*"; sleep 5; } | telnet localhost 5023

#OVS3
echo "[+] Initializing OVS3"
{ echo "/gns3volumes/init_script/OVS*"; sleep 5; } | telnet localhost 5025

#OVS4
echo "[+] Initializing OVS4"
{ echo "/gns3volumes/init_script/OVS*"; sleep 5; } | telnet localhost 5027