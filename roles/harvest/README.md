# harvest

Install and configure Harvest on Raspberry Pi hosts using release artifacts
published on GitHub.

The role downloads a single `harvest-<version>.tar.gz` source distribution from
GitHub Releases, installs it into a Python virtualenv, and manages the
`harvest` systemd service.

## Requirements

- A Debian-based host with access to GitHub Releases
- A `pi` user on the target host
- Redis available on the target host

## Role Variables

```yaml
harvest_version: 0.0.5
harvest_root: /home/pi/harvest
harvest_force_update: false

harvest_release_owner: Lowess
harvest_release_repo: harvest
harvest_release_version: "{{ harvest_version }}"
harvest_release_asset_name: "harvest-{{ harvest_release_version }}.tar.gz"
harvest_release_url: "https://github.com/{{ harvest_release_owner }}/{{ harvest_release_repo }}/releases/download/{{ harvest_release_version }}/{{ harvest_release_asset_name }}"

harvest_hardware_config: ""
```

`harvest_hardware_config` is optional YAML content written to
`/home/pi/.harvest/hardware.yml` when provided.

## Dependencies

- `common`

## Example Playbook

```yaml
---
- hosts: harvest
  become: true
  roles:
    - role: lowess.lab110.harvest
      vars:
        harvest_version: 0.0.5
        harvest_force_update: false
        harvest_hardware_config: |
          sensors:
            default: {}
```

## Notes

- Release tags are expected to match `harvest_version` exactly, for example
  `0.0.5`.
- Set `harvest_force_update: true` to re-download the release archive and
  rebuild the virtualenv.
- The role no longer depends on controller-side `hardware.yml` or `dist/`
  files.
