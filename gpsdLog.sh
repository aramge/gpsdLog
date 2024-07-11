#!/usr/bin/bash

RAMDISK=/media/ramdisk
TARGET=/home/ramge/local/tracks/gpsd.gpx
ERROR=0.005k

if [[ $1 != +([0-9]) ]]
then
  echo Usage: $0 SECONDS
  echo usually started from systemd. See gpsdLog.service.
  exit 1
fi 

gpspipe -r -x "$1" \
  | grep '$GNGGA\|$GNRMC' \
  | tail -n +4 \
  > "$RAMDISK/gpsd_$(TZ=z date +%Y-%m-%dT%H:%M:%SZ).nmea"

NMEAS=$(ls $RAMDISK/gpsd*.nmea | head -n -1)
COUNT=$(echo "$NMEAS" | wc | awk '{ print $1 }')

if [ "$COUNT" -ge 1 ] # There are older, unprocessed nmea log files
then
  gpsbabel \
    -t \
    -i nmea \
    $(for i in $NMEAS ; do echo -n "$i" | xargs echo "-f" ; done) \
    -x track,merge \
    -x simplify,crosstrack,error="$ERROR" \
    -o gpx \
    -F $RAMDISK/nmea.gpx
  if [ -f "$TARGET" ]
  then
    gpsbabel \
      -t \
      -i gpx \
      -f $RAMDISK/nmea.gpx \
      -i gpx \
      -f "$TARGET" \
      -x track,merge \
      -x simplify,crosstrack,error="$ERROR" \
      -o gpx \
      -F $RAMDISK/tmp.gpx
    rm $RAMDISK/nmea.gpx
    mv $RAMDISK/tmp.gpx $RAMDISK/nmea.gpx
  fi
  mv $RAMDISK/nmea.gpx "$TARGET"
  echo "$NMEAS" | xargs rm 
fi

