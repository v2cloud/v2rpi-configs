#!/bin/bash
# This file should not be change

# execute v2cloud.sh script correctly (because the file may be overwritten during runtime)
cat /usr/local/bin/v2cloud.sh | bash &> /tmp/v2startup_log 