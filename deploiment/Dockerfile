FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

# Installation d'OpenLDAP (version stable) et des outils LDAP
RUN apt-get update && \
    apt-get install -y slapd ldap-utils && \
    rm -rf /var/lib/apt/lists/*

# Copier les fichiers de configuration et d'initialisation
COPY init_ldap.sh /usr/local/bin/init_ldap.sh
COPY ppolicy_setup.ldif /tmp/ppolicy_setup.ldif

RUN chmod +x /usr/local/bin/init_ldap.sh

# Déclaration des volumes pour externaliser les données et la configuration
VOLUME ["/var/lib/ldap", "/etc/ldap/slapd.d"]

# Exposition du port LDAP standard
EXPOSE 389

# Lancement de l'initialisation
CMD ["/usr/local/bin/init_ldap.sh"]
