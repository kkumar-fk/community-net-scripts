for i in `ls -tr *.out 2>/dev/null`
do
	echo "--------------------- $i -------------------"

	# For CPU 0-71 and 72-143
	a=`grep -P "RXq#: (?:[0-9]|[1-6][0-9]|7[01])\b" $i  | grep pkt-rate | awk '{print $NF}' | add`
	b=`grep -P "RXq#: (?:7[2-9]|1[0-3][0-9]|14[0-3])\b" $i | grep pkt-rate | awk '{print $NF}' | add`
	if [ -z "$b" ]
	then
		b=1	# Avoid divide by zero
	fi

	r=`echo "scale=1; $a/$b" | bc -l`
	echo "Queues 0-71: $a"
	echo "Queues 72-143: $b"
	echo "Ratio: $r"

	egrep "Packets sent|Packets received|Packets dropped|Segments retr" $i

	awk '{ gsub(",", "", $2);
		if ($1 >= 0 && $1 <= 71) sum1 += $2;
		else if ($1 >= 72 && $1 <= 143) sum2 += $2;
	     }
	     END {
		print "#NET_RX softIRQ events on cores 0-71: " sum1;
		print "#NET_RX softIRQ events on cores 72-143: " sum2;
		print "Total NET_RX softIRQ events: " sum1 + sum2;
	     }' $i

	# net_rx=`grep NET_RX $i | awk '{print $NF}'`
	# echo "Total NET_RX softIRQ events: $net_rx"
	awk '/Local CPU utilization:/ {
		gsub(/[()]/, "", $12);
		printf "Local CPU: User: %s System: %s Softirq: %s", $5, $7, $9;
		printf " Total: %s\n", $12
	}' $i
	ipi=`egrep "Local IPI" $i | awk '{print $(NF-2)$(NF-1)$NF}'`
	echo "Local IPI's: $ipi"

	# Very specific to aRFS, can comment out unless aRFS metrics in kernel.
	grep "aRFS Add: " $i | sed 's/ Del:.*//'
	total1=`grep Wrong $i | awk '{print $NF}'`
	total2=`grep "aRFS Add:" $i | awk '{print $3 + $5 + $7}'`
	echo "Total aRFS entries processed: $((total1 + total2))"

	egrep "Wrong" $i
done
