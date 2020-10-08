#!/bin/bash

if [ -z "$1" ]
  then
    echo "You must provide the LDAP server IP as first argument"
  elif [ -z "$2" ]
    then
      echo "You must provide the organization DN as second argument"
  else
    echo "ldappasswd -H ldap://${1} -x -D \"uid=\$USER,${2}\" -W -A -S" >> change_ldap_password.sh
    chmod +x change_ldap_password.sh
fi
