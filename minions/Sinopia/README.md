Sinopia container documentation
-------

[Fichier compose](docker-compose.yml)

# Sinopia

Sinopia est un serveur de stockage de package NPM. Il permet de stocker ses propres packages ou de stocker des pacgages officiels. Cela permet l'accès à ces derniers même que les serveurs npm sont hors ligne.


# Problèmes rencontrés

**Import des scoped packages**  
Les packages commençant avec le caractère @ ne sont pas téléchargé. Pour palier à celà, il faut modifier la configuration dans le fichier `config.yaml` comme suit :

```yaml
'@*/*':
  # scoped packages
  allow_access: $all
  allow_publish: $authenticated
  proxy: npmjs
```

Ajouter npmjs comment proxy pour ces packages règle le problème.

**Impossible de mapper le dossier `/sinopia/registry`**  
En mettant à disposition le dossier `/sinopia/registry` et en le mappant dans le docker-compose, il est impossible de déployer l'image : le fichier `/bin/sinopia.sh` n'existe pas.
