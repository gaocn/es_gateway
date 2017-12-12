--[[
    @Date 2017-08-29
    @Description: dynamically configure upstream for different elasticsearch clusters
      by call MIP interface to fetch information of elasticsearch clusters

    NOTE: all retrieve infomation should be lower case ~_~

    @refactor: 2017/12/09  by gww
]]--

-- to reuse this module, define this file as a module which cause this module will be loaded only once. 
--module('request_dispatcher_config', package.seeall)

local logger = require "es_gateway.utils.logger"
-- local gateway_conf = require "es_gateway.gateway_conf"
--local fileName="/home/sm01/openresty-1.11.2/nginx/conf/es_cluster_upstream.conf"
--local SYSTEM_CLUSTER_MAP = ngx.shared.system_cluster_map

--[[ @func: split string into an array
     EG: str = 'str1, str2, str3'
         split(str) => {'str1', 'str2', 'str3'}
]]--
local function split(str, sep)
    local sep = sep or "\t"
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(str, pattern , function(w) fields[#fields + 1] = w end)
    return fields
end

-- 
--  @refactor:
--     rename function from writeUpstream to generate_upstream_conf_helper
-- 
local function generate_upstream_conf_helper(upstream_conf_file_path, upstream_name, addresses, mode)

    logger.debug("generate upstream conf %s!", upstream_conf_file_path)
    local mode= mode or 'w+b'
    
    local file = io.open(upstream_conf_file_path, mode)
    if not file then
       logger.debug("open file %s failed!", upstream_conf_file_path)
       return false
    end
    
    header = 'upstream ' .. upstream_name .. '{\n'
    logger.debug(header)
    if file:write(header) == nil then
        logger.debug('write file %s failed!', upstream_conf_file_path)
        return false 
    end
    
    for _, addr in ipairs(split(addresses, ',')) do
        addr = 'server ' .. addr .. ' weight=1 max_fails=2 fail_timeout=10;\n'
        logger.debug(addr)
        if file:write(addr) == nil then
            logger.debug('write file %s failed!', upstream_conf_file_path)
            return false 
        end
    end
    footer = '}\n'
    logger.debug(footer)
    if file:write(footer) == nil then
        logger.debug('write file failed!')
        return false 
    end
    io.flush(file)
    io.close(file)
end


local _M = {}

--[[ @func: cache mapping information between system_id and cluster, retrieve 
            system_id and cluster infomation format from MIP interface
       @param mapping_info: string
                format: system_id:cluster_name;[system_id:cluster_name;]
           EG:
                "ararat:elog;beehive:ulog;e3c-mip:ulog:mank:ulog:qpay:ulog"
     @refactor: 2017/12/09
         rename function from generateSystemClusterMap to hash_system_cluster_map
]]--
function _M.hash_system_cluster_map(gateway_conf, mapping_info)
   
   system_cluster_map = gateway_conf.system_cluster_map
   logger.debug('*#*# ~_~  #*#*',mapping_info)

   for _, val in ipairs(split(mapping_info, ';')) do
      item = split(val, '#')
      --logger:debug(item[1] .. item[2])
      system_cluster_map[item[1]] = item[2]
   end

    --for k, v in pairs(ngx.shared.system_cluster_map) do
    --    logger.debug("%s -- %s", k, v)
    --end 
end

 --[[ @func: generate upstream cluster conf file, retrieve cluster 
             infomation format from MIP interfance
        @param cluster_info: string 
               format: clcluster_name:ip1[,ip2];[cluster_name:ip1[,ip2];]
            EG:
               "ulog:10.230.135.128:9200,10.230.135.127:9600;elog:10.230.135.128:9200,01.230.135.127:9200"
       @refactor: 2017/12/09
           rename function from generateEsDispatcherUpstreams to generate_upstreams_conf
]]--
function _M.generate_upstreams_conf(gateway_conf, cluster_info)

    local upstream_conf_file_path = gateway_conf.upstream_conf_path
    -- make sure generate a new configuration from beginning 
    --  and delete old content in the conf file 
    isWriten = false

    for _, val in ipairs(split(cluster_info, ';')) do
       item = split(val, '#')
        if isWriten then
           mode = 'a+b'
        else
           mode = 'w+b'
        end
        generate_upstream_conf_helper(upstream_conf_file_path, item[1], item[2], mode)
        isWriten = true
    end
end

return setmetatable(_M, {
    __tostring = function(tb) 
        return "[Request Dispatcher do previous configuration before do dispatch requests!]"
    end,
    __index = {
        -- for test
        split = split
    }
})

--*****************************   UNIT TEST   ************************************--
-- init shared dict, and store it into share momery
--generateSystemClusterMap()
--generateEsDispatcherUpstreams()
