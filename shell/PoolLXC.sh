#!/bin/bash

## OLD SCRIPT ##

## Create X Amount of pools
i=1

while [ $i -le 8 ]
do
 pveum pool add Pool0$i
 pct clone 7004 "1${i}01" --hostname muramasa --pool Pool0$i
 pct set "1${i}01" --net0 name=eth0,bridge=vx0$i,ip=dhcp #Fuck my green ass
 pct snapshot "1${i}01" "READY"

 pct clone 7002 "1${i}02" --hostname gaebulg --pool Pool0$i
 pct set "1${i}02" --net0 name=eth0,bridge=vx0$i,ip=dhcp
 pct snapshot "1${i}02" "READY"

 pct clone 7003 "1${i}03" --hostname scabbard --pool Pool0$i
 pct set "1${i}03" --net0 name=eth0,bridge=vx0$i,ip=dhcp
 pct snapshot "1${i}03" "READY"

 ((i++))
done
