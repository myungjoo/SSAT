#!/usr/bin/env bash

if [[ "$SSATAPILOADED" == "1" ]]
then
	echo "Loaded"
else
	echo "Not Loaded"
fi
testInit

testResult 1 T1 "Dummy Test 1"
testResult 1 T2 "Dummy Test 2"
testResult 0 T3 "Dummy Test 3" 1


report
