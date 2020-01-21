#!/usr/bin/env bash
##
## @file ssat-api.sh
## @author MyungJoo Ham <myungjoo.ham@gmail.com>
## @date Jun 22 2018
## @brief This is API set for SSAT (Shell Script Automated Tester)
##

if [[ "$nocolor" != "1" ]]
then
	Black='\033[0;30m'
	DarkGray='\033[1;30m'
	Red='\033[0;31m'
	LightRed='\033[1;31m'
	Green='\033[0;32m'
	LightGreen='\033[1;32m'
	Orange='\033[0;33m'
	Yellow='\033[1;33m'
	Blue='\033[0;34m'
	LightBlue='\033[1;34m'
	Purple='\033[0;35m'
	LightPurple='\033[1;35m'
	Cyan='\033[0;36m'
	LightCyan='\033[1;36m'
	LightGray='\033[0;37m'
	White='\033[1;37m'
	NC='\033[0m'
else
	Black=''
	DarkGray=''
	Red=''
	LightRed=''
	Green=''
	LightGreen=''
	Orange=''
	Yellow=''
	Blue=''
	LightBlue=''
	Purple=''
	LightPurple=''
	Cyan=''
	LightCyan=''
	LightGray=''
	White=''
	NC=''
fi


ResultLog=""

# Platform dependent variables
KernelName=$(uname -s)
if [[ "${KernelName}" == "Darwin" ]]; then
	StatCmd_GetSize="stat -f %z"
	SO_EXT="dylib"
else
	StatCmd_GetSize="stat --printf=%s"
	SO_EXT="so"
fi

## @fn writef()
## @private
## @param $1 the string to be printed.
## @brief Prepare report result
function writef() {
	if [[ "${SILENT}" == "0" ]]
	then
		printf "$1\n"
	fi
	ResultLog="$ResultLog$1\n"
}

## @fn report()
## @brief Report results of a test group (a "runTest.sh" in a testee directory)
function report() {
	if (( ${_fail} == 0 && ${_criticalFail} == 0 ))
	then
		writef "${Green}==================================================${NC}"
		writef "${LightGreen}[PASSED]${NC} Test Group $_group ${Green}Passed${NC}"
	else
		if (( ${_criticalFail} > 0 ))
		then
			writef "${Green}==================================================${NC}"
			writef "${Red}[FAILED]${NC} Test Group $_group has ${Red}failed cases ($_fail)${NC}"
		else
			writef "${Green}==================================================${NC}"
			writef "${LightGreen}[PASSED]${NC} Test Group $_group has ${Red}failed cases ($_fail), but they are ignorable cases and not critical.${NC}"
		fi
	fi

	if [[ "$INDEPENDENT" -eq "1" ]]
	then
	# do nothing
		echo ""
	else
		_ignore=$((_fail-_criticalFail))
		_fail=${_criticalFail}
		writef "${_cases},${_pass},${_fail},${_ignore}"
		echo "${ResultLog}" > ${_filename}
		printf "\n${_filename}\n"
	fi

	if (( ${_criticalFail} > 0 ))
	then
		exit 1
	else
		exit 0
	fi
}

## @fn testInit()
## @brief Initialize runTest.sh shell test case
function testInit() {
	_pass=0
	_fail=0
	_criticalFail=0
	_cases=0
	_filename=$(mktemp)
	_group=`basename "$1"`
	if [[ "${#_group}" -eq "0" ]]
	then
		_group="(Unspecified)"
	fi

	writef "${Green}==================================================${NC}"
	writef "    Test Group ${Green}$_group${NC} Starts."
}

