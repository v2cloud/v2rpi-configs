#!/bin/bash

branch=$(zenity --list --width=550 --height=220 \
  --title="Select to switch V2 Client branch" \
  --column="Branch" --column="Description" \
    alpha "High chance to break, have newest features and bug fixes" \
    beta "In between alpha and beta" \
    stable "Most stable but may not have desired features")

# check  current branch
downloadURL=""
case $branch in
    "alpha") downloadURL="https://github.com/v2cloud/Denver-Releases-Alpha/releases";;
    "beta") downloadURL="https://github.com/v2cloud/Denver-Releases-Beta/releases";;
    "stable") downloadURL="https://github.com/v2cloud/Denver-Releases/releases" ;;

    *)
        zenity --error --title="Switch branch failed"  --text="No branch is selected!" --width=200 --timeout=3 &
        exit 1
    ;;
esac

# get download app name
appName=$(curl -s "$downloadURL"  | grep -m1 armv7 | grep -Eo '(V2-Cloud-.*AppImage)')
if  [ -z "$appName" ]; then
  zenity --info --title="Switch branch failed"  --text="Cannot get download link. Please check connection!" --width=450 --timeout=5 &
  exit 1;
fi

if [ -f "/home/pi/$appName" ]; then
  zenity --info --title="No action required"  --text="$appName is the newest" --width=450 --timeout=5 &
  exit 0;
fi

zenity --info --title="Switching to $branch"  --text="Downloading $appName ..." --width=450 --timeout=5 &
# update newest V2 Client app
cd /tmp \
  && curl -s "$downloadURL" \
  | grep -m1 armv7  \
  | grep -oE 'href="[^"]*' \
  | sed 's/href="/https:\/\/github.com/' \
  | wget -i - \
  && ls | grep '^V2-Cloud.*\.AppImage$' \
  | tr -d '\n'| sudo xargs -r0 chmod 777 \
  && sudo rm /home/pi/V2-Cloud-* \
  ; sudo mv /tmp/V2-Cloud-* /home/pi

if [ -f "/home/pi/$appName" ]; then 
    # get user's confirmation 
    zenity --question --title="Switch to $branch complete" --text="Do you want to relaunch the app?" --width=300 --default-cancel
    if [ $? == 0 ]; then 
        sudo systemctl restart lightdm.service
    fi
else
    zenity --error --title="Switch branch failed"  --text="Switch to $branch failed. Please retry!" --width=300 --timeout=3 &
    exit 1
fi
