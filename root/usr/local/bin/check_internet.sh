#!/bin/bash

ping_command='ping -c 1 google.com 1> /dev/null'
bash -c "$ping_command"
while [ $? -ne 0 ]
do
    echo "waiting for internet ..."
    sleep 3
    bash -c "$ping_command"
done
echo "Internet is now online"
exit 0
