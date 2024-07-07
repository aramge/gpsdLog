#!/usr/bin/bash

LATEST=$(sed -rn 's/.*<time>([0-9]+.*Z).*/\1/p' "$1" | tail -n1)
cat "$1" \
  | sed "s/<time>.*<\/time>/<time>$LATEST<\/time>/" \
  > gpsd_$LATEST.gpx
echo $LATEST
