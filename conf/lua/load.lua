
local args = ngx.req.get_uri_args();

ngx.req.clear_header('host')
ngx.req.clear_header('referer')

ngx.var.cloud = args.cloud;
