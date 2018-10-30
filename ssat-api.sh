#!/usr/bin/env bash
##
# @file ssat-api.sh
# @author MyungJoo Ham <myungjoo.ham@gmail.com>
# @date Jun 22 2018
# @license Apache-2.0
# @brief This is API set for SSAT (Shell Script Automated Tester)
#

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

function writef {
	if [[ "${SILENT}" == "0" ]]
	then
		printf "$1\n"
	fi
	ResultLog="$ResultLog$1\n"
}

##
# @brief Report results of a test group (a "runTest.sh" in a testee directory)
#
function report {
	if (( ${_fail} == 0 ))
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
			writef "${LightGreen}[PASSED]${NC} Test Group $_group has ${Red}failed cases ($_fail), but they are not critical.${NC}"
		fi
	fi

	if [[ "$INDEPENDENT" -eq "1" ]]
	then
	# do nothing
		echo ""
	else
		writef "${_cases},${_pass},${_fail}"
		echo "${ResultLog}" > $_filename
		printf "$_filename\n"
	fi

	if (( ${_criticalFail} > 0 ))
	then
		exit 1
	else
		exit 0
	fi
}

function testInit {
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

##
# @brief Write Test Log
# @param $1 1 = success / 0 = fail
# @param $2 test case ID (short string)
# @param $3 test case description
# @param $4 set 1 if this is not critical (don't care if it's pass or fail)_
function testResult {
	_cases=$((_cases+1))
	if [[ "${1}" == "1" ]]
	then
		writef "${LightGreen}[PASSED]${NC} ${Green}$2${NC}:$3${NC}"
		_pass=$((_pass+1))
	else
		_fail=$((_fail+1))
		if [[ "${4}" == "1" ]]
		then
			writef "${Purple}[FAILED][Ignorable] $2${NC}:${Purple}$3${NC}"
		else
			writef "${Red}[FAILED][Critical] $2${NC}:${Purple}$3${NC}"
			_criticalFail=$((_criticalFail+1))
		fi
	fi
}

##
# @brief Call Test Case (a shell script), expected exit = 0
# @param $1 Full path to the executable (e.g., ~/script/a1.sh)
# @param $2 Full string of the arguments to $1 (e.g., "-q -n --dryrun")
# @param $3 test case ID
# @param $4 test case description
# @param $5 set 1 if this is not critical (don't care if it's pass or fail)_
function callTestSuccess {
	callutput=$(. $1 $2)
	retcode=$?
	if (( ${retcode} == 0 ))
	then
		testResult 1 "$3" "$4" $5
	else
		testResult 0 "$3" "$4 ret($retcode)" $5
	fi
}

##
# @brief Call Test Case (a shell script), expected exit != 0
# @param $1 Full path to the executable (e.g., ~/script/a1.sh)
# @param $2 Full string of the arguments to $1 (e.g., "-q -n --dryrun")
# @param $3 test case ID
# @param $4 test case description
# @param $5 set 1 if this is not critical (don't care if it's pass or fail)_
function callTestFail {
	callutput=$(. $1 $2)
	retcode=$?
	if (( ${retcode} != 0 ))
	then
		testResult 1 "$3" "$4 ret($retcode)" $5
	else
		testResult 0 "$3" "$4" $5
	fi
}

##
# @brief Call Test Case (a shell script), expected exit == $5
# @param $1 Full path to the executable (e.g., ~/script/a1.sh)
# @param $2 Full string of the arguments to $1 (e.g., "-q -n --dryrun")
# @param $3 test case ID
# @param $4 test case description
# @param $5 Expected exit code.
# @param $6 set 1 if this is not critical (don't care if it's pass or fail)_
function callTestExitEq {
	callutput=$(. $1 $2)
	retcode=$?
	if (( ${retcode} == $5 ))
	then
		testResult 1 "$3" "$4" $6
	else
		testResult 0 "$3" "$4 ret($retcode)" $6
	fi
}

##
# @brief Compare two result files expected to be equal
# @param $1 Path to result 1 (golden)
# @param $2 Path to result 2 (test run)
# @param $3 test case ID
# @param $4 test case description
# @param $5 0 if the size is expected to be equal as well. 1 if golden (result 1) might be smaller (will ignore rest of result 2). 2 if the opposite of 1. If $5 > 2, it denotes the max size of compared bytes. (compare the first $5 bytes only)
# @param $6 set 1 if this is not critical (don't care if it's pass or fail)_
function callCompareTest {
	# Try cmp.
	command -v cmp
	if (( $? == 0 ))
	then
		# use cmp
		echo NYI
	else
		# use internal logic (slower!)
		echo NYI
	fi
	echo NYI
}

SSATAPILOADED=1
