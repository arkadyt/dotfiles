#!/bin/bash

# wipeout
mongo \
  --eval "db.getCollectionNames().forEach(function(n){db[n].remove({})});" \
  localhost:27017/socnet

# restore
mongorestore \
  -d socnet \
  ~/cloud-scripts/dbrestore/socnet
