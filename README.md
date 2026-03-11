# 110lab Ansible Collection

This repository is initialized as an Ansible collection with a structure modeled
after [`geerlingguy/ansible-collection-mac`](https://github.com/geerlingguy/ansible-collection-mac).

The starter collection FQCN is `lowess.lab110`.

The repository name can still be `ansible-collection-110lab`, but the collection
`name` in `galaxy.yml` cannot start with a digit, so `lab110` is used instead
of `110lab`.

## Layout

```text
.
|-- .github/workflows/
|-- galaxy.yml
|-- galaxy-deploy.yml
|-- meta/runtime.yml
|-- plugins/
|-- roles/example/
`-- tests/
```

## Included starter role

The collection includes a minimal starter role:

- `lowess.lab110.example`

It is intentionally small and safe to replace once you add real roles.

## Installation

For local development, point Ansible at this repository through a standard
collection path, for example:

```bash
mkdir -p ./ansible_collections/lowess
ln -s "$(pwd)" ./ansible_collections/lowess/lab110
```

To build the collection artifact:

```bash
ansible-galaxy collection build
```

## Usage

Example playbook:

```yaml
---
- name: Test the collection
  hosts: localhost
  gather_facts: false

  vars:
    example_enabled: true

  roles:
    - lowess.lab110.example
```

## Next steps

- Replace `lowess` and `lab110` in [`galaxy.yml`](galaxy.yml) if you want a
  different namespace or collection name.
- Review repository, documentation, homepage, and issues URLs before publishing.
- Replace the example role with your real roles under `roles/`.
