#!/usr/bin/env bash

basedir=$(dirname $0)

compactfunctions="${basedir}/compact_functions.pl"

threads=8

echo "Starting merge"

function merge {
for session_dir in $*;
do
	session_md5=$(basename ${session_dir} _session)

	session_execution="code/${session_md5}_session"
	session_data="code/${session_md5}_data"

	${compactfunctions} ${session_dir}  > ${session_data}
	echo "return { executions = { $(cat $session_dir) } }" > ${session_execution}
done
}

mkdir -p code

total=$(find template -name "*_session" | wc -l);
split=$(( $total / $threads + 1));
wait=$(for i in $(seq 0 $(( $threads - 1))) ;
do
        merge $(find template -name "*_session" | head -$(( $total - $split * $i )) | tail -$split) &
        echo $?
done )



# Creates the queries.lua
# queries.lua will be loaded by ptqd2lua.lua

echo "Starting queries.lua"

outputfile="queries.lua"
rm $outputfile
echo "querytemplate   = { $(find template -name "*_query"     | sort | while read filename ; do md5="$(basename $filename _query)";     echo "u$md5 = \"$(cat $filename | sed ':a;N;$!ba;s/\n/ /g;s/\r//g' | sed 's/"/\\"/g')\"," ; done ) }" >> $outputfile

echo "datatemplate    = { $(find template -name "*_data"  | sort | while read filename ; do echo "u$(basename $filename _data) = \"$(cat $filename | sed ':a;N;$!ba;s/\n/ /g;s/\r//g' | sed 's/"/\\"/g')\"," ; done ) }" >> $outputfile

echo "sessiontemplate = { $(find code -name "*_session" | while read filename ; do
	session_md5=$(basename $filename _session)
	for i in $( seq 1 $(ls data/$(echo $session_md5 | sed 's/_/\//g')/*_data | wc -l))
	do
		echo "u${session_md5}= $i," ;
	done
done | sort -R) }" >> $outputfile

sed -i 's/, }$/ }/g;s/},  }/}}/g' $outputfile


