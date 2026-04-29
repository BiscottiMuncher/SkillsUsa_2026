#!/bin/bash

#teams=("1020" "1071" "1198" "1223" "1271" "1297" "1491" "1952" "2354" "2377" "2530" "2614" "2646" "2875" "3143" "3145" "3164" "5020")
teams=("1020" "1071" "1198")

inet=1
for team in "${teams[@]}"; do
        echo $team
        pveum pool add "Team-$team"

        qm clone 707 ${team}1 --name "Kali-${team}-1" -pool "Team-$team"
        qm set ${team}1 --net0 virtio,bridge=vx0${inet}
        qm snapshot ${team}1 "READY"

        qm clone 707 ${team}2 --name "Kali-${team}-2" -pool "Team-$team"
        qm set ${team}2 --net0 virtio,bridge=vx0${inet}
        qm snapshot ${team}2 "READY"

        ((inet++))
done
