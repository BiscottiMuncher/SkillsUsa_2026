
teams=("1020" "1071" "1198" "1223" "1271" "1297" "1491" "1952" "2354" "2377" "2530" "2614" "2646" "2875" "3143" "3145" "3164" "5020")
echo "id,username,email,firstname,lastname,idnumber,institution,department,phone1,phone2,city,country,password,timezone,cohort1"
inet=10
for team in "${teams[@]}"; do   
        echo "${inet},${team}-1,${team}-1@skills.org,${team},1,,,,,,,,$(uuidgen | sed 's/[-]//g' | head -c 8; echo;),America/Los_Angeles,Competitors"
        ((inet++))
        echo "${inet},${team}-2,${team}-2@skills.org,${team},2,,,,,,,,$(uuidgen | sed 's/[-]//g' | head -c 8; echo;),America/Los_Angeles,Competitors"
        ((inet++))
done
