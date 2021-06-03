#!/bin/bash

# download newest alpha
cd /home/pi/Downloads \
  && curl -s https://github.com/v2cloud/Denver-Releases-Alpha/releases \
  | grep -m1 armv7  \
  | grep -oE 'href="[^"]*' \
  | sed 's/href="/https:\/\/github.com/' \
  | wget -i - \
  && ls | grep '^V2-Cloud.*\.AppImage$' \
  | tr -d '\n'| sudo xargs -r0 chmod 777 \
  && sudo rm /home/pi/V2-Cloud-* \
  ; sudo mv /home/pi/Downloads/V2-Cloud-* /home/pi