--
-- User: 高文文
-- Date: 2017/12/12
-- Description: 
--

package.path = package.path ..';..\\?.lua';

local logger = require "es_gateway.utils.logger"
local gateway_cong = require "es_gateway.gateway_conf"

local dispatcher_conf = require "es_gateway.core.request_dispatcher_config"


--  TEST   for request_dispatcher_conf

logger.debug("[TEST] init_config file: %s", gateway_cong.init_config)

local config = gateway_cong.init_config
local fd = assert(io.open(config, 'r'))
local systemClusterInfo = fd:read()
local clusterInfo = fd:read()
fd:close()

logger.debug("[TEST]sysClusterInfo: %s, ClusterInfo: %s", systemClusterInfo, clusterInfo)


dispatcher_conf.hash_system_cluster_map(gateway_cong, systemClusterInfo)
dispatcher_conf.generate_upstreams_conf(gateway_cong, clusterInfo)


logger.debug(tostring(dispatcher_conf))

--  TEST   for request_dispatcher
local dispatcher = require "es_gateway.core.request_dispatcher"
logger.debug(tostring(dispatcher))

-- 需要在集成测试环境
--dispatcher.dispatch_kibana_request()
--dispatcher.dispatch_sql_request()
--dispatcher.dispatch_request()


