# jailEtudiant v1.3.1 version antiCache
Script sh, lancé admin, empêchant l'élève d'installer des applications non reconnues par l'institut

Update 1.2 : On enlève le path Chrome des verifications comme plus valide.

Update 1.3 : On piège le cache (si un autre script essaie d'en faire un à partir du dossier Printers, voir [cacheIT!](https://github.com/c22dev/cacheIT) en cassant l'application et son contenu.

Update 1.3.1 : On crée une application vide falsifiée (fake.app) pour déclencher la mise à jour d'un pottentiel cache en plus de la corruption précédente.
### Lancer le script.sh en tant que daemon (check periodique toutes les 10min) :
Modifiez le fichier .plist et changez `/path/to/jailEtu.sh` par le chemin d'accès vers jailEtu.sh (chemin de préfèrence admin uniquement en écriture pour empêcher suppression par élève)
Deplacez le fichier modifié live.cclerc.jailetu.plist dans /Library/LaunchDaemons/
Puis lancez la commande suivante en tant qu'admin 
```bash
sudo launchctl load /Library/LaunchDaemons/
```
Si vous souhaitez modifier l'intervalle de 10min, changez la valeur de StartInterval (à l'origine 600) par un chiffre (en secondes)

### Modifier les filtres du script sh :
Modifiez les noms autorisés par le script en modifiant la variable suivante (début du script)
<img width="72" alt="Capture d’écran 2023-10-22 à 16 22 32" src="https://github.com/c22dev/jailEtudiant/assets/102235607/c69f7497-ec47-458e-91dc-bee793bca380">
Uniquement Canon, Apple, et Epson sont mis. Pourquoi ? Car la plupart des imprimantes utilise le bundle com.apple...
Liste disponible dans le fichier [FILTRES.txt](https://raw.githubusercontent.com/c22dev/jailEtudiant/main/FILTRES.txt)
