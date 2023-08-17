#!/usr/bin/env bash
##
## @file ssat.sh
## @author MyungJoo Ham <myungjoo.ham@gmail.com>
## @date Jun 22 2018
## @brief This executes test groups and reports aggregated test results.
## @return 0 if all PASSED. Positive if some FAILED.
## @todo Separate GStreamer related functions as plugins
##
## This uses sed, date, cmp
##
## If there is no arguments specified, this will search for all "runTest.sh" in
## the subdirectory of this file and regard them as the test groups.
##
## If a testgroup (runTest.sh) returns 0 while there are failed testcase,
## it implies that the failed testcases may be ignored and it's good to go.
##
## If --help or -h is given, this will show detailed description.

##
## @mainpage SSAT
## @section intro        Introduction
## - Introduction     :  Shell Script Automated Tester
## @section Program      Program Name
## - Program Name     :  ssat
## - Program Details  :  SSAT is a software testing framework for test cases written in BASH shell scripts.
##   It can search for test scripts recursively from a given path and summarize the test results.
##   If there is any "critical" fail, ssat will return non-zero values on its exit.
## @section INOUTPUT     Input/output data
## - INPUT            :  Test Cases (If not supplied, the current path is the root of test cases)
## - OUTPUT           :  Summary of test results to stdout. Exit code of 0 if success, non-zero if not success.
## @section CREATEINFO   Code information
## - Initial date     :  2018/06/22
## - Version          :  1.2.0

TARGET=$(pwd)
TARGET_ASSIGNED=0
BASEPATH=`dirname "$0"`
BASENAME=`basename "$0"`
TESTCASE="runTest.sh"
SUMMARYFILENAME=""

#
SILENT=1
PROGRESSLOGLEVEL=0
COUNTNEGATIVE=0
COUNTNEGATIVEPOSTFIX=""
VALGRIND=0
date=`date +"%b %d %Y"`

## @fn createTemplate()
## @brief Generate runTest template file
##
## Note that the generated template has no license.
## The SSAT user may put their own license for the generated files.
## I hereby grant the right to relicense the generated files.
function createTemplate() {
	if [[ -f "runTest.sh" ]]
	then
		printf "Cannot create runTest.sh here. The file already exists at $(pwd).\n\n"
		exit 1
	fi

	echo -e "#!/usr/bin/env bash\n\
##\n\
## @file runTest.sh\n\
## @author MyungJoo Ham <myungjoo.ham@gmail.com>\n\
## @date ${date}\n\
## @brief This is a template file for SSAT test cases. You may designate your own license.\n\
#\n\
if [[ \"\$SSATAPILOADED\" != \"1\" ]]\n\
then\n\
	SILENT=0\n\
	INDEPENDENT=1\n\
	search=\"ssat-api.sh\"\n\
	source \$search\n\
	printf \"\${Blue}Independent Mode\${NC}\\n\"\n\
fi\n\
testInit \$1 # You may replace this with Test Group Name\n\
\n\
#testResult 1 T1 \"Dummy Test1\"\n\
#callTestSuccess gst-launch-1.0 \"-q videotestsrc ! videoconvert ! autovideosink\" T2 \"This may run indefinitely\"\n\
#callCompareTest golden.log executeResult.log T3 \"The two files must be same\" 0\n\
\n\
report\n" > runTest.sh
chmod a+x runTest.sh

	exit 0
}

# Handle arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
	-h|--help)
		printf "usage: ${BASENAME} [--help] [<path>] [--testcase <filename>] [--nocolor] [--showstdout] [--createtemplate] [--countnegative <postfix>] \n\n"
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
		printf "Do not emit colored text\n"
		printf "    --nocolor or -n\n"
		printf "\n"
		printf "Show stdout of test cases\n"
		printf "    --showstdout or -s\n"
		printf "\n"
		printf "Create a template 'runTest.sh' test group at your current directory\n"
		printf "    --createtemplate or -c\n"
		printf "\n"
		printf "Show progress during execution\n"
		printf "    --progress or -p or -p=(0,1,9)\n"
		printf "        '0' : Do not print logs in progress. If -p is not given, -p=0 is assumed.\n"
		printf "        '1' : Print test group names only in progress.\n"
		printf "        '2-9' : Print all logs in progress. If -p is given without numbers, -p=9 is used.\n"
		printf "     $ ${BASENAME} -p=1\n"
		printf "     $ ${BASENAME} --progress=9 (equal to --progress) \n"
		printf "\n"
		printf "Enable valgrind to perform memcheck\n"
		printf "    --enable-valgrind or -vg\n"
		printf "\n"
		printf "Shows this message\n"
		printf "    --help or -h\n"
		printf "    $ ${BASENAME} --help \n"
		printf "\n"
		printf "Count negative test cases with the given postfix\n"
		printf "    --countnegative or -cn\n"
		printf "    $ ${BASENAME} --countnegative _n\n"
		printf "    $ ${BASENAME} -cn _n\n"
		printf "\n"
		printf "Write result summary as a file\n"
		printf "    --summary <filename>\n"
		printf "\n\n"
		exit 0
	;;
	-n|--nocolor)
	nocolor=1
	shift
	;;
	-t|--testcase)
	TESTCASE="$2"
	shift
	shift
	;;
	-cn|--countnegative)
	COUNTNEGATIVE=1
	COUNTNEGATIVEPOSTFIX="$2"
	if [[ "${COUNTNEGATIVEPOSTFIX}" == "" ]]
	then
		printf "${BASENAME} -cn or --countnegative requires postfix.\n\n"
		exit -2
	fi
	shift
	shift
	;;
	-s|--showstdout)
	SILENT=0
	shift
	;;
	-c|--createtemplate)
	createTemplate
	shift
	;;
	-p|-p=*|--progress|--progress=*)
	if [[ $key == "-p" || $key == "--progress" ]]
	then
	    PROGRESSLOGLEVEL=9
	    printf "Progress Log level is not given. Print all logs in progress.\n"
	else
	    PROGRESSLOGLEVEL=${key#*=}
	    printf "Given progress log level is ${PROGRESSLOGLEVEL}.\n"
	fi
	shift
	;;
	-vg|--enable-valgrind)
	VALGRIND=1
	shift
	;;
	--summary)
	SUMMARYFILENAME="$2"
	shift
	shift
	;;
	*) # Unknown, which is probably target (the path to root-dir of test groups).
	# If this is the second occurrence, ignore it.
	# Assume that the previous string is path and the later string is an invalid argument.
	if [ $TARGET_ASSIGNED -eq 0 ]
	then
		TARGET="$1"
		TARGET_ASSIGNED=1
	fi
	shift
	esac
