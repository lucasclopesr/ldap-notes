# Useful scripts

I intend to fill this folder with some useful scripts I might need to complement the LDAP Server-Client installation. What motivated me to create this folder and the current scripts in it is the following scenario: I now have a LDAP server and clients that consume information from the server. The users are created in the client according to the LDAP database and they can  login using a password I first provided to them. However, they may want to (and should) alter  the password I sent, but that must be done using 

`ldappasswd -H ldap://<ldap-server-ip> -x -D "<user_dn>" -W -A -S`

`<user_dn>` should be something like `uid=joao,ou=People,dc=example,dc=com`.

I want to hide this from the final user because it is something they don't need to see or worry about.

## Changing password

  First, I created a script `generate_password_change.sh` in which the administrator (me, or you) can enter the LDAP server address and an organization setup. This script generates the string `ldappasswd -H ldap://<ldap-server-ip> -x -D "<organization_dn>" -W -A -S` replacing `<ldap-server-ip>` and `<organization_dn>` to the parameters passed to the script. For example:

  `./generate_password_change.sh 192.168.0.3 ou=People,dc=example,dc=com`

Generates

  `ldappasswd -H ldap://192.168.0.3 -x -D 'uid=$USER,ou=People,dc=example,dc=com' -W -A -S`

In a file called `change_ldap_password.sh` that is supposed to go into all LDAP clients. I am using `/opt/change_ldap_password.sh` but you can place it wherever you want.

Next step was to add a global alias (at `/etc/bash.bashrc` for the command). I created the following alias: `alias ldap_passwd='/opt/change_ldap_password.sh`. All for the final user!

### Next steps

  - Generate different scripts for different organizations and map them to the same alias in some way.
    
  - Validate argument inputs in `generate_password_change.sh`.

  - Find a way to automate the following steps: distribute the `change_ldap_password.sh` to all client machines; Add the alias to `/etc/bash.bashrc` in all machines. Using something like Puppet or Ansible maybe?

### References

  I used [this site](https://www.digitalocean.com/community/tutorials/how-to-change-account-passwords-on-an-openldap-server) to learn how the user could change their own password.
