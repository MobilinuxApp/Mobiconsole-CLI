#!/bin/bash

PASSWORD="demopasswd"
USERNAME="demousername"

echo '$USERNAME  ALL=(ALL:ALL) ALL' >> /etc/sudoers

if id -u "$USERNAME" >/dev/null 2>&1; then
    userdel -r -f $USERNAME
    useradd -m -p $PASSWORD -s /bin/bash $USERNAME
    usermod -a -G sudo $USERNAME
    echo $USERNAME:$PASSWORD | chpasswd

else
    useradd -m -p $PASSWORD -s /bin/bash $USERNAME
    usermod -a -G sudo $USERNAME
    echo $USERNAME:$PASSWORD | chpasswd
fi

