#!/bin/bash

CONTAINER_NAME=wnetb

sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

sudo docker pull arkadyt/wnetb:latest
sudo docker run -p 5001:5000 -d --env-file=env/wnetb.env --name $CONTAINER_NAME arkadyt/wnetb:latest
