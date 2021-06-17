#!/bin/bash

# get branch
branch=$(zenity --list --width=550 --height=220 \
  --title="Select to switch V2 Client branch" \
  --column="Branch" --column="Description" \
    alpha "High chance to break, have newest features and bug fixes" \
    beta "In between alpha and beta" \
    stable "Most stable but may not have desired features")

# check  current branch
branchURL=""
case $branch in
    "alpha") branchURL="https://api.github.com/repos/v2cloud/Denver-Releases-Alpha/releases";;
    "beta") branchURL="https://api.github.com/repos/v2cloud/Denver-Releases-Beta/releases";;
    "stable") branchURL="https://api.github.com/repos/v2cloud/Denver-Releases/releases" ;;

    *)
      zenity --error --title="Switch branch failed"  --text="No branch is selected!" --width=300 --timeout=3 &
      exit 1
    ;;
esac

# get download url
downloadURL=$(curl -s $branchURL | grep -m1 'browser_download_url.*armv7l.AppImage' | grep -Eo '(https.*AppImage)')

if  [ -z "$downloadURL" ]; then
  zenity --info --title="Switch branch failed"  --text="Cannot get download link. Please check connection!" --width=450 --timeout=5 &
  exit 1;
fi

# extract app name from downloadURL
appName=$(echo $downloadURL | grep -Eo '(V2-Cloud-.*AppImage)')

if  [ -z "$appName" ]; then
  zenity --info --title="Switch branch failed"  --text="Cannot get app name. Please check connection!" --width=450 --timeout=5 &
  exit 1;
fi

# check current local app name
if [ -f "/home/pi/$appName" ]; then
  zenity --info --title="No action required"  --text="$appName is the newest" --width=450 --timeout=5 &
  exit 0;
fi

downloadingWindow="Switching to $branch"
zenity --info --title="$downloadingWindow"  --text="Downloading $appName ..." --width=450 &

# remove download failed app
sudo rm "/tmp/$appName" &> /dev/null

# update newest V2 Client app
cd /tmp \
  && echo "$downloadURL" | wget -i - \
  && sudo chmod 777 ./$appName \
  && sudo rm /home/pi/V2-Cloud-*AppImage \
  ; sudo mv "/tmp/$appName" "/home/pi/$appName"

# notify result
wmctrl -c "$downloadingWindow" 
if [ -f "/home/pi/$appName" ]; then 
    # get user's confirmation 
    zenity --question --title="Switch to $branch complete" --text="Do you want to relaunch the app?" --width=300 --default-cancel
    if [ $? == 0 ]; then 
      sudo systemctl restart lightdm.service
    fi
else
    zenity --error --title="Switch branch failed"  --text="Switch to $branch failed. Please retry!" --width=300
    exit 1
fi
