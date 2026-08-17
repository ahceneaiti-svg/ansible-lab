# Lab Ansible via Docker

Environnement de test léger pour apprendre et pratiquer Ansible en local, sans VM.
4 conteneurs (Ubuntu 24.04, Fedora 40, Debian 12, Arch Linux) avec SSH + Python3 préinstallés.

## Prérequis

- Docker + Docker Compose
- Ansible (sur la machine hôte)
- `ssh-keygen` (fourni avec OpenSSH)

## Démarrage rapide

```bash
make up      # génère la clé SSH, build les images, lance les conteneurs
make test    # ansible all -m ping
```

Sans Makefile:

```bash
./setup.sh                 # génère keys/id_ansible (+ .pub)
docker compose up -d --build
ansible all -m ping
```

## Détails

| Conteneur | Distro         | Port SSH hôte |
|-----------|----------------|----------------|
| ubuntu    | Ubuntu 24.04   | 2201           |
| fedora    | Fedora 40      | 2202           |
| debian    | Debian 12      | 2203           |
| archlinux | Arch Linux     | 2204           |

- Utilisateur SSH: `ansible` (sudo NOPASSWD sur les 4 conteneurs)
- Authentification: clé SSH dédiée générée dans `keys/id_ansible` (ignorée par git)
- Inventaire: `inventory.ini`, groupes par distro + groupe `all`

## Exemples

```bash
# ping tous les hôtes
ansible all -m ping

# ping un groupe précis
ansible fedora_lab -m ping

# lancer le playbook de vérification (facts + ping)
ansible-playbook ping.yml

# exécuter une commande ad-hoc
ansible all -a "cat /etc/os-release"
```

## Arrêt / nettoyage

```bash
make down     # arrête les conteneurs
make clean    # arrête + supprime la clé SSH générée
```

## Structure

```
.
├── docker/
│   ├── ubuntu/Dockerfile
│   ├── fedora/Dockerfile
│   ├── debian/Dockerfile
│   └── archlinux/Dockerfile
├── keys/                # clé SSH générée (non versionnée)
├── docker-compose.yml
├── inventory.ini
├── ansible.cfg
├── ping.yml
├── setup.sh
└── Makefile
```
