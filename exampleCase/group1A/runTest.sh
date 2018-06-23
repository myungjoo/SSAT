#!/usr/bin/env bash

if [[ "$SSATAPILOADED" != "1" ]]
then
	echo "Not Loaded"
	SILENT=0
	search="ssat-api.sh"
	source $search

	retcode=$?
	count=0
	while (( ${retcode} != 0 ))
	do
		count=$((count+1))
		if (( ${count} > 5 ))
		then
			break
		fi

		search="../${search}"
		source $search
		retcode=$?
	done
fi

testInit

testResult 1 T1 "Dummy Test 1"
testResult 1 T2 "Dummy Test 2"
testResult 0 T3 "Dummy Test 3" 1

report
