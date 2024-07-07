#!/usr/bin/bash


LOGFILES=$(ls /media/ramdisk/gpsd*.nmea)
ANZAHL=$(echo "$LOGFILES" | wc | awk '{ print $1 }') 
FILES=$(echo "$LOGFILES" | head -n $((ANZAHL-1)))

if [ "$ANZAHL" -gt 1 ] # Liegen neue (ältere gpsd-Logdateien vor?
then
  gpsbabel \
    -t \
    -i nmea \
    $(for i in $FILES ; do echo -n "$i" | xargs echo "-f" ; done) \
    -x track,merge \
    -x simplify,crosstrack,error=0.01k \
    -o gpx \
    -F /media/ramdisk/gpsd_"$(TZ=z date +%Y-%m-%dT%H:%M:%SZ)".gpx
  echo "$FILES" | xargs rm 
fi

