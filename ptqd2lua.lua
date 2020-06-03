require("queries")
-- Called by sysbench one time to initialize this script
function thread_init()
  -- Create globals to be used elsewhere in the script
  -- drv - initialize the sysbench mysql driver
  drv = sysbench.sql.driver()
  -- con - represents the connection to MySQL
  con = drv:connect()
end
-- Called by sysbench when script is done executing
function thread_done()
  -- Disconnect/close connection to MySQL
  con:disconnect()
end

function load_data(fileName)
  fileContent = read_file(fileName)
  result = {}
  for part in fileContent:gmatch("[^\t]+") do
      result[#result+1] = part
  end
  return result
end

-- Called by sysbench for each execution
function event()
  -- If user requested to disable transactions,
  -- do not execute BEGIN statement
  if not sysbench.opt.skip_trx then
    con:query("BEGIN")
  end
  -- Run our custom statements
  -- execute_selects()
  --  execute_inserts()
  -- Like above, if transactions are disabled,
  -- do not execute COMMIT
  i=math.random(#md5)
  
  status, data = pcall(load_data,"data/".. md5[i] .."_data_fifo")
  if (status)
  then
     print(string.format(queries[i], unpack(data)));
  end
  if not sysbench.opt.skip_trx then
    con:query("COMMIT")
  end
end

local open = io.open


for k,v in pairs(md5) do
	print(string.format("%s: %s", k, v))
end

function read_file(path)
    local file = open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

