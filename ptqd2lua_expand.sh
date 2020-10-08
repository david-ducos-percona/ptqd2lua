#!/usr/bin/env bash

basedir=$(dirname $0)

ptquerydigest="${basedir}/pt-query-digest.mine"
generatefunctions="${basedir}/generate_functions.pl"
createtemplates="${basedir}/create_templates.pl"

if [ "$1" == "" ]
then
	echo "You need to provide a file as parameter, for example:"
	echo "# ptqd2lua_expand.sh mysql-slow.log"
	exit
fi

echo "Starting pt-query-digest"
$ptquerydigest --no-report $1 
threads=8
dirname="ptqd2lua.$(date "+%Y%m%d%H%M%S")"

if [ ! -d "data" ] || [ ! -d "template" ]
then
	echo "Error: data or template path doesn't exist."
	exit
fi

mkdir $dirname
mv data template $dirname
cd $dirname

# Moves the files from data/*_data to data/<session template md5>/
function data_split_by_session_id() {
	sleep 1
	for file in $* ;
	do
		uniq=$(awk -F'" , "' '{print $1 $2}' $file | sed ':a;N;$!ba;s/\n/ /g' ) ;
		session_md5=$(echo "$uniq" | md5sum | cut -f1 -d' ') ;
		dir="data/${session_md5}"
		mkdir -p $dir
		mv $file $dir
	done
}

echo "Processing $(ls data/*_data | wc -l ) sessions files"
total=$(ls data/*_data | wc -l);
split=$(( $total / $threads + 1));
wait=$(for i in $(seq 0 $(( $threads - 1))) ;
do
	data_split_by_session_id $(ls data/*_data | head -$(( $total - $split * $i )) | tail -$split) &
done )

echo "Reduced to $(find data -mindepth 1 -maxdepth 1 -type d | wc -l)."

# Moves the files from data/<session template md5>/*_data to data/<session template md5>/<data template md5>/
# Creates the '_value' files in data/<session template md5>/<data template md5>/
# Creates the '_generate' files in data/<session template md5>/<data template md5>/
function parallel_process() {
	for session_dir in $*
	do
		# In a session execution, variables could be linked. We need to establish if there is one pattern or several.
		for file in ${session_dir}/*_data
		do
			${createtemplates} $file > ${file}_template
			template_md5=$(md5sum ${file}_template | cut -f1 -d' ')
			data_dir=${session_dir}/${template_md5}
			mkdir -p $data_dir
			for f in $( ls ${session_dir}/*_value )
			do
				cat $f >> ${data_dir}/$(basename $f)
				rm $f
			done
			mv ${file}_template $file ${session_dir}/${template_md5}/
		done
	        session_md5=$(basename $session_dir)
		wait=$(find $session_dir -mindepth 1 -maxdepth 1 -type d | while read template_dir; do
			template_md5=$(basename $template_dir)
                	cat       $(ls ${template_dir}/*_template | head -1) > template/${session_md5}_${template_md5}_session
			${generatefunctions} $(ls ${template_dir}/*_value )  &
		done)
	done
}

echo "Starting to create session template and value"

# iterate per session_md5
total=$(find data -mindepth 1 -maxdepth 1 -type d | wc -l);
split=$(( $total / $threads + 1));
wait=$(for i in $(seq 0 $(( $threads - 1))) ;
do
        parallel_process $(find data -mindepth 1 -maxdepth 1 -type d | head -$(( $total - $split * $i )) | tail -$split) &
done )

echo "Total amount of session templates: $(find data -mindepth 2 -maxdepth 2 -type d | wc -l)"
echo "Now, you need to go to $dirname and execute ptqd2lua_merge.sh:"
echo "cd $dirname"
echo "${basedir}/ptqd2lua_merge.sh"
