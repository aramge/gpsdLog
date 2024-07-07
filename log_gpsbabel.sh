#!/usr/bin/bash

LOGFILES=$(ls /media/ramdisk/gpsd*.nmea)
COUNT=$(echo "$LOGFILES" | wc | awk '{ print $1 }') 
FILES=$(echo "$LOGFILES" | head -n $((COUNT-1)))

if [ "$COUNT" -gt 1 ] # There are older, unprocessed nmea log files
then
  gpsbabel \
    -t \
    -i nmea \
    $(for i in $FILES ; do echo -n "$i" | xargs echo "-f" ; done) \
    -x track,merge \
    -x simplify,crosstrack,error=0.01k \
    -o gpx \
    -F /home/ramge/local/tracks/gpsd_"$(TZ=z date +%Y-%m-%dT%H:%M:%SZ)".gpx
  echo "$FILES" | xargs rm 
fi

