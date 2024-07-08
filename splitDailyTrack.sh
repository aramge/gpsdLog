#!/usr/bin/bash

RAMDISK=/media/ramdisk
SOURCE=$RAMDISK/gpsd.gpx
TMPFILE=$RAMDISK/splitDailyTracks.gpx
TMPFILE2=$RAMDISK/splitDailyTracks2.gpx
TARGET=/home/ramge/local/tracks/gpsd

# filter out anything but digits
passdigits () {
  sed 's/[^0-9]//g' | head -c 14
}

finish () {
  echo cleaning up
  rm $TMPFILE
  echo Done!
  exit 0
}

if [ -f $TMPFILE ]
then
  echo We are in recursion mode!
  # Any points left? Otherwise finish
  grep -q trk $TMPFILE || finish
else
  echo First cycle
  # Create the working file which will be processed by recursion
  cp "$SOURCE" "$TMPFILE"
fi

# Find all track point times, get rid of the metadata (delete creation time)
TRKTIMES="$(cat "$TMPFILE" | perl -0777 -pe 's|<metadata>.*?</metadata>||sg' | grep -o "20.*Z" )"
EARLIEST="$(echo -e "$TRKTIMES" | head -n 1 )"
LATEST="$(echo "$TRKTIMES" | tail -n 1 )"
TODAY0="$(TZ=z date +%Y-%m-%dT00:00:00Z)"
# Beginning of day -> First trackpoint
EARLIEST1="$(TZ=z date -d "$EARLIEST" +%Y-%m-%dT00:00:00Z)"
# Beginning of next day -> Last trackpoint
EARLIEST2=$(TZ=z date -d "$EARLIEST1 + 1 day" +%Y-%m-%dT00:00:00Z)

if [[ "$LATEST" < "$TODAY0" ]]
then
  echo Splitting
  START=$(echo $EARLIEST | passdigits)
  STOP=$(echo $EARLIEST2 | passdigits)
  LATEST=$(echo $LATEST | passdigits)
echo Start $START
echo Stop $STOP
echo LATEST $LATEST
  if [ -f "$TARGET"_"$EARLIEST2.gpx" ]
  then
    echo "$TARGET"_"$EARLIEST2.gpx" exists. Will not overwrite
    finish
  else
    # Write the first day
    gpsbabel -i gpx -f "$TMPFILE" -x track,start="$START",stop="$STOP" -o gpx -F "$TARGET"_"$EARLIEST2.gpx"
    touch -d "$EARLIEST2" "$TARGET"_"$EARLIEST2.gpx"
  fi
  # Write the remaining days
  gpsbabel -i gpx -f "$TMPFILE" -x track,start="$STOP",stop="$LATEST" -o gpx -F "$TMPFILE2"
  mv $TMPFILE2 $TMPFILE
  # Recurr with the remaining days, start this script again
  "$0"
  exit 0
fi

