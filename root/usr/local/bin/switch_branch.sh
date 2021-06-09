#!/bin/bash

# get rpi-configs branch or set default to 'main'
branch=$(sudo cat /etc/v2-config | grep BRANCH | sed 's/BRANCH=//')

case $branch 
  in "dev") ;;
  *) branch="main" ;;
esac

NOW=$(date '+%Y-%m-%d %H:%M:%S')
echo "$NOW Execute switch_branch.sh in '$branch' branch of v2rpi-configs repo" >> /tmp/switch_branch_logs
curl -s https://raw.githubusercontent.com/v2cloud/v2rpi-configs/$branch/switch_branch.sh | sudo bash 
