#!/bin/bash

cd /tmp && \
rm -rf /tmp/v2rpi-configs ; \
git clone "https://github.com/v2cloud/v2rpi-configs"

if [[ -d /tmp/v2rpi-configs ]]; then
  echo "v2rpi-configs downloaded";
else 
  echo "/tmp/v2rpi-configs does not exist. Quit!"; exit 1
fi

rootPath="/tmp/v2rpi-configs/root/"
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
        sudo mkdir -p "$targetPath" && sudo bash -c "cat $srcFile > $targetPath" && sudo chmod 777 "$targetFile"
      else
        echo "    Create/Overwrite file $targetFile"
        sudo mkdir -p "$targetPath" && sudo bash -c "cat $srcFile > $targetPath"
      fi
    fi
    echo
  fi
done;

