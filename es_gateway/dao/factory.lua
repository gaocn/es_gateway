--
-- User: ╦ънднд
-- Date: 2017/12/19
-- Description:
--
local Object = require "es_gateway.vendor.classic"
local DAO =  Object:extend()

DAO.ret_error = 'STUB'

function DAO:find_all()
    local plugins  =  {}
    plugins[1] = 'request_termination'
    return plugins, DAO.ret_error
end

return DAO