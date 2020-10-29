local cjson = require "cjson.safe"
local db = require "db"
local fs = require "fs"
local util = require "util"

-- local breakSocketHandle, debugXpCall = require("LuaDebugOpenrestyJit")("localhost", 7003);

local method = ngx.req.get_method()

local full = db.get_full()
local using = db.get_using()

if method == "POST" then
    -- POST
    cjson.decode_array_with_array_mt(true)

    local body = ngx.req.get_body_data()
    if nil == body then
        local file_name = ngx.req.get_body_file()
        if file_name then
            body = fs.get_file(file_name)
        end
    end

    local data = cjson.decode(body)
    if data == nil then
        ngx.say("无法解析:"..body)
        return;
    end

    local req_full = cjson.encode(data.full)
    local req_using = cjson.encode(data.using)

    if req_full ~= full and req_full ~= nil and req_using ~= "" then
        db.set_full(req_full);
    end

    if req_using ~= using and req_using ~= nil and req_using ~= "" then
        db.set_using(req_using);
    end

    ngx.header["Content-Type"] = "application/json; charset=utf-8"

    ngx.say([[{ "message": "ok"}]])
else
    ngx.exit(ngx.HTTP_NOT_ALLOWED)
end
