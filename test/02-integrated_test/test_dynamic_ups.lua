--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/18
-- Description: 
--
package.path = package.path ..';..\\?.lua';

local logger = require "es_gateway.utils.logger"
local upstreams = require "es_gateway.upstreams.dynamic_ups"

local server = "10.230.135.128:9200"
upstreams.add('ulog', server)

local server = "10.230.135.128:9200"
upstreams.remove('ulog', server)

server = "10.230.135.127:9600"
upstreams.remove('ulog', server)

server  = "10.230.135.128:9200,10.233.87.54:9200,10.230.135.127:9600"
upstreams.update('ulog', server)

server = "10.233.87.54:9200"
upstreams.remove('ulog', server)

logger.debug(upstreams.get())

-- test save
--upstreams.save()
