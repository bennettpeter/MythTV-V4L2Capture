#!/bin/bash

# External Recorder Cleanup
# Parameter 1 - recorder name e.g. v4l2cap1

# This script is called at the end of a recording

recname=$1
channum=$2

. /etc/opt/mythtv/v4l2capture.conf
scriptname=`readlink -e "$0"`
scriptpath=`dirname "$scriptname"`
scriptname=`basename "$scriptname" .sh`
logfile=$LOGDIR/${scriptname}_${recname}.log
LOGDATE='date +%Y-%m-%d_%H-%M-%S'

{
echo `$LOGDATE` "Start of run ***********************"

    # get any parameters you may have set in the v4l2cap*.conf file
    eval $(egrep '^ANDROID_DEVICE=|^OTHER_PARM=' /etc/opt/mythtv/${recname}.conf)

    # Replace these lines with your code to clean up and/or power off the box
    # (optional).
    adb connect $ANDROID_DEVICE
    export ANDROID_DEVICE
    adb-sendkey.sh BACK
    adb disconnect $ANDROID_DEVICE

} >> $logfile 2>&1

