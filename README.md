# Notes on LDAP setup and configuration

This is a simple notebook on setting up and configuring OpenLDAP on a private virtual  network using Virtual Machines as clients and servers. The goal is to use LDAP's database to authenticate users on a small, local network.

## Logs

The log files (extension `.log`) are generated using the `script` linux tool. It generates an ANSI format file that is rather unreadable. To actually improve a bit the reading process, use the `convert-logs.sh` utility. It takes as parameter a log file and outputs an HTML and a plain text files using the tools `ansi2html` and `ansi2txt`. You'll need those installed.



## Setting up the LDAP server

In order to have a LDAP setup, you will need to setup a Client-Server architecture. Don't worry, it's pretty simple! 

### Installation

First, on your server machine, run `apt install slapd ldap-utils`. During installation you will have to configure the admin account password for your LDAP server. After the installation is complete, edit the file `/etc/ldap/ldap.conf` modifying the following lines:

```sh
BASE dc=<example>,dc=<com>
URI ldap://<serverhostname>.example.com
TLS_CACERT /etc/ssl/certs/ca-certificates.crt
```

Change \<example>, \<com> and \<serverhostname> to your own domain components and the hostname of your server (you can check it by executing the `hostname` command in the terminal). A further explanation of the acronyms (e.g., DC, DN, OU, DIT) can be found [here](https://ubuntu.com/server/docs/service-ldap) and [here](https://stackoverflow.com/questions/18756688/what-are-cn-ou-dc-in-an-ldap-search).

### First steps

To add some content to your database, use the command `ldapadd -x -D cn=admin,dc=example,dc=com -W -f add_content.ldif`. The file `add_content.ldif` should look something like:

```shell
dn: ou=People,dc=example,dc=com
objectClass: organizationalUnit
ou: People

dn: ou=Groups,dc=example,dc=com
objectClass: organizationalUnit
ou: Groups

dn: cn=miners,ou=Groups,dc=example,dc=com
objectClass: posixGroup
cn: miners
gidNumber: 5000

dn: uid=john,ou=People,dc=example,dc=com
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: john
sn: Doe
givenName: John
cn: John Doe
displayName: John Doe
uidNumber: 10000
gidNumber: 5000
userPassword: {CRYPT}x
gecos: John Doe
loginShell: /bin/bash
homeDirectory: /home/john
```

(This is an example file. You should create your own posixGroups, organizational Units and users).

Alter the  users' password with `ldappasswd -x -D cn=<admin>,dc=<example>,dc=<com> -W -S uid=<user>,ou=<userOrganization>,dc=<example>,dc=<com>`.

## Setting up the LDAP Clients

Setting up the LDAP Client can be a little tricky, but don't be afraid! The setup presented here is to just use LDAP as a centralized user and directory database for authentication purposes. For that, you'll need to `apt install libpam-ldap libnss-ldap` in your Client machines. **Attention! During installation, some important information is required, such as the address of the LDAP server (it is suggested to use `ldap://<ip-of-server>:<port-if-not-default>` instead of `ldapi:///<ip-of-server>` to enforce TCP connection), the domain components of your LDAP admin account (cn=\<admin>,dc=\<example>,dc=\<com>) and its password. Do not fail this step, for I have done so and could only fix it by doing it all over again.**

After the installation is complete, you can use `ldapsearch -H ldap://<ip-of-server> -x * -b dc=<example>,dc=<com>` to check if your client is able to communicate with your server.



### Post installation set up

After installation, you will have to manually edit a couple of files:

- In `/etc/nsswitch.conf `,  add a `ldap` entry for `passwd`, `group` and `shadow`. This will make `nss` look for entities in LDAP:

  ```sh
  passwd:         compat systemd ldap
  group:          compat systemd ldap
  shadow:         compat ldap
  ```

- In `/etc/pam.d/common-session`, add this line to the end of the file:

  ```sh
  session required	pam_mkhomedir.so skel=/etc/skel umask=077
  ```

  This will make `pam` create a home directory for LDAP users when they first login.

- Reboot your client. With luck, everything will be set up and ready to ship.

## Further work

- Check out how to import already existing users using `migrationstool`.
- Check out how to setup a more secure LDAP connection (not using default `389` port).
- Improve this documentation.



## References

[Ubuntu OpenLDAP Server tutorial](https://ubuntu.com/server/docs/service-ldap)

[OpenLDAP server tutorial for Debian 10 (Buster)](https://computingforgeeks.com/how-to-install-and-configure-openldap-server-on-debian/)

Check out these two videos on LDAP: [O que é LDAP?](https://www.youtube.com/watch?v=l8BwMlPRMF8), [Configurando um servidor OpenLDAP com autenticação](https://www.youtube.com/watch?v=uaxGJs48nSY).
