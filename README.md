# Bluetooth speaker scripts for Linux

Pairing a Bluetooth speaker in a headless Linux can be a mess. This repository
contains a bash script [connect.sh](connect.sh) that will help you connect
to your speaker and configure it so that the audio is routed to the speaker.

I wrote this script since I needed to connect a bluetooth speaker and play
audio to it from [Home Assistant](http://www.home-assistant.io).

However the script is not restricted to Home Assistant. It can be used
by anyone who wants to connect to a bluetooth speaker, particulary if
running on a headless Linux installation (no GUI).

# System requirements

The script use PulseAudio and NOT Alsa. I'm currently using Armbian 20.08.07
Buster on a BananaPi SBC, but all hardware platforms (PC, RaspberryPi, OrangePi,
ROCK64 etc.) running a modern Linux should work.

Install the required packages:

    sudo apt-get install bluetooth pulseaudio pulseaudio-module-bluetooth

Secure that user is part of the lp group:

    sudo adduser $USER lp

You also need bluetooth integrated on your board or use a bluetooth USB stick.

The speaker needs to support A2DP profile over Bluetooth (which is almost always
the case for all bluetooth speakers).

# Preparation

You need to know the bluetooth MAC address of your bluetooth device. 

Start your bluetooth speaker and put it in pairing mode.

To figure the MAC you can run:

    bluetoothctl
    [bluetooth] power on
    [bluetooth] agent on
    [bluetooth] default-agent
    [bluetooth] scan on

Check all addresses and names printed on the screen. You should find your speaker
there and copy the MAC address.

Run:

    [bluetooth] scan off
    [bluetooth] exit

# Run

To connect to the Bluetooth speaker your need to turn it on and put it in pairing
mode. The run:

    sh connect.sh <MAC>

Where MAC is in the format XX:XX:XX:XX:XX:XX.

# Troubleshooting

The most common problem is that the speaker of some reason stops support audio
streaming, i.e. the A2DP sink (Bluetooth audio output) suddenly stops working.

If this is the case you need to restart your Bluetooth speaker and put in paring
mode and re-run the script.

# Run from Home Assistant

Personally I'm using the script to connect to the bluetooth speaker and to play
audio, such as a doorbell sound, when someone hits my ZigBee button which I
have at my front door.

Add following rows to configuration.yaml

    shell_command:
      connect_bluetooth_speaker: sh /home/myusername/.homeassistant/bluetooth_speaker_scripts/connect.sh 11:22:33:44:55:66
      doorbell_sound: play -v 1 /home/myusername/.homeassistant/sounds/doorbell.wav

Now we have created two services that we can call from Home Assistant:

- shell\_command.connect\_bluetooth\_speaker
- shell\_command.doorbell\_sound

To automatically connect to bluetooth speaker when Home Assistant starts
add an automation which triggers on homeassistant start event.
 
