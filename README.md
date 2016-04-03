# lego-wrapper
wrapper for lego let'sencrypt client automation

Each file in /etc/lego.d/domains contains list of domains for which **one** certificate is generated. First line is expected to contain the base domain, other lines will be added to the certificate as aliases (subjAltName).

Configurable via /etc/lego.d/lego.conf (default config file, can be edited in the script).

Do not forget to add your email addres to lego.conf (EMAIL=your@e-mail.example.com).

Make sure you read and accept Let's Encrypt's TOC **before** you run this script **OR** remove the TOC= configuration option to be prompted for acceptance by Lego at runtime.

