#!/bin/sh

count=0
while [ ! -e /dev/fb0 ]; do
    if [ "$count" -ge 20 ]; then
        exit 0
    fi
    sleep 0.25
    count=$((count + 1))
done

# Leave the last drawn frame in place until the graphical session takes over.
printf '\n' | /usr/bin/fbi -d /dev/fb0 --cachemem 8 --noverbose --nointeractive -T 1 -1 -t 0 -a /usr/local/share/kiosk/splash.png
