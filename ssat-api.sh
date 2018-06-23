#!/usr/bin/env bash
##
# @file ssat-api.sh
# @author MyungJoo Ham <myungjoo.ham@gmail.com>
# @date Jun 22 2018
# @license Apache-2.0
# @brief This is API set for SSAT (Shell Script Automated Tester)
#

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

##
# @brief Report results of a test group (a "runTest.sh" in a testee directory)
# @param $1 # total test cases
# @param $2 # total success cases
# @param $3 # test log
# @param $4 # print outs from test (stdout)
#
function report {
	echo NYI
}

##
# @brief Write Test Log
# @param $1 1 = success / 0 = fail
# @param $2 test case ID (short string)
# @param $3 test case description
function testResult {
	echo NYI
}

##
# @brief Call Test Case (a shell script), expected exit = 0
# @param $1 Full path to the executable (e.g., ~/script/a1.sh)
# @param $2 Full string of the arguments to $1 (e.g., "-q -n --dryrun")
# @param $3 test case ID
# @param $4 test case description
function callTestSuccess {
	echo NYI
}

##
# @brief Call Test Case (a shell script), expected exit != 0
# @param $1 Full path to the executable (e.g., ~/script/a1.sh)
# @param $2 Full string of the arguments to $1 (e.g., "-q -n --dryrun")
# @param $3 test case ID
# @param $4 test case description
function callTestFail {
	echo NYI
}

##
# @brief Call Test Case (a shell script), expected exit == $5
# @param $1 Full path to the executable (e.g., ~/script/a1.sh)
# @param $2 Full string of the arguments to $1 (e.g., "-q -n --dryrun")
# @param $3 test case ID
# @param $4 test case description
# @param $5 Expected exit code.
function callTestExitEq {
	echo NYI
}

##
# @brief Compare two result files expected to be equal
# @param $1 Path to result 1 (golden)
# @param $2 Path to result 2 (test run)
# @param $3 test case ID
# @param $4 test case description
# @param $5 0 if the size is expected to be equal as well. 1 if golden (result 1) might be smaller (will ignore rest of result 2). 2 if the opposite of 1. If $5 > 2, it denotes the max size of compared bytes. (compare the first $5 bytes only)
function callCompareTest {
	echo NYI
}

SSATAPILOADED=1
