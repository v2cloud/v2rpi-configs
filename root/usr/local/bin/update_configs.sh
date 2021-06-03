#!/bin/bash

CONFIGS_DIR="/tmp/v2rpi-configs-main"

cd /tmp && \
rm -rf "$CONFIGS_DIR" ; \
wget -O - https://github.com/v2cloud/v2rpi-configs/archive/refs/heads/main.tar.gz | tar xz

if [[ -d "$CONFIGS_DIR" ]]; then
  echo "$CONFIGS_DIR downloaded";
else 
  echo "$CONFIGS_DIR does not exist. Quit!"; exit 1
fi

rootPath="$CONFIGS_DIR/root/"
rootPathLength=`echo $rootPath | wc -c`

for srcFile in $(find $rootPath -print); do
  # only check files
  if [[ -f $srcFile ]]; then
    # skip files
    case $srcFile in
        *"boot/config.txt"*) continue ;;
        *"etc/X11/xorg.conf"*) continue ;;
        *"home/pi/.v2cloud/V2-Cloud-VNC"*) continue ;;
        *"README.md"*) continue ;;
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
        echo "    Create/Overwrite file $targetFile"
        sudo mkdir -p "$targetPath" && sudo bash -c "cat $srcFile > $targetFile"
      fi
    fi
    echo
  fi
done;

