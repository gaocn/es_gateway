--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/6
-- Description: 
--
package.path = package.path ..';..\\?.lua';

local logger = require "es_gateway.utils.logger"

logger.info("%s ---- %s", "This is a test", 'hello wordl')
logger.disable()
logger.debug("%s ---- %s", "This is a test", 'hello wordl')
logger.warn("%s ---- %s", "This is a test", 'hello wordl')
logger.enable()
logger.error("%s ---- %s", "This is a test", 'hello wordl')

print(logger)
logger('a', 'b')

a={1}

print(#a)

table.remove(a, 1)
print(#a)

if #a == 0 then
    print("nil")
end