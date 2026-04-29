#!/bin/bash

teams=("1020" "1071" "1198" "1223" "1271" "1297" "1491" "1952" "2354" "2377" "2530" "2614" "2646" "2875" "3143" "3145" "3164" "5020")
#teams=("1020" "1071" "1198" "1223" "1271" "1297")

inet=1

for team in "${teams[@]}"; do
	echo $team
	qm stop ${team}1
	qm stop ${team}2
	qm destroy ${team}1
	qm destroy ${team}2
	pveum pool delete "Team-$team"
	((inet++))
done

