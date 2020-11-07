# Script for disconnecting Bluetooth connected devices
# and stopping pulse audio
#
# For system requirements see README.md
#
# Usage:
#
#  sh disconnect.sh
#
# Copyright 2020 by Joel Midstjärna.
# All rights reserved. See LICENSE.txt.
bluetoothctl disconnect
bluetoothctl power off
pulseaudio -k
bluetoothctl power on
