#!/bin/bash
if [ $# -eq 1 ]
then
	echo [WARNING] No search library specified.
	echo "          "Use only if just one Version information is specified.
elif [ $# -ne 2 ]
then
	echo usage: getVersion fileToSearch nameToSearch
	exit
fi

printf "Version of $2: v%d." 0x`objdump -t $1 | sed -nr "s/([0-9abcdef]*).*"$2"_VERSION_MAJOR_REF/\1/p"`
printf "%d." 0x`objdump -t $1 | sed -nr "s/([0-9abcdef]*).*"$2"_VERSION_MINOR_REF/\1/p"`
printf "%d." 0x`objdump -t $1 | sed -nr "s/([0-9abcdef]*).*"$2"_VERSION_PATCH_REF/\1/p"`
printf "%d." 0x`objdump -t $1 | sed -nr "s/([0-9abcdef]*).*"$2"_VERSION_REVISION_REF/\1/p"`
printf "%d\n" 0x`objdump -t $1 | sed -nr "s/([0-9abcdef]*).*"$2"_BUILD_NUMBER_REF/\1/p"`