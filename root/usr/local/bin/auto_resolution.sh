#!/bin/bash

# comment custom resolution settings in config,txt
sudo sed -i 's/^hdmi_[^_]*:[0|1]/#&/' '/boot/config.txt' && sudo reboot
