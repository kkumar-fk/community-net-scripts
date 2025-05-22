#!/bin/bash

. ./env

rps_cnt=512
if [ $# -eq 1 ]
then
	rps_cnt=$1
fi

dev=`ip r | grep default | awk '{print $5}'`

echo "Using $rps_cnt as arfs rps_flow_cnt value"
sudo $TEST_DIR/set_irq.sh
sudo $TEST_DIR/set_xps.sh
sudo $TEST_DIR/arfs.sh on $dev $rps_cnt
