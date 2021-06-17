#!/bin/bash

# check V2 VNC app and download if it is not available
# current V2 VNC app
appName=$(ls /home/pi/.v2cloud | grep '^V2-Cloud-VNC.*\.AppImage$')

if [ ! -z "$appName" ]; then
  echo "V2-Cloud-VNC is available"
  exit 0
fi

# else download the V2-Cloud-VNC app
echo "downloading the lastest V2-Cloud-VNC app"
downloadURL=$(curl -s https://api.github.com/repos/v2cloud/v2vnc-releases/releases | grep -m1 'browser_download_url.*armv7l.AppImage' | grep -Eo '(https.*AppImage)')

if  [ -z "$downloadURL" ]; then
  echo "Cannot get V2-VNC download link" ; exit 1;
fi

# extract app name from downloadURL
appName=$(echo $downloadURL | grep -Eo '(V2-Cloud-.*AppImage)')

if  [ -z "$appName" ]; then
  echo "Cannot get the downloaded app name" ; exit 1;
fi

# remove download failed app
sudo rm "/tmp/$appName" &> /dev/null

cd /tmp \
  && echo "$downloadURL" | wget -qi - \
  && sudo chmod 777 ./$appName \
  && sudo mv "/tmp/$appName" "/home/pi/.v2cloud/$appName"

# check
appName=$(ls /home/pi/.v2cloud | grep '^V2-Cloud-VNC.*\.AppImage$')

if [ ! -z "$appName" ]; then
  echo "$appName is downloaded"
else
  echo "Failed to download V2-Cloud-VNC"
fi
