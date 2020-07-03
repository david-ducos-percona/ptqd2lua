require("queries")
require("oltp_common")

-- Called by sysbench one time to initialize this script
function thread_init()
  -- Create globals to be used elsewhere in the script
  -- drv - initialize the sysbench mysql driver
  drv = sysbench.sql.driver()
  -- con - represents the connection to MySQL
  con = drv:connect()
  a={}
  for i=0, sysbench.opt.threads do
	a[i]={}
  end
  for k,query in pairs(sessions) do
	  table.insert(a[k % sysbench.opt.threads],k)
  end
end

-- Called by sysbench when script is done executing
function thread_done()
  -- Disconnect/close connection to MySQL
  con:disconnect()
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function search_next_session(thread_number)
	if not(#a[thread_number] == 0)
	then
		return table.remove(a[thread_number])
	end
	return 0;
end

function execute_session(sid)
	if not(sid == 0)
	then
		for k,query in pairs(sessions[sid]) do
			con:query(string.format(md5queries["a"..query[1]],unpack(split(query[2],'\t'))))
		end
	end
end


-- Called by sysbench for each execution
function event()
	execute_session(search_next_session(sysbench.tid))
end
