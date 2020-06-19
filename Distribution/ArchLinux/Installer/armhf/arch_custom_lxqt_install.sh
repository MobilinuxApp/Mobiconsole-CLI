#!/data/data/com.termux/files/usr/bin/bash
folder=arch-fs
termux-setup-storage
pkg install dialog
dialog --title "Storage Info" --msgbox "\n\nStandard Arch Linux Installation would occupy around 1.5GB of space on your device.\n\nIf you wish to Quit right now press Ctrl+C\n\n Press OK to Continue." 20 40
dlink="https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/ArchLinux"
if [ -d "$folder" ]; then
	first=1
	echo "skipping downloading"
fi
tarball="arch-rootfs.tar.gz"
if [ "$first" != 1 ];then
	if [ ! -f $tarball ]; then
		echo "Download Rootfs, this may take a while base on your internet speed."
		case `dpkg --print-architecture` in
		aarch64)
			archurl="aarch64" ;;
		arm)
			archurl="armv7" ;;
		*)
			echo "unknown architecture"; exit 1 ;;
		esac
		wget "http://os.archlinuxarm.org/os/ArchLinuxARM-${archurl}-latest.tar.gz" -O $tarball
	fi
	cur=`pwd`
	mkdir -p "$folder"
	cd "$folder"
	echo "Decompressing Rootfs, please be patient."
	proot --link2symlink tar -xf ${cur}/${tarball}||:
	cd "$cur"
fi
mkdir -p arch-binds
bin=start-arch.sh
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
if [ -n "\$(ls -A arch-binds)" ]; then
    for f in arch-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b arch-fs/root:/dev/shm"
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
echo "You can now launch Arch Linux with the ./${bin} script"
echo "Preparing additional component for the first time, please wait..."
wget "https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/ArchLinux/Installer/armhf/resolv.conf" -P arch-fs/root
wget "https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/ArchLinux/Installer/armhf/additional.sh" -P arch-fs/root
rm -rf arch-fs/root/.bash_profile


wget $dlink/Installer/DEs/LXQT/arch_lxqt_de.sh -O $folder/root/arch_lxqt_de.sh
echo " #!/bin/bash
bash ~/additional.sh
pacman -Syyuu --noconfirm && pacman -S wget sudo --noconfirm 
mkdir -p ~/.vnc
clear
if [ ! -f /root/arch_lxqt_de.sh ]; then
    wget --tries=20 $dlink/Installer/DEs/LXQT/arch_lxqt_de.sh -O /root/arch_lxqt_de.sh
    bash ~/arch_lxqt_de.sh
else
    bash ~/arch_lxqt_de.sh
fi
clear
if [ ! -f /usr/local/bin/vncserver-start ]; then
    wget --tries=20  $dlink/Installer/DEs/LXQT/vncserver-start -O /usr/local/bin/vncserver-start 
    wget --tries=20 $dlink/Installer/DEs/LXQT/vncserver-stop -O /usr/local/bin/vncserver-stop
    chmod +x /usr/local/bin/vncserver-stop
    chmod +x /usr/local/bin/vncserver-start
fi
if [ ! -f /usr/bin/vncserver ]; then
    pacman -S tigervnc --noconfirm > /dev/null
fi
pacman -S firefox --noconfirm 
clear
echo 'Creating new user'
wget --tries=20 https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Debian/Installer/adduser.sh -O /root/adduser.sh && chmod +x adduser.sh
sed -i 's/demousername/defaultusername/g; s/demopasswd/defaultpasswd/g' adduser.sh
bash ~/adduser.sh
echo 'User creation....Done'
echo 'Writing Help Script'
wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/distro-help -P /usr/local/bin/
chmod +x /usr/local/bin/distro-help
clear
echo 'You can login to new user using "su - USERNAME" '
echo 'Welcome to Mobilinux | Arch Linux'
rm -rf /root/adduser.sh
rm -rf /root/arch_lxqt_de.sh
rm -rf ~/.bash_profile" > $folder/root/.bash_profile 

bash $bin
