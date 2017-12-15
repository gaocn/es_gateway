--[[    
    @Author gww
    @Date   2017-05-05
    @Description: read and parse api.acl to hash table, and 
	
#    lua read this file and parse relevant data for later use, for every request with uri:
#       if URI is ON, then nginx allow this request.
#       if URI is OFF, then nginx deny this request.
#********************************************************************************************
#format: URI [ALL,HEAD,GET,PUT^LPOST,DELETE]  [ON|OFF]
#exapmle: 
#         /_refresh ALL OFF
#        /_settings HEAD,GET ON
#Note: in order to accelerate process speed, this file is read only once at the start of nginx
#
]]--

local logger = require "es_gateway.utils.logger"
local gateway_conf = require "es_gateway.gateway_conf"
local dispatcher_config = require "es_gateway.core.request_dispatcher_config"

-- @Refactor 
-- local config = '/home/sm01/openresty-1.11.2/config'
-- local ACL_TABLE = ngx.shared.acl_table
-- local aclFile = '/home/sm01/openresty-1.11.2/nginx/conf/lua/api.acl'
local init_config = gateway_conf.init_config
local ACL_TABLE = gateway_conf.acl_table
local acl_conf = gateway_conf.acl_conf


local function load_ACL(fileName)
    local acl = assert(io.open(fileName, 'r'))
    for line in acl:lines() do
        if string.match(line, '^#') == nil then
            if string.match(line, '^%s*$') == nil then
                uri, method, on_off = string.match(line, "(.-)%s+(.-)%s+([%a]+)")
                --print(uri, '--', method, '--', on_off)
	            if uri ~= nil then
            	    local tb = {}
            	    tb['method'] = method
            	    tb['on_off'] = on_off
            	    ACL_TABLE[uri] = tb
	            end
             end
        end
    end
    --[[print ACL_TABLE
    for key,value in pairs(ACL_TABLE) do
        print(key,'--', value['method'],'--', value['on_off'])
    end]]--
    acl:close()
end

--[[    
    #    lua read this file and parse relevant data for later use.
    #********************************************************************************************
    #format: SERVER[0-9]{1,} IP:PORT
    #exapmle: 
    #        SERVER1 10.230.135.126:7000
    #        SERVER2 10.230.135.126:7001
    #Note: in order to accelerate process speed, this file is read only once at the start of nginx
    #
    local REDIS_CONFIG = ngx.shared.redis_config
    local redisConfigFile = '/home/sm01/openresty-1.11.2/nginx/conf/redis.config'
    function loadRedisConfig(fileName)
        local fd = assert(io.open(fileName, 'r'))
        for line in fd:lines() do
            if string.match(line, '^#') == nil then
                if string.match(line, '^%s*$') == nil then
                    server, addr = string.match(line, "(.-)%s+(.*)")
                    --print(server, '--', addr)
                    if server ~= nil then
                        REDIS_CONFIG[server] = addr
                    end
                end
            end
        end
            fd:close()
    end
]]--

local welcome = [[

--**********************************************************************************
--*                                MAIN  ENTRY                                     *
-- ULOG TEAM,  ULOG GATEWAY ENTRY  POINT, YOUR LOVELY KEEPER.                      *
--
--     /\ 
--     <> 
--     <>
--     <>  
--    /~~\ 
--   /~~~~\ 
--  /~~~~~~\
--  |[][][[]
--  |[][][[]
--  |[][][]|
--  |[][][]|
--  |[][][]|
--  |[][][]|
--  |[][][]|
--  |[][][]|
--  |[][][]|
--  |[][][]|
--  |[|--|]| 
--  |[|  |]|
--  ========
-- ==========
-- |[[    ]|]
-- ==========
--**********************************************************************************
]]

local _M = {}

function _M.init()
    -- init shared dict, and store it into share momery
    load_ACL(acl_conf)

    local fd = assert(io.open(init_config, 'r'))
    local system_cluster_info = fd:read()
    local cluster_info = fd:read()
    fd:close()

    logger.debug("System_cluster_info: %s", system_cluster_info)
    logger.debug("cluster_info: %s", cluster_info)
    dispatcher_config.hash_system_cluster_map(gateway_conf, system_cluster_info)
    dispatcher_config.generate_upstreams_conf(gateway_conf, cluster_info)
end

function _M.welcome()
    logger.debug(welcome)
end

return _M