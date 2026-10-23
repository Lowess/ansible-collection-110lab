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
| `kiosk_splash_enabled` | `true` | Show the PNG during boot and behind Chromium; set to `false` to disable |
| `kiosk_splash_image` | `splash.png` | Bundled PNG, or supply a controller-side image path |
| `kiosk_splash_rotation` | `0` | Rotate the PNG clockwise by 0, 90, 180, or 270 degrees |

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
        kiosk_splash_rotation: 0
```

The role includes `roles/kiosk/files/splash.png`. A root service draws the PNG
once on `/dev/fb0` using `fbi`, before the display manager starts. `swaybg`
shows the same image as the labwc background until Chromium covers it. This
follows AnotterKiosk's framebuffer drawing approach without replacing the
system's init process, detaching virtual consoles, or enabling the kernel's
fullscreen logo. The service waits at most five seconds for `/dev/fb0` and
cannot hold up the graphical session for more than ten seconds. If the
framebuffer is unavailable, the Wayland background can still appear.

This splash starts after Linux has begun booting; it cannot hide firmware or
very early kernel messages. Raspberry Pi OS may also show its own Plymouth
screen. A reboot is required to see the boot splash; a desktop logout/login is
enough to check the Wayland background. To use another image, set
`kiosk_splash_image` to an absolute PNG path on the Ansible controller. For a
portrait panel, adjust
`kiosk_splash_rotation` after checking the first boot.

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
