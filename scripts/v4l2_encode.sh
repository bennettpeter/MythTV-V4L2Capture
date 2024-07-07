#!/bin/bash

# External Recorder Encoder
# Parameter 1 - recorder name e.g. v4l2cap1

# This script must write nothing to stdout other than the encoded data.

recname=$1

. /etc/opt/mythtv/v4l2capture.conf
scriptname=`readlink -e "$0"`
scriptpath=`dirname "$scriptname"`
scriptname=`basename "$scriptname" .sh`
ffmpeg_pid=
logfile=$LOGDIR/${scriptname}_${recname}.log
LOGDATE='date +%Y-%m-%d_%H-%M-%S'
TEMPDIR="/tmp"

function exitfunc {
    local rc=$?
    echo `$LOGDATE` "Exit" >> $logfile
    if [[ "$ffmpeg_pid" != "" ]] && ps -q $ffmpeg_pid >/dev/null ; then
        kill $ffmpeg_pid
    fi
}

echo `$LOGDATE` "Start of run ***********************" >> $logfile
trap exitfunc EXIT

# get config parameters
eval $(egrep '^AUDIO_IN=|^VIDEO_IN=' /etc/opt/mythtv/${recname}.conf)

ffmpeg -hide_banner -loglevel error -f v4l2 -thread_queue_size 256 -input_format $INPUT_FORMAT \
  -framerate $FRAMERATE -video_size $RESOLUTION \
  -use_wallclock_as_timestamps 1 \
  -i $VIDEO_IN -f alsa -ac 2 -ar 48000 -thread_queue_size 1024 \
  -itsoffset $AUDIO_OFFSET -i $AUDIO_IN \
  -c:v libx264 -vf format=yuv420p -preset $X264_PRESET -crf $X264_CRF -c:a aac \
  -f mpegts -  &

ffmpeg_pid=$!

{
    sleep 20
    # Loop to check if recording is working.
    while (( 1 )) ; do
        if ! ps -q $ffmpeg_pid >/dev/null ; then
            echo `$LOGDATE` "ffmpeg terminated"
            break
        fi
        sleep 30
    done
} &>> $logfile 2>&1

