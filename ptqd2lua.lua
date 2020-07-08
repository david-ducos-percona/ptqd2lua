require("queries")
require("oltp_common")

-- Called by sysbench one time to initialize this script
function thread_init()
  -- Create globals to be used elsewhere in the script
  -- drv - initialize the sysbench mysql driver
  drv = sysbench.sql.driver()
  -- con - represents the connection to MySQL
  con = drv:connect()
  sessions_per_thread={}
  current_sid={}
  current_pos={}
  for i=0, sysbench.opt.threads do
        sessions_per_thread[i]={}
        current_pos[i]=1
  end
  for k,query in pairs(sessions) do
	  table.insert(sessions_per_thread[k % sysbench.opt.threads],k)
  end
  for i=0, sysbench.opt.threads do
        current_sid[i]=table.remove(sessions_per_thread[i]);
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
	if not(#sessions_per_thread[thread_number] == 0)
	then
		return table.remove(sessions_per_thread[thread_number])
	end
	return 0;
end

function next_pos(thread_number)
	if not(current_sid[thread_number] == 0 )
	then
		if (#sessions[current_sid[thread_number]] > current_pos[thread_number])
	        then
			current_pos[thread_number]=current_pos[thread_number]+1
		else
			current_sid[thread_number]=search_next_session(thread_number)
			current_pos[thread_number]=1
--			print ("starting new session id:",current_sid[thread_number])
	        end
	end
        return 0;
end

function execute_session(sid)
	if not(sid == 0)
	then
		query=sessions[sid][current_pos[sysbench.tid]]
		con:query(string.format(md5queries["a"..query[1]],unpack(split(query[2],'\t'))))
	end
	next_pos(sysbench.tid)
end

-- Called by sysbench for each execution
function event()
	execute_session(current_sid[sysbench.tid])
end
