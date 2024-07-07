#!/usr/bin/bash

# Add a ramdisk to /etc/fstab:
# tmpfs		/media/ramdisk	tmpfs	defaults,size=10M	0	0

gpspipe -r -x 60 \
  | grep '$GNGGA\|$GNRMC' \
  | tail -n +4 \
  > "/media/ramdisk/gpsd_$(TZ=z date +%Y-%m-%dT%H:%M:%SZ).nmea"

