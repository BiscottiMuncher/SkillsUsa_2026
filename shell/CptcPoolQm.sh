#!/bin/bash

#teams=("1020" "1071" "1198" "1223" "1271" "1297" "1491" "1952" "2354" "2377" "2530" "2614" "2646" "2875" "3143" "3145" "3164" "5020")
#teams=("1020" "1071" "1198" "1223" "1271" "1297" "1491" "1952" "2354" "2377")
#teams=("3902")
#teams=("1010","1020","1030","1040","1050")
teams=("1030" "1040" "1050" "1060" "1070")
inet=3
out=0

for team in "${teams[@]}"; do
	if [ $inet -le 9 ]; then
		out="0${inet}"
	else
		out=$inet
	fi

	echo $team
	pveum pool add "Team-$team"

	pct clone 303 ${team}3 --hostname "OOS-${team}-1" --pool "Team-$team"
 	pct set ${team}3 --net0 name=eth0,bridge=vx0$inet,ip="192.168.${inet}.167/24"
	pct snapshot ${team}3 "READY"

        pct clone 303 ${team}4 --hostname "OOS-${team}-2" --pool "Team-$team"
        pct set "${team}4" --net0 name=eth0,bridge=vx0$inet,ip="192.168.${inet}.169/24"
        pct snapshot ${team}4 "READY"

        pct clone 303 ${team}5 --hostname "OOS-${team}-3" --pool "Team-$team"
        pct set ${team}5 --net0 name=eth0,bridge=vx0$inet,ip="192.168.${inet}.142/24"
        pct snapshot ${team}5 "READY"

        pct clone 309 ${team}9 --hostname "FILE-${team}-9" --pool "Team-$team"
        pct set ${team}9 --net0 name=eth0,bridge=vx0$inet,ip="192.168.${inet}.198/24"
        pct snapshot ${team}9 "READY"


## BEGIN KVM


	qm clone 402 ${team}2 --name "KALI-${team}-2" --pool "Team-$team" --full false
	qm set ${team}2 --net0 virtio,bridge=vx${out}
	qm snapshot ${team}2 "READY"

        qm clone 306 ${team}6 --name "WEB-${team}-6" --pool "Team-$team" --full false
        qm set ${team}6 --net0 virtio,bridge=vx${out}
        qm snapshot ${team}6 "READY"

        qm clone 308 ${team}8 --name "DICOM-${team}-8" --pool "Team-$team" --full false
        qm set ${team}8 --net0 virtio,bridge=vx${out}
        qm snapshot ${team}8 "READY"


	((inet++))
done