## @fn testResult()
## @brief Write Test Log
## @param $1 1 = success / 0 = fail ($5 is not 1)
## @param $2 test case ID (short string)
## @param $3 test case description
## @param $4 set 1 if this is not critical (don't care if it's pass or fail)_
## @param $5 set 1 if $1==0 is success and $1!=0 is fail.
function testResult() {
	if [[ "${PROGRESS}" -eq "1" ]]
	then
		echo "Case ${2}(${3}) report ${1}" > /dev/stderr
	fi

	_cases=$((_cases+1))
	_good=0
	if [[ "${5}" -eq "1" ]]; then
		if [[ "${1}" -eq "0" ]]; then
			_good=1
		fi
	else
		if [[ "${1}" -eq "1" ]]; then
			_good=1
		fi
	fi

	if [[ "${_good}" -eq "1" ]]
	then
		writef "${LightGreen}[PASSED]${NC} ${Green}$2${NC}:$3${NC}"
		_pass=$((_pass+1))
	else
		_fail=$((_fail+1))
		if [[ "${4}" == "1" ]]
		then
			writef "${Purple}[IGNORED] $2${NC}:${Purple}$3${NC}"
		else
			writef "${Red}[FAILED][Critical] $2${NC}:${Purple}$3${NC}"
			_criticalFail=$((_criticalFail+1))
		fi
	fi
}

## @fn callTestSuccess()
## @brief Call Test Case (a shell script), expected exit = 0
## @param $1 Full path to the executable (e.g., ~/script/a1.sh)
## @param $2 Full string of the arguments to $1 (e.g., "-q -n --dryrun")
## @param $3 test case ID
## @param $4 test case description
## @param $5 set 1 if this is not critical (don't care if it's pass or fail)_
function callTestSuccess() {
	callutput=$(. $1 $2)
	retcode=$?
	if (( ${retcode} == 0 ))
	then
		testResult 1 "$3" "$4" $5
	else
		testResult 0 "$3" "$4 ret($retcode)" $5
	fi
}

## @fn callTestFail()
## @brief Call Test Case (a shell script), expected exit != 0
## @param $1 Full path to the executable (e.g., ~/script/a1.sh)
## @param $2 Full string of the arguments to $1 (e.g., "-q -n --dryrun")
## @param $3 test case ID
## @param $4 test case description
## @param $5 set 1 if this is not critical (don't care if it's pass or fail)_
function callTestFail() {
	callutput=$(. $1 $2)
	retcode=$?
	if (( ${retcode} != 0 ))
	then
		testResult 1 "$3" "$4 ret($retcode)" $5
	else
		testResult 0 "$3" "$4" $5
	fi
}

## @fn callTestExitEq()
## @brief Call Test Case (a shell script), expected exit == $5
## @param $1 Full path to the executable (e.g., ~/script/a1.sh)
## @param $2 Full string of the arguments to $1 (e.g., "-q -n --dryrun")
## @param $3 test case ID
## @param $4 test case description
## @param $5 Expected exit code.
## @param $6 set 1 if this is not critical (don't care if it's pass or fail)_
function callTestExitEq() {
	callutput=$(. $1 $2)
	retcode=$?
	if (( ${retcode} == $5 ))
	then
		testResult 1 "$3" "$4" $6
	else
		testResult 0 "$3" "$4 ret($retcode)" $6
	fi
}

## @fn callCompareTest()
## @brief Compare two result files expected to be equal
## @param $1 Path to result 1 (golden)
## @param $2 Path to result 2 (test run)
## @param $3 test case ID
## @param $4 test case description
## @param $5 0 if the size is expected to be equal as well. 1 if golden (result 1) might be smaller (will ignore rest of result 2). 2 if the opposite of 1. If $5 > 2, it denotes the max size of compared bytes. (compare the first $5 bytes only)
## @param $6 set 1 if this is not critical (don't care if it's pass or fail)_
function callCompareTest() {
	# Try cmp.
	output=0
	command -v cmp
	# If cmp is symlink, then it could be from busybox and it does not support "-n" option
	if [[ $? == 0 && ! -L $(which cmp) ]]
	then
		# use cmp
		if (( $5 == 0 )); then
			# Size should be same as well.
			cmp $1 $2
			output=$?
		elif (( $5 == 1 )); then
			# Compare up to the size of golden
			cmp -n `${StatCmd_GetSize} $1` $1 $2
			output=$?
		elif (( $5 == 2 )); then
			# Compare up to the size of test-run
			cmp -n `${StatCmd_GetSize} $2` $1 $2
			output=$?
		else
			# Compare up to $5 bytes.
			cmp -n `${StatCmd_GetSize} $5` $1 $2
			output=$?
		fi
		if (( ${output} == 0 )); then
			output=1
		else
			output=0
		fi
		testResult $output "$3" "$4" $6
	else
	    # use internal logic (slower!)
	    bufsize=`${StatCmd_GetSize} $1`
	    if (( $5 == 2 )); then
		bufsize=`${StatCmd_GetSize} $2`
	    else
		bufsize=$5
	    fi
	    diff <(dd bs=1 count=$bufsize if=$1 &>/dev/null) <(dd bs=1 count=$bufsize if=$2 &>/dev/null)
	    output=$?
	    if (( ${output} == 0 )); then
		output=1
	    else
		output=0
	    fi
	    testResult $output "$3" "$4" $6
	fi
}

