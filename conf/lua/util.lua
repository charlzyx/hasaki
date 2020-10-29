local util = {}


function util.root_domain(host)
    local rootdomain = host;
    local m = ngx.re.match(host, "(\\w+|\\d+)+.\\w+$")

    if m ~= nil and m[0] ~= nil then
        rootdomain = m[0];
    end;

    return rootdomain;
end

function util.rank(rules, uri)
    local name = ""
    local id = ""
    local match = ""
    local to = ""
    local max_weight = 0

    for _, rule in pairs(rules) do
        local weight = tonumber(rule.weight)
        if max_weight <= weight then
            local is = ngx.re.match(uri, rule.capture.match)
            if is ~= nil then
                max_weight = weight
                match = rule.capture.match
                to = rule.dispatch.to
                name = rule.name
                id = rule.id
            end
        end
    end
    return {match = match, to = to, name = name, id = id}
end

return util
