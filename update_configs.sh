#!/bin/bash

# This online script is called from
# 1. /user/local/bin/v2cloud.sh (auto update, main goal: silently update on the same branch)
# 2. /usr/local/bin/update_configs.sh (manual update, main goal: interactively update to other branch)
#     Example: change from 'main' to 'dev'
#       1. The local file /usr/local/bin/update_configs.sh (on main branch) is executed
#       2. User choose 'dev' branch
#       3. This online script (on dev branch) is pulled and executed instead of (on main branch)
#       4. The local file /usr/local/bin/update_configs.sh may be replaced with the one on 'dev' branch if it is different

# install required pkgs
installed() {
    return $(dpkg-query -W -f '${Status}\n' "${1}" 2>&1|awk '/ok installed/{print 0;exit}{print 1}')
}

pkgs=(libevent-pthreads-2.1-6 libjpeg8 sshpass feh wmctrl simple-scan printer-driver-all)
missing_pkgs=""

for pkg in ${pkgs[@]}; do
  if ! $(installed $pkg) ; then
    missing_pkgs+=" $pkg"
  fi
done

if [ ! -z "$missing_pkgs" ]; then
  echo "Install $missing_pkgs" 
  sudo apt install -y $missing_pkgs
fi
### 

# get rpi-config branch
branch=$(sudo cat /etc/v2-config | grep BRANCH | sed 's/BRANCH=//')

# validate branch
valid=0;
for b in $(curl -s https://api.github.com/repos/v2cloud/v2rpi-configs/branches | sed -ne 's/^.*name": "\([^"]*\).*$/\1/p' | tr '\n' ' '); do
  if [[ "$branch" == "$b" ]]; then
    valid=$((valid+1))
    echo "Updating config in branch '$branch'"
    break
  fi
done

# invalid value then reset to default
if [[ $valid -eq 0 ]]; then 
  echo "Branch '$branch' is invalid! Updating config from the default 'main' branch"
  branch="main"
fi

SECONDS=0
CONFIGS_DIR="/tmp/v2rpi-configs-$branch"

# download config files
cd /tmp && \
rm -rf "$CONFIGS_DIR" ; \
wget -O - https://github.com/v2cloud/v2rpi-configs/archive/refs/heads/$branch.tar.gz | tar xz

# exit if failed
if [[ -d "$CONFIGS_DIR" ]]; then
  echo "$CONFIGS_DIR downloaded";
else 
  echo "$CONFIGS_DIR does not exist. Quit!"; exit 1
fi

rootPath="$CONFIGS_DIR/root/"
rootPathLength=`echo $rootPath | wc -c`
updated=0

# update config files
for srcFile in $(find $rootPath -print); do
  # only check files
  if [[ -f $srcFile ]]; then
    # skip files
    case $srcFile in
        *"boot/config.txt"*) continue ;;
        *"etc/X11/xorg.conf"*) continue ;;
        *"home/pi/.v2cloud/V2-Cloud-VNC"*) continue ;;
        *"README.md"*) continue ;;
        *"etc/v2-config"*) continue ;;
        *"etc/v2-release"*) continue ;;
    esac
    # echo $srcFile
    targetFile=${srcFile:$((rootPathLength - 2))}
    targetPath=${targetFile%/*}
    # compare
    echo "compare between $srcFile $targetFile"
    cmp $srcFile $targetFile 2> /dev/null
    if [[ $? -eq 0 ]]
      then echo "EQUAL"
    else
      #diff  $srcFile $targetFile 
      if [[ "$targetFile" == *".sh" ]]; then
        echo "    Create/Overwrite bash file $targetFile"
        sudo mkdir -p "$targetPath" && sudo bash -c "cat $srcFile > $targetFile" && sudo chmod 777 "$targetFile"
      else
        echo "    Create/Overwrite      file $targetFile"
        sudo mkdir -p "$targetPath" && sudo bash -c "cat $srcFile > $targetFile" && sudo chmod 666 "$targetFile"
      fi
      updated=$((updated+1))
    fi
    echo
  fi
done;

echo "update $updated configs in $SECONDS seconds"

NOW=$(date '+%Y-%m-%d %H:%M:%S')
hashId=`curl -s https://api.github.com/repos/v2cloud/v2rpi-configs/commits/$branch | grep -m1 sha | sed -ne 's/^.*sha": "\([^"]*\).*$/\1/p'`

# reset & update v2-config file
# string with newline
DEFAULT_CONFIG=$'\nID=HASH-ID\nUPDATED=YYYY-MM-DD hh:mm:ss\nFILE_CHANGED=0'
# add branch
DEFAULT_CONFIG="BRANCH=$branch$DEFAULT_CONFIG"
sudo echo "$DEFAULT_CONFIG" > /etc/v2-config

sudo sed -i "s/ID=.*/ID=$hashId/g" /etc/v2-config
sudo sed -i "s/UPDATED=.*/UPDATED=$NOW/g" /etc/v2-config
sudo sed -i "s/FILE_CHANGED=.*/FILE_CHANGED=$updated/g" /etc/v2-config

# ask for reboot if have changes
if [[ $updated -ne 0 ]]; then
  # re-focus because it is hidden by the V2 Cloud app kiosk mode
  sleep 3 && wmctrl -a "V2 AVA is updated" &

  zenity --question --title="V2 AVA is updated" --text="<b>Please reboot to apply changes</b>" --width=400
  if [ $? == 0 ]; then 
    sudo reboot
  fi
fi
