#!/usr/bin/env bash

basedir=$(dirname $0)
sysbench="/home/davidducos/git/mysysbench/sysbench/src/sysbench"
user=
password=
host=
db=
threads=8

${sysbench} ${basedir}/ptqd2lua.lua run     --mysql-user=${user} --mysql-password=${password} --mysql-host=${host} --threads=${threads}  --events --mysql-db=${db} --report-interval=5 --time=120 # --mysql-ignore-errors=1292 #,1062 #,1449 #,1449,1054,1062,1264


