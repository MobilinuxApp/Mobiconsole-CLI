#!/bin/bash
clear
echo "Installing i3wm"
sleep 2
sudo apt update -y
apt install dialog
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
              apt install i3 tightvncserver wget nano dbus-x11 xorg xterm xfce4-terminal pcmanfm shotwell feh cairo-dock libexo-1-0 --no-install-recommends -y
        fi
 
         # Full is selected
        if [ "$_return" = "2" ]
        then
            	echo 'Installing Full System '
		        sleep 4
		        apt install i3 tightvncserver wget nano dbus-x11 xorg xterm xfce4-terminal pcmanfm shotwell feh cairo-dock libexo-1-0 firefox-esr gimp neofetch libreoffice lightdm libreoffice-gtk synaptic vlc xdg-utils xorg xserver-xorg-input-all xserver-xorg-video-all -y
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

apt-get clean

read -p "Want to install default browser ? (y/n)" choice
case "$choice" in 
  y|Y ) sudo apt install epiphany-browser -y ;;
  n|N ) echo "Ok... Not epiphany browser";;
  * ) echo "invalid";;
esac

read -p "What to install chromium browser ? (y/n) [ Chromium might not work on arm/arm32/armhf devices ] " choice
case "$choice" in 
  y|Y ) wget https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Uninstall/ubchromiumfix.sh && chmod +x ubchromiumfix.sh && ./ubchromiumfix.sh && rm -rf ubchromiumfix.sh ;;
  n|N ) echo "Ok... Not installing Chromium";;
  * ) echo "invalid";;
esac

mkdir -p ~/.vnc

wget https://raw.githubusercontent.com/Mobiconsole-CLI/Distribution/Ubuntu/Installer/WindowManager/wallpaper.jpg -O /usr/share/wallpaper.jpg
echo "#!/bin/bash
[ -r ~/.Xresources ] && xrdb ~/.Xresources
export PULSE_SERVER=127.0.0.1
export DISPLAY=:1
export ~/.Xauthority
dbus-launch i3 &
dbus-launch cairo-dock &
feh --bg-fill /usr/share/wallpaper.jpg " > ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup

wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/development-branch/Distribution/Ubuntu/Installer/WindowManager/i3/vncserver-start -O /usr/local/bin/vncserver-start
wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/development-branch/Distribution/Ubuntu/Installer/WindowManager/i3/vncserver-stop -O /usr/local/bin/vncserver-stop
chmod +x /usr/local/bin/vncserver-start
chmod +x /usr/local/bin/vncserver-stop


echo "You can now start vncserver by running vncserver-start"
echo " "
echo "It will ask you to enter a password when first time starting it."
echo " "
echo "The VNC Server will be started at 127.0.0.1:5901"
echo " "
echo "You can connect to this address with a VNC Viewer you prefer"
echo ""
echo " "
echo "**Note : Please note that you will need to enter view only password too while configuring VNC password to avoid connection errors."
echo " "
echo ""
echo "Running vncserver-start"
echo ""
echo ""
echo ""
echo " To Kill VNC Server just run vncserver-stop "
echo ""
echo ""
echo ""

vncpasswd
vncserver-start
