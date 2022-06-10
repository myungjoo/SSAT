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

command -v gst-launch-1.0 || report
command -v gst-inspect-1.0 || report

filename=$(mktemp)
gstTestBackground "videotestsrc num-buffers=5 is-live=true  ! video/x-raw,width=64,height=48,framerate=1/1 ! filesink location=${filename}" GBKG1 0 0 5
testResult 1 GBKG1-AFT "After launching the background" 0
wait $pid
testResult 1 GBKG1-CMP "After the background is completed" 0

gst-inspect-1.0 udpsrc &> /dev/null
val=$?
if [ "${val}" == "0" ]; then
	gstTestBackground "udpsrc ! video/x-raw,width=64,height=48,framerate=1/1 ! fakesink async=false" GBKG2 0 0 5
	testResult 1 GBKG2-AFT "After launching the background" 0
	kill $pid
	testResult 1 GBKG2-CMP "After the background is killed" 0

	gstTestBackground "udpsrc ! video/x-raw,width=64,height=48,framerate=1/1 ! fakesink" GBKG3 0 1 5
	testResult 1 GBKG3-AFT "After launching the background" 0
	kill $pid
	testResult 1 GBKG3-CMP "After the background is killed" 0
else
	testResult 0 GBKG2 "udpsrc-based gst background test failed: udpsrc not found: gst-inspect returns ${val}." 1
fi


report
