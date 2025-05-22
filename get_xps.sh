#!/bin/bash

if [ $# -gt 0 ]
then
	dev=$1
else
	dev=`ip r | grep default | awk '{print $5}'`
fi

cd /sys/class/net/$dev/queues

queues=`ls -d tx* | cut -d- -f2 | sort -n`
for q in $queues
do
	echo "tx-$q: `cat tx-$q/xps_cpus`"
done
