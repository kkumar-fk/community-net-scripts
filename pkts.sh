#!/bin/bash

if [ $# -eq 0 ]
then
	echo "sleep-time [optional devname]"
	exit 1
fi

tm=$1
RATE=500
min_exp=$((tm * RATE))

if [ $# -gt 1 ]
then
	dev=$2
else
	dev=`ip r | grep default | awk '{print $5}'`
fi

sudo ethtool -S $dev > /tmp/start.$$
sleep $tm
sudo ethtool -S $dev > /tmp/end.$$

# Most modern OS have consistent naming of following tx and rx pkts,
# but if different, then this needs to be fixed.
grep "tx.*packets" /tmp/start.$$ | awk '{print $NF}' > /tmp/start_tx.$$
grep "tx.*packets" /tmp/end.$$   | awk '{print $NF}' > /tmp/end_tx.$$
grep "rx.*packets" /tmp/start.$$ | awk '{print $NF}' > /tmp/start_rx.$$
grep "rx.*packets" /tmp/end.$$   | awk '{print $NF}' > /tmp/end_rx.$$

paste -d- /tmp/end_tx.$$ /tmp/start_tx.$$ | bc -l > /tmp/diff_tx.$$
paste -d- /tmp/end_rx.$$ /tmp/start_rx.$$ | bc -l > /tmp/diff_rx.$$

(
echo "-------- TX --------"
txq=0
cat /tmp/diff_tx.$$ | while read num
do
	if [ $num -gt $min_exp ]
	then
		num=$((num / tm))
		echo "TXq#: $txq pkt-rate: $num"
	fi
	txq=$((txq+1))
done
) > /tmp/out.tx.$$

(
echo "-------- RX --------"
rxq=0
cat /tmp/diff_rx.$$ | while read num
do
	if [ $num -gt $min_exp ]
	then
		num=$((num / tm))
		echo "RXq#: $rxq pkt-rate: $num"
	fi
	rxq=$((rxq+1))
done
) > /tmp/out.rx.$$

for i in {0..143}
do
	t=`grep "TXq#: $i " /tmp/out.tx.$$`
	r=`grep "RXq#: $i " /tmp/out.rx.$$`

	bad=0
	if [ -z "$t" ]
	then
		bad=$((bad+1))
		t="No-TX"
	fi

	if [ -z "$r" ]
	then
		bad=$((bad+1))
		r="No-RX"
	fi

	if [ $bad != 2 ]
	then
		echo "$t		$r"
	fi
done

rm -f /tmp/out.tx.$$ /tmp/out.rx.$$
rm -f /tmp/start*.$$ /tmp/end*.$$ /tmp/diff*.$$
