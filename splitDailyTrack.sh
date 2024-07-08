#!/usr/bin/bash

RAMDISK=/media/ramdisk
SOURCE=$RAMDISK/gpsd.gpx
TMPFILE=$RAMDISK/splitDailyTracks.gpx
TMPFILE2=$RAMDISK/splitDailyTracks2.gpx
TARGET=/home/ramge/tmp/gpsd

if [ -f $TMPFILE ]
then
  echo We are in recursion mode!
else
  echo First cycle
  cp "$SOURCE" "$TMPFILE"
fi

TRKTIMES="$(grep -o "20.*Z" "$TMPFILE" | tail -n +2)"
EARLIEST="$(echo -e "$TRKTIMES" | head -n 1)"
LATEST="$(echo "$TRKTIMES" | tail -n 1)"
TODAY0="$(TZ=z date +%Y-%m-%dT00:00:00Z)"
EARLIEST1="$(TZ=z date -d "$EARLIEST" +%Y-%m-%dT00:00:00Z)"
EARLIEST2=$(TZ=z date -d "$EARLIEST1 + 1 day" +%Y-%m-%dT00:00:00Z)

echo TIMES "$TIMES"
echo EARLIEST "$EARLIEST"
echo EARLIEST1 "$EARLIEST1"
echo EARLIEST2 "$EARLIEST2"
echo LATEST "$LATEST"
echo TODAY0 "$TODAY0"

if [[ "$LATEST" < "$TODAY0" ]]
then
  echo Splitting
  gpsbabel -i gpx -f "$TMPFILE" -x track,start="$EARLIEST",stop="$EARLIEST2" -o gpx -F "$TARGET\_$EARLIEST2.gpx"
  gpsbabel -i gpx -f "$TMPFILE" -x track,start="$EARLIEST2",stop="$LATEST" -o gpx -F "$TMPFILE2"
  mv $TMPFILE2 $TMPFILE
  "$0" "$1"
  exit 0
fi

echo cleaning up
rm $TMPFILE
rm $TMPFILE2
echo Done!
