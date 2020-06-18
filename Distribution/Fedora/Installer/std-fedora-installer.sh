#!/data/data/com.termux/files/usr/bin/bash
folder=fedora-fs
termux-setup-storage
pkg install dialog
dialog --title "Storage Info" --msgbox "\n\nStandard Fedora Installation would occupy around 1GB of space on your device.\n\nIf you wish to Quit right now press Ctrl+C\n\n Press OK to Continue." 20 40
dlink="https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Fedora"
if [ -d "$folder" ]; then
	first=1
	echo "skipping downloading"
fi
tarball="fedora-rootfs.tar.xz"
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
		*)
			echo "unknown architecture"; exit 1 ;;
		esac
		wget "https://github.com/MobilinuxApp/Mobiconsole-CLI/blob/master/Distribution/Fedora/Rootfs/${archurl}/fedora-rootfs-${archurl}.tar.xz?raw=true" -O $tarball
  fi
	cur=`pwd`
	mkdir -p "$folder"
	cd "$folder"
	echo "Decompressing Rootfs, please be patient."
	proot --link2symlink tar -xJf ${cur}/${tarball} --exclude='dev'||:
	
	echo "Setting up name server"
	echo "127.0.0.1 localhost" > etc/hosts
    echo "nameserver 8.8.8.8" > etc/resolv.conf
    echo "nameserver 8.8.4.4" >> etc/resolv.conf
	cd "$cur"
fi
mkdir -p fedora-binds
bin=start-fedora.sh
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
if [ -n "\$(ls -A fedora-binds)" ]; then
    for f in fedora-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b fedora-fs/root:/dev/shm"
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

wget --tries=20 $dlink/Installer/DEs/XFCE4/fedora_xfce4_de.sh -O $folder/root/fedora_xfce4_de.sh
clear
echo "Setting up the installation of XFCE VNC"
echo "#!/bin/bash
yum install wget dialog sudo -y
clear
if [ ! -f /root/fedora_xfce4_de.sh ]; then
    wget --tries=20 $dlink/Installer/DEs/XFCE4/fedora_xfce4_de.sh -O /root/fedora_xfce4_de.sh
    bash ~/fedora_xfce4_de.sh
else
    bash ~/fedora_xfce4_de.sh
fi
clear
if [ ! -f /usr/local/bin/vncserver-start ]; then
    wget --tries=20  $dlink/LXDE/vncserver-start -O /usr/local/bin/vncserver-start
    wget --tries=20 $dlink/LXDE/vncserver-stop -O /usr/local/bin/vncserver-stop
        chmod +x /usr/local/bin/vncserver-stop
    chmod +x /usr/local/bin/vncserver-start
fi
if [ ! -f /usr/bin/vncserver ]; then
    yum install tigervnc-server -y
fi
clear
echo 'Installing browser'
yum install firefox -y
echo 'Creating new user'
wget --tries=20 https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Debian/Installer/adduser.sh -O /root/adduser.sh && chmod +x adduser.sh
sed -i 's/demousername/defaultusername/g; s/demopasswd/defaultpasswd/g' adduser.sh
bash ~/adduser.sh
echo 'User creation....Done'
echo 'Writing Help Script'
wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/distro-help -P /usr/local/bin/
chmod +x /usr/local/bin/distro-help
clear
echo 'You can login to new user using su - USERNAME'
echo 'Welcome to Mobilinux | Fedora 30 '
rm -rf /root/adduser.sh
rm -rf ~/.bash_profile" > $folder/root/.bash_profile 
rm -rf fedora_xfce4_de.sh
bash $bin
