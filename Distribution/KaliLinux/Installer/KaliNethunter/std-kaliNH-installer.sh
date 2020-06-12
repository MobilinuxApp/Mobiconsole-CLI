#!/data/data/com.termux/files/usr/bin/bash
termux-setup-storage
dlink="https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/KaliLinux"
if [ -d "$folder" ]; then
	first=1
	echo "skipping downloading"
fi
tarball="nethunter-rootfs.tar.gz"
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
		wget "https://build.nethunter.com/kalifs/kalifs-latest/kalifs-${archurl}-full.tar.xz" -O $tarball
	fi
	cur=`pwd`
	echo "Decompressing Rootfs, please be patient."
	proot --link2symlink tar -xJf ${cur}/${tarball} --exclude='dev'||:
	cd "$cur"
fi
mv kali-${archurl} nethunter-fs
rm nethunter-fs/etc/apt/sources.list
rm -rf nethunter-fs/dev
echo "deb http://mirror.fsmg.org.nz/kali kali-rolling main contrib non-free" >> nethunter-fs/etc/apt/sources.list
echo "deb-src http://mirror.fsmg.org.nz/kali kali-rolling main contrib non-free" >> nethunter-fs/etc/apt/sources.list
wget https://archive.kali.org/archive-key.asc -O nethunter-fs/etc/apt/trusted.gpg.d/kali-archive-key.asc
mkdir -p nethunter-binds
bin=start-nethunter.sh
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
command+=" -r nethunter-fs"
if [ -n "\$(ls -A nethunter-binds)" ]; then
    for f in nethunter-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b nethunter-fs/root:/dev/shm"
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

wget --tries=20 $dlink/Installer/DEs/XFCE4/kali_xfce4_de.sh -O $folder/root/kali_xfce4_de.sh
clear
echo "Setting up the installation of XFCE VNC"

echo "APT::Acquire::Retries \"3\";" > $folder/etc/apt/apt.conf.d/80-retries #Setting APT retry count
echo "#!/bin/bash
rm -rf /etc/resolv.conf
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
apt update -y && apt install wget sudo dialog -y
clear
if [ ! -f /root/kali_xfce4_de.sh ]; then
    wget --tries=20 $dlink/Installer/DEs/XFCE4/kali_xfce4_de.sh -O /root/kali_xfce4_de.sh
    bash ~/kali_xfce4_de.sh
else
    bash ~/kali_xfce4_de.sh
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
echo 'Installing browser'
apt install firefox-esr -y
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
echo 'You can login to new user using su - USERNAME'
echo 'Welcome to Mobilinux | Kali NetHunter'
rm -rf /root/adduser.sh
rm -rf /root/kali_xfce4_de.sh
rm -rf ~/.bash_profile" > $folder/root/.bash_profile 
 
bash $bin
