#!/bin/bash
echo "Installing XFCE Desktop"
echo " "
echo " "
echo "Updating the system "
echo " "
echo " "
pacman -Suuyy --noconfirm
pacman -S xfce4 xfce4-goodies sudo --noconfirm 
pacman -S tigervnc --noconfirm

wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/ArchLinux/Installer/DEs/XFCE4/xstartup   -P ~/.vnc/
wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/ArchLinux/Installer/DEs/XFCE4/vncserver-start -P /usr/local/bin/
wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/ArchLinux/Installer/DEs/XFCE4/vncserver-stop -P /usr/local/bin/
chmod +x ~/.vnc/xstartup
chmod +x /usr/local/bin/vncserver-start
chmod +x /usr/local/bin/vncserver-stop

echo " "
echo "You can now start vncserver by running vncserver-start"
echo " "
echo "It will ask you to enter a password when first time starting it."
echo " "
echo "The VNC Server will be started at 127.0.0.1:5901"
echo " "
echo "You can connect to this address with a VNC Viewer you prefer"
echo " "
echo "Connect to this address will open a window with XFCE Desktop Environment"
echo " "
echo " "
echo "**Note : Please note that you will need to enter view only password too while configuring VNC password to avoid connection errors."
echo " "
echo " "
echo "Running vncserver-start"
echo " "
echo " "
echo " "
echo "To Kill VNC Server just run vncserver-stop"
echo " "
echo " "
echo " "

echo "export DISPLAY=":1"" >> /etc/profile
source /etc/profile
vncserver-start
