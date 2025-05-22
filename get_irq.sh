#!/bin/bash

if [ $# -eq 1 ]
then
	dev=$1
else
	dev=`ip r | grep default | awk '{print $5}'`
fi

irqs=`grep $dev /proc/interrupts | cut -d: -f1`
irq_no=0
for i in $irqs
do
	echo "$i ($irq_no): `cat /proc/irq/$i/smp_affinity_list`"
	irq_no=$((irq_no+1))
done
