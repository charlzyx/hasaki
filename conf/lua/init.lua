local db = require "db"

os.getenv("HOME")

db.touch();
db.clear();
db.init();
