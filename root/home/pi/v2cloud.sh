#!/bin/bash

# Enable/Disable xorg.conf file for dual screen - start
XORG_CONFIG_FILE='/etc/X11/xorg.conf'
XORG_CONFIG_FILE_DISABLE='/etc/X11/xorg.conf.disable'
isHDMI0connected=$(/usr/bin/tvservice -s -v 2 | grep "state 0xa" | wc -l)
isHDMI1connected=$(/usr/bin/tvservice -s -v 7 | grep "state 0xa" | wc -l)
isXorgConfDualScreenExist=$(ls $XORG_CONFIG_FILE | wc -l)

echo "isHDMI0connected $isHDMI0connected"
echo "isHDMI1connected $isHDMI1connected"
echo "isXorgConfDualScreenExist $isXorgConfDualScreenExist"

if   [[ $isHDMI0connected == "1" ]] && [[ $isHDMI1connected == "1" ]] && [[ $isXorgConfDualScreenExist == "0" ]]; then
  echo "enable xorg config file for dual screen"
  sudo mv $XORG_CONFIG_FILE_DISABLE $XORG_CONFIG_FILE && sudo service lightdm restart
elif [[ $isHDMI0connected == "1" ]] && [[ $isHDMI1connected == "0" ]] && [[ $isXorgConfDualScreenExist == "1" ]]; then
  echo "disable xorg config file for dual screen"
  sudo mv $XORG_CONFIG_FILE $XORG_CONFIG_FILE_DISABLE && sudo service lightdm restart
elif [[ $isHDMI0connected == "0" ]] && [[ $isHDMI1connected == "1" ]] && [[ $isXorgConfDualScreenExist == "1" ]]; then
  echo "disable xorg config file for dual screen"
  sudo mv $XORG_CONFIG_FILE $XORG_CONFIG_FILE_DISABLE && sudo service lightdm restart
fi
# Enable/Disable xorg.conf file for dual screen - end ---

# SETUP WIFI - start
# get wlan0 MAC address
current_mac=$(cat /sys/class/net/wlan0/address)

# convert to upper-case
CURRENT_MAC=${current_mac^^}

# use comma as separator
IFS=","

# update MAC address of wifi connections
for con in $(nmcli -t -f NAME,TYPE connection | grep 802-11-wireless | tr '\n' ',' | sed 's/:802-11-wireless//g'); do
   mac_address=$(sudo cat "/etc/NetworkManager/system-connections/$con.nmconnection" | grep mac-address= | sed 's/mac-address=//')

   # if there is cur_mac_address and it is not equal current MAC
   if [[ ! -z $mac_address && $mac_address != $CURRENT_MAC ]]; then
     echo "Update MAC address of ${con} from ${mac_address} to ${CURRENT_MAC}"
     sudo nmcli con modify id "${con}" wifi.mac-address "${CURRENT_MAC}"
   else
     echo "${con} has the same MAC address ${mac_address}"
   fi
done
# SETUP WIFI - end ---

# set background image
feh --bg-fill '/home/pi/background.png'

# current V2 Cloud app
appName=$(ls /home/pi/ | grep '^V2-Cloud.*\.AppImage$')

# check new version was downloaded
newAppName=$(ls /home/pi/.cache/v2client-electron-updater/pending/ | grep '^V2-Cloud.*\.AppImage$')

if [[ -z "$newAppName" ]]; then
  cd /home/pi && ./$appName --no-security &
else
  mv /home/pi/.cache/v2client-electron-updater/pending/$newAppName /home/pi/$newAppName
  rm /home/pi/$appName
  cd /home/pi && ./$newAppName --no-security &
fi

# close unused apps
killall light-locker

# wait for internet connection
check_internet.sh

# update configs
if  ls /home/pi/ | grep '^V2-Cloud.*armv7l\.AppImage$' | grep -E '(alpha|beta)'; then
  echo "update dev configs"
  curl -s https://raw.githubusercontent.com/v2cloud/v2rpi-configs/alpha/update_configs.sh | sudo bash &> /tmp/update_logs
else
  echo "update prod configs"
  curl -s https://raw.githubusercontent.com/v2cloud/v2rpi-configs/main/update_configs.sh | sudo bash &> /tmp/update_logs
fi
