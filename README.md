# Bluetooth speaker scripts Home Assistant

Scripts for connecting, disconnecting, check connection
status and play audio on a Bluetooth speaker.

I wrote the scripts so that they can be used from Home
Assistant.

# System requirements

The scripts use BlueAlsa and NOT PulseAudio. I tried to
use PulseAudio and I have described my experience with
this tool further down. 

I'm currently using Armbian 20.08.07 Buster on a BananaPi 
SBC, but all hardware platforms (PC, RaspberryPi, OrangePi,
ROCK64 etc.) running a modern Linux should work.

Install the required packages:

    sudo apt-get install bluetooth bluealsa

Some platforms, including mine, did not have bluealsa as a 
prebuilt package. Therefore you need to build it as described
[here](https://github.com/Arkq/bluez-alsa).

Also, you need to install bluealsa as a system service.
Copy the [bluealsa.service](bluealsa.service) to:

    /etc/systemd/system/bluealsa.service

And run:

    sudo systemctl enable bluealsa
    sudo systemctl start bluealsa

You also need bluetooth integrated on your board or use a 
bluetooth USB stick.

The speaker needs to support A2DP profile over Bluetooth 
(which is almost always the case for all bluetooth speakers).

# Run

To connect to the Bluetooth speaker run:

    sh connect.sh <MAC>

Where MAC is in the format XX:XX:XX:XX:XX:XX.

To just check if the Bluetooth speaker is connected then run:

    sh is_connected.sh <MAC>

The script will return "Connected" or "Disconnected"

To play audio over the Bluetooth speaker, and as a backup,
play over the standard audio output (for example AUX):

    sh play.sh <audio file> <MAC>

The MAC argument is optional in all the above commands. 
You can also write the MAC address to following file 
that needs to be in the same location as the scripts:

    speaker_mac.conf 


# Run from Home Assistant

Personally I'm using the script to connect to the bluetooth speaker and to play
audio, such as a doorbell sound, when someone hits my ZigBee button which I
have at my front door.

First of all write your speaker MAC address to speaker_mac.conf and put it
in your script location.

Add following rows to configuration.yaml

    shell_command:
      connect_bluetooth_speaker: sh /home/user/.homeassistant/bluetooth_speaker_scripts/connect.sh
      doorbell_sound: sh /home/user/.homeassistant/bluetooth_speaker_scripts/play.sh /home/user/sound/doorbell.wav

    binary_sensor:
      - platform: command_line
      command: 'sh /home/user/.homeassistant/bluetooth_speaker_scripts/is_connected.sh
      name: 'Bluetooth Speaker'
      payload_on: 'Connected'
      payload_off: 'Disconnected'

Now we have created two services that we can call from Home Assistant:

- shell\_command.connect\_bluetooth\_speaker
- shell\_command.doorbell\_sound

You also have the binary sensor:

- binary\_sensor.bluetooth\_speaker

To automatically connect to Bluetooth speaker when it is disconneted
add an automation:

- Trigger: time\_pattern, every minute (/1)
- Condition: State, binary\_sensor.bluetooth\_speaker, state: 'off'
- Action: run service shell\_command.connect\_bluetooth\_speaker


# Why not use pulsealsa?

I tried to get Bluetooth using pulsealsa but did not manage
to be able to get A2DP to work when running pulsealsa in 
service mode, i.e. as a daemon. 

Running in user mode was not an option either, because when
Home Assistant is started, there is no user session and thus
pulsealsa won't start. A workround is to login a user session
separately, using the same user as Home Assistant, but this
user session will eventually time out. In my case the timeout
was 2 hours (of inactivity) and after this point pulsealsa
will be deactivated.

There are some scripts for pulseaudio [here](pulseaudio/README.md),
but they will not work.

Only blueaudio seems to be stable to run as a service process.

# Troubleshooting

If the speaker connects and disconnects immediatly after it might
be that you need to restart bluealsa:

    sudo systemctl restart bluealsa
