# ptqd2lua
With pt-query-digest, we can parse the queries to get a file with the queries executed and the data

# my commands to test it
```
cat ps571-slow.log | ./pt-query-digest.mine --no-report  > log 2>log
./script.sh
./sysbench.sh
```
