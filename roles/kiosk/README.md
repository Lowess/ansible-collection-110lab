# kiosk

Run a web page in a Chromium app window on Raspberry Pi OS Desktop with labwc.
Chromium starts after desktop auto login and restarts if it exits. The desktop
remains underneath for troubleshooting, and SSH remains available. The role
leaves display orientation, touch configuration, and Wi-Fi credentials alone.

The default `app` mode opens a maximized window without Chromium tabs or an
address bar. It lets the Raspberry Pi OS on-screen keyboard appear above the
page when a text field receives focus. True fullscreen mode can hide that
keyboard behind Chromium. The desktop panel or window border may still be
visible in `app` mode.

## Requirements

- Raspberry Pi OS Desktop with labwc and a working network connection
- An existing non-root user for the desktop session
- SSH and sudo access for Ansible

The role explicitly checks that Ansible can become root before touching APT or
system settings. If that check fails under Semaphore, configure its task to
use a credential with sudo privileges and provide a become password when that
account requires one.

## Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `kiosk_user` | `pi` | Existing desktop user |
| `kiosk_url` | empty, required | HTTP(S) page to display |
| `kiosk_browser_package` | `chromium` | Debian package to install |
| `kiosk_browser_binary` | `/usr/bin/chromium` | Browser executable |
| `kiosk_browser_mode` | `app` | `app` for on-screen keyboard; `fullscreen` for true kiosk fullscreen |
| `kiosk_restart_delay` | `5` | Seconds before restarting Chromium after exit |
| `kiosk_desktop_autologin` | `true` | Enable desktop auto login with `raspi-config` |
| `kiosk_disable_screen_blanking` | `true` | Keep the kiosk display on |
| `kiosk_splash_image` | empty | Optional image on the Ansible controller for the early boot splash |
| `kiosk_splash_rotation` | `0` | Rotate the source image clockwise by 0, 90, 180, or 270 degrees |

## Usage

```yaml
---
- name: Configure kiosk
  hosts: kiosk
  become: true
  roles:
    - role: lowess.lab110.kiosk
      vars:
        kiosk_user: pi
        kiosk_url: "https://example.com/"
        kiosk_splash_image: splash.png
        kiosk_splash_rotation: 0
```

Place `splash.png` in `roles/kiosk/files/`, or set `kiosk_splash_image` to an
absolute file path on the Ansible controller. Leave the variable empty to
keep the current boot splash untouched. When an image is set, the role uses
Raspberry Pi OS's `rpi-splash-screen-support` tool to show it during early boot.
It converts the source to the required 24-bit, uncompressed TGA with no more
than 224 colours and dimensions no larger than 1920 x 1080. For a portrait
panel, adjust `kiosk_splash_rotation` after checking the first boot.

The custom image is an **early boot** splash. Raspberry Pi OS may subsequently
show its standard Plymouth splash before the desktop and Chromium appear. The
role removes the text console from the display via the official splash tool
and hides routine systemd boot status; logs remain available through
`journalctl`. A reboot is required to see splash changes.

After the first run, log out and back in or reboot once to start the kiosk
session. Later role changes to the launcher also take effect after the next
desktop login or browser restart. The role uses `raspi-config` to select the
Raspberry Pi OS desktop auto-login mode; configure the kiosk user as the Pi's
primary desktop user before running it.

In Raspberry Pi OS Control Centre > Display, set **On-screen keyboard** to
**Enabled if touchscreen found** or **Enabled always**. Squeekboard must be
enabled as well as visible above the browser for text entry to work.

## Debugging over SSH

Use the kiosk user's home directory in place of `/home/pi` if needed.

```sh
# Pause restarts, then close Chromium to reveal the desktop.
touch /home/pi/.config/kiosk/paused
pkill -u pi -x chromium || true

# Read browser logs.
journalctl -b -t kiosk-chromium --no-pager -n 80

# Resume; the launcher checks the pause file every two seconds.
rm /home/pi/.config/kiosk/paused
```

To disable startup permanently, remove the Ansible-marked block from
`~/.config/labwc/autostart` and log out. A later run of this role will restore
that block.

Chromium uses its basic password store to avoid a keyring dialog at automatic
login. Saved browser credentials are protected by the Pi user's file
permissions rather than a separate keyring password.