## @fn gstTest()
## @brief Execute gst-launch with given arguments
## @todo Separate this function to "gstreamer extension plugin"
## @param $1 gst-launch-1.0 Arguments
## @param $2 test case ID
## @param $3 set 1 if this is not critical (don't care if it's pass or fail)
## @param $4 set 1 if this passes if gstLaunch fails.
## @param $5 set 1 to enable PERFORMANCE test.
function gstTest() {
	if [[ "$VALGRIND" -eq "1" ]]; then
		calloutputprefix='valgrind --track-origins=yes'
	fi
	if [[ "${SILENT}" -eq "1" ]]; then
		calloutput=$(eval $calloutputprefix gst-launch-1.0 -f -q $1 &> /dev/null)
	else
		calloutput=$(eval $calloutputprefix gst-launch-1.0 -f -q $1)
	fi

	retcode=$?
	desired=0
	if [[ "${4}" -eq "1" ]]; then
		if [[ "${retcode}" -ne "0" ]]; then
			desired=1
		fi
	else
		if [[ "${retcode}" -eq "0" ]]; then
			desired=1
		fi
	fi

	if [[ "$desired" -eq "1" ]]; then
		testResult 1 "$2" "gst-launch of case $2" $3
	else
		testResult 0 "$2" "gst-launch of case $2" $3
	fi

	if [[ "$5" -eq "1" ]]; then
		if (( ${#GST_DEBUG_DUMP_DOT_DIR} -le 1 )); then
			GST_DEBUG_DUMP_DOT_DIR="./performance"
		fi
		dot -Tpng $GST_DEBUG_DUMP_DOT_DIR/*.PLAYING_PAUSED.dot > $GST_DEBUG_DUMP_DOT_DIR/debug/$base/$2.png
		gst-report-1.0 --dot $GST_DEBUG_DUMP_DOT_DIR/*.gsttrace | dot -Tsvg > $GST_DEBUG_DUMP_DOT_DIR/profile/$base/$2.svg
		rm -f $GST_DEBUG_DUMP_DOT_DIR/*.dot
		rm -f $GST_DEBUG_DUMP_DOT_DIR/*.gsttrace
	fi
}

## @fn convertBMP2PNG()
## @brief Convert all *.bmp to *.png in the current directory
## @todo macronice "bmp2png" searching.
## @todo Separate this function to "gstreamer extension plugin"
function convertBMP2PNG() {
	tool="bmp2png"
	if [ -x bmp2png ]; then
		tool="bmp2png"
	else
		if [ -x ../bmp2png ]; then
			tool="../bmp2png"
		else
			if [ -x ../../bmp2png ]; then
				tool="../../bmp2png"
			else
				tool="../../../bmp2png"
				# Try this and die if fails
			fi
		fi
	fi
	for X in `ls *.bmp`
	do
		if [[ $X  = *"GRAY8"* ]]; then
			$tool $X --GRAY8
		else
			$tool $X
		fi
	done
}

SSATAPILOADED=1
