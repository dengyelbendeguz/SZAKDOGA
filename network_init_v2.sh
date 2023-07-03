#! /bin/bash

### WORK IN PROGRESS ###
#   Script to initialize OpenVSwitches already running in GNS3
#   uses telnet to connect to locally ran controller and switches, then
#   - on switches: sets controller and OF protocol

echo "Confirm ports:"
echo "OVS1  5004"
echo "OVS2  5006"
read -n 1 -s -r -p "Press any key to confirm"

#RYU
#OVS1
echo "[+] Initializing OVS1"
{ echo "ovs-vsctl set-controller br0 tcp:192.168.0.254:6633";
  sleep 1;
  echo "ovs-vsctl set bridge br0 protocols=OpenFlow13";
  sleep 5; } | telnet localhost 5004

#OVS2
echo "[+] Initializing OVS1"
{ echo "ovs-vsctl set-controller br0 tcp:192.168.0.254:6633";
  sleep 1;
  echo "ovs-vsctl set bridge br0 protocols=OpenFlow13";
  sleep 5; } | telnet localhost 5006
