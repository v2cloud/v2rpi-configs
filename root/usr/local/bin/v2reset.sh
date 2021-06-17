#!/bin/bash

# get user's confirmation 
zenity --question --title="Reset V2 Cloud AVA" --text="<span color=\"red\"><b>Are you sure, proceed to reset your V2 Cloud AVA?</b></span>" --width=250 --default-cancel
if [ $? != 0 ]; then 
  exit 0
fi

# clean networkmanager connections
sudo rm /etc/NetworkManager/system-connections/*

# clean electron app cache
sudo rm -rf '/home/pi/.config/V2 Cloud Alpha'
sudo rm -rf '/home/pi/.config/V2 Cloud Beta'
sudo rm -rf '/home/pi/.config/V2 Cloud'
sudo rm -rf '/home/pi/.config/v2vnc-electron'

# disable ssh
sudo systemctl disable ssh.service

# copy default files
sudo cp '/home/pi/.v2cloud/files/config.txt' '/boot/config.txt'
sudo cp '/home/pi/.v2cloud/files/xorg.conf' '/etc/X11/xorg.conf'

# delete files
sudo rm '/etc/X11/xorg.conf.disable' /home/pi/.v2cloud/V2-Cloud-VNC*AppImage

# clear history
sudo cat /dev/null > /home/pi/.bash_history

# get user's confirmation 
zenity --question --title="Reset Complete" --text="V2 Cloud AVA is going to <b>reboot</b> to apply changes.\nDo you want to <b>shutdown</b> instead?" --width=400 --default-cancel
if [ $? == 0 ]; then 
  sudo shutdown -h now
else
  sudo reboot
fi
