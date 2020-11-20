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
  echo "You need to provide speaker bluetooth MAC address"
  exit 1
fi

export BLUETOOTH_MAC=$1

export BLUETOOTH_MAC_STR=`echo $BLUETOOTH_MAC | tr : _`
export BLUETOOTH_SINK=bluez_sink.${BLUETOOTH_MAC_STR}.a2dp_sink

# Check if audio is routed to bluetooth speaker. 
if pactl info 2> /dev/null | grep -q "${BLUETOOTH_SINK}"; then
  echo "Connected"
else
  echo "Disconnected"
fi
