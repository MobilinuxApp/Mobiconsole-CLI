#!/data/data/com.termux/files/usr/bin/bash
termux-setup-storage
pkg install dialog
dialog --title "Storage Info" --msgbox "\n\nStandard BackBox OS Installation would occupy around 2GB of space on your device.\n\nIf you wish to Quit right now press Ctrl+C\n\n Press OK to Continue." 20 40
dlink="https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/BackBox"
folder=backbox-fs
if [ -d "$folder" ]; then
	first=1
	echo "skipping downloading"
fi
tarball="backbox-rootfs.tar.xz"
if [ "$first" != 1 ];then
	if [ ! -f $tarball ]; then
		echo "Download Rootfs, this may take a while base on your internet speed."
		case `dpkg --print-architecture` in
		aarch64)
			archurl="arm64" ;;
		arm)
			archurl="armhf" ;;
		amd64)
			archurl="amd64" ;;
		x86_64)
			archurl="amd64" ;;	
		i*86)
			archurl="i386" ;;
		x86)
			archurl="i386" ;;
		*)
			echo "unknown architecture"; exit 1 ;;
		esac
		wget "https://github.com/MobilinuxApp/Mobiconsole-CLI/blob/master/Distribution/BackBox/Rootfs/${archurl}/backbox-rootfs-${archurl}.tar.xz?raw=true" -O $tarball		
fi
	cur=`pwd`
	mkdir -p "$folder"
	cd "$folder"
	echo "Decompressing Rootfs, please be patient."
	proot --link2symlink tar -xJf ${cur}/${tarball}||:
	cd "$cur"
fi
mkdir -p backbox-binds
bin=start-backbox.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" --kill-on-exit"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A backbox-binds)" ]; then
    for f in backbox-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b backbox-fs/root:/dev/shm"
command+=" -b /data"
command+=" -b /mnt"
command+=" -b /proc/mounts:/etc/mtab"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to / 
command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

echo "fixing shebang of $bin"
termux-fix-shebang $bin
echo "making $bin executable"
chmod +x $bin
echo "removing image for some space"
rm $tarball

#DE installation addition

wget --tries=20 $dlink/Installer/DEs/XFCE4/backbox_xfce4_de.sh -O $folder/root/backbox_xfce4_de.sh
clear
echo "Setting up the installation of XFCE VNC"

echo "APT::Acquire::Retries \"3\";" > $folder/etc/apt/apt.conf.d/80-retries #Setting APT retry count
echo "#!/bin/bash
#mv /etc/apt/sources.list  /etc/apt/sources.list.old 
#wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/BackBox/Installer/sources.list -O /etc/apt/sources.list
echo 'Updating the System'
apt update
rm -rf /var/lib/apt/lists/*
apt update --fix-missing
apt-get dist-upgrade --fix-missing
echo " "
apt install wget sudo dialog -y
clear
if [ ! -f /root/backbox_xfce4_de.sh ]; then
    wget --tries=20 $dlink/Installer/DEs/XFCE4/backbox_xfce4_de.sh -O /root/backbox_xfce4_de.sh
    bash ~/backbox_xfce4_de.sh
else
    bash ~/backbox_xfce4_de.sh
fi
clear
if [ ! -f /usr/local/bin/vncserver-start ]; then
    wget --tries=20  $dlink/Installer/DEs/XFCE4/vncserver-start -O /usr/local/bin/vncserver-start
    wget --tries=20 $dlink/Installer/DEs/XFCE4/vncserver-stop -O /usr/local/bin/vncserver-stop
    chmod +x /usr/local/bin/vncserver-stop
    chmod +x /usr/local/bin/vncserver-start
fi
if [ ! -f /usr/bin/vncserver ]; then
    apt install tigervnc-standalone-server -y
fi
clear
echo 'Installing Browser'
apt install firefox-esr -y 
clear
echo 'Creating new user'
wget --tries=20 https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Debian/Installer/adduser.sh -O /root/adduser.sh && chmod +x adduser.sh
sed -i 's/demousername/defaultusername/g; s/demopasswd/defaultpasswd/g' adduser.sh
bash ~/adduser.sh
echo 'User creation....Done'
clear
echo 'You can login to new user using su - USERNAME'
echo ' Welcome to Mobilinux | BackBox OS '
rm -rf /root/adduser.sh
rm -rf /root/backbox_xfce4_de.sh
rm -rf ~/.bash_profile" > $folder/root/.bash_profile 

bash $bin
