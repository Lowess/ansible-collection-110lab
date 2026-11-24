# splash

Show an image during Raspberry Pi boot and as the labwc desktop background.
The role works on its own or through the `kiosk` role. It installs `fbi`,
`swaybg`, and ImageMagick, prepares one PNG, enables a framebuffer service,
and starts the Wayland background from the desktop user's labwc autostart.

## Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `splash_user` | `pi` | Desktop user running labwc |
| `splash_enabled` | `true` | Enable the boot splash and background |
| `splash_image` | `splash.png` | Bundled PNG, or an absolute PNG path on the Ansible controller |
| `splash_rotation` | `0` | Rotate the PNG clockwise by 0, 90, 180, or 270 degrees |

## Usage

```yaml
---
- name: Configure Raspberry Pi splash and background
  hosts: kiosk
  become: true
  roles:
    - role: lowess.lab110.splash
      vars:
        splash_user: pi
        splash_image: splash.png
        splash_rotation: 0
```

The same prepared image is displayed by `fbi` on `/dev/fb0` during boot and
by `swaybg` after labwc starts. The boot service waits up to five seconds for
the framebuffer and has a ten-second start timeout. The role migrates the old
`kiosk-splash.service` to `splash-screen.service` when present.

Reboot to see a changed boot splash. Log out and back in to see a changed
desktop background. Set `splash_enabled: false` to disable both on the next
role run; the background process already running in the current session will
exit when the session ends.
