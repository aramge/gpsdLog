# gpsdLog
Log GPS data from gpsd, simplify it and store it as a daily gpx track

* Installation

Should work on linux and similar systems. I run it on a Raspberry Pi Zero on my boat.

Install [[gpsd][https://gpsd.gitlab.io/gpsd]]

Create a ramdisk. Eventually add it to $/etc/fstab$. The ramdisk should be big enough to hold the logfiles.

$log_gpspipe.sh$: Log the GPS data from the $gpsd$ in NMEA format with $gpspipe$. I am only interested in the sentences GGA for position, hdop and RMC for position, cog, sog. The log file is stored on the ramdisk.

Start $log_gpspipe.sh$ with cron, e.g. every hour. The $gpspipe$ should run the same length of time.

$log_gpsbabel.sh$: To reduce the amount of data, the logfiles are merged, simplified and converted to gpx format. The used nmea log files are deleted to free up the space on the ramdisk.

Start $log_gpsbabel.sh$ with cron, e.g. daily. The output should be stored on a permanent file system.
