#!/data/data/com.termux/files/usr/bin/bash

echo "Starting to uninstall, please be patient..."

chmod 777 -R backbox-fs
rm -rf backbox-fs
rm -rf backbox-binds
rm -rf backbox.sh
rm -rf start-backbox.sh
rm -rf backbox_lxde_de.sh
rm -rf backbox_lxqt_de.sh
rm -rf bockbox_mate_de.sh
rm -rf backbox_xfce4_de.sh
rm -rf backbox-ssh.sh
rm -rf backbox_awesome_wm.sh
rm -rf backbox_icewm_wm.sh
rm -rf backbox_custom.sh
rm -rf backbox_custom_awesome.sh
rm -rf backbox_custom_icewm.sh
rm -rf backbox_custom_lxde.sh
rm -rf backbox_custom_lxqt.sh
rm -rf backbox_custom_mate.sh
rm -rf std-backbox-installer.sh
rm -rf backbox_uninstall.sh

echo "Done"