done

source ${BASEPATH}/ssat-api.sh

if [[ "${#TARGET}" -eq "0" ]]
then
	TARGET="."
fi

TNtc=0
TNtcpass=0
TNtcfail=0
TNtcignore=0
TNtcneg=0
TNgroup=0
TNgrouppass=0
TNgroupfail=0
log=""
groupLog=""

while read -d $'\0' file
do
	CASEBASEPATH=`dirname "$file"`
	CASENAME=`basename "$CASEBASEPATH"`
	Ntc=0
	Npass=0
	Nfail=0
	Nneg=0
	tmpfile=$(mktemp)

	if [[ ${PROGRESSLOGLEVEL} -ge 1 ]]; then
		printf "[Starting] $CASENAME\n"
	fi
	pushd $CASEBASEPATH > /dev/null
	output=$(. $file $CASEBASEPATH)
	retcode=$?
	popd > /dev/null

	logfile="${output##*$'\n'}"
	resultlog=$(<$logfile)
	effectiveOutput=`printf "$resultlog" | sed '$d'`
	log="$log$effectiveOutput\n"

	lastline=`printf "${resultlog}" | sed '$!d'`
	IFS=,
	set $lastline
	Ntc=$1
	Npass=$2
	Nfail=$3
	Nignore=$4
	Nneg=$5
	unset IFS

	TNtc=$((TNtc+Ntc))
	TNtcpass=$((TNtcpass+Npass))
	TNtcfail=$((TNtcfail+Nfail))
	TNtcignore=$((TNtcignore+Nignore))
	TNtcneg=$((TNtcneg+Nneg))

	TNgroup=$((TNgroup+1))
	if [[ "$retcode" -eq "0" ]]
	then
		TNgrouppass=$((TNgrouppass+1))
		groupLog="${groupLog}${LightGreen}[PASSED]${NC} ${Blue}${CASENAME}${NC} ($Npass passed among $Ntc cases)\n"
	else
		TNgroupfail=$((TNgroupfail+1))
		groupLog="${groupLog}${Red}[FAILED]${NC} ${Blue}${CASENAME}${NC} ($Npass passed among $Ntc cases)\n"
	fi

	printf "$log\n"
	log=""
done < <(find $TARGET -name $TESTCASE -print0)

printf "\n\n==================================================\n\n"

printf "==================================================\n\n"
printf "$groupLog"
printf "==================================================\n"

ADDITIONALSTRING=""
ADDITIONALSUMMARY=""
if (( ${COUNTNEGATIVE} == 1 ))
then
	total=$((TNtcpass+TNtcfail+TNtcignore))
	pos=$((total-TNtcneg))
	ADDITIONALSTRING="${ADDITIONALSTRING} | Positive: ${pos} / Negative: ${TNtcneg}"
	ADDITIONALSUMMARY="${ADDITIONALSUMMARY}, negative=${TNtcneg}"
fi

if [ "${SUMMARYFILENAME}" != "" ]
then
	echo "passed=${TNtcpass}, failed=${TNtcfail}, ignored=${TNtcignore}${ADDITIONALSUMMARY}" > "${SUMMARYFILENAME}"
fi
if (( ${TNgroupfail} == 0 ))
then
	printf "${LightGreen}[PASSED] ${Blue}All Test Groups (${TNgroup}) Passed!${NC}\n"
	printf "         TC Passed: ${TNtcpass} / Failed: ${TNtcfail} / Ignored: ${TNtcignore} ${ADDITIONALSTRING}\n\n";
	exit 0
else
	printf "${Red}[FAILED] ${Purple}There are failed test groups! (${TNgroupfail})${NC}\n"
	printf "         TC Passed: ${TNtcpass} / Failed: ${TNtcfail} / Ignored: ${TNtcignore} ${ADDITIONALSTRING}\n\n";
	exit 1
fi
# gather reports & publish them.
