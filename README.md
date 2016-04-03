# lego-wrapper
Wrapper for [xenolf's lego](https://github.com/xenolf/lego) Let's Encrypt client automation.

Each file in /etc/lego.d/domains contains list of domains for which **one** certificate is generated. First line is expected to contain the base domain, other lines will be added to the certificate as aliases (subjAltName).

Configurable via /etc/lego.d/lego.conf (default config file, can be edited in the script).

Do not forget to add your email addres to lego.conf (EMAIL=your@e-mail.example.com).

Make sure you read and accept [Let's Encrypt's TOS](https://letsencrypt.org/documents/LE-SA-v1.0.1-July-27-2015.pdf) **before** you run this script **OR** remove the TOC= configuration option to be prompted for acceptance by Lego at runtime.

Don't forget to unset the TESTSERVER variable to make live working certificates. By default the wrapper only produces testing certificates.

This script is suitable for running by cron or any other automation tools. Certificates will only be renewed when in renewal window set by RENEWLEFT (defaults to within the last 30 days of validity)

!!! Warning !!!
Be **extremely careful** when running with '-i' parameter, any pre-existing certificate and key files bearing the name of the base domain in system storage (usually /etc/ssl/{certs,private}) **WILL BE OVERWRITTEN**, no questions asked. You have been warned.

