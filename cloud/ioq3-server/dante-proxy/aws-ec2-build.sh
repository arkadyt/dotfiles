#!/bin/bash

HOME=/root

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

function install_build_tools {
    report "Installing build tools"

    apt-get update
    apt-get install gcc make -y
}

function dl_dante_pkg {
    report "Downloading dante package"

    cd $HOME && mkdir software && cd software
    wget http://www.inet.no/dante/files/dante-1.4.2.tar.gz
    tar -xvz -f dante-1.4.2.tar.gz
}

function build_dante {
    report "Compiling dante"

    cd $HOME/software
    mv dante-1.4.2 dante && cd dante

    ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --disable-client \
        --without-libwrap \
        --without-bsdauth \
        --without-gssapi \
        --without-krb5 \
        --without-upnp \
        --without-pam

    make && make install
}

function create_daemon {
    report "Setting up a daemon"

    cd /etc/init.d
    wget https://raw.githubusercontent.com/arkadyt/dotfiles/master/cloud/dante/manual-dante-daemon
    mv manual-dante-daemon danted
    chmod +x danted
    update-rc.d danted defaults
}

function launch_daemon {
    report "Launching the danted daemon"

    systemctl enable danted
    systemctl start danted
    systemctl status danted
}

install_build_tools
dl_dante_pkg
build_dante
create_daemon
launch_daemon

report "Done" true
