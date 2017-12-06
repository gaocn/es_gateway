--
-- User: ╦ънднд
-- Date: 2017/12/6
-- Description: 
--
package.path = package.path ..';..\\?.lua';

local killer = require "es_gateway.utils.kill"

print('TEST KILL')

pid_file = "/home/sm01/openresty-1.11.2/nginx/logs/nginx.pid"

--killer.kill(pid_file)
print(killer.is_running(pid_file) == 0)


