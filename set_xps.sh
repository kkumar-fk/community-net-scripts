#!/bin/bash

if [ $# -gt 0 ]
then
	dev=$1
else
	dev=`ip r | grep default | awk '{print $5}'`
fi

cd /sys/class/net/$dev/queues
queues=`ls -d tx* | cut -d- -f2 | sort -n`

zeroes=""
str="1"
iters=1
total=1

for q in $queues
do
	echo $str > tx-$q/xps_cpus

	iters=$((iters+1))
	if [ $iters == 5 ]
	then
		iters=1
		zeroes="0$zeroes"
		total=$((total+1))
		if [ $total == 9 ]
		then
			zeroes=",$zeroes"
			total=1
		fi
		str="1$zeroes"
	else
		str=`echo $str | sed 's/4/8/' | sed 's/2/4/' | sed 's/1/2/'`
	fi
done
