#!/bin/bash

rm -f /tmp/netp.*

if [ $# -lt 5 ]
then
	echo "Server Procs Time TCP_STREAM/TCP_RR Size {dev}"
	exit 1
fi

. ./env

server=$1
procs=$2
tm=$3
ttype=$4
size=$5

if [ $# -gt 5 ]
then
	dev=$6
else
	dev=`ip r | grep default | awk '{print $5}'`
fi

# Let tests warm up to steady state before we start getting metrics.
if [ $tm -gt 60 ]
then
	measure_tm=$((((tm-2))-5))
	sleep_time=5
else
	measure_tm=$((tm-4))
	sleep_time=2
fi

echo "Sleep for $sleep_time and measure for $measure_tm"

# Maximum local & remote CPUs to use.
lcpus=`nproc`
rcpus=`nproc`

# Temporarily use 72 cores on client for testing aRFS. Comment out for
# normal benchmarks.
# lcpus=72

function run_stream()
{
	echo "---------- Running $procs TCP_STREAM, size = $size ----------"

	lcpu=0
	rcpu=0
	for i in `seq 1 $procs`
	do
		netperf -T $lcpu,$rcpu -t TCP_STREAM -l $tm -H $server -- \
			-m $size | tail -1 > /tmp/netp.$i.$$ 2>&1 &
		sleep 0.001	# Let netperf start connecting atleast.

		lcpu=$((lcpu+1))
		if [ $lcpu == $lcpus ]
		then
			lcpu=0
		fi
		rcpu=$((rcpu+1))
		if [ $rcpu == $rcpus ]
		then
			rcpu=0
		fi
	done
}

function run_rr()
{
	echo "------------ Running $procs TCP_RR, size = $size -------------"

	lcpu=0
	rcpu=0
	for i in `seq 1 $procs`
	do
		netperf -T $lcpu,$rcpu -t TCP_RR -l $tm -H $server -- \
			-r $size -D | tail -2 | head -1 > /tmp/netp.$i.$$ 2>&1 &
		sleep 0.001	# Let netperf start connecting atleast.

		lcpu=$((lcpu+1))
		if [ $lcpu == $lcpus ]
		then
			lcpu=0
		fi
		rcpu=$((rcpu+1))
		if [ $rcpu == $rcpus ]
		then
			rcpu=0
		fi
	done
}

if [ "$ttype" == "TCP_STREAM" ]
then
	run_stream
elif [ "$ttype" == "TCP_RR" ]
then
	run_rr
else
	echo "Unknown test: $ttype"
	exit 1
fi

# Let the tests get started before we start measuring utilization/metrics.
sleep $sleep_time

$TEST_DIR/system_util.sh $measure_tm a > /tmp/cpu.local 2>&1 &
$TEST_DIR/pkts.sh $measure_tm $dev > /tmp/pkts.local 2>&1 &
$TEST_DIR/ipi.sh $measure_tm > /tmp/ipi.local 2>&1 &

# Don't need metrics from remote at this time.
# ssh $server $TEST_DIR/system_util.sh \
#	$measure_tm a > /tmp/cpu.remote 2>&1 &
# ssh $server $TEST_DIR/pkts.sh $measure_tm > /tmp/pkts.remote 2>&1 &
# ssh $server $TEST_DIR/ipi.sh $measure_tm > /tmp/ipi.remote 2>&1 &

wait

if [ "$ttype" == "TCP_STREAM" ]
then
	bw=`awk '{print $NF}' /tmp/netp.* | add`
	echo "BW for $procs processes: $bw"
else
	pps=`awk '{print $NF}' /tmp/netp.* | cut -d. -f1 | add`
	avg_pps=$((pps/procs))
	avg_latency=`echo "scale=2; (1000000/$avg_pps)" | bc -l`
	echo "Total PPS for $procs processes: $pps"
	echo "Average PPS for 1 process: $avg_pps latency: $avg_latency"
fi

echo "Local Packets Per Queue (via 'ethtool -S')"
cat /tmp/pkts.local | sed 's/^/	/'
echo "Local IPI's: `cat /tmp/ipi.local`"
echo "Local CPU utilization: `cat /tmp/cpu.local`"

rm -f /tmp/ipi.local /tmp/cpu.local /tmp/pkts.local

# echo "Remote Packets Per Queue:"
# cat /tmp/pkts.remote | sed 's/^/	/'
# echo "Remote IPI's: `cat /tmp/ipi.remote`"
# echo "Remote CPU utilization: `cat /tmp/cpu.remote`"

echo "------------------------------------------------------------------------"
