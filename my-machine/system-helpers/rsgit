#!/bin/bash

rel_path="MISC/Backups/GitHub"
hdrive_path="/home/arkadyt/_Storage/Cloud/$rel_path"

cd $hdrive_path

# ! -name .      : excludes . 
find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && git pull" \;

rclone sync $hdrive_path gdr:HDrive/$rel_path -v --size-only
