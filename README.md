# jailEtudiant
Script sh, lancé admin, empêchant l'élève d'installer des applications pas reconnues par l'institut

### Lancer le script.sh en tant que daemon (check periodique toutes les 10min) :
Modifiez le fichier .plist et changez `/path/to/jailEtu.sh` par le chemin d'accès vers jailEtu.sh (root pour empêcher suppression par élève)
Deplacez le fichier modifié live.cclerc.jailetu.plist dans /Library/LaunchDaemons/
Puis lancez la commande suivante en tant qu'admin 
```bash
sudo launchctl load /Library/LaunchDaemons/
```
Si vous souhaitez modifier l'intervalle de 10min, changez la valeur de StartInterval (à l'origine 600) par un chiffre (en secondes)

### Modifier les filtres du script sh :
Modifiez les noms autorisés par le script en modifiant la variable suivante (début du script)
<img width="72" alt="Capture d’écran 2023-10-22 à 16 22 32" src="https://github.com/c22dev/jailEtudiant/assets/102235607/c69f7497-ec47-458e-91dc-bee793bca380">
Par défaut, les noms d'entreprises d'imprimantes commun sont mis, ainsi que Google (facultatif si prevu de desinstaller Google Chrome > à enlever).
Liste disponible dans le fichier FILTRES.md
