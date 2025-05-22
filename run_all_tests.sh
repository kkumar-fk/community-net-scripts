#!/bin/bash

tm=180
dev=`ip r | grep default | awk '{print $5}'`

if [ $# -eq 0 ]
then
	echo "$0: ip <tm> <dev>"
	exit 1
fi

ip=$1
if [ $# -gt 1 ]
then
	tm=$2
	if [ $# -gt 2 ]
	then
		dev=$3
	fi
fi

. ./env

# If required, change this to have larger port range.
# sudo sysctl -w net.ipv4.ip_local_port_range="8000 65535"

iters=1

# CONN="1024 2048 4096 8192"
# RPS="512 1024 1024"
CONN="64 128 1024"
RPS="512 1024 1024"

# Comment out if testing different kernels but this is kept here in
# case the kernel was modified to add a new sysctl that switches path
# dynamically.
# Set to 0 for original kernel, and non-zero for fixed kernel.
# arfs_fix=0
# echo $arfs_fix | sudo tee /proc/sys/net/arfs_fix

for conn in $CONN
do
	for rps in $RPS
	do
		$TEST_DIR/set_irq_xps_arfs.sh $rps
		echo "--------- Running with conn:$conn RPS: $rps -----------"
		$TEST_DIR/test_with_metrics.sh $ip $tm $dev $iters $conn

		# Rename files with proper tags.
		# TODO: This can be done in test_with_metrics.sh
		cd Results
		for i in `seq 1 $iters`
		do
			mv run_iter_"$i".out \
				conns_"$conn"_rps_"$rps"_iter_"$i".out
		done
		cd ..
	done
	echo "---------------------------------------------------------"
	sleep 5
done
