#!/bin/bash

sudo docker run -p 5001:5000 -d --env-file=env/wnetb.env arkadyt/wnetb:latest
