#!/bin/bash

# If any argument is passed, clear the sysctl's we added.
arg=""
if [ $# -gt 0 ]
then
	arg="0"
fi

. ./env

# Comment if no sysctl added in code.
sudo $TEST_DIR/sysctl.sh $arg > /tmp/save.$$

arfs_added=`grep -w kk_arfs_added /tmp/save.$$ | awk '{print $NF}'`
arfs_updated=`grep -w kk_arfs_updated /tmp/save.$$ | awk '{print $NF}'`
arfs_skipped=`grep -w kk_arfs_skipped /tmp/save.$$ | awk '{print $NF}'`
arfs_del=`grep -w kk_arfs_del /tmp/save.$$ | awk '{print $NF}'`
wrong_entry=`grep -w kk_wrong_entry /tmp/save.$$ | awk '{print $NF}'`

rm -f /tmp/save.$$

echo "aRFS Add: $arfs_added Update: $arfs_updated Skip: $arfs_skipped Del: $arfs_del"
echo "Wrong Entry Avoided: $wrong_entry"
