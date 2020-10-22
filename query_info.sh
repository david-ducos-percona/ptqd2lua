

query_md5=$1
position=$2

echo "Query template:"
cat template/*${query_md5}*_query

echo "Head of Sessions:"
grep $query_md5 code/*session_* | cut -d':' -f1 | sort | uniq | head


echo "Head of Data:"
grep $query_md5 code/*session_* | cut -d'_' -f1-3 | sort | uniq | while read filename ; do cat data/$(basename $filename _session | sed 's/_/\//')/*_data | grep $query_md5 ; done | head 

echo "Data Template:"
grep $query_md5 code/*session_* | cut -d'_' -f1-3 | sort | uniq | while read filename ; do cat data/$(basename $filename _session | sed 's/_/\//')/*_data | grep $query_md5 ; done | cut -d'"' -f2-|  awk -F'" , "' '{print $2}' | sort | uniq | while read md5template; do echo "$md5template " $(cat template/${md5template}_data); echo ; done

echo "Data Example:"
grep $query_md5 code/*session_* | cut -d'_' -f1-3 | sort | uniq | while read filename ; do cat data/$(basename $filename _session | sed 's/_/\//')/*_data | grep $query_md5 ; done | cut -d'"' -f2-|  awk -F'" , "' '{print $1"\t"$2}' | sort | uniq | while read fornext; do echo "$fornext" | sed 's/\t/\n/g' | lua /home/davidducos/git/ptqd2lua/shorttest.lua | sed 's/%s/\n/g' | while read line;
	do
		if [ "$i" == "" ]
		then
			i=1;
		fi
		echo "$line : $i"
		i=$(( $i + 1 ))
	done
done
if [ "$position" != "" ]
then
	grep $query_md5 code/*session_* | cut -d'_' -f1-3 | sort | uniq | while read filename ; do cat data/$(basename $filename _session | sed 's/_/\//')/*_data | grep $query_md5 ; done | cut -d'"' -f2-|  awk -F'" , "' '{print $2}' | sort | uniq | while read md5template; 
	do
		find data -name "${query_md5}_${md5template}_${position}_generate" | while read filename ;
		do
			echo "File: $( echo $filename | cut -d'/' -f2-3 | sed 's/\//_/g')"
			cat $filename

			echo $filename | cut -d'/' -f2-3 | sed 's/\//_/g'  |  /home/davidducos/git/newptqd2lua/ptqd2lua/session_info.sh  | grep "$query_md5" 

		done
	done
fi
