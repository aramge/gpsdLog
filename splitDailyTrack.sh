#!/usr/bin/bash

RAMDISK=/media/ramdisk
TMPFILE=$RAMDISK/split.gpx
TMPFILE2=$RAMDISK/split2.gpx
STORAGE=/home/ramge/local/track

cat $1 > $TMPFILE

TIMES="$(grep -o "20.*Z" "$TMPFILE" | tail -n +2)"
EARLIEST="$(echo -e "$TIMES" | head -n 1)"
LATEST="$(echo "$TIMES" | tail -n 1)"
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
  gpsbabel -i gpx -f "$TMPFILE" -x track,start="$EARLIEST",stop="$EARLIEST2" -o gpx -F "$STORAGE/gpsd_$EARLIEST2.gpx"
  gpsbabel -i gpx -f "$TMPFILE" -x track,start="$EARLIEST2",stop="$LATEST" -o gpx -F "$TMPFILE2"
  mv $TMPFILE2 $TMPFILE
  "$0" "$1"
  exit 0
fi

echo Nothing to do
