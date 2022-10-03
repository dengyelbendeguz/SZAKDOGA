#!/bin/bash

SCRIPT_NAME="$1"
sudo chmod a+wrx $SCRIPT_NAME
sudo sed -i -e 's/\r$//' $SCRIPT_NAME