#!/data/data/com.termux/files/usr/bin/bash

echo "Starting to uninstall, please be patient..."

chmod 777 -R centos-fs
rm -rf centos-fs
rm -rf centos-binds
rm -rf centos.sh
rm -rf start-centos.sh
rm -rf ssh-yum.sh
rm -rf centos_uninstall.sh

echo "Done"
