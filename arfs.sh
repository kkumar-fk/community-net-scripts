#!/bin/bash

if [ $# -eq 0 ]
then
	echo "arfs.sh [on/off/check] <dev> <hashsize>"
	exit 1
fi

if [ $# -eq 1 ]
then
	dev=`ip r | grep default | awk '{print $5}'`
	rps_cnt=512
else
	dev=$2
	if [ $# -eq 3 ]
	then
		rps_cnt=$3
	fi
fi

# Assume we use Combined
NUM_QUEUES=`sudo ethtool -l $dev | grep Combined | tail -1 | awk '{print $NF}'`

if [ "$1" == "check" ]
then
	echo "Current values for ARFS are:"
	echo "	Global: `cat /proc/sys/net/core/rps_sock_flow_entries`"
	echo "	Local: `for f in /sys/class/net/$dev/queues/rx-*/rps_flow_cnt
	do
		cat $f
	done | tr '\n' ' '`
	"
	exit 0
elif [ "$1" == "on" ]
then
	sudo ethtool -K $dev ntuple on
	rps_total_cnt=$((rps_cnt*NUM_QUEUES))

	echo $rps_total_cnt > /proc/sys/net/core/rps_sock_flow_entries
	for f in /sys/class/net/$dev/queues/rx-*/rps_flow_cnt
	do
		echo $rps_cnt > $f
	done
elif [ "$1" == "off" ]
then
	sudo ethtool -K $dev ntuple off
	echo 0 > /proc/sys/net/core/rps_sock_flow_entries
	for f in /sys/class/net/$dev/queues/rx-*/rps_flow_cnt
	do
		echo 0 > $f
	done
fi

echo "New values for ARFS:"
echo "	Global: `cat /proc/sys/net/core/rps_sock_flow_entries`"
echo "	Local: `for f in /sys/class/net/$dev/queues/rx-*/rps_flow_cnt
	do
		cat $f
	done | tr '\n' ' '`
"
