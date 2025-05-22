#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Sleep time"
	exit 1
fi

. ./env

tm=$1

c1=`grep CAL: /proc/interrupts | sed 's/CAL://g' | sed 's/Function.*//g' | \
	sed 's/^ //' | sed 's/ $//' | tr ' ' '\n' | sed '/^$/d' | add`
sleep $tm
c2=`grep CAL: /proc/interrupts | sed 's/CAL://g' | sed 's/Function.*//g' | \
	sed 's/^ //' | sed 's/ $//' | tr ' ' '\n' | sed '/^$/d' | add`

c=$((c2-c1))
c_rate=`echo "scale=1; $c/$tm" | bc -l`

echo "Function Call Intr (IPI): $c_rate / sec"
