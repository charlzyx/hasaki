local cjson = require "cjson.safe"
local db = require "db"
local fs = require "fs"

-- local breakSocketHandle, debugXpCall = require("LuaDebugOpenrestyJit")("localhost", 7003);

local method = ngx.req.get_method()

local full = db.get_full()
local using = db.get_using()
local safe_full = full;
local safe_using = using;
if full == nil or full == "null" or full == "" then
    safe_full = "{}"
end;
if using == nil or using == "null" or using == "" then
    safe_using = "{}"
end;

if method == "GET" then
    -- GET
    ngx.header["Content-Type"] = "application/json; charset=utf-8"
    ngx.say([[{ "full": ]] .. safe_full .. [[,"using":]] .. safe_using .. [[}]])
else
    ngx.exit(ngx.HTTP_NOT_ALLOWED)
end
