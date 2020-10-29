local server = require "resty.websocket.server"
local log = require "log"
local cjson = require "cjson.safe"

local loging = false
local alive = true
local err_count = 0

local total = 0
local prev = 0
local LOG_MAX_LEN = 10000
local PING_ERROR_MAX = 3
local consumed = {}

local wb, err =
    server.new {
    timeout = 5000, -- 超时时间 5 秒
    max_payload_len = 1024 * 64 -- 数据帧最大 64KB
}

if not wb then -- 检查对象是否创建成功
    ngx.log(ngx.ERR, "failed to init: ", err) -- 记录错误日志
    ngx.exit(444) -- 无法运行 WebSocket 服务
end

local function cleaning()
    check_alive = nil
    flush = nil
    wb:send_text("wtffff")
    ngx.exit(444)
end

local function check_alive()
    if alive == false then
        cleaning()
        return
    end
    local bytes, err = wb:send_ping()
    if err ~= nil then
        err_count = err_count + 1
    end
    ngx.sleep(5)
    check_alive()
end

local function flush()
    if alive == false or not wb then
        cleaning()
        return
    end

    if #consumed > LOG_MAX_LEN then
        for i = 1, 100 do
            table.remove(1, consumed)
        end
    end

    loging = true
    local len = 0
    if wb then
        local i = 1
        for k, v in pairs(log) do
            if consumed[k] ~= true then
                len = len + 1
                if v and v.sent then
                    local json, err = cjson.encode({trace = true, data = v, total = total })
                    wb:send_text(json)

                    total = total + 1
                    consumed[k] = true
                end
            end
        end

        ngx.sleep(0.66)

        flush()
    end
end

if loging == false then
    flush()
end

local data, typ, bytes, err  -- 返回值使用的变量声明

while true do -- 无限循序提供服务
    data, typ, err = wb:recv_frame() -- 接受数据帧

    if not data then -- 检查是否接收成功
        if not string.find(err, "timeout", 1, true) then -- 忽略超时错误
            ngx.log(ngx.ERR, "failed to recv: ", err) -- 其他错误则记录日志
            ngx.exit(444) -- 无法运行 WebSocket 服务
        end
    end

    if typ == "close" then -- close 数据帧
        bytes, err = wb:send_close() -- 发送 close 数据帧
        alive = false
        ngx.exit(0) -- 服务正常结束
    end

    if typ == "ping" then -- ping 数据帧
        bytes, err = wb:send_pong() -- 发送 pong 数据帧
    end

    -- echo
    if typ == "text" then -- 文本数据帧
        bytes, err = wb:send_text(data) -- 发送响应数据
    end
end
