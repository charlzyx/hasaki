local db = require "db"
local util = require "util"
local cjson = require "cjson"
local log = require "log"
local fs = require "fs"
local cookie = require "cookie"

local uri = ngx.var.uri
local host = ngx.var.host
local LOG_MAX_LEN = 10000;

local method = ngx.req.get_method()

local rule = util.rank(db.rules, uri)

local upp = ngx.re.sub(uri, rule.match, rule.to)
upp = upp:gsub("//127.0.0.1", "//host.docker.internal")
upp = upp:gsub("//localhost", "//host.docker.internal")

local rootdomain = util.root_domain(host)

-- to log
local query = ngx.req.get_uri_args()
local headers = ngx.req.get_headers()

cjson.decode_array_with_array_mt(true)

local body = ngx.req.get_body_data()
if nil == body then
    local file_name = ngx.req.get_body_file()
    if file_name then
        body = fs.get_file(file_name)
    end
end

local cookies = {}
local ck, err = cookie:new()
if ck then
    local fields, err = ck:get_all()
    if fields then
        cookies = fields
    end
end

ngx.ctx.uid = ngx.var.request_id

local query_string = ngx.encode_args(query)

if query_string == "" then
    ngx.var.upp = upp
else
    ngx.var.upp = upp .. "?" .. query_string
end

ngx.var.cookie_domain = rootdomain

if #log > LOG_MAX_LEN then
    table.remove(1, log);
end

log[ngx.ctx.uid] = {
    sent = false,
    now = ngx.now(),
    uid = ngx.ctx.uid,
    req = {
        method = ngx.var.request_method,
        status = ngx.status,
        headers = headers,
        cookies = cookies,
        query = query,
        body = body
    },
    diff = {
        uri = {
            from = host .. ngx.var.uri,
            to = ngx.var.upp
        },
        cookie = {
            -- from = by loglog.lua,
            to = {
                domain = rootdomain,
                path = "/"
            }
        }
    },
    resp = {
        -- headers = by loglog.lua,
        -- status = by loglog.lua
    }
}
