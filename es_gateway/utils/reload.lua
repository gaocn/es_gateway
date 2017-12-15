--
-- User: ╦ънднд
-- Date: 2017/12/15
-- Description:  relaod nginx server using nginx_signal
--

local nginx_signal = require "es_gateway.utils.nginx_signal"
local gateway_conf = require "es_gateway.gateway_conf"
local signal = nginx_signal.nignx_shell_helper

local function reload()
    ok, msg = signal(gateway_conf, "reload")
    return ok
end

return setmetatablt({}, {
    __index = {
        reload = reload
    }
})