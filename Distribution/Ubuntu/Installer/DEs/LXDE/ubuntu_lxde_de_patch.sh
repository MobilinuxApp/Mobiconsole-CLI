#!/bin/bash

#Get the necessary components
sudo apt-mark hold udisks2
sudo apt-get update
apt install dialog
clear
trap '' 2
dialog --clear --backtitle "System Installation Type" --title "Choose Installation type:" --menu "Please select:" 10 45 3 1 "Minimal Installation 1.5GB" 2 "Full Installation 4GB" 2>temp
# OK is pressed
if [ "$?" = "0" ]
then
        _return=$(cat temp)
 
        # Minimal is selected
        if [ "$_return" = "1" ]
        then
                echo 'Installing Minimal System '
		            sleep 4
    		        apt-get install lxde-core lxterminal tigervnc-standalone-server xfe tigervnc-common dbus-x11 --no-install-recommends -y
        fi
 
         # Full is selected
        if [ "$_return" = "2" ]
        then
            	echo 'Installing Full System '
		          sleep 4
		          apt-get install lxde-core lxterminal tigervnc-standalone-server dbus-x11 ubuntu-desktop lxde xfe gimp neofetch libreoffice -y
    		      sudo apt update -y && sudo apt install wget -y && wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Patches/librepatch.sh && bash librepatch.sh
        fi
 # Cancel is pressed
else
        echo "Cancel is pressed, Restarting The Menu......"
	sleep 3
	dialog --menu "Choose Installation type:" 10 40 3 1 "Minimal Installation 1.5GB" 2 "Full Installation 4GB" 2>temp
fi
 
# remove the temp file
rm -f temp
trap 2
sudo apt-get clean

#Setup the necessary files
mkdir -p ~/.vnc

echo "#!/bin/bash
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
export PULSE_SERVER=127.0.0.1
XAUTHORITY=$HOME/.Xauthority
export XAUTHORITY                                                         
LANG=en_US.UTF-8
export LANG
echo $$ > /tmp/xsession.pid
dbus-launch --exit-with-session startlxde &" > ~/.vnc/xstartup

echo " "

echo "Running browser patch"
wget https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Uninstall/ubchromiumfix.sh && chmod +x ubchromiumfix.sh
./ubchromiumfix.sh && rm -rf ubchromiumfix.sh

echo "You can now start vncserver by running vncserver-start"
echo " "
echo "It will ask you to enter a password when first time starting it."
echo " "
echo "The VNC Server will be started at 127.0.0.1:5901"
echo " "
echo "You can connect to this address with a VNC Viewer you prefer"
echo " "
echo "Connect to this address will open a window with LXDE Desktop Environment"
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

vncpasswd
vncserver-start
