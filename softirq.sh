#!/bin/bash

# Usage: ./net_rx_diff.sh <interval_seconds>
tm=${1:-1}	# default to 1 second if not specified

. ./env

# Function to extract NET_RX counts as an array
get_net_rx_counts()
{
	grep NET_RX /proc/softirqs | awk -F: '{print $2}' \
		| tr -s ' ' '\n' | tail -n +2
}

# RATE=500
# RATE is not important. We will just add up softirqs for 0-71 and 72-143 later.
RATE=0
min_exp=$((tm * RATE))

# Function to get the sum of RX softirqs
get_softirqs() {
	grep NET_RX /proc/softirqs | awk \
		'{sum=0; for(i=2; i<=NF; i+=2) sum+=$i} END {print sum}'
}

# Get initial softirqs count
rx1=($(get_net_rx_counts))
# initial_softirqs=$(get_softirqs)

# Sleep for the specified time
sleep $tm

# Second snapshot
rx2=($(get_net_rx_counts))
# final_softirqs=$(get_softirqs)

# Calculate the softirqs per second
# softirqs_per_second=$(( (final_softirqs - initial_softirqs) / tm ))
# echo "NETIF_RX Softirqs processed per second: $softirqs_per_second"

# Output header
echo "CPU Softirqs processed (over ${tm}s)"
echo "-------------------------------"

# Calculate per-CPU number of softirqs
for ((i=0; i<${#rx1[@]}; i++))
do
	diff=$(( ${rx2[$i]} - ${rx1[$i]} ))
	if [ $diff -ge $min_exp ]
	then
		printf "%3d  %'12d events\n" "$i" "$diff"
	fi
done
