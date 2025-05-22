#!/bin/bash

# Give utilization of cores:
#	1. If no arguments, give the utilization of ALL cores.
#	2. If argument is "a" (stands for "all"), give the utilization of
#	   ALL cores.
#	3. Else give utilization for specific cores only. e.g., given
#	   ./system_util.sh 1 3 5, this calculates for cores 1, 3 and 5.

if [ $# -eq 0 ]
then
	echo "<Sleep-time> <'a' or {cpu1 <cpu2...>}"
	exit 1
fi

. ./env

tm=$1
str=""

if [ $# -eq 1 ]
then
	# No arguments - give the utilization of ALL cores. The space at
	# the end of "cpu " is important.
	str="cpu "
else
	if [ "$2" == "a" ]
	then
		# Give the utilization of ALL cores. The space at the end
		# of "cpu " is important.
		str="cpu "
	else
		# Else give utilization for specific cores only.
		# e.g., given ./system_util.sh 1 3 5, this calculates for
		# cores 1, 3 and 5.
		for i in $*
		do
			str="$str""cpu$i "
			shift 1
			if [ $# -gt 0 ]
			then
				str="$str""|"
			fi
		done
	fi
fi

# Let the test warm up by sleeping for a second.
sleep 1

egrep "$str" /proc/stat > /tmp/cpu.start.$$
sleep $tm
egrep "$str" /proc/stat > /tmp/cpu.end.$$

us1=`awk '{print $2}' /tmp/cpu.start.$$ | add`
sy1=`awk '{print $4}' /tmp/cpu.start.$$ | add`
sirq1=`awk '{print $8}' /tmp/cpu.start.$$ | add`

us2=`awk '{print $2}' /tmp/cpu.end.$$ | add`
sy2=`awk '{print $4}' /tmp/cpu.end.$$ | add`
sirq2=`awk '{print $8}' /tmp/cpu.end.$$ | add`

us=$((((us2-us1))/$tm))
sy=$((((sy2-sy1))/$tm))
sirq=$((((sirq2-sirq1))/$tm))
total=$((((us + sy)) + sirq))
total_cpus=`echo "scale=2; $total/100" | bc -l`

echo "User: $us System: $sy Softirq: $sirq CPU: $total ($total_cpus)"
rm -f /tmp/*.$$

exit 0
