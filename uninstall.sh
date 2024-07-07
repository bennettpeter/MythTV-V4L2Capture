#!/bin/bash
set -e
if [[ -f /etc/opt/mythtv/v4l2install.conf ]] ; then
    source /etc/opt/mythtv/v4l2install.conf
else
    echo "ERROR, V4l2Capture is not installed"
    exit 2
fi

echo "Are you sure you want to uninstall V4l2Capture?"
echo Type Y to continue
read -e resp
if [[ "$resp" != Y ]] ; then exit 2 ; fi

rm -rf  "$SCRIPTDIR"
rm /etc/opt/mythtv/v4l2capture.conf
rm /etc/opt/mythtv/v4l2cap?.conf
rm /etc/opt/mythtv/v4l2chans.txt
rm /etc/opt/mythtv/v4l2install.conf

echo "Uninstall completed successfully"
