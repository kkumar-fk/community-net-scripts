#!/bin/bash

reset=0
if [ $# -eq 1 ]
then
	reset=1
fi

cd /proc/sys/net
 
for i in *arfs*
do
	f=`basename $i`
	echo "$f: `cat $i`"
	if [ $reset -eq 1 ]
	then
		if [ "$i" == "arfs_fix" ]
		then
			echo "Skipping $i"
		else
			echo 0 > $i
		fi
	fi
done
