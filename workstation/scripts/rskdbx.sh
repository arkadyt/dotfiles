#!/bin/bash

DATE=`date +%Y%m%d_%H%M%S`
NAME="Passwords_$DATE.kdbx"

echo copying to hard drive...
rclone copyto ~/Documents/Passwords.kdbx /home/arkadyt/_Storage/Cloud/MISC/Passwords/$NAME -v

echo copying to gdr...
rclone copyto ~/Documents/Passwords.kdbx gdr:HDrive/MISC/Passwords/$NAME -v

echo copying to gdr_lena...
rclone copyto ~/Documents/Passwords.kdbx gdr_lena:$NAME -v
