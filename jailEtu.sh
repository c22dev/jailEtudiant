#!/bin/bash

# jailEtu
# v1.0 - Constantin CLERC

# variables
# on autorise ici des bundle ids
# google est autorisé donc chrome pourrait être lancé, vous pouvez l'enlever si besoin
# https://support.apple.com/en-us/HT201311 j'ai pris les noms depuis cette liste complete
# si un élève ne parvient pas à imprimer, on peut rajouter le bundle id de son imprimante
# le plus souvent, les imprimantes qui utilisent AirPrint sont tous registered sous le bundle com.apple.print.PrinterProxy.
elements=("google" "canon" "hp" "apple" "canon" "aurora" "brother" "conexant" "deli" "dell" "develop" "eline" "epson" "f+" "fuji" "xerox" "fujifilm" "funai" "g&g" "gandg" "gestetner" "hewlett-packard" "hewlettpackard" "infotec" "konica" "kyocera" "lanier" "airprint" "lexmark" "muratec" "lg" "xiaomi" "mi" "munbyn" "nec" "nrg" "ntt" "oki" "olivetti" "panasonic" "pantum" "princiao" "prink" "ricoh" "rollo" "samsung" "savin" "sharp" "sindoh" "star-micronics" "star_micronics" "starmicronics" "micronics" "star" "ta" "toshiba" "zink" "iprint" "lantronix" "lexmark" "lrs" "seh")
app_files=()
dir1="/Users/etudiant/Library/Printers"
dir2="/Users/etudiant/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Helpers"

# func de check de bundle id 
function check_bundle_id {
    bundle_id=$1
    for element in "${elements[@]}"; do
        if [[ $bundle_id == *$element* ]]; then
            return 0
        fi
    done
    return 1
}

# On check si un fichier existe dans le dossier Printers et Google
if [ "$(find $dir1 -mindepth 1 -maxdepth 1)" ] || [ "$(find $dir2 -mindepth 1 -maxdepth 1)" ]; then
    # 1. On regarde dans chaque .app et on check les bundle IDs
    # oui mais, l'élève peut modifier le bundle ID en utilisant vscode et en modifiant la plist. C'est pour quoi en 2e étape on va verifier la signature
    # 2. On regarde dans chaque .app et on check la signature (on utilise codesign)
    while IFS= read -r -d '' app_path; do
        app_files+=("$app_path")
    done < <(find $dir1 $dir2 -type d -name "*.app" -print0)

    for app_path in "${app_files[@]}"; do
        # On obtient le bundle id depuis l'Info.plist dans l'app et on definie une variable par la réponse.
        bundle_id=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$app_path/Contents/Info.plist" 2>/dev/null)
        if [[ -n $bundle_id ]] && check_bundle_id "$bundle_id"; then
            # Vérification de la signature et récupération du Bundle ID
            signature_output=$(codesign --display --verbose=4 "$app_path" 2>&1)
            if echo "$signature_output" | grep -q "Identifier=$bundle_id"; then
                echo "Signature correcte. CODESIGN BID: $bundle_id"
            else
                echo "Signature incorrecte, suppression de : $app_path"
                rm -rf "$app_path"
            fi
        else
            echo "Supression de $app_path car il n'as pas un Bundle ID autorisé"
            rm -rf "$app_path"
        fi
    done
fi

# On a check si une app non autorisée était installée. Maintenant, il faut verifier si la binary de mas est installée.
# On va vérifier si le fichier contient le nom du kit obligatoire : MasKit, puis le supprimer

# mais avant, on doit supprimer les apps téléchargées par l'élève dans /Applications depuis le Mac App Store
# en me renseignant, je suis tombé sur cette commande :
# find /Applications -path '*Contents/_MASReceipt/receipt' -maxdepth 4 -print |\sed 's#.app/Contents/_MASReceipt/receipt#.app#g; s#/Applications/##'
# problème, elle liste aussi des Apps téléchargées par FileWave.
# donc je me suis dit qu'on pouvais peut-être jouer au jeu de l'élève et utiliser mas pour list les apps téléchargées !
# ça peut prendre du temps, ça devrait eliminer toute les apps installées avec mas.
# ce script doit etre run admin pour delete des apps dans /Applications
# si l'élève a supprimé mas, il faudrait le re-télécharger par ce script (je n'ai pas fais cela car je ne connais pas vos paths d'execution administrateur, et que pottentielement la liste mas est effacée)

while IFS= read -r -d '' file; do
    if [[ -f "$file" && -r "$file" ]]; then
        if grep -q "MasKit" "$file"; then
            file_name=$(basename "$file")
            if [[ "$file_name" != *.md ]]; then
                directory=$(dirname "$file")
                output=$("$directory/$file_name" list)

                while read -r line; do
                    name=$(echo "$line" | awk -F'  ' '{print $2}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    echo "$name"
                    fullName="/Applications/$name.app/"
                    echo "$fullName"
                    rm -rf "$fullName"
                done <<< "$output"
            fi
        fi
    fi
done < <(find $dir1/ -type f -print0)

# meme principe avec la dir2

while IFS= read -r -d '' file; do
    if [[ -f "$file" && -r "$file" ]]; then
        if grep -q "MasKit" "$file"; then
            file_name=$(basename "$file")
            if [[ "$file_name" != *.md ]]; then
                directory=$(dirname "$file")
                output=$("$directory/$file_name" list)

                while read -r line; do
                    name=$(echo "$line" | awk -F'  ' '{print $2}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    echo "$name"
                    fullName="/Applications/$name.app/"
                    echo "$fullName"
                    rm -rf "$fullName"
                done <<< "$output"
            fi
        fi
    fi
done < <(find $dir2/ -type f -print0)

# je pourrais delete la binary mas pour gagner du temps dans le processus precedent mais on est jamais trop sur
# on enlève la binary de mas.
find "$dir1" "$dir2" -type f -exec grep -q "MasKit" {} \; -exec rm {} \;

# prochaine etape : telechargé avec safari ?
# je n'ai pas trouvé d'informations sur le sujet. 
# un check depuis filewave, qui check si l'app est dans la liste des apps autorisées, peut-être effectué
# ici j'ai listé toutes les apps filewave
# anki flash cards, simplemind lite, to mp3 converter free, hex friend, keynote, numbers, pages, post-it.
# je ne peux pas mettre à jour cette liste donc je n'implementerai pas de manière de verifier la methode safari. 
