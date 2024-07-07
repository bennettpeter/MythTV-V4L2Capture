#!/bin/bash

# External Recorder Frontend
# Parameter 1 - recorder name e.g. v4l2cap1, v42l2cap2, etc.

# In mythtv setup, create a capture card type EXTERNAL. Enter command path
# as /opt/mythtv/v4l2cap/v4l2capture.sh v4l2cap1
# (fill in correct path and recorder id)
# setup /etc/opt/mythtv/v4l2cap1.conf

# This script must write nothing to stdout or stderr, also it must not
# redirect stdout or stderr of mythexternrecorder as these are both
# used by mythbackend for communicating with mythexternrecorder

recname=$1

# The shift is to remove recname from the parameters
# so that the rest of the parameters get passed to mythexternrecorder
shift
. /etc/opt/mythtv/v4l2capture.conf
scriptname=`readlink -e "$0"`
scriptpath=`dirname "$scriptname"`
scriptname=`basename "$scriptname" .sh`
logfile=$LOGDIR/${scriptname}_${recname}.log
{
    # get VIDEO_IN and AUDIO_IN from conf
    eval $(egrep '^AUDIO_IN=|^VIDEO_IN=' /etc/opt/mythtv/${recname}.conf)
    if [[ ! -e $VIDEO_IN ]] ; then
        echo `$LOGDATE` ERROR $VIDEO_IN does not exist
        rc=2
    fi

    srch=$(echo $AUDIO_IN | sed 's/hw:/card /;s/,/.*device /')
    if ! arecord -l|grep -q "$srch" ; then
        echo `$LOGDATE` ERROR $AUDIO_IN does not exist
        rc=2
    fi

    if (( rc > 1 )) ; then exit $rc ; fi
} &>>$logfile 2>&1

echo `$LOGDATE` mythexternrecorder  --exec --conf /etc/opt/mythtv/${recname}.conf "${@}" >>$logfile
mythexternrecorder  --exec --conf /etc/opt/mythtv/${recname}.conf "${@}"
rc=$?

echo `$LOGDATE` mythexternrecorder ended rc=$rc >>$logfile
exit $rc
