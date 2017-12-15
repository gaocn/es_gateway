--[[
    @Author gww
    @Date   2017-08-28
    @Description 
]]--

--*********************  function definition  **************************--
--[[
  function: split string into an array
  eg: str = 'str1, str2, str3'
    split(str) => {'str1', 'str2', 'str3'}
]]--

local logger = require('logger')

function split(str, sep)
    local sep = sep or "\t"
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(str, pattern , function(w) fields[#fields + 1] = w end)
    return fields
end

--[[
  function: use token to retrieve data from redis
]]--
function getTokenValue(token)
    local parser = require("redis.parser");
    local res = ngx.location.capture("/redis", {args = {key = id}});
    --local res = ngx.location.capture("/r", {args = {key = token}});
    --for key, val in pairs(res) do 
    --    print(key, '--', val)
    --end
    --ngx.say(res.status)
    --ngx.say(res.body)
    
    if res.status ~= 200 then
        logger:debug(res.status .. res.body)
        return nil
    end
    if string.find(res.body, 'MOVED') then
        _, ip, port = string.match(res.body, "-MOVED%s+(%d-)%s+(.-):(.*)")
        --ngx.say(ip, '--', port)
         reply = _getTokenValueHelper(token, ip, port)
    else
        reply = parser.parse_reply(res.body)
    end

    if reply == nil or string.len(reply) == 0 then
       return nil
    end
    return split(string.sub(reply, 2, -2), ',')
end


function _getTokenValueHelper(token, ip, port)
    local redis = require("resty.redis")
    local cache = redis.new()
    local ok, err = cache.connect(cache, ip, port)

    cache:set_timeout(1000)
    if not ok then
        logger:debug("failed to connect:" .. err)  
        return nil
    end

    local res, err = cache:get(token)
    if not res then
        logger:debug("failed to get key:" .. token .. err)  
        return nil
    end
    if res == ngx.null then
        logger:debug(token .. " not found.")  
        return nil
    end

    --ngx.say(res)
    return res
    --return split(string.sub(res, 2, -2), ',')
end


--*********************  MAIN FUNC   *********************************--


--[[
    retrieve header
    curl -H"X_TOKEN:indices" localhost:80/kafka_ebflog_qpay_log-2017.04.08?pretty
]]--
local token = ngx.var.http_x_token
ngx.say('--',token,'--')
if token == nil then
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

local indices = getTokenValue(token)
ngx.say(indices)
