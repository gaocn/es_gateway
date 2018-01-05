--
-- User: ������
-- Date: 2017/12/6
-- Description: 
--
package.path = package.path ..';..\\?.lua';

local conf = require "es_gateway.gateway_conf"

assert(conf)




for k, v in pairs(conf) do
--    print(type(k) .. '  ' ..  type(v))
    if type(v) == 'string'  then
        print(string.format("%s = %s", k, v))
    elseif type(v) == 'table' then
        print(string.format("%s: {", k))
        for key, value in pairs(v) do
            print(string.format("   %s = %s", key, tostring(value)))
        end
        print("}")
    end
end
