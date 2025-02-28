#!/bin/bash
set -e

echo "=== Vérification de Docker ==="
if ! command -v docker &> /dev/null; then
    echo "Docker n'est pas installé. Installation de Docker..."
    # Mise à jour des paquets et installation des dépendances
    apt-get update -q
    apt-get install -yq apt-transport-https ca-certificates curl gnupg lsb-release
    # Ajout de la clé GPG officielle de Docker
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    # Ajout du repository Docker stable
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
        | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -q
    apt-get install -yq docker-ce docker-ce-cli containerd.io
    echo "Docker a été installé avec succès."
else
    echo "Docker est déjà installé."
fi

echo "=== Construction de l'image OpenLDAP ==="
docker build -t ldap-openldap:stable .

echo "=== Lancement du container OpenLDAP ==="
docker run -d --name openldap-server \
    -p 389:389 \
    -v ldap_data:/var/lib/ldap \
    -v ldap_config:/etc/ldap/slapd.d \
    ldap-openldap:stable

echo "=== Déploiement terminé. Vérifiez l'état du container avec 'docker ps'. ==="
