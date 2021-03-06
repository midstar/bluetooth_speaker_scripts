# Script for checking if Bluetooth speaker is connected
#
# For system requirements see README.md
#
# Usage:
#
#  sh is_connected.sh <speaker MAC address>
# 
# Writes Connected or Disconnected
#
# Copyright 2020 by Joel Midstjärna.
# All rights reserved. See LICENSE.txt.

if [ "$#" -ne 1 ]; then
  # Read from speaker_mac.conf
  export SCRIPT_DIR=`dirname "$0"`
  export BLUETOOTH_MAC=`cat $SCRIPT_DIR/speaker_mac.conf`
else 
  export BLUETOOTH_MAC=$1
fi

if bluetoothctl info $BLUETOOTH_MAC | grep -q "Connected: yes"; then
  echo "Connected"
else
  echo "Disconnected"
fi
