#!/bin/bash

sudo /usr/lib/ioquake3/ioq3ded \
  +set fs_game excessiveplus \
  +set vm_game 0 +set dedicated 2 \
  +exec server.cfg
