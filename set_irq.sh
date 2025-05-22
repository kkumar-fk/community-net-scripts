#!/bin/bash

if [ $# -gt 0 ]
then
	dev=$1
else
	dev=`ip r | grep default | awk '{print $5}'`
fi

start_cpu=0
ncpus=`nproc`
lastcpu=$((((ncpus-1))+start_cpu))
cpus=`seq $start_cpu $lastcpu`

count=1
for i in `grep $dev /proc/interrupts | cut -d: -f1`
do
	cpu=`echo $cpus | tr ' ' '\n' | head -$count | tail -1`
	echo $cpu > /proc/irq/$i/smp_affinity_list
	count=$((count+1))
done
