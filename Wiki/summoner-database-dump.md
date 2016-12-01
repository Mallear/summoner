# Documentation - `summoner-database-dump` script

Le script `summoner-database-dump` permet d'effectuer le dump (export) des bases de données stockées dans des dockers.

## Déroulement

Ce script récupère tout les conteneurs de base de données tournant sur la machine hôte, définit son type et effectue un dump de la base grâce à l'utilitaire approprié.  
Une fois le dump réalisé, il est envoyé sur Dropbox.

**Pour que le script se déroule convenablement, il est nécessaire que tout les conteneurs de BdD soient nommés selon le schéma défini [dans les règles de nommage](https://gitlab.com/puzle-project/Summoner/blob/master/README.md#regle-nommage).**

## Communication avec Dropbox

Le transfert du fichier de dump sur Dropbox s'effectue grâce au script [Dropbox-uploader](https://github.com/andreafabrizi/Dropbox-Uploader) développé par Andrea Fabrizi et disponible gratuitement sur GitHub.

Pour fonctionner, ce script a besoin de votre token d'authentification Dropbox afin que l'API Dropbox accorde l'accès à votre compte. Pour cela, il suffit de créer un accès à l'API Dropbox via l'[interface web](https://www.dropbox.com/developers/apps).

_Marche à suivre :_
* _Create App_, select _dropbox API_
* Selectionnez le type d'accès que vous souhaitez
* Nommez votre application
* Générez votre _access token_

Ce token vous sera demandé à la première exécution du script ou bien, vous pouvez ajouter la ligne `OAUTH_ACCESS_TOKEN=<token>` dans un fichier nommé `.dropbox_uploader` situé dans le répertoire `$HOME` de votre utilisateur.
