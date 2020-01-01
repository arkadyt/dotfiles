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

ROOT_USER=root
ROOT_HOME=/$ROOT_USER
HOME=/home/ubuntu
SRVCONFPATH=$HOME/code/dotfiles/cloud/api-servers/foss-other

# keys to "sed in" (include) during deployment:
# s3 r/o access with s3:ListBucket and s3:getObject permissions
# restricted to $S3_BUCKET ARN.
AWS_KEY_ID=redacted
AWS_SECRET=redacted
AWS_REGION=us-west-1
AWS_OUTPUT=json
S3_BUCKET=cert.apis.arkadyt.com
AWS_USER_DATA_PATH=/var/lib/cloud/instances/i-*

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

  mkdir $ROOT_HOME/.aws
  cd $ROOT_HOME/.aws

  rm -f credentials config
  touch credentials config
  echo [default] | tee -a credentials config

  # use tee/dd in case we need to use "sudo" in the future
  echo region=$AWS_REGION | tee -a config
  echo output=$AWS_OUTPUT | tee -a config

  # append text with dd to avoid leaving keys in aws log files
  echo aws_access_key_id=$AWS_KEY_ID     | dd of=credentials oflag=append conv=notrunc
  echo aws_secret_access_key=$AWS_SECRET | dd of=credentials oflag=append conv=notrunc
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

function cleanup {
  report "Cleaning up"

  # remove aws credentials after use for security reasons
  rm -rf $ROOT_HOME/.aws

  # remove the current script from the system as it contains the AWS credentials
  rm -rf $AWS_USER_DATA_PATH/*user-data*
  rm -rf $AWS_USER_DATA_PATH/scripts

  # $0 is a path of the current script; not guaranteed to work on all systems
  # rm -- "$0" 
}

function obtain_ssl_certs {
  report "Obtaining SSL certificates"
  local reissue_cert=$1
  local cert_storage=/etc/letsencrypt/archive
  local cert_smlinks=/etc/letsencrypt/live

  if reissue_cert; then
    certbot certonly \
      --nginx \
      --agree-tos \
      --non-interactive \
      -d apis.arkadyt.com \
      -m certbot7@arkadyt.com
  else
    # otherwise fetch & install backup
    mkdir -p $cert_smlinks
    mkdir -p $cert_storage
    aws s3 cp --recursive s3://$S3_BUCKET $cert_storage
    ln -s $cert_storage/* $cert_smlinks
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
  local app__secret=s$(openssl rand -hex 36)
  local basedir=$HOME/apps/$app_name

  # do not enable auth on db (protected by AWS VPC and iptables)
  local contents=(
    "SECRET=$app__secret"
    "MONGO_URI=mongodb://db:27017/$app_name"
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
  # wipe the script from EC2 vm for security reasons
  cleanup
}

initialize_server

report "Successfully initialized API server" true
