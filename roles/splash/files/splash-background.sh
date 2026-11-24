#!/bin/sh
set -u

image=/usr/local/share/splash-screen/splash.png

# Raspberry Pi OS uses swaybg when Active Desktop is off.
/usr/bin/swaybg --image "$image" --mode fit --color 000000 >/dev/null 2>&1 &

# With Active Desktop, PCManFM draws over swaybg and owns the wallpaper.
if ! command -v pcmanfm >/dev/null 2>&1; then
    exit 0
fi

attempt=0
while [ "$attempt" -lt 30 ]; do
    if pgrep -u "$(id -u)" -x pcmanfm >/dev/null 2>&1; then
        /usr/bin/pcmanfm --set-wallpaper="$image" --wallpaper-mode=fit >/dev/null 2>&1
        exit $?
    fi
    attempt=$((attempt + 1))
    sleep 1
done
