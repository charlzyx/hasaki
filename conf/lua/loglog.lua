local log = require "log";
local headers = ngx.resp.get_headers();

log[ngx.ctx.uid].sent = true;
log[ngx.ctx.uid].diff.cookie.from = headers['Set-Cookie'];
log[ngx.ctx.uid].resp = {
   headers = headers,
   status = ngx.status
}

local function fillspace(size)
   local space = "";
   for i = 1, size do  -- The range includes both ends.
      space = space.." ";
   end
   return space;
end

local function loglog(loglike, deep)
   local str = "";
   if (type(loglike) == "table") then
      for k, v in pairs(loglike) do
         if k ~= "diff" then
            str = str.."\n"..fillspace(deep)..k..":";
            if (type(loglike) == "table") then
               str = str..loglog(v, deep + 2);
            else
               str = str..tostring(v)
               str = str.."\n";
            end
         end
      end
   else
      str = str..tostring(loglike);
   end
   return str;
end

local function prelog(loglike)
   local str = "\n----------------------------------------------------------------------------------------\n";
   str = str..loglike.diff.uri.from.." ~> "..loglike.diff.uri.to;
   str = str..loglog(loglike, 0);
   str = str.."\n----------------------------------------------------------------------------------------\n";
   return str;
end

local mylog = log[ngx.ctx.uid]
ngx.log(ngx.INFO, prelog(mylog));
