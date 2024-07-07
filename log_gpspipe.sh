#!/usr/bin/bash

gpspipe -r -x 60 \
  | grep '$GNGGA\|$GNRMC' \
  | tail -n +4 \
  > "/media/ramdisk/gpsd_$(TZ=z date +%Y-%m-%dT%H:%M:%SZ).nmea"

