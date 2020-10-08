#!/usr/bin/env bash

basedir=$(dirname $0)
sysbench="/home/davidducos/git/mysysbench/sysbench/src/sysbench"
user=
password=
host=
db=

${sysbench} ${basedir}/session_info.lua run --mysql-user=${user} --mysql-password=${password} --mysql-host=${host} --threads=1 --time=10 --events --mysql-db=${db}
