# ptqd2lua
With pt-query-digest, we can parse the queries to get a file with the queries executed and the data

# Sysbench version

Current Sysbench version doesn't support hexadecimal values that is why I created this patch:
```
https://github.com/davidducos/sysbench/tree/patch-1
```
And this pull request
```
https://github.com/akopytov/sysbench/pull/382
```
This are the steps to download and compile it:
```
git clone https://github.com/davidducos/sysbench.git
git switch patch-1
./autogen.sh
./configure
make
```

After this pull request is merge to master:
```
https://github.com/akopytov/sysbench/pull/382
```
we are not going to need to use this sysbench version

# My commands to test
```
ptqd2lua_expand.sh ps571-slow.log
```
And then follow the instructions


# Troubleshooting errors

It is expected to see errors, for instance: 
```
ptqd2lua.20201002170316$ /home/davidducos/git/newptqd2lua/ptqd2lua/my_sysbench.sh
sysbench 1.1.0-c8e2e5b (using bundled LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 8
Report intermediate results every 5 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

FATAL: mysql_drv_query() returned error 1292 (Truncated incorrect DOUBLE value: '78,131,91,94') for query 'UPDATE `employee` SET `nextAvailOrder`=NULL, `waitTime`=0 WHERE locationID = '1007717' AND nextAvailOrder IS NOT NULL AND employeeID NOT IN ('78,131,91,94')'
FATAL: `thread_run' function failed: /home/davidducos/git/newptqd2lua/ptqd2lua/ptqd2lua.lua:132: SQL error, errno = 1292, state = '22007': Truncated incorrect DOUBLE value: '78,131,91,94'
```
Initially we need to check which is the query that is causing the issue:
```
ptqd2lua.20201002170316$ grep 'UPDATE `employee` SET `nextAvailOrder`=' template/*query
template/7A8D68F446F621FED747F1708A58EA2A_query:UPDATE `employee` SET `nextAvailOrder`=NULL, `waitTime`=%s WHERE locationID = %s AND nextAvailOrder IS NOT NULL AND employeeID NOT IN (%s)
template/9B498C9E2C07CA1263A6F5C81261EAEF_query:UPDATE `employee` SET `nextAvailOrder`=%s WHERE id = %s
template/E79754161DE5DAB60D1F3231B5034DF1_query:UPDATE `employee` SET `nextAvailOrder`=%s, `waitTime`=%s WHERE locationID = %s AND employeeID = %s
```
In this case, we easily identified 7A8D68F446F621FED747F1708A58EA2A.
Then we can get more information with query_info.sh
```
ptqd2lua.20201002170316$ query_info.sh 7A8D68F446F621FED747F1708A58EA2A
```
it will show information about the query, like the query template, some session that are using this query and some example of data that is being used. It will also show the data template and some examples of the query might look like. 

You will be able to so how the session is being filled using this command:
```
echo "00c96a282ef1bec87bd784aab928388f_79be7226eefd61a1df87c0dc27eae8a7" | session_info.sh
```
Take into consideration that session_info.sh is starting sysbench as we need the random functions that sysbench provides.


