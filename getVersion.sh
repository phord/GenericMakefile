#!/bin/bash
objdump -t $1 | grep REF > /tmp/getVersion.txt
if [ $# -eq 1 ]
then
	# remove file extention of the first argument
	LIST=$(echo $1 | sed -nr "s/(.*)\..*/\1/p")

	if [[ -z $LIST ]]
	then
		LIST=$1
	fi

	echo No second argument specified, searching for all entries.
	LIST=`cat /tmp/getVersion.txt | grep REF | sed -nr 's/[0-9abcdef]*.*[0-9abcdef]*[ \t](.*)_BUILD_YEAR_REF/\1/p'`

elif [ $# -eq 2 ]
then
	# remove file extention of second argument
	LIST=$(echo $2 | sed -nr "s/(.*)\..*/\1/p")
	if [[ -z $LIST ]]
	then
		LIST=$2
	fi
else
	echo "  "usage: "   "getVersion.sh fileToSearch
	echo "  "optional: getVersion.sh fileToSearch entryToSearch
	exit
fi

# only search objdump once. Save the relevant output to a tmp file.
for ARG in $LIST
do
	printf "Version of $ARG:\n"
	TMP=$(cat /tmp/getVersion.txt | sed -nr "s/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}"$ARG"_BUILD_DAY_REF/\1/p")
	if [[ $TMP ]]
	then
		printf "  Build Date: %02d." 0x$TMP
	fi
	TMP=$(cat /tmp/getVersion.txt | sed -nr "s/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}"$ARG"_BUILD_MONTH_REF/\1/p")
	if [[ $TMP ]]
	then
		printf "%02d." 0x$TMP
	fi
	TMP=$(cat /tmp/getVersion.txt | sed -nr "s/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}"$ARG"_BUILD_YEAR_REF/\1/p")
	if [[ $TMP ]]
	then
		printf "%02d - " 0x$TMP
	fi
	TMP=$(cat /tmp/getVersion.txt | sed -nr "s/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}"$ARG"_BUILD_HOUR_REF/\1/p")
	if [[ $TMP ]]
	then
		printf "%02d:" 0x$TMP
	fi
	TMP=$(cat /tmp/getVersion.txt | sed -nr "s/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}"$ARG"_BUILD_MIN_REF/\1/p")
	if [[ $TMP ]]
	then
		printf "%02d:" 0x$TMP
	fi
	TMP=$(cat /tmp/getVersion.txt | sed -nr "s/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}"$ARG"_BUILD_SEC_REF/\1/p")
	if [[ $TMP ]]
	then
		printf "%02d\n" 0x$TMP
	fi
	TMP=$(cat /tmp/getVersion.txt | sed -nr "s/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}"$ARG"_VERSION_MAJOR_REF/\1/p")
	if [[ $TMP ]]
	then
		printf "  vMajor: %d\n" 0x$TMP
	fi
	TMP=$(cat /tmp/getVersion.txt | sed -nr "s/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}"$ARG"_VERSION_MINOR_REF/\1/p")
	if [[ $TMP ]]
	then
		printf "  vMinor: %d\n" 0x$TMP
	fi
	TMP=$(cat /tmp/getVersion.txt | sed -nr "s/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}"$ARG"_VERSION_PATCH_REF/\1/p")
	if [[ $TMP ]]
	then
		printf "  vPatch: %d\n" 0x$TMP
	fi
	TMP=$(cat /tmp/getVersion.txt | sed -nr "s/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}"$ARG"_VERSION_REVISION_REF/\1/p")
	if [[ $TMP ]]
	then
		printf "  Revision: %d\n" 0x$TMP
	fi
	TMP=$(cat /tmp/getVersion.txt | sed -nr "s/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}"$ARG"_BUILD_NUMBER_REF/\1/p")
	if [[ $TMP ]]
	then
		printf "  Build: %d\n" 0x$TMP
	fi
done

rm /tmp/getVersion.txt