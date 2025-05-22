#!/bin/bash

if [ $# -eq 0 ]
then
	echo "Orgfile Newfile"
	exit 1
fi

org=$1
new=$2

count=$(grep -c "0-71" $org)

# Improve using formatted "print" instead of echo.
echo "------------------------------------------------------"
echo "Metric			Org		New"
echo "------------------------------------------------------"
echo -n "Pkts on Queues 0-71	`grep 0-71 $org | awk '{print $NF}' | add | awk -v c=$count '{printf "%d", $1/c}'`"
echo "	`grep 0-71 $new | awk '{print $NF}' | add | awk -v c=$count '{printf "%d", $1/c}'`"
echo -n "Pkts on Queues 72-143	`grep 72-143 $org | awk '{print $NF}' | add | awk -v c=$count '{printf "%d", $1/c}'`"
echo "		`grep 72-143 $new | awk '{print $NF}' | add | awk -v c=$count '{printf "%d", $1/c}'`"

echo -n "CPU Utililization	`grep 'Local CPU:' $org | awk '{print $NF}' | grep -o '[0-9.]*' | add | awk -v c=$count '{printf "%.2f", $1/c}'`"
echo "		`grep 'Local CPU:' $new | awk '{print $NF}' | grep -o '[0-9.]*' | add | awk -v c=$count '{printf "%.2f", $1/c}'`"

echo -n "Number IPI's/sec	`grep 'Local IPI' $org | awk '{print $NF}' | grep -o '[0-9.]*' | add | awk -v c=$count '{printf "%d", $1/c}'`"
echo "		`grep 'Local IPI' $new | awk '{print $NF}' | grep -o '[0-9.]*' | add | awk -v c=$count '{printf "%d", $1/c}'`"

sent_org=`grep "Packets sent" $org | awk '{print $NF}' | add | awk -v c=$count '{printf "%d", $1/c}'`
sent_new=`grep "Packets sent" $new | awk '{print $NF}' | add | awk -v c=$count '{printf "%d", $1/c}'`
echo "Packets sent		$sent_org	$sent_new"

rcvd_org=`grep "Packets received" $org | awk '{print $NF}' | add | awk -v c=$count '{printf "%d", $1/c}'`
rcvd_new=`grep "Packets received" $new | awk '{print $NF}' | add | awk -v c=$count '{printf "%d", $1/c}'`
echo "Packets recvd		$rcvd_org	$rcvd_new"

drop_org=`grep "Packets dropped" $org | awk '{print $NF}' | add | awk -v c=$count '{printf "%d", $1/c}'`
drop_new=`grep "Packets dropped" $new | awk '{print $NF}' | add | awk -v c=$count '{printf "%d", $1/c}'`
echo "Packets dropped		$drop_org		$drop_new"

retran_org=`grep "Segments retr" $org | awk '{print $NF}' | add | awk -v c=$count '{printf "%d", $1/c}'`
retran_new=`grep "Segments retr" $new | awk '{print $NF}' | add | awk -v c=$count '{printf "%d", $1/c}'`
echo "Segments retransmitted	$retran_org		$retran_new"

soft_org=`grep "Total NET_RX" $org | awk '{print $NF}' | add`
soft_new=`grep "Total NET_RX" $new | awk '{print $NF}' | add`
echo "SoftIRQ events		$soft_org	$soft_new"

# Very specific to aRFS, can comment out unless aRFS metrics in kernel.
x1=`grep "aRFS Add:" $org | awk '{print $5}' | add | awk -v c=$count '{printf "%d", $1/c}'`
x2=`grep "aRFS Add:" $org | awk '{print $7}' | add | awk -v c=$count '{printf "%d", $1/c}'`
x3=`grep "aRFS Add:" $new | awk '{print $5}' | add | awk -v c=$count '{printf "%d", $1/c}'`
x4=`grep "aRFS Add:" $new | awk '{print $7}' | add | awk -v c=$count '{printf "%d", $1/c}'`
echo "aRFS Skip		$x1		$x3"
echo "aRFS Update		$x2		$x4"

echo -n "Wrong aRFS avoided	`grep Wrong $org | awk '{print $NF}' | grep -o "[0-9.]*" | add | awk -v c=$count '{printf "%d", $1/c}'`"
echo "		`grep Wrong $new | awk '{print $NF}' | grep -o "[0-9.]*" | add | awk -v c=$count '{printf "%d", $1/c}'`"

echo -n "Total aRFS events	`grep "Total aRFS" $org | awk '{print $NF}' | grep -o "[0-9.]*" | add | awk -v c=$count '{printf "%d", $1/c}'`"
echo "		`grep "Total aRFS" $new | awk '{print $NF}' | grep -o "[0-9.]*" | add | awk -v c=$count '{printf "%d", $1/c}'`"

echo "------------------------------------------------------"
