# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A lightweight local Ansible lab built with Docker. It spins up 4 containers (Ubuntu 24.04, Fedora 40, Debian 12, Arch Linux), each with SSH + Python3 preinstalled, so Ansible playbooks/ad-hoc commands can be run against them from the host immediately — no VMs.

## Commands

```bash
make up      # generate SSH key (if missing) + build images + start all 4 containers
make test    # ansible all -m ping
make down    # stop containers
make restart # down + up
make ps      # docker compose ps
make clean   # down + delete generated SSH key (keys/id_ansible*)
```

Without make:

```bash
./setup.sh                    # generates keys/id_ansible (ed25519, no passphrase) if not present
docker compose up -d --build  # build + start all 4 containers
ansible all -m ping
ansible-playbook ping.yml     # runs the verification playbook (ping + distro facts)
```

Target a single distro group: `ansible ubuntu_lab -m ping` (groups: `ubuntu_lab`, `fedora_lab`, `debian_lab`, `archlinux_lab`).

Ad-hoc command example: `ansible all -a "cat /etc/os-release"`.

## Architecture

- **`docker/<distro>/Dockerfile`** — one Dockerfile per distro (ubuntu, fedora, debian, archlinux). Each installs `openssh-server`/`openssh` + `python3` + `sudo`, creates the `ansible` user (passwordless sudo), copies `keys/id_ansible.pub` into `/home/ansible/.ssh/authorized_keys`, runs `ssh-keygen -A` to generate host keys, and runs `sshd -D` in the foreground as CMD. Build `context` for all services is the repo root (set in `docker-compose.yml`) so each Dockerfile can `COPY keys/id_ansible.pub` directly — **the SSH key must be generated before `docker compose build`** (the Makefile enforces this via the `build: keygen` dependency).
- **`docker-compose.yml`** — defines the 4 services, each exposing container port 22 to a distinct host port (ubuntu=2201, fedora=2202, debian=2203, archlinux=2204) on a shared bridge network `ansible_lab`.
- **`inventory.ini`** — static inventory: one group per distro (`<distro>_lab`), each with a single host pointing at `127.0.0.1:<mapped port>`. Shared `[all:vars]` sets `ansible_user=ansible`, the private key path (`./keys/id_ansible`), `ansible_python_interpreter`, and disables strict host key checking (containers get fresh host keys on every rebuild).
- **`ansible.cfg`** — points at `inventory.ini`, disables host key checking and retry files.
- **`ping.yml`** — sample/verification playbook: pings all hosts and prints `ansible_facts['distribution']`/`distribution_version` per host. Use `ansible_facts['x']`, not the legacy `ansible_x` top-level fact vars (avoids the `INJECT_FACTS_AS_VARS` deprecation warning).
- **`setup.sh`** — idempotent: generates `keys/id_ansible` (ed25519) only if it doesn't already exist, then fixes permissions (600/644). This key pair is gitignored and regenerated per-clone.

## Gotchas

- Host key checking is disabled by design (`ansible_ssh_common_args` in `inventory.ini` + `host_key_checking` in `ansible.cfg`) because containers get new SSH host keys on every rebuild.
- Inventory group names use a `_lab` suffix (`ubuntu_lab`, not `ubuntu`) specifically to avoid Ansible's "Found both group and host with same name" warning, since the hostnames themselves are `ubuntu`, `fedora`, etc.
- Arch Linux's sshd binary lives at `/usr/bin/sshd`; Ubuntu/Debian/Fedora use `/usr/sbin/sshd`. Keep this in mind if editing the Dockerfiles' `CMD`.
