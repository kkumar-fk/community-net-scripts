#!/bin/bash

if [ $# -ne 1 ]
then
	echo "TIME"
	exit 1
fi

start=`netstat -s | grep -i "segments retransmitted" | awk '{print $1}'`
sleep $1
end=`netstat -s | grep -i "segments retransmitted" | awk '{print $1}'`
diff=$((end - start))
echo "Segments retransmitted: $diff"
