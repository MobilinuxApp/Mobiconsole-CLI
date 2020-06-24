#!/bin/bash

mkdir sources
cd sources
wget http://deb.debian.org/debian/pool/main/f/fakeroot/fakeroot_1.20.2.orig.tar.bz2
cd fakeroot_1.20.2/
./bootstrap
./configure — prefix=/opt/fakeroot \
 — libdir=/opt/fakeroot/libs \
 — disable-static \
 — with-ipc=tcp
make
sudo make install
sleep 3
echo 'if [[ $UID -ge 1000 && -d /opt/fakeroot/bin && -z $(echo $PATH | grep -o /opt/fakeroot/bin ) ]]'
then
export PATH=”${PATH}:/opt/fakeroot/bin”
fi' > /etc/profile
sleep 3
cd ..
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -Syu fakeroot-tcp
