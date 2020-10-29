local cjson = require "cjson"
local util = require "util"

cjson.decode_array_with_array_mt(true)

local body = ngx.req.get_body_data()
if nil == body then
    local file_name = ngx.req.get_body_file()
    if file_name then
        body = fs.get_file(file_name)
    end
end

local data = cjson.decode(body)
local uri = data.uri
local rules = data.rules
local match = data.match
local to = data.to

local path = ngx.re.sub(uri, [[(http|https)://(www.)?(\w+(\.)?)+]], "")

local rank = util.rank(rules, uri);

local m = ngx.re.match(path, match)
local next = ngx.re.sub(path, match, to)
local is = false
if (m ~= nil) then
    is = true
end

local json =
    cjson.encode(
    {
        is = is,
        next = next,
        rank = {
            to = rank.to,
            name = rank.name,
            id = rank.id
        }
    }
)

ngx.header["Content-Type"] = "application/json; charset=utf-8"
ngx.say(json)
