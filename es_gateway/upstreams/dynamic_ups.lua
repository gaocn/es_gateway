--
-- User: gww
-- Date: 2017/12/18
-- Description:
--    using this module, we can dynamicly add/remove/update upstreams servers,
--  in order to persist upstream configuration,  we providing an interface for persistence.
--  Using this interface  we  can save upstream configuration into file, redis  or databases.
--

local dispatcher_config =  require "es_gateway.core.request_dispatcher_config"
local gateway_conf =  require  "es_gateway.gateway_conf"
local logger = require "es_gateway.utils.logger"
local response = require "es_gateway.utils.response"
local str = require "es_gateway.utils.string"
local cmd =  require "es_gateway.utils.cmd.reload"
local handler =  require "es_gateway.core.handler"
local json  = require "cjson.safe"

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

local  function update_config(cluster_info, system_cluster_info)
    local fd = assert(io.open(gateway_conf.init_config, 'r'))
    local fd_system_cluster_info = fd:read()
    local fd_cluster_info = fd:read()
    fd:close()

    if cluster_info then
        fd_cluster_info = cluster_info
    end
    if  system_cluster_info then
        fd_system_cluster_info = system_cluster_info
    end

    fd = assert(io.open(gateway_conf.init_config, 'w+'))
    fd:write(string.format("%s\n%s\n",fd_system_cluster_info, fd_cluster_info))
    fd:close()

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
    update_config(cluster_info)
    cmd.reload_without_call_mip()
end


function _M.get(cluster)
    if upstreams[cluster] ~= nil then
        logger.debug("get [%s] servers [%s]", cluster, upstreams[cluster])
        return upstreams[cluster]
    end
    return nil
end

---
-- @param cluster
-- @param server one server address once a time
--
function _M.add(cluster, server)
    if cluster == nil or server == nil then
        return  false
    end

    --if server exists
    if upstreams[cluster]:find(server) then
        logger.debug("[%s] adding server [%s] already existed!", cluster, server)
        return false
    end
    --TODO 验证serve的合法性

    if cluster ~= nil and server ~= nil then
        upstreams[cluster] = string.format("%s,%s", upstreams[cluster], server)
        _M.save()
        logger.debug("[%s] add server [%s] target: %s", cluster, server, upstreams[cluster])
        return true
    end
    return false
end

--- @funcs  remove
--   @param cluster: 例如10.230.135.128:9200,10.230.135.127:9600
--  @bug 这可能是一个bug但是没有修改，原因是：为了保证上有服务器之上有一个可用地址，当仅仅存在一个服务器地址时，删除该服务器地址的操作不生效
--  NOTE: delete a server address once a time
--
function _M.remove(cluster, server)
    if cluster == nil or server == nil then
        return  false
    end

    local ups = upstreams[cluster]

    if cluster ~= nil and server ~= nil then
        local s, e = ups:find(server)
        if s == 1   then                               -- 1. server in the first
            upstreams[cluster] = str.lstrip(ups, server .. ',')
        elseif  e == #ups then                         -- 2. server in  the last
            upstreams[cluster] = str.rstrip(ups, ','  ..  server)
        elseif s ~= nil and e ~= nil then                          -- 3. server  in the  middle
            upstreams[cluster] = string.format("%s%s", ups:sub(1,s - 1), ups:sub(e + 2, #ups))
        else
            return false
        end
        _M.save()
        logger.debug("[%s] remove server [%s]  target: %s", ups, server, upstreams[cluster])
        return true
    end
    return false
end

function _M.update(cluster, servers)
    if cluster ~= nil and servers ~= nil then
        upstreams[cluster] = servers
        _M.save()
        logger.debug("update [%s] with servers [%s]", cluster, servers)
        return true
    end
    return false
end

--- @func  process: process request from /upstream/*, a temporary method to process upstream configuration
-- 
local process_helper = {
    ["/upstream/show"] = function(cluster, servers)
        return _M.get(cluster)
    end,
    ["/upstream/add"] =  function(cluster, servers)
        return _M.add(cluster, servers)
    end,
    ["/upstream/remove"] =  function(cluster, servers)
        return _M.remove(cluster, servers)
    end,
    ["/upstream/update"] = function(cluster, servers)
        return _M.update(cluster, servers)
    end
}

local  function process()
    local jsonT
    local request_method = ngx.var.request_method
    local action = string.lower(ngx.var.uri)
    local http_body = handler.http_body()
    local ret = {}

    if http_body and request_method  == 'POST' then

        logger.debug("Uri: %s, HTTP BODY: %s, Method: %s",  action, http_body,request_method)

        jsonT = json.decode(http_body)

        if not jsonT or not jsonT['cluster'] then
            ret['message'] = 'Illegal Request Body!'
            response.send(400, ret)
        end

        if action and process_helper[action] then
            local ok

            if jsonT['servers'] then
                ok =  process_helper[action](jsonT['cluster'], jsonT['servers'])
            else
                ok =  process_helper[action](jsonT['cluster'])
            end
            ret['result'] = tostring(ok)
            ret['action'] = action
            response.send(200, ret)
        end
    else
        ret['message'] = 'wrong request method(only POST is allowed) or empty body!'
        response.send(400, ret)
    end
end


return setmetatable(_M, {
    __tostring = function(tb)
        return "Upstrems Module Used  to configure upstream Dynamically!"
    end,
    __index = {
        load = load,
        save =save,
        process = process
    }
})
