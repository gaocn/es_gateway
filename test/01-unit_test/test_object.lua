--
-- User: ╦ънднд
-- Date: 2017/12/18
-- Description: 
--
package.path = package.path ..';..\\?.lua';
local Object = require "es_gateway.vendor.classic"
local cls = Object:extend()

function cls:new(name)
    self._name = name
end


for k, v  in pairs(cls) do
    print(k, v)
end
print(cls:is(Object))
print(tostring(cls))