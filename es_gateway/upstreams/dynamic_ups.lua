--
-- User: ������
-- Date: 2017/12/18
-- Description:
--    using this module, we can dynamicly add/remove/update upstreams servers,
--  in order to persist upstream configuration,  we providing an interface for persistence.
--  Using this interface  we  can save upstream configuration into file, redis  or databases.
--

local dispatcher_config =  require "es_gateway.core.request_dispatcher_config"
local gateway_conf =  require  "es_gateway.gateway_conf"
local logger = require "es_gateway.utils.logger"
local str = require "es_gateway.utils.string"
local cmd =  require "es_gateway.utils.cmd.reload"

local split = str.split
local upstreams = gateway_conf.upstreams

local typ_checks = {
    array = function(v) return type(v) == "table" end,
    string = function(v) return type(v) == "string" end,
    number = function(v) return type(v) == "number" end,
    boolean = function(v) return type(v) == "boolean" end,
    ngx_boolean = function(v) return v == "on" or v == "off" end
}

local _M = {}

-- @func load:  load upstream configuration
--   @param cluster_info:
--   eg:  elog#10.230.135.128:9200,10.230.135.127:9600,10.230.135.126:9200;ulog#10.230.135.128:9200,10.230.135.127:9600,10.230.135.126:9200
--
local function load(cluster_info)
    local cluster = split(cluster_info, ';')
    for _, v in ipairs(cluster) do
        local c = split(v, '#')
        upstreams[c[1]] = c[2]
    end

    for k, v in pairs(upstreams) do
        logger.debug("Cluster: %s, Ips: %s", k,  v)
    end
end

--
-- @func save: save upstream configuration to file by
--   call request_dispatcher_config.generate_upstreams_conf(gateway_conf, cluster_info)
--
local function save()
    local cluster_info
    for k,v in pairs(upstreams)  do
        if typ_checks.string(k) and typ_checks.string(v) then
            if cluster_info == nil then
                cluster_info = string.format("%s#%s", k, v)
            else
                cluster_info = string.format("%s;%s#%s", cluster_info, k, v)
            end
        end
    end
    dispatcher_config.generate_upstreams_conf(gateway_conf, cluster_info)
    cmd.reload()
end



function _M.get(cluster)
    if upstreams[cluster] ~= nil then
        logger.debug("get [%s] servers [%s]", cluster, upstreams[cluster])
        return upstreams[cluster]
    end
    return nil
end

function _M.add(cluster, server)
    --if server exists
    if upstreams[cluster]:find(server) then
        logger.debug("[%s] adding server [%s] already existed!", cluster, server)
        return
    end
    if cluster ~= nil and server ~= nil then
        upstreams[cluster] = string.format("%s,%s", upstreams[cluster], server)
        logger.debug("[%s] add server [%s] target: %s", cluster, server, upstreams[cluster])
    end
end

-- @funcs  remove
--   @param cluster: ����10.230.135.128:9200,10.230.135.127:9600
--
function _M.remove(cluster, server)
    local ups = upstreams[cluster]

    if cluster ~= nil and server ~= nil then
        local s, e = ups:find(server)
        if s == 1   then                               -- 1. server in the first
            upstreams[cluster] = str.lstrip(ups, server .. ',')
        elseif  e == #ups then                         -- 2. server in  the last
            upstreams[cluster] = str.rstrip(ups, ','  ..  server)
        elseif s ~= nil and e ~= nil then                          -- 3. server  in the  middle
            upstreams[cluster] = string.format("%s%s", ups:sub(1,s - 1), ups:sub(e + 2, #ups))
        end
        logger.debug("[%s] remove server [%s]  target: %s", ups, server, upstreams[cluster])
    end
end

function _M.update(cluster, servers)
    if cluster ~= nil and servers ~= nil then
        upstreams[cluster] = servers
        logger.debug("update [%s] with servers [%s]", cluster, servers)
    end
end


return setmetatable(_M, {
    __tostring = function(tb)
        return "Upstrems Module Used  to configure upstream Dynamically!"
    end,
    __index = {
        load = load,
        save =save
    }
})
