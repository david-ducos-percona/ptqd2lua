require("queries")
-- require("oltp_common")


function load_file(filename)
--	print("Loading file: "..filename.."\n")
	local f=io.open(filename,"r")
	if f~=nil then 
		io.close(f)
		local f = assert(loadfile(filename ))
	        my_data = f()
        	return my_data;
	end
	return "ERROR: File not found: "..filename;
end


function load_session_execution(session_id)
	filename="code/" .. session_id:sub(2) .. "_session"
	my_data = load_file(filename)
--      print("Loading Session Execution: ".. filename)
	return my_data.executions;	
end

function load_session_data(session_id)
	filename="code/" .. session_id:sub(2) .. "_data"
        my_data = load_file(filename)
--	print("Loading Session Data: ".. filename)
        return my_data;
end


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
  current_pack={}
  removed_sid={}
  data_per_thread={}
  -- Initialize sessions per thread list and the current position per thread
  for thread_number=0, sysbench.opt.threads-1 do
        sessions_per_thread[thread_number]={}
        current_pos[thread_number]=1
  end
  -- Loading the session ids into the sessions per thread
  i=0
  for session_id in pairs(sessiontemplate) do
	  table.insert(sessions_per_thread[i % sysbench.opt.threads],session_id)
	  i=i+1
  end
  -- Now, we can load the session content based on the session id in the pack list
  for thread_number=0, sysbench.opt.threads - 1 do
        current_sid[thread_number]=table.remove(sessions_per_thread[thread_number]);
	removed_sid[thread_number]={}
	current_pack[thread_number]    = load_session_execution(current_sid[thread_number])
        data_per_thread[thread_number] = load_session_data     (current_sid[thread_number])
  end
end

-- Called by sysbench when script is done executing
function thread_done()
  -- Disconnect/close connection to MySQL
  con:disconnect()
end

-- This function is removing the backslashed, needs FIX
function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function search_next_session(thread_number)
--	print("Searching new session\n")
	i=table.remove(sessions_per_thread[thread_number])
	current_pack[thread_number] = load_session_execution(i)
	data_per_thread[sysbench.tid]=load_session_data(i)
	table.insert(removed_sid[thread_number],i)
	if (#sessions_per_thread[thread_number] == 0)
	then
--		Restarting the sessions that needs to be executed by this thread
--		This is to get the neverends workload feeling
		sessions_per_thread[thread_number]=removed_sid[thread_number];
		removed_sid[thread_number]={}
--		print("Reinitializing Thread: " .. thread_number);
	end
	return i
end

function next_pos(thread_number)
	if not(current_sid[thread_number] == 0 )
	then
		if (#current_pack[thread_number] > current_pos[thread_number])
	        then
			current_pos[thread_number]=current_pos[thread_number]+1
		else
			current_sid[thread_number]=search_next_session(thread_number)
			current_pos[thread_number]=1
--			print ("Starting new session id:",current_sid[thread_number])
	        end
	end
        return 0;
end

function execute_session(sid)
	if not(sid == 0)
	then
		pack=current_pack[sysbench.tid][current_pos[sysbench.tid]]
		md5="u"..pack[1]
		data=pack[3]
		elem=split(data,'\t')
		newdata=""
--		print(pack[1] .. " " .. pack[2].."\n")
		for i,e in pairs(elem) do
			if not(e=="")
			then
				newdata=newdata .. data_per_thread[sysbench.tid][e:sub(5)] .. "\t"
			end
		end
		data=string.format(datatemplate["u"..pack[2]],unpack(split(newdata:sub(1, #newdata - 1),'\t')))
		query_ready_to_execute=string.format(querytemplate[md5],unpack(split(data,'\t')))
		next_pos(sysbench.tid)
		-- Next line should be UNCOMMENTED           
		con:query(query_ready_to_execute)
--		print (query_ready_to_execute)
	else
		next_pos(sysbench.tid)
	end
end

-- Called by sysbench for each execution
function event()
	execute_session(current_sid[sysbench.tid])
end
