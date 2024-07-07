#!/usr/bin/bash

gpspipe -r -x 3600 \
  | grep '$GNGGA\|$GNRMC' \
  | tail -n +4 \
  > "/media/ramdisk/gpsd_$(TZ=z date +%Y-%m-%dT%H:%M:%SZ).nmea"

