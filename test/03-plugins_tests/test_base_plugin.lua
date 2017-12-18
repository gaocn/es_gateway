--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/18
-- Description: 
--
local base_plugin = require "es_gateway.plugins.base_plugin"

base_plugin:new("Test_Plugin")

base_plugin:init_worker()
base_plugin:certificate()
base_plugin:rewrite()
base_plugin:access()
base_plugin:header_filter()
base_plugin:body_filter()
base_plugin:log()

