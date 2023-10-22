#!/bin/bash

# jailEtu
# v1.0 - Constantin CLERC

# variables
# on autorise ici des bundle ids
# google est autorisé donc chrome pourrait être lancé, vous pouvez l'enlever si besoin
# https://support.apple.com/en-us/HT201311 j'ai pris les noms depuis cette liste complete
# si un élève ne parvient pas à imprimer, on peut rajouter le bundle id de son imprimante
elements=("google" "canon" "hp" "apple" "canon" "aurora" "brother" "conexant" "deli" "dell" "develop" "eline" "epson" "f+" "fuji" "xerox" "fujifilm" "funai" "g&g" "gandg" "gestetner" "hewlett-packard" "hewlettpackard" "infotec" "konica" "kyocera" "lanier" "airprint" "lexmark" "muratec" "lg" "xiaomi" "mi" "munbyn" "nec" "nrg" "ntt" "oki" "olivetti" "panasonic" "pantum" "princiao" "prink" "ricoh" "rollo" "samsung" "savin" "sharp" "sindoh" "star-micronics" "star_micronics" "starmicronics" "micronics" "star" "ta" "toshiba" "zink" "iprint" "lantronix" "lexmark" "lrs" "seh")
app_files=()

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
if [ "$(find /Users/etudiant/Library/Printers -mindepth 1 -maxdepth 1)" ] || [ "$(find /Users/etudiant/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Helpers -mindepth 1 -maxdepth 1)" ]; then
    # 1. On regarde dans chaque .app et on check les bundle IDs
    # oui mais, l'élève peut modifier le bundle ID en utilisant vscode et en modifiant la plist. C'est pour quoi en 2e étape on va verifier la signature
    # 2. On regarde dans chaque .app et on check la signature (on utilise codesign)
    while IFS= read -r -d '' app_path; do
        app_files+=("$app_path")
    done < <(find /Users/etudiant/Library/Printers /Users/etudiant/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Helpers -type d -name "*.app" -print0)

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
