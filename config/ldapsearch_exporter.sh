# BIND variables
echo "début du scipt"
date
echo "" 
srvldap=()
whoami_file=/tmp/ldapwhoami.metrics
search_file=/tmp/ldapsearch.metrics
final_file=/app/metrics/final.metrics
filtre=()


rm -f $search_file
rm -f $whoami_file

# Test de connexion LDAP
function fonction.ldapwhoami {

    for srv in "${srvldap[@]}"; do
        if timeout 0.5 ldapwhoami -x -H "${srv}" > /dev/null 2>&1; then
            echo "ldapwhoami_status{ldapsrv=\"$srv\"} 1" >> "$whoami_file"
            srvldapwhoami+=("$srv")
        else
            echo "ldapwhoami_status{ldapsrv=\"$srv\"} 0" >> "$whoami_file"
        fi
    done
}

fonction.ldapwhoami

# time ldapsearch
for srv in "${srvldapwhoami[@]}"; do
    TIMEFORMAT='%R %U %S';
    time_output=$( { time ldapsearch -LLL -x -H "${srv}" "${filtre}" > /dev/null; } 2>&1 )
    if [ $? -eq 0 ]; then
        # Récupérer les valeurs de temps de sortie
        IFS=' ' read -ra times <<< $time_output
        real_time=${times[0]}
        user_time=${times[1]}
        sys_time=${times[2]}
        # Ajouter le nom du serveur à chaque ligne de sortie
        echo "ldapsearch_time{ldapsrv=\"$srv\",metric=\"real_time\"} $real_time" >> "$search_file"     
        echo "ldapsearch_time{ldapsrv=\"$srv\",metric=\"user_time\"} $user_time" >> "$search_file"       
        echo "ldapsearch_time{ldapsrv=\"$srv\",metric=\"sys_time\"} $sys_time" >> "$search_file"   
    else
        echo "ldapsearch_error{ldapsrv=\"$srv\",metric=\"error\"} 1" >> "$search_file"
    fi
done



cat $whoami_file $search_file > $final_file
echo ""
cat  $final_file
echo "" 
echo "FIN DU SCRIPT"
echo "" 
echo "" 
sleep 1