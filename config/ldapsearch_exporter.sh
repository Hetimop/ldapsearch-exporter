#!/bin/bash

while true; do
# Nom du fichier de sortie
filetmp="/app/metrics/tmp.metrics"
filename="/app/metrics/ldapsearch.metrics"
rm -f $filetmp
touch $filetmp

# Définition de la fonction pour la commande LDAP
function ldapsearch_time {
    local url="$1"
    local filtre="$2"
    local output="$3"
    local real user sys 

    # Test de connexion LDAP
    if ! ldapwhoami -x -H "${url}" > /dev/null 2>&1; then
        echo "Erreur: impossible de se connecter à ${url}"
        return
    fi

    # Exécuter la commande et stocker le résultat dans une variable
    TIMEFORMAT='%R %U %S';
    {
        res="$( { time ldapsearch -LLL -x -H "${url}" "${filtre}" ;} 2>&1 > /dev/null )"
        read real user sys <<< "$res"
        echo "ldap_search_uid_real{ldapsrv=\"$url\",filtre=\"$filtre\"} ${real/,/}" >> "$output"
        echo "ldap_search_uid_user{ldapsrv=\"$url\",filtre=\"$filtre\"} ${user/,/}" >> "$output"
        echo "ldap_search_uid_sys{ldapsrv=\"$url\",filtre=\"$filtre\"} ${sys/,/}" >> "$output"
    }
}

# URL du domaine LDAP
urls=()

# Filtre LDAP à utiliser pour les requêtes
filtres=()

# Boucle pour effectuer une requête LDAP pour chaque filtre, pour chaque serveur de la liste
for url in "${urls[@]}"; do
if ldapwhoami -x -H "${url}" -o nettimeout=1 > /dev/null 2>&1; then
    for filtre in "${filtres[@]}"; do
        ldapsearch_time "$url" "$filtre" "$filetmp"
    done
else
    echo "ldapwhoami_erreur{ldapsrv=\"$url\"} 1" >> "$filetmp"
fi

done

cp $filetmp $filename

sleep 1

done