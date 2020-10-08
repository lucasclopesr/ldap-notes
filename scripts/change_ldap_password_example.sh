ldappasswd -H ldap://192.168.0.3 -x -D "uid=$USER,ou=People,dc=example,dc=com" -W -A -S
