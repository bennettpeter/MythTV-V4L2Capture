#!/bin/bash

# External Recorder Tuner
# Parameter 1 - recorder name e.g. v4l2cap1
# Parameter 2 - channel number

# This script must be modified to tune a channel
# on the requested recorder

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

    # Before the start of each recording, this script is called
    # to tune the channel. It is killed after 5 seconds even if the
    # channel has not been tuned. The script is called again 10 seconds
    # later and is allowed to run as long as is needed.
    # The 6 second sleep makes sure that the script is killed before
    # it starts tuning, because a partial tuning followed by a full
    # tuning will likely not work.
    sleep 6

    # get any parameters you may have set in the v4l2cap*.conf file
    eval $(egrep '^ANDROID_DEVICE=|^OTHER_PARM=' /etc/opt/mythtv/${recname}.conf)

    # Replace the following lines with your code to tune the channel and start streaming
    adb connect $ANDROID_DEVICE
    export ANDROID_DEVICE
    adb-sendkey.sh DPAD_CENTER
    adb disconnect $ANDROID_DEVICE
    
    echo `$LOGDATE` Now tuned to channel $channum
} >> $logfile 2>&1

