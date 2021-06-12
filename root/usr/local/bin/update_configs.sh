#!/bin/bash

# manually update configs
branch=$(zenity --list --width=500 --height=200 \
  --title="Select branch to manually update config" \
  --column="Branch" --column="Description" \
    main "Stable V2 ANA configurations" \
    dev "Development V2 ANA configurations")

DEFAULT_CONFIG=""
case $branch in
  "dev") 
    DEFAULT_CONFIG=$'BRANCH=dev\nID=HASH-ID\nUPDATED=YYYY-MM-DD hh:mm:ss\nFILE_CHANGED=0'
  ;;
  "main") 
    DEFAULT_CONFIG=$'BRANCH=main\nID=HASH-ID\nUPDATED=YYYY-MM-DD hh:mm:ss\nFILE_CHANGED=0'
  ;;

  *)
    zenity --error --title="Update configs failed"  --text="No branch is selected!" --width=300 --timeout=3 &
    exit 1
  ;;
esac
sudo echo "$DEFAULT_CONFIG" > /etc/v2-config

NOW=$(date '+%Y-%m-%d %H:%M:%S')
echo "$NOW Execute update_configs.sh in '$branch' branch of v2rpi-configs repo" >> /tmp/update_configs_logs
curl -s https://raw.githubusercontent.com/v2cloud/v2rpi-configs/$branch/update_configs.sh | sudo bash &> /tmp/update_logs

# Notify Result
currentConfig=`cat /etc/v2-config`
if [[ "$DEFAULT_CONFIG" == "$currentConfig" ]]; then
	zenity --error --title="Update Failed"  --text="Please try again!" --width=300
	exit 1;
fi

result=`sudo cat /etc/v2-config`
changeList=`cat /tmp/update_logs | grep Create | sed 's/.*file//'`

zenity --info --title="Update Complete"  --text="<b>You may need to restart to apply changes</b>\n<tt>$result\n\n$changeList</tt>" --width=500
