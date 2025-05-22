#!/bin/bash

if [ $# -eq 0 ]
then
	echo "$0: ip {tm} {dev} {iters} {conn}"
	exit 1
fi

. ./env

ip=$1
tm=60
dev=`ip r | grep default | awk '{print $5}'`
iters=1
procs=16

if [ $# -gt 1 ]
then
	tm=$2
	if [ $# -gt 2 ]
	then
		dev=$3
		if [ $# -gt 3 ]
		then
			iters=$4
			if [ $# -gt 4 ]
			then
				procs=$5
			fi
		fi
	fi
fi

echo "Dest: $ip Dev: $dev Time: $tm Iters: $iters Procs: $procs"

mkdir -p Results

for i in `seq 1 $iters`
do
	echo "------------- Iteration: $i ----------------"

	# Clear metrics (comment if no sysctl added in code).
	sudo $TEST_DIR/sysctl.sh 0 > /dev/null

	# Metrics runs for 5 more seconds to capture any outliers.
	new_tm=$((tm+5))

	$TEST_DIR/drops.sh $new_tm $dev > /tmp/drops.$$ &
	$TEST_DIR/softirq.sh $new_tm > /tmp/softirq.$$ &
	$TEST_DIR/total_pkts.sh $new_tm $dev > /tmp/total_pkts.$$ &
	$TEST_DIR/retrans.sh $new_tm > /tmp/retrans.$$ &

	# Not required, we get this from softirq.sh already
	# $TEST_DIR/pkts_netrx.sh $new_tm $dev > /tmp/pkts_netrx.$$ &
	sleep 0.1

	$TEST_DIR/netperf_test.sh $ip $procs $tm TCP_STREAM 1024 \
				$dev > /tmp/result.$$ 2>&1 &
	wait

	sleep 0.5
	(
		cat /tmp/result.$$
		echo
		cat /tmp/softirq.$$
		cat /tmp/total_pkts.$$
		cat /tmp/retrans.$$
		cat /tmp/drops.$$
		# cat /tmp/pkts_netrx.$$

		$TEST_DIR/save_arfs.sh 0
	) > Results/run_iter_$i.out

	rm -f /tmp/result.$$ /tmp/softirq.$$ /tmp/total_pkts.$$ /tmp/retrans.$$ /tmp/pkts_netrx.$$ /tmp/drops.$$
	sleep 10
done
