#!/data/data/com.termux/files/usr/bin/bash

echo "Uninstalling Kali, please be patient..."

chmod 777 -R kali-fs
rm -rf kali-fs
rm -rf kali-binds
rm -rf kali.sh
rm -rf start-kali.sh
rm -rf kali-ssh.sh
rm -rf kali_lxde_de.sh
rm -rf kali_lxqt_de.sh
rm -rf kali_mate_de.sh
rm -rf kali_xfce4_de.sh
rm -rf kali_awesome_de.sh
rm -rf kali_icewm_de.sh
rm -rf kali_custom.sh
rm -rf kali_custom_awesome.sh
rm -rf kali_custom_icewm.sh
rm -rf kali_custom_lxde.sh
rm -rf kali_custom_lxqt.sh
rm -rf kali_custom_mate.sh
rm -rf std-kali-installer.sh
rm -rf kali_uninstall.sh

echo "Done"
