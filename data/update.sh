#!/bin/sh
DATADIR=`dirname $0`

echo ----------------------------------------------------------------
echo downloading oscon.ics
echo
#curl --output $DATADIR/oscon.ics http://www.oscon.com/oscon2011/public/schedule/ical/oscon
echo

echo ----------------------------------------------------------------
echo downloading data.ics
echo
#curl --output $DATADIR/data.ics  http://www.oscon.com/oscon2011/public/schedule/ical/data
echo

echo ----------------------------------------------------------------
echo downloading java.ics
echo
#curl --output $DATADIR/java.ics  http://www.oscon.com/oscon2011/public/schedule/ical/java

echo ----------------------------------------------------------------
echo convert ics files to json
echo
NODE_PATH=$DATADIR/../vendor/underscore:$DATADIR/../vendor/node-ical:$DATADIR/../modules coffee update-json.coffee > calendar-entries.json.js
