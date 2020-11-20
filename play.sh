# Script for playing audio on Bluetooth speaker if it is
# connected. Otherwise it will play audio using the default
# audio device (for example AUX).
#
# For system requirements see README.md
#
# Usage:
#
#  sh play.sh <audio file> <speaker MAC address>
#
# Copyright 2020 by Joel Midstjärna.
# All rights reserved. See LICENSE.txt.

if [ -z $1 ]; then
  echo "ERROR! Audio file argument missing"
  exit 1
fi

export AUDIO_FILE=$1

if [ -z $2 ]; then
  # Read from speaker_mac.conf
  export SCRIPT_DIR=`dirname "$0"`
  export BLUETOOTH_MAC=`cat $SCRIPT_DIR/speaker_mac.conf`
else 
  export BLUETOOTH_MAC=$2
fi

aplay -D bluealsa:DEV=$BLUETOOTH_MAC,PROFILE=a2dp $AUDIO_FILE || (
 aplay $AUDIO_FILE
)

