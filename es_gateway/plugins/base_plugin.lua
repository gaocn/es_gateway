--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/18
-- Description: base plugin
--
local Object = require "es_gateway.vendor.classic"
local BasePlugin = Object:extend()

local ngx_log = ngx.log
local DEBUG = ngx.DEBUG

function BasePlugin:new(name)
    self._name = name
end

-- init_worker_by_lua
-- Executed upon every Nginx worker process's startup.
function BasePlugin:init_worker()
    ngx_log(DEBUG, "executing plugin \"", self._name, "\": init_worker")
end

---ssl_certificate_by_lua_block
--Executed during the SSL certificate serving phase of the SSL handshake.
function BasePlugin:certificate()
    ngx_log(DEBUG, "execcuting  plugin \"", self._name, "\":  certificate")
end

---rewrite_by_lua_block
-- Executed for every request upon its reception from a client as a rewrite phase handler.
--NOTE in this phase neither the api nor the consumer have been identified, hence this handler
--will only be executed if the plugin was configured as a global plugin!
--
function BasePlugin:rewrite()
    ngx_log(DEBUG, "execcuting  plugin \"", self._name, "\":  rewrite")
end

---access_by_lua
--Executed for every request from a client and before it is being proxied to the upstream service.
function BasePlugin:access()
    ngx_log(DEBUG, "execcuting  plugin \"", self._name, "\":  access")
end

---header_filter_by_lua
--Executed when all response headers bytes have been received from the upstream service.
--
function BasePlugin:header_filter()
    ngx_log(DEBUG, "execcuting  plugin \"", self._name, "\":  header_filter")
end

---body_filter_by_lua
--Executed for each chunk of the response body received from the upstream service.
-- Since the response is streamed back to the client, it can exceed the buffer size
--and be streamed chunk by chunk. hence this method can be called multiple times if the response is large.
--@See the lua-nginx-module documentation for more details.
--
function BasePlugin:body_filter()
    ngx_log(DEBUG, "execcuting  plugin \"", self._name, "\":  body_filter")
end

---log_by_lua
-- Executed when the last response byte has been sent to the client.
--
function BasePlugin:log()
    ngx_log(DEBUG, "execcuting  plugin \"", self._name, "\":  log")
end

return  BasePlugin
