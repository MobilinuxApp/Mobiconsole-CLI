#!/bin/bash 
echo "Uninstalling Manjaro "
chmod 777 -R manjaro-fs
rm -rf manjaro-fs
rm -rf manjaro-binds
rm -rf manjaro.sh
rm -rf start-manjaro.sh
rm -rf manjaro_uninstall.sh

echo "Done"
