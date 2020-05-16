#!/bin/bash
#
# Script downloads few of my open source apps from github,
# configures SSL certificates, nginx reverse proxy and docker.
# Then launches the applications.
#
# All APIs are reachable from apis.arkadyt.com/*

ROOT_USER=root
ROOT_HOME=/$ROOT_USER

HOME=/home/ubuntu
SRVCONFPATH=$HOME/code/dotfiles/cloud/api-servers/foss-other
CERT_BUCKET=cert.apis.arkadyt.com

AWS_REGION=us-west-1
AWS_OUTPUT=json

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

function config_aws {
  report "Configuring AWS"

  # will configure default profile
  aws configure set region $AWS_REGION
  aws configure set output $AWS_OUTPUT
}

function setup_software {
  report "Downloading software"

  apt-get update
  apt-get install -y \
    software-properties-common

  add-apt-repository universe -y
  add-apt-repository ppa:certbot/certbot -y

  # add mongo org repository
  wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add -
  echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" \
    | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list

  apt-get update
  apt-get install -y \
    git \
    docker.io \
    docker-compose \
    certbot \
    python-certbot-nginx \
    mongodb-org-tools \
    awscli

  config_aws
}

function obtain_ssl_certs {
  report "Obtaining SSL certificates"

  if [ $# -gt 0 ]; then
    certbot certonly \
      --nginx \
      --agree-tos \
      --non-interactive \
      -d apis.arkadyt.com \
      -m certbot7@arkadyt.com
  else
    # otherwise fetch & install backup
    local fetchdir=$HOME/s3certbkp
    mkdir -p $fetchdir
    aws s3 cp --recursive s3://$CERT_BUCKET $fetchdir
    tar xvzf $fetchdir/certificates.tar.gz -C /
    certbot renew
  fi
}

function setup_proxy {
  report "Setting up proxy"

  local confpath=$HOME/code/dotfiles
  local ngnxpath=$confpath/cloud/api-servers/foss-other/nginx
  local osslpath=/etc/nginx/openssl

  git clone https://github.com/arkadyt/dotfiles.git $confpath

  # set up SSL certs
  obtain_ssl_certs

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
  local app_secret=s$(openssl rand -hex 36)
  local basedir=$HOME/apps/$app_name

  # do not enable auth on db; it runs on the same machine and isn't exposed to internet
  # this makes protected VPC subnet, OS firewall and periodic data resets more than sufficient
  # if anyone breaks into the EC2 instance we'll have much bigger problems
  local contents=(
    "SECRET=$app_secret"
    "MONGO_URI=mongodb://db:27017/$app_name"
    "NODE_ENV=production"
    "PORT=$2"
  )

  write_to_file $basedir/.env ${contents[@]}
}

function install_app {
  local app_name=$1
  local app_port=$2

  # clone app and generate .env file
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
  setup_software
  setup_proxy

  # set up automatic cert renewals and database resets
  crontab -u root $SRVCONFPATH/root-crontab

  launch_app 'wework' 28000
  # run initial db restore with 10 sec lag to make sure
  # db service is up by the time we run mongorestore
  sleep 10 && sh $HOME/apps/wework/db/dbrestore.sh

  launch_app 'vspace' 28010

  # reload nginx to use config with updated ports
  nginx -s reload
}

initialize_server

report "Successfully initialized API server" true
