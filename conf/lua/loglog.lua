local log = require "log";
local headers = ngx.resp.get_headers();

log[ngx.ctx.uid].sent = true;
log[ngx.ctx.uid].diff.cookie.from = headers['Set-Cookie'];
log[ngx.ctx.uid].resp = {
   headers = headers,
   status = ngx.status
};
