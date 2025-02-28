#!/bin/bash

# Ce script prépare une VM Debian fraîche pour héberger le container OpenLDAP.
# Il doit être exécuté en tant que root.

set -e

# Vérification des privilèges root
if [ "$(id -u)" -ne 0 ]; then
    echo "Erreur : Ce script doit être exécuté en tant que root."
    exit 1
fi

echo "=== Mise à jour initiale du système ==="
apt-get update -y
apt-get upgrade -y

echo "=== Vérification de l'installation de sudo ==="
if ! command -v sudo &> /dev/null; then
    echo "sudo n'est pas installé. Installation de sudo..."
    apt-get install -y sudo
else
    echo "sudo est déjà installé."
fi

echo "=== Installation des dépendances nécessaires pour Docker ==="
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

echo "=== Ajout de la clé GPG officielle de Docker ==="
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "=== Ajout du dépôt Docker stable ==="
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "=== Mise à jour des paquets après ajout du dépôt Docker ==="
apt-get update -y

echo "=== Installation de Docker CE, Docker CE CLI et containerd ==="
apt-get install -y docker-ce docker-ce-cli containerd.io

echo "=== Configuration de Docker pour démarrer automatiquement ==="
systemctl enable docker
systemctl start docker

echo "=== Vérification de l'installation de Docker ==="
docker --version

echo "=== Préparation des répertoires pour l'externalisation des données ==="
mkdir -p /srv/docker/ldap_data
mkdir -p /srv/docker/ldap_config

echo "Les répertoires suivants ont été créés (ou existent déjà) :"
echo "  - /srv/docker/ldap_data"
echo "  - /srv/docker/ldap_config"

echo "=== Préparation terminée. Vous pouvez désormais déployer le container OpenLDAP. ==="
