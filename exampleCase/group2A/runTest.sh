#!/usr/bin/env bash

if [[ "$SSATAPILOADED" != "1" ]]
then
	SILENT=0
	INDEPENDENT=1
	search="ssat-api.sh"
	source $search

	retcode=$?
	count=0
	while (( ${retcode} != 0 ))
	do
		count=$((count+1))
		if (( ${count} > 5 ))
		then
			echo "Cannot find ssat-api.sh"
			exit 1
		fi

		search="../${search}"
		source $search
		retcode=$?
	done
	printf "${Blue}Independent Mode${NC}\n"
fi

testInit $1

testResult 1 TA "Dummy Test A"
testResult 1 TB "Dummy Test B"

report
