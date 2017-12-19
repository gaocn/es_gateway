--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/18
-- Description: 
--
package.path = package.path ..';..\\?.lua';
local response = require "es_gateway.utils.response"
local logger = require "es_gateway.utils.logger"


--local M = {
--    status_code  = {
--        HTTP_203 = 203
--    }
--}
--local t = {
--    [M.status_code.HTTP_203]  = function() return "2" end
--}
--for k,v in  pairs(t) do
--    print(k, v)
--end

for k,  v  in  pairs(response)  do
    print(tostring(k), tostring(v))
end
--send function: 0x41673d10
--status_code table: 0x416755c8
--send_HTTP_CONFLICT function: 0x4166fad8
--send_HTTP_INTERNAL_SERVER_ERROR function: 0x4166c150
--send_HTTP_SESRVICE_UNAVAILABLE function: 0x4166fa78
--send_HTTP_METHOD_NOT_ALLOWED function: 0x41118c48
--send_HTTP_BAD_REQUEST function: 0x411177f0
--send_HTTP_UNAUTHORIZED function: 0x41118be0
--send_HTTP_CREATED function: 0x41664120
--send_HTTP_UNSUPPORTED_MEDIA_ERROR function: 0x4166c1c0
--send_HTTP_NO_CONTENT function: 0x41120410
--send_HTTP_NOT_FOUND function: 0x4111a138
--send_HTTP_FORBBIDDEN function: 0x411203b0
--send_HTTP_OK function: 0x4111a168

--response.send_HTTP_OK()