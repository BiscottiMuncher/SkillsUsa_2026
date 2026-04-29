#!/bin/bash

teams=("1020" "1071" "1198" "1223" "1271" "1297" "1491" "1952" "2354" "2377" "2530" "2614" "2646" "2875" "3143" "3145" "3164" "5020")
#teams=("1020" "1071" "1198" "1223" "1271" "1297" "1491" "1952" "2354" "2377")
#teams=("3902")
inet=20
out=0

for team in "${teams[@]}"; do
	if [ $inet -le 9 ]; then
		out="0${inet}"
	else
		out=$inet
	fi

	echo $team
	pveum pool add "Team-$team"

	qm clone 707 ${team}1 --name "Kali-${team}-1" --pool "Team-$team" --full false
	qm set ${team}1 --net0 virtio,bridge=vx${out}
	qm snapshot ${team}1 "READY"
#	qm start ${team}1

	qm clone 707 ${team}2 --name "Kali-${team}-2" --pool "Team-$team" --full false
        qm set ${team}2 --net0 virtio,bridge=vx${out}
	qm snapshot ${team}2 "READY"
#	qm start ${team}2
	((inet++))
done
