--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/18
-- Description:
--     helper methods to send HTTP responses to clients.
-- Most used HTTP status codes and responses are implemented as helper methods.
-- @copyright
-- @license [Apache 2.0](https://opensource.org/licenses/Apache-2.0)
-- @module es_gateway.utils.responses
-- @usage
--    local responses = require "es_gateway.utils.responses"
--
--    -- in one of the plugins' phases.
--    -- the `return` keyword is optional since the execution will be stopped
--    -- anyways. It simply improves code readability.
--    return responses.send_HTTP_OK()
--
--    -- Or:
--    return responses.send_HTTP_NOT_FOUND("No entity for given id")
--
--    -- Raw send() helper:
--    return responses.send(418, "This is a teapot")

local cjson = require "cjson.safe"
local meta = require "es_gateway.meta"
local logger = require "es_gateway.utils.logger"

local server_header = string.format("%s/%s", meta._NAME, meta._VERSION)

---Define the most common HTTP status codes for sugar methods, each of those status will have
-- a  shortcut method(sugar),  which is prefixed by "send_".
-- those shortcut method's signature is "send_<STATUS_CODE_KEY>(message,headers)"
-- @field HTTP_OK 200 OK
-- @field HTTP_CREATED 201 Created
-- @field HTTP_NO_CONTENT 204 No Content
-- @field HTTP_BAD_REQUEST 400 Bad Request
-- @field HTTP_UNAUTHORIZED 401 Unauthorized
-- @field HTTP_FORBIDDEN 403 Forbidden
-- @field HTTP_NOT_FOUND 404 Not Found
-- @field HTTP_METHOD_NOT_ALLOWED 405 Method Not Allowed
-- @field HTTP_CONFLICT 409 Conflict
-- @field HTTP_UNSUPPORTED_MEDIA_TYPE 415 Unsupported Media Type
-- @field HTTP_INTERNAL_SERVER_ERROR Internal Server Error
-- @field HTTP_SERVICE_UNAVAILABLE 503 Service Unavailable

local _M = {
    status_code = {
        HTTP_OK = 200,
        HTTP_CREATED = 201,
        HTTP_NO_CONTENT = 204,

        HTTP_BAD_REQUEST = 400,
        HTTP_UNAUTHORIZED = 401,
        HTTP_FORBBIDDEN = 403,
        HTTP_NOT_FOUND = 404,
        HTTP_METHOD_NOT_ALLOWED  = 405,
        HTTP_CONFLICT = 409,
        HTTP_UNSUPPORTED_MEDIA_ERROR = 415,

        HTTP_INTERNAL_SERVER_ERROR = 501,
        HTTP_SESRVICE_UNAVAILABLE = 503,
    }
}

-- Define default response bodies for some status codes.
local responses_default_content = {
    [_M.status_code.HTTP_UNAUTHORIZED] = function(content)
        return content or "Unauthorized"
    end,
    [_M.status_code.HTTP_NO_CONTENT] =  function(content)
        return  nil
    end,
    [_M.status_code.HTTP_NOT_FOUND] = function(content)
        return content or "Not Found"
    end,
    [_M.status_code.HTTP_INTERNAL_SERVER_ERROR] = function(content)
        return content or "An Unexpected Error Occured"
    end,
    [_M.status_code.HTTP_METHOD_NOT_ALLOWED] = function(content)
        return content or "Method Not Allowed"
    end,
    [_M.status_code.HTTP_SESRVICE_UNAVAILABLE] = function(content)
        return content or "Service Unavailable"
    end
}

--- @func send_response:  return a closure  which respond with a certain status code
--    @param[type=number] status_code
--
local function send_response(status_code)
    --- @func : send a JSON response with content and headers corressponding to status code
    --   If the content  happens to be an error(500)£¬it will be  logged  by ngx.log as an  ERR
    -- @see   https://github.com/openresty/lua-nginx-module
    --
    -- @return ngx.exit(Exit current context)
    return function(content, headers)
        if status_code == _M.status_code.HTTP_INTERNAL_SERVER_ERROR  then
            if content then ngx.log(ngx.ERR, tostring(content)) end
        end

        ngx.status = status_code
        ngx.header['Content-Type'] = 'application/json; charset=utf-8'
        ngx.header['Server'] = server_header

        if headers then
            for k, v  in pairs(headers) do
                ngx.header[k] =  v
            end
        end

        if type(responses_default_content[status_code]) == 'function' then
            content = responses_default_content[status_code](content)
        end

        local encoded, err

        if content then
            encoded, err = cjson.encode(type(content) == 'table' and content or {message = content})

            if not encoded then
                ngx.log(ngx.ERR, '[admin] could not encode value: ', err)
            end

            ngx.say(encoded)
        end

        return ngx.exit(status_code)
    end
end

-- Generate sugar methods for all  default status codes
--
for status_code_name, status_code in pairs(_M.status_code) do
    _M['send_' .. status_code_name] = send_response(status_code)
end

local closure_cache = {}

---  @func send : Not all status code  are available as sugar methods, this
--       function can  be used to send any response
--     @param status_code :  http  response status
--     @param body : string or table  used to be the body of send response. table  will be  encoded  by cjson  directly.
--           string will be transformed to table using format "{message: body}", which will  be encoded  by  cjson
--     @param  headers : http response  headers
function _M.send(status_code, body, headers)
    local  res = closure_cache[status_code]
    if not res then
        res = send_response(status_code)
        closure_cache[status_code] = res
    end
    return  res(body, headers)
end

---  TESTS
--for k,v  in  paires(_M) do
--    print(k, v)
--end

return _M
