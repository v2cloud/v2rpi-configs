#!/bin/bash

zenity --info --text="V2 VNC is starting ..." --width=200 --timeout=5 &

# current V2 VNC app
appName=$(ls /home/pi/.v2cloud | grep '^V2-Cloud-VNC.*\.AppImage$')

cd /home/pi/.v2cloud && ./$appName
