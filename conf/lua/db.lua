local cjson = require "cjson.safe"
local fs = require "fs"
local conf = require "conf"

local db = {}

db.KEYS = { FULL = "FULL", USING = "USING" }

-- 持久化
-- ~/.hasaki/config.full.json
-- ~/.hasaki/config.using.json

-- 内存中正在使用的规则
db.rules = {};

function db.using(rules)
  if rules ~= nil then
    db.rules = rules
  end
end

function db.touch()
  fs.touch_config()
end

function db.clear()
  -- 清理
  ngx.shared.db:flush_all()
  ngx.shared.db:flush_expired()
end

function db.set_full(config_full)
  if config_full == '' or config_full == 'null' or config_full == '' then
    return
  end
  fs.write_file(conf.CONFIG_PATH_FULL, config_full)
  ngx.shared.db:set(db.KEYS.FULL, config_full)
end
function db.set_using(config_using)
  if config_using == '' or config_using == 'null' or config_using == '' then
    return
  end;
  fs.write_file(conf.CONFIG_PATH_USING, config_using)
  ngx.shared.db:set(db.KEYS.USING, config_using)
  cjson.decode_array_with_array_mt(true)
  -- sync rules
  local using = cjson.decode(config_using)
  if using ~= nil then
    db.using(using.rules);
  end
end

function db.get_full()
  local config_full = fs.get_file(conf.CONFIG_PATH_FULL)
  return config_full
end
function db.get_using()
  local config_using = fs.get_file(conf.CONFIG_PATH_USING)
  return config_using
end

function db.init()
  local config_full = db.get_full()
  local config_using = db.get_using()

  if config_full ~= nil then
    db.set_full(config_full)
  end;


  if config_using ~= nil then
    db.set_using(config_using)
  end;
end

return db
