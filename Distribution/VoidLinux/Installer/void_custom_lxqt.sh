#!/data/data/com.termux/files/usr/bin/bash
folder=void-fs
dlink="https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/VoidLinux"
if [ -d "$folder" ]; then
  first=1
  echo "skipping downloading"
fi
tarball="void.tar.xz"

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
    wget "https://github.com/MobilinuxApp/Mobiconsole-CLI/blob/master/Distribution/VoidLinux/Rootfs/${archurl}/void_${archurl}.tar.xz?raw=true" -O $tarball
  fi
  mkdir -p "$folder"
  echo "Decompressing Rootfs, please be patient."
  proot --link2symlink tar -xJf ${tarball} -C $folder||:
fi

mkdir -p void-binds
bin=start-void.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A void-binds)" ]; then
    for f in void-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b void-fs/root:/dev/shm"
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

echo "Fixing DNS for internet connection"
rm -rf void-fs/etc/resolv.conf
echo "nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 192.168.1.1
nameserver 127.0.0.1" > void-fs/etc/resolv.conf

echo "making $bin executable"
chmod +x $bin
rm $tarball

#DE installation addition

wget --tries=20 $dlink/Installer/DEs/LXQT/void_lxqt_de.sh -O $folder/root/void_lxqt_de.sh > /dev/null
clear
echo "Setting up the installation of LXQT VNC"

echo "#!/bin/bash
xbps-install -Su -y && xbps-install -S lxqt xorg tigervnc wget sudo -y 
if [ ! -f /root/void_xfce4_de.sh ]; then
    wget --tries=20 $dlink/Installer/DEs/LXQT/void_lxqt_de.sh -O /root/void_lxqt_de.sh > /dev/null
    bash ~/void_lxqt_de.sh
else
    bash ~/void_lxqt_de.sh
fi
clear
if [ ! -f /usr/local/bin/vncserver-start ]; then
    wget --tries=20  $dlink/Installer/DEs/LXQT/vncserver-start -O /usr/local/bin/vncserver-start > /dev/null
    wget --tries=20 $dlink/Installer/DEs/LXQT/vncserver-stop -O /usr/local/bin/vncserver-stop > /dev/null
    chmod +x /usr/local/bin/vncserver-stop
    chmod +x /usr/local/bin/vncserver-start
fi
if [ ! -f /usr/bin/vncserver ]; then
    xbps-install -S lxqt xorg tigervnc wget -y  > /dev/null
fi
echo 'Creating new user'
wget --tries=20 https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Debian/Installer/adduser.sh -O /root/adduser.sh && chmod +x adduser.sh
sed -i 's/demousername/defaultusername/g; s/demopasswd/defaultpasswd/g' adduser.sh
bash ~/adduser.sh
echo 'User creation....Done'
echo 'You can login to new user using su - USERNAME'
echo ' Welcome to Mobilinux | Void Linux '
rm -rf ~/.bash_profile" > $folder/root/.bash_profile 

bash $bin
