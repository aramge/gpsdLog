#!/usr/bin/bash

# RAMDISK=/media/ramdisk
# SOURCE=/home/ramge/local/tracks/gpsd.gpx
# TARGETS=/home/ramge/local/tracks/gpsd
RAMDISK=/home/ramge/tmp
SOURCE=/home/ramge/tmp/crosstrack.gpx
TARGETS=/home/ramge/tmp/gpsd
TMPFILE=$RAMDISK/splitDailyTracks.gpx
TMPFILE2=$RAMDISK/splitDailyTracks2.gpx

# filter out anything but digits
passdigits () {
  echo "$1" | sed 's/[^0-9]//g' | head -c 14
}

trktimes () {
  perl -0777 -pe 's|<time>.*?</time>||' < "$1" | grep -o "20.*Z"
}

finish () {
  if [ -f "$TMPFILE" ]
  then 
    rm "$TMPFILE"
  fi
  if [ -f "$TMPFILE2" ]
  then 
    rm "$TMPFILE2"
  fi
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

# Find all track point times, get rid of the first occurance. (This is the creation time of the file)
TRKTIMES=$(trktimes "$TMPFILE")
EARLIEST="$(echo "$TRKTIMES" | head -n 1 )"
 echo "$EARLIEST"
# Beginning of next day -> Last trackpoint
FIRSTDAYEOD=$(TZ=z date -d "$EARLIEST + 1 day" +%Y-%m-%dT00:00:00Z)
 echo "$FIRSTDAYEOD"

echo Splitting
if [ -f "$TARGETS"_"$FIRSTDAYEOD.gpx" ]
then
  echo "$TARGETS"_"$FIRSTDAYEOD.gpx" exists. Will not overwrite
  finish
else
#  echo earliest start "$(passdigits "$EARLIEST")"
#  echo firstdayeod stop "$(passdigits "$FIRSTDAYEOD")"
  gpsbabel \
    -i gpx \
    -f "$TMPFILE" \
    -x track,stop=$(passdigits "$FIRSTDAYEOD") \
    -o gpx \
    -F "$TARGETS"_"$FIRSTDAYEOD".gpx
  touch -d "$FIRSTDAYEOD" "$TARGETS"_"$FIRSTDAYEOD".gpx
  # Recurr with the remaining days, start this script again
  gpsbabel \
    -i gpx \
    -f "$TMPFILE" \
    -x track,start=$(passdigits "$FIRSTDAYEOD") \
    -o gpx \
    -F "$TMPFILE2"
  grep -q trk "$TMPFILE2" && {
    if [ -f "$TMPFILE2" ]
    then 
      mv "$TMPFILE2" "$TMPFILE"
      "$0"
    fi
  }
fi

finish
