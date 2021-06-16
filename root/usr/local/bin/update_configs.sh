#!/bin/bash

old_branch=$(sudo cat /etc/v2-config | grep BRANCH | sed 's/BRANCH=//')

# fetch branches
options=""
for b in $(curl -s https://api.github.com/repos/v2cloud/v2rpi-configs/branches | sed -ne 's/^.*name": "\([^"]*\).*$/\1/p' | tr '\n' ' '); do
  case $b in
    main) options="$options $b 'Stable V2 ANA configurations'" ;;
    dev) options="$options $b 'Development V2 ANA configurations'" ;;

    *) options="$options $b 'Custom V2 AVA configurations'" ;;
  esac
done

cmd="zenity --list --width=500 --height=200 --title='Select branch to manually update config' --column='Branch' --column='Description' $options"

# manually update configs
branch=$(eval $cmd)

if [[ -z "$branch" ]]; then
  zenity --error --title="Update configs failed"  --text="No branch is selected!" --width=300 --timeout=3 &
  exit 1
fi

# string with newline
DEFAULT_CONFIG=$'\nID=HASH-ID\nUPDATED=YYYY-MM-DD hh:mm:ss\nFILE_CHANGED=0'
# add branch
DEFAULT_CONFIG="BRANCH=$branch$DEFAULT_CONFIG"

sudo echo "$DEFAULT_CONFIG" > /etc/v2-config

NOW=$(date '+%Y-%m-%d %H:%M:%S')
echo "$NOW Execute update_configs.sh in '$branch' branch of v2rpi-configs repo" >> /tmp/update_logs
curl -s https://raw.githubusercontent.com/v2cloud/v2rpi-configs/$branch/update_configs.sh | sudo bash &> /tmp/update_logs

# Notify Result
currentConfig=`sudo cat /etc/v2-config`
if [[ "$DEFAULT_CONFIG" == "$currentConfig" ]]; then
	zenity --error --title="Update Failed"  --text="Please try again!" --width=300
	exit 1;
fi

result=`sudo cat /etc/v2-config`
changeList=`cat /tmp/update_logs | grep Create | sed 's/.*file//'`

zenity --info --title="Update Complete"  --text="<b>You may need to restart to apply changes</b>\nFrom '$old_branch' to '$branch' \n<tt>$result\n\n$changeList</tt>" --width=500
