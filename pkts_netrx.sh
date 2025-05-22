#!/bin/bash

# Check for correct number of arguments
if [ $# -eq 0 ]
then
	echo "Usage: $0: <seconds> {dev}"
	exit 1
fi

tm=$1

if [ $# -gt 1 ]
then
	dev=$2
else
	dev=`ip r | grep default | awk '{print $5}'`
fi

# Function to get RX packets from /proc/net/dev for $dev
get_rx_packets()
{
	grep $dev /proc/net/dev | awk '{print $3}' || {
		echo "Error: Interface $dev not found."
		exit 1
	}
}

# Function to get NET_RX events from /proc/softirqs
get_net_rx_events()
{
	# Sum NET_RX counts across all CPUs
	grep NET_RX /proc/softirqs | awk '{sum=0; for(i=2;i<=NF;i++) sum+=$i; print sum}' || {
		echo "Error reading /proc/softirqs."
		exit 1
	}
}

# Get initial values
initial_nic_packets=$(get_rx_packets)
initial_net_rx_events=$(get_net_rx_events)

# Wait for $tm seconds
sleep $tm

# Get final values
final_nic_packets=$(get_rx_packets)
final_net_rx_events=$(get_net_rx_events)

# Calculate differences
total_nic_packets=$((final_nic_packets - initial_nic_packets))
total_net_rx_events=$((final_net_rx_events - initial_net_rx_events))
ratio=$((total_nic_packets / total_net_rx_events))

# Print results
echo "Total packets RX'd (/proc/net/dev): $total_nic_packets"
echo "Total NET_RX events (/proc/softirqs): $total_net_rx_events"
echo "#packets per event: $ratio"
