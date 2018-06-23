#!/usr/bin/env bash

echo $SSATAPILOADED

if [ "$SSATAPILOADED" == "1" ]
then
	echo "Loaded"
else
	echo "Not Loaded"
fi

report ${passed} ${total}
