# glow

Install and configure Glow on Raspberry Pi hosts using release artifacts
published on GitHub.

The role downloads a single `glow-<version>.tar.gz` source distribution from
GitHub Releases, installs it into a Python virtualenv, and manages the `glow`
systemd service.

## Requirements

- A Debian-based host with access to GitHub Releases
- A `pi` user on the target host
- Raspberry Pi hardware where SPI configuration is applicable

## Role Variables

```yaml
glow_version: 0.0.1
glow_root: /home/pi/glow
glow_force_update: false

glow_release_owner: Lowess
glow_release_repo: glow
glow_release_version: "{{ glow_version }}"
glow_release_asset_name: "glow-{{ glow_release_version }}.tar.gz"
glow_release_url: "https://github.com/{{ glow_release_owner }}/{{ glow_release_repo }}/releases/download/{{ glow_release_version }}/{{ glow_release_asset_name }}"
```

## Dependencies

- `lowess.lab110.common`

## Example Playbook

```yaml
---
- hosts: glow
  become: true
  roles:
    - role: lowess.lab110.glow
      vars:
        glow_version: 0.0.3
        glow_force_update: false
```

## Notes

- Release tags are expected to match `glow_version` exactly, for example
  `0.0.3`.
- The role no longer manages Nginx or a separate frontend artifact.
- Set `glow_force_update: true` to re-download the release archive and rebuild
  the virtualenv.
