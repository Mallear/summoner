# phpLDAPAdmin

Same functionalities as OpenLDAP : configuration with a config.php file mapped in a volume to the directory in the container.

## TLS 

User our own certificate or generate one. Generated with the container hostnam `--hostname`.

---------

# Problems

* TLS certification with Letsencrypt is done when the container is up. So first deplyment is lacking of these certificates and LDAP will create its own. 

# Solution

* Deployment in two time : first without certs to lets LETSENCYRPT to generate its own. Restart to take these certs as the only one.
* Generate letsencrypt certs by hand and start LDAP tools after.