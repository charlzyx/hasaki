local conf = {}


os.getenv("pwd")

conf.CONFIG_PATH_DIR = "/hasaki"
conf.CONFIG_PATH_FULL = conf.CONFIG_PATH_DIR.."/conf.full.json"
conf.CONFIG_PATH_USING = conf.CONFIG_PATH_DIR.."/conf.using.json"

return conf
