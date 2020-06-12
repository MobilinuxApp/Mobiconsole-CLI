#!/bin/bash

#Get the necessary components
pacman -Sy --noconfirm openssh

#Setup the necessary files
wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/ArchLinux/Installer/SSH/sshd_config -P /etc/ssh

echo "You can now start OpenSSH Server by running /etc/rc.d/sshd start"
echo " "
echo "The Open Server will be started at 127.0.0.1:22"
