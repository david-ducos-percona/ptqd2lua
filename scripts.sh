
outputfile="queries.lua"
rm $outputfile

echo "md5queries = { $(find data -name "*_query" | sort | while read filename ; do echo " a$(basename $filename _query) = \"$(cat $filename)\"," ; done ) }" | sed 's/, }$/ }/g' >> $outputfile

echo "sessions = { $(find data -name "*_data" | sort | while read filename ; do echo "[$(basename $filename _data)] = { $(cat $filename)  }," ; done ) }" | sed 's/, }$/ }/g;s/},  }/} }/g' >> $outputfile

