local fs = {}
local conf = require "conf"

function fs.get_file(file_name)
    local f = assert(io.open(file_name, "r"))
    local string = f:read("*all")
    f:close()
    return string
end

function fs.write_file(file_name, string)
    local f = assert(io.open(file_name, "w"))
    f:write(string)
    f:close()
end

function fs.touch_config()
    os.execute("mkdir -p "..conf.CONFIG_PATH_DIR)
    os.execute("ls -al "..conf.CONFIG_PATH_DIR)
    os.execute("touch "..conf.CONFIG_PATH_FULL)
    os.execute("touch "..conf.CONFIG_PATH_USING)
end

return fs
