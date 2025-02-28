#!/bin/bash
set -e

echo "=== Vérification du module ppolicy dans /usr/lib/ldap ==="
if ! ls /usr/lib/ldap | grep -q ppolicy; then
    echo "Erreur : ppolicy.la introuvable dans /usr/lib/ldap. Le module ppolicy est requis pour le fonctionnement du serveur."
    exit 1
fi

echo "=== Initialisation d'OpenLDAP ==="

if [ ! -d /etc/ldap/slapd.d ]; then
    echo "Configuration initiale en cours..."
    echo "slapd slapd/no_configuration boolean false" | debconf-set-selections
    dpkg-reconfigure -f noninteractive slapd
fi

echo "Démarrage temporaire de slapd..."
/usr/sbin/slapd -h "ldap:/// ldapi:///" -d 1 &
SLAPD_PID=$!

sleep 5

echo "=== Chargement de la configuration ppolicy ==="
if ! ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/ppolicy_setup.ldif ; then
    echo "Erreur lors de l'application de la configuration ppolicy." >&2
    kill $SLAPD_PID
    exit 1
fi

echo "Configuration ppolicy appliquée avec succès."

kill $SLAPD_PID
sleep 2

echo "=== Redémarrage d'OpenLDAP en mode foreground ==="
exec /usr/sbin/slapd -h "ldap:/// ldapi:///" -d 1
