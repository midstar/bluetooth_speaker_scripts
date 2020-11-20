# Script for connecting to Bluetooth speaker
#
# For system requirements see README.md
#
# Usage:
#
#  sh connect.sh <speaker MAC address>
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

echo "Trying to connect to bluetooth speaker with MAC ${BLUETOOTH_MAC}"

echo "Check if bluealsa is running"
if ps -A | grep -q "bluealsa"; then
  echo "bluealsa is running"
else
  echo "ERROR! bluealsa is NOT running"
  echo "Manually start it with sudo privileges and restart this script. Run:"
  echo "  > sudo systemctl start bluealsa"
  exit 1
fi

echo "Check that bluetooth daemon is running"
if ps -A | grep -q "bluetoothd"; then
  echo "bluetooth daemon is running"
else
  echo "ERROR! bluetooth daemon is NOT running."
  echo "Manually start it with sudo privileges and restart this script. Run:"
  echo "  > sudo systemctl start bluetooth"
  exit 1
fi	

bluetoothctl power on

echo "Check that speaker is trusted"
if bluetoothctl devices | grep -q "${BLUETOOTH_MAC}"; then
  echo "Speaker is trusted"
else
  echo "Trusting speaker with MAC ${BLUETOOTH_MAC}"
  bluetoothctl power on
  bluetoothctl agent on
  bluetoothctl default-agent
  bluetoothctl pair $BLUETOOTH_MAC
  bluetoothctl trust $BLUETOOTH_MAC
fi

echo "Check if speaker is connected"
if bluetoothctl info $BLUETOOTH_MAC | grep -q "Connected: yes"; then
  echo "Speaker is connected"
else
  echo "Speaker is not connected. Trying to connect"
  if bluetoothctl connect $BLUETOOTH_MAC; then
    echo "Speaker is connected"
    echo "Waiting for 5 seconds for pulsealsa to create sink"
    sleep 5
  else
    echo "Try reset blueooth controller"
    bluetoothctl disconnect
    bluetoothctl power off
    bluetoothctl power on
    echo "Try to connect to speaker again"
    if bluetoothctl connect $BLUETOOTH_MAC; then
      echo "Speaker is connected"
      echo "Wating for 5 seconds for bluealsa to connect"
      sleep 5
    else
      echo "ERROR! Unable to connect to speaker"
      echo "Secure that your speaker is turned on and in pairing mode!"
      exit 1
    fi
  fi
fi
