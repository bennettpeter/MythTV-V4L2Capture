#!/bin/bash

if [[ -f /etc/opt/mythtv/v4l2install.conf ]] ; then
    source /etc/opt/mythtv/v4l2install.conf
fi

if [[ "$MYTHTVUSER" == "" ]] ; then MYTHTVUSER=mythtv ; fi
if [[ "$MYTHTVGROUP" == "" ]] ; then MYTHTVGROUP=mythtv ; fi
if [[ "$SCRIPTDIR" == "" ]] ; then SCRIPTDIR=/opt/mythtv/v4l2cap ; fi

if [[ ! -f /etc/opt/mythtv/v4l2install.conf ]] ; then
    echo Install configuration:
    echo MythTV User: $MYTHTVUSER
    echo MythTV Group: $MYTHTVGROUP
    echo Install Directory: $SCRIPTDIR
    echo To change these set MYTHTVUSER, MYTHTVGROUP, and SCRIPTDIR before running install.sh
    echo Type Y to continue, N to cancel.
    read -e resp
    if [[ "$resp" != Y ]] ; then exit 2 ; fi
    mkdir -p /etc/opt/mythtv
    echo "MYTHTVUSER=$MYTHTVUSER" > /etc/opt/mythtv/v4l2install.conf
    echo "MYTHTVGROUP=$MYTHTVGROUP" >> /etc/opt/mythtv/v4l2install.conf
    echo "SCRIPTDIR=$SCRIPTDIR" >> /etc/opt/mythtv/v4l2install.conf
else
    echo "WARNING: This package has previous been installed. If you install"
    echo "again you will overwrite any script customizations you have made."
    echo Type Y to continue, N  to cancel.
    read -e resp
    if [[ "$resp" != Y ]] ; then exit 2 ; fi
fi

scriptname=`readlink -e "$0"`
scriptpath=`dirname "$scriptname"`

err=0
if ! which ffmpeg >/dev/null ; then
    echo ERROR ffmpeg is not installed
    err=1
fi
if ! which vlc >/dev/null >/dev/null; then
    echo WARNING you will need vlc installed to test your system
fi

if (( err )) ; then
    exit 2
fi

set -e

mkdir -pv /var/log/mythtv_scripts
chown $MYTHTVUSER:$MYTHTVGROUP /var/log/mythtv_scripts
chmod 2775 /var/log/mythtv_scripts

adduser $MYTHTVUSER audio
adduser $MYTHTVUSER video

export MYTHTVUSER SCRIPTDIR

mkdir -p /etc/opt/mythtv
cp --update=none $scriptpath/settings/v4l2capture.conf /etc/opt/mythtv/

if [[ ! -f /etc/opt/mythtv/v4l2cap1.conf ]] ; then
    envsubst < $scriptpath/settings/v4l2cap1.conf > /etc/opt/mythtv/v4l2cap1.conf
fi

mkdir -p $SCRIPTDIR
rm -f $SCRIPTDIR/*
cp $scriptpath/scripts/* $SCRIPTDIR
chmod +x $SCRIPTDIR/*

mkdir -p /etc/udev/rules.d
cp --update=none $scriptpath/udev/* /etc/udev/rules.d/

echo "Install completed successfully"
