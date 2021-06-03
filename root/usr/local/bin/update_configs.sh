#!/bin/bash

# while getopts u:p: flag
# do
#     case "${flag}" in
#         u) username=${OPTARG};;
#         p) passwd=${OPTARG};;
#     esac
# done
# echo "Username: $username";
# echo "Pass: $passwd";

cd /tmp && \
rm -rf /tmp/v2rpi-configs ; \
git clone "https://github.com/v2cloud/v2rpi-configs" \
#rm -rf $dest ; \
#mv /tmp/v2rpi/release-image/configs/root $dest 

if [[ -d /tmp/v2rpi ]]
then echo "/tmp/v2rpi exist";
else echo "/tmp/v2rpi does not exist"; exit 1
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

