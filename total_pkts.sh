#!/bin/bash

if [ $# -eq 0 ]
then
	echo "Time {dev}"
	exit 1
fi

tm=$1

if [ $# -eq 2 ]
then
	dev=$2
else
	dev=`ip r | grep default | awk '{print $5}'`
fi

# Function to extract RX packets
get_rx_packets()
{
	grep "$dev" /proc/net/dev | awk '{print $3}'
}

get_tx_packets()
{
	grep "$dev" /proc/net/dev | awk '{print $11}'
}

# Get initial RX/TX packets
rx_start=$(get_rx_packets)
tx_start=$(get_tx_packets)

sleep $tm

# Get final RX packets
rx_end=$(get_rx_packets)
tx_end=$(get_tx_packets)

# Calculate result
rx_diff=$((rx_end - rx_start))
tx_diff=$((tx_end - tx_start))

echo "Packets sent: $tx_diff"
echo "Packets received: $rx_diff"
