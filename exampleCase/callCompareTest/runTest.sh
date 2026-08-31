#!/usr/bin/env bash
##
## @file runTest.sh
## @brief Test group for callCompareTest itself
## @details
## callCompareTest compares a prefix of two files when mode is 1, 2, or a byte
## count. That prefix comparison used to be delegated to "cmp -n", which behaves
## differently across implementations: BSD cmp decides whether two files differ
## from their full sizes and so rejects any size mismatch even when -n limited
## the comparison. These cases pin the intended behaviour on every platform.
##
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

printf 'ABCDEFGHIJ' > long.dat
printf 'ABCDE' > prefix.dat
printf 'ABCxE' > mismatch.dat
printf 'ABCDEFGHIJ' > long_copy.dat

## @fn expectNoMatch()
## @brief Assert that callCompareTest reports a mismatch
## @param $1 first file, $2 second file, $3 mode, $4 case ID, $5 description
function expectNoMatch() {
	local result
	# Run the comparison in a subshell so that only this assertion is reported.
	result=$( callCompareTest $1 $2 "$4" "$5" $3 1 > /dev/null; echo ${output} )
	testResult ${result} "$4" "$5" 0 1
}

callCompareTest prefix.dat long.dat 1-1 "mode 1: golden is a prefix of the test run" 1 0
expectNoMatch mismatch.dat long.dat 1 1-2_n "mode 1: a difference inside the compared range is detected"
expectNoMatch long.dat prefix.dat 1 1-3_n "mode 1: a test run shorter than the golden is detected"

callCompareTest long.dat prefix.dat 2-1 "mode 2: test run is a prefix of the golden" 2 0
expectNoMatch long.dat mismatch.dat 2 2-2_n "mode 2: a difference inside the compared range is detected"

callCompareTest long.dat long_copy.dat 3-1 "mode 0: identical files" 0 0
expectNoMatch prefix.dat long.dat 0 3-2_n "mode 0: a prefix is not accepted"

callCompareTest mismatch.dat long.dat 4-1 "mode N: only the first N bytes are compared" 3 0
expectNoMatch mismatch.dat long.dat 5 4-2_n "mode N: a difference within N bytes is detected"

expectNoMatch nosuchfile.dat long.dat 1 5-1_n "a missing file is detected"

rm -f long.dat prefix.dat mismatch.dat long_copy.dat

report
