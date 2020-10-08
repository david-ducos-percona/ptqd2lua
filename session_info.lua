
-- Reads the session md5 from the stdin and shows the session generation

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
	my_data = load_file("code/" .. session_id .. "_session")
--        print("Loading Session Execution: ".. session_id:sub(2) .."Random: ".. sysbench.rand.hexadecimal(32, 32))
	return my_data.executions;	
end

function load_session_data(session_id)
        my_data = load_file("code/" .. session_id .. "_data")
--	print("Loading Session Data: ".. session_id:sub(2))
        return my_data;
end


function readAll(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end


function load_template_data(session_id)
        my_data = readAll("template/" .. session_id .. "_data")
--      print("Loading Session Data: ".. session_id:sub(2))
        return my_data;
end

function load_template_query(session_id)
        my_data = readAll("template/" .. session_id .. "_query")
--      print("Loading Session Data: ".. session_id:sub(2))
        return my_data; 
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
	session=load_session_execution(i)
	data=load_session_data(i)
end

function execute_session(sid)
	data_per_thread=load_session_data(sid)
	session=load_session_execution(sid)
	current_pos=1
	while  current_pos < #session 
		do
		pack=session[current_pos]
		md5="u"..pack[1]
		querytemplate=load_template_query(pack[1])
		datatemplate=load_template_data(pack[2])
		data=pack[3]
		elem=split(data,'\t')
		newdata=""
		for i,e in pairs(elem) do
			if not(e=="")
			then
				newdata=newdata .. data_per_thread[e:sub(5)] .. "\t"
			end
		end
		data=string.format(datatemplate,unpack(split(newdata:sub(1, #newdata - 1),'\t')))
		query_ready_to_execute=string.format(querytemplate,unpack(split(data,'\t')))
		print (pack[1].." "..pack[2]..":"..query_ready_to_execute)
		current_pos=current_pos+1
	end
end

function thread_init()
	s = io.read()
	execute_session(s)

end

function event()
        s = io.read()
        execute_session(s)
end
