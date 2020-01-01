#!/bin/bash
#
# Script downloads few of my open source apps from github,
# configures SSL certificates, nginx reverse proxy and docker.
# Then launches the applications.
#
# All APIs are reachable from apis.arkadyt.com.
#
# For more information look into nginx configuration here:
#     github.com/arkadyt/dotfiles/cloud/nginx

HOME=/home/ubuntu
SRVCONFPATH=$HOME/code/dotfiles/cloud/api-servers/foss-other

function report {
    # if final report message
    if [ $2 ]; then
        echo "" && echo ""
        echo $1
        echo "" && echo ""
    else
        echo "" && echo ""
        echo $1...
        echo "########################################"
    fi
}

function dl_software {
  report "Downloading software"

  apt-get update
  apt-get install -y \
    software-properties-common

  add-apt-repository universe -y
  add-apt-repository ppa:certbot/certbot -y

  apt-get update
  apt-get install -y \
    git \
    docker.io \
    docker-compose \
    certbot \
    python-certbot-nginx \
    mongodb-server
}

function setup_proxy {
  report "Setting up proxy"

  local confpath=$HOME/code/dotfiles
  local ngnxpath=$confpath/cloud/api-servers/foss-other/nginx
  local osslpath=/etc/nginx/openssl

  git clone https://github.com/arkadyt/dotfiles.git $confpath

  # set up SSL certs
  certbot certonly \
    --nginx \
    --agree-tos \
    --non-interactive \
    -d apis.arkadyt.com \
    -m certbot7@arkadyt.com

  # set up nginx sites
  rm /etc/nginx/sites-available/* -rf
  rm /etc/nginx/sites-enabled/* -rf
  cp -r $ngnxpath/sites-available /etc/nginx
  ln -s /etc/nginx/sites-available/* /etc/nginx/sites-enabled

  # force-copy nginx.conf
  \cp -f $ngnxpath/nginx.conf /etc/nginx

  # generate self signed cert for default site (undefined)
  mkdir -p $osslpath
  openssl req \
    -nodes -batch -new -x509 \
    -keyout $osslpath/nginx.key \
    -out $osslpath/nginx.crt

  # reload nginx with new config
  nginx -s reload
}

function write_to_file {
  local pathname=$1; shift
  local contents=("$@")

  if [ -f $pathname ]; then 
    truncate -s 0 $pathname
  else
    touch $pathname
  fi

  echo ${contents[@]} | sed "s/ /\n/g" > $pathname
}

function gen_app_keys {
  local app_name=$1
  local app_port=$2
  local app__secret=s$(openssl rand -hex 36)
  local basedir=$HOME/apps/$app_name

  local contents=(
    "SECRET=$app__secret"
    "MONGO_URI=mongodb://localhost:27017/$app_name"
    "NODE_ENV=production"
    "PORT=$2"
  )

  # for docker-compose and the app itself
  write_to_file $basedir/.env ${contents[@]}
}

function install_app {
  local app_name=$1
  local app_port=$2

  # clone app and generate random secret keys, db pwd and username
  git clone https://github.com/arkadyt/$app_name.git $HOME/apps/$app_name
  gen_app_keys $app_name $app_port

  # update ports in nginx config (search for location block and edit next line)
  sed -Ei "/\/$app_name\/ \{/{n;s/[[:digit:]]{4}\//$app_port\//}" \
    /etc/nginx/sites-available/apis.arkadyt.com
}

function launch_app {
  local app_name=$1
  local app_port=$2

  report "Launching app ($app_name)"

  local pathname=$HOME/apps/$app_name
  install_app $app_name $app_port

  cd $pathname
  docker-compose up -d
}

function initialize_server {
  dl_software
  setup_proxy

  launch_app 'wework' 28000
  launch_app 'vspace' 28010
  # reload nginx to use config with updated ports
  nginx -s reload

  # set up automatic cert renewals and database resets
  crontab -u root $SRVCONFPATH/root-crontab
  # run initial db restore with 10 sec lag to make sure
  # db service is up by the time we run mongorestore
  sleep 10 && sh $HOME/apps/wework/db/dbrestore.sh
}

initialize_server

report "Successfully initialized API server" true
