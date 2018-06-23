#!/usr/bin/env bash
##
# @file ssat.sh
# @author MyungJoo Ham <myungjoo.ham@gmail.com>
# @date Jun 22 2018
# @license Apache-2.0
# @brief This executes test groups and reports aggregated test results.
# @exit 0 if all PASSED. Positive if some FAILED.
#
# If there is no arguments specified, this will search for all "runTest.sh" in
# the subdirectory of this file and regard them as the test groups.
#
# If --help or -h is given, this will show detailed description.

TARGET=$(pwd)
BASEPATH=`dirname "$0"`
BASENAME=`basename "$0"`
TESTCASE="runTest.sh"
source ${BASEPATH}/ssat-api.sh

#
DOTEST=1
SILENT=1

# Handle arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
	-h|--help)
		printf "usage: ${BASENAME} [--help] [<path>] [--testcase <filename>]\n\n"
		printf "These are common ${Red}ssat${NC} commands used:\n\n"
		printf "Test all test-groups in the current ($(pwd)) directory, recursively\n"
		printf "    (no options specified)\n"
		printf "    $ ${BASENAME}\n"
		printf "\n"
		printf "Test all test-groups in the specified directory, recursively\n"
		printf "    <path>\n"
		printf "    $ ${BASENAME} /home/username/test\n"
		printf "    If there are multiple paths, the last one will be used\n"
		printf "\n"
		printf "Search for \"filename\" as the testcase scripts\n"
		printf "    --testcase or -t\n"
		printf "    $ ${BASENAME} --testcase cases.sh\n"
		printf "    Search for cases.sh instead of runTest.sh\n"
		printf "\n"
		printf "Shows this message\n"
		printf "    --help or -h\n"
		printf "    $ ${BASENAME} --help \n"
		printf "\n\n"
		exit 0
	;;
	-t|--testcase)
	TESTCASE="$2"
	shift
	shift
	;;
	*) # Unknown, which is probably target (the path to root-dir of test groups).
	TARGET="$1"
	esac
done

if [[ ${#TARGET} -eq 0 ]]
then
	TARGET="."
fi

find $TARGET -name $TESTCASE -print0 | while read -d $'\0' file
do
	CASEBASEPATH=`dirname "$file"`
	pushd $CASEBASEPATH
	source $file
	popd
done
		

# gather reports & publish them.
