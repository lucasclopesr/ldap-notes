# Notes on LDAP setup and configuration

  This is a simple notebook on setting up and configuring LDAP on a private virtual 
  network using Virtual Machines as clients and servers.

## Logs

  The log files (extension `.log`) are generated using the `script` linux tool. It
  generates an ANSI format file that is rather unreadable. To actually improve a bit
  the reading process, use the `convert-logs.sh` utility. It takes as parameter a
  log file and outputs an HTML and a plain text files using the tools `ansi2html` and
  `ansi2txt`. You'll need those installed.
