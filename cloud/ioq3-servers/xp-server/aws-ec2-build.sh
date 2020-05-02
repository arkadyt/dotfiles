#!/bin/bash

#
# WARNING:
#
# (Context: script is used in "User Data" section of an EC2 launch template)
# 
# Amazon will run the script under the root user.
# Any files you create will be owned by root.
#
# For debug output, cat /var/log/cloud-init-output.log.
#
# Upon launch, script is copied to:
#     /var/lib/cloud/instances/i-*/user-data*
#     /var/lib/cloud/instances/i-*/scripts/*
#
# It won't be deleted after run.
# Don't forget to delete it since AWS keys are hardcoded into the file.
#


# setup variables
ROOT_USER=root
ROOT_HOME=/$ROOT_USER
Q3_USER=ioq3
Q3_HOME=/home/$Q3_USER
AWS_REGION=us-east-1
AWS_OUTPUT=json
S3_BUCKET=ioq3ded
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

function add_users {
    report "Adding users"

    useradd -m -g users -g sudo -s /bin/bash -d $Q3_HOME $Q3_USER
}

function install_software {
    report "Installing software"

    apt-get update
    apt-get -y install ioquake3-server awscli
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
}

function dl_game_content {
    report "Downloading game content"

    mkdir $Q3_HOME/.q3a
    aws s3 cp --recursive s3://$S3_BUCKET/.q3a $Q3_HOME/.q3a
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

function launch_server {
    report "Launching server"

    # add Q3_USER to sudoers and allow paswordless command execution
    echo "$Q3_USER ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

    chmod +x $Q3_HOME/.q3a/xp_start
    su $Q3_USER -c "sudo sh $Q3_HOME/.q3a/xp_start"
}

add_users
install_software
config_aws
dl_game_content
launch_server
cleanup

report "Finished arkadyt ioquake3 server initialization!" true
