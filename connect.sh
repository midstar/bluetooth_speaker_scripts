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
  echo "You need to provide speaker bluetooth MAC address"
  exit 1
fi

export BLUETOOTH_MAC=$1

echo "Trying to connect to bluetooth speaker with MAC ${BLUETOOTH_MAC}"

export BLUETOOTH_MAC_STR=`echo $BLUETOOTH_MAC | tr : _`
export BLUETOOTH_SINK=bluez_sink.${BLUETOOTH_MAC_STR}.a2dp_sink

# Check if audio is routed to bluetooth speaker. 
# Exits script with 0 if ok.
exit_if_audio_routed_to_bluetooth_speaker() {
  echo "Check if audio is routed to Bluetooth speaker"
  if pactl info | grep -q "${BLUETOOTH_SINK}"; then
    echo "Audio is routed to Bluetooth speaker"
    exit 0
  fi
  echo "Audio is NOT routed to Bluetooth speaker"
}

exit_if_audio_routed_to_bluetooth_speaker


echo "Check if pulseaudio is running"
if pulseaudio --check; then
  echo "pulseaudio is running"
else
  echo "pulseaudio is NOT running - attemt to start"
  pulseaudio --start
  if pulseaudio --check; then
    echo "pulseaudio is running"
  else
    echo "ERROR! Unable to start pulseaudio"
    exit 1    
  fi
fi

echo "Check that we can connect to pulseaudio"
if pactl info > /dev/null; then
  echo "Possible to connect to pulseaudio"
else
  echo "Unable to connect to pulseaudio. Trying to restart"
  pulseaudio -k && pulseaudio --start
  if pactl info > /dev/null; then
    echo "Possible to connect to pulseaudio"
  else
    echo "ERROR! Unable to connect to pulseadio, even after restart of pulseadio."
    exit 1
  fi
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
  else
    echo "ERROR! Unable to connect to speaker"
    echo "Secure that your speaker is turned on and in pairing mode!"
    exit 1
  fi
fi

exit_if_audio_routed_to_bluetooth_speaker

echo "Audio is not routed to the bluetooth speaker"

echo "Trying to change default sink to bluetooth speaker"
if pacmd set-default-sink $BLUETOOTH_SINK; then
  echo "Default sink set to bluetooth speaker"
else
  echo "ERROR! Unable to route audio to bluetooth speaker!"
  echo "You probably need to restart your speaker and"
  echo "put it into pairing mode again"
  exit 1
fi

exit_if_audio_routed_to_bluetooth_speaker

echo "ERROR! Audio is not routed to bluetooth speaker."
echo "You probably need to restart your speaker and"
echo "put it into pairing mode again"
exit 1
