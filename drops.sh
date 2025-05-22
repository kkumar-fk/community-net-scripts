#!/bin/bash

if [ $# -eq 0 ]
then
	echo "Time-to-wait {dev}"
	exit 1
fi

tm=$1

if [ $# -eq 2 ]
then
	dev=$2
else
	dev=`ip r | grep default | awk '{print $5}'`
fi

start=`sudo ethtool -S $dev | grep "rx_dropped:" | awk '{print $NF}'`
sleep $tm
end=`sudo ethtool -S $dev | grep "rx_dropped:" | awk '{print $NF}'`

drops=$((end-start))
echo "Packets dropped in $tm seconds: $drops"
