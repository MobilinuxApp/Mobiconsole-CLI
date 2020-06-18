#!/data/data/com.termux/files/usr/bin/bash

echo "Starting to uninstall, please be patient..."

chmod 777 -R fedora-fs
rm -rf fedora-fs
rm -rf fedora-binds
rm -rf fedora.sh
rm -rf start-fedora.sh
rm -rf fedora_lxde_de.sh
rm -rf fedora_lxqt_de.sh
rm -rf fedora_mate_de.sh
rm -rf fedora_xfce4_de.sh
rm -rf fedora-ssh.sh
rm -rf fedora_awesome_wm.sh
rm -rf fedora_icewm_wm.sh
rm -rf fedora_custom.sh
rm -rf fedora_custom_awesome.sh
rm -rf fedora_custom_icewm.sh
rm -rf fedora_custom_lxde.sh
rm -rf fedora_custom_lxqt.sh
rm -rf fedora_custom_mate.sh
rm -rf std-fedora-installer.sh
rm -rf fedora_uninstall.sh

echo "Done"
