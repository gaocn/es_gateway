--
-- User: ╦ънднд
-- Date: 2017/12/15
-- Description:  relaod nginx server using nginx_signal
--

local nginx_signal = require "es_gateway.utils.nginx_signals"
local gateway_conf = require "es_gateway.gateway_conf"
local signal = nginx_signal.nignx_shell_helper

local function reload()
    ok, msg = signal(gateway_conf, "reload")
    if ok then
        msg = "reload nginx successfully!"
    end
    return msg
end

return setmetatable({}, {
    __index = {
        reload = reload
    }
})