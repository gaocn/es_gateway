--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/12
-- Description: 
--

local redis = require "resty.redis"
local parser = require "redis.parser"
local logger = require "es_gateway.utils.logger"
local str_utils = require "es_gateway.utils.string"


--[[
  function: use token to retrieve data from redis
  @Modified gww
  for redis cluster, wo need to retrieve value of the 'token' according to corresponding feedback if redis cluster.
]]--
local function get_token_value(token)
    local res = ngx.location.capture("/r", {args = {key = token}});
    --for key, val in pairs(res) do
    --    logger.debug(key, '--', val)
    --end
    --ngx.say(res.status)
    --logger.debug(res.body)

    if res.status ~= 200 then
        logger.warn("%s %s", res.status, res.body)
        return nil
    end
    if string.find(res.body, 'MOVED') then
        _, ip, port = string.match(res.body, "-MOVED%s+(%d-)%s+(.-):(.*)")
        --ngx.say(ip, '--', port)
        reply = _get_token_value_helper(token, ip, port)
    else
        reply = parser.parse_reply(res.body)
    end

    if reply == nil or string.len(reply) == 0 then
        return nil
    end
--    logger.debug('redis reply: %s', reply)
    return str_utils.split(string.sub(reply, 2, -2), ',')
end


 function _get_token_value_helper(token, ip, port)
    local cache = redis.new()
    local ok, err = cache.connect(cache, ip, port)

    cache:set_timeout(1000)
    if not ok then
        logger.debug("failed to connect:" .. err)
        return nil
    end

    local res, err = cache:get(token)
    if not res then
        logger.warn("failed to get key with token[%s]: %s", token, err)
        return nil
    end
    if res == ngx.null then
        logger.warn("token[%s] not found", token)
        return nil
    end

    return res
    --return split(string.sub(res, 2, -2), ',')
end

local _M = {}

return setmetatable(_M, {
    __tostring = function(t)
        return "Reids Helper fetch value with token from redis"
    end,
    __index = {
        get_token_value = get_token_value
    }
})