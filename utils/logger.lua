--[[
    @Date 2017-11-07
    @Description: logger module used to log msg convinencely, supporting turn ON/OFF logging message.

    NOTE: all retrieve infomation should be lower case ~_~
]]--

-- to reuse this module, define this file as a module which cause this module will be loaded only once. 
module('logger', package.seeall)

-- debug < info < warn < error
_M = {
    _LEVELS = {
        debug = 1,
        info = 2,
        warn = 3,
        error = 4
    }
}

local s_levels = {}
for k, v in pairs(_M._LEVELS) do
    s_levels[v] = k
end

_M.s_levels = s_levels
_M.default_level = _M._LEVELS.debug


function _M.setPriority(pri)
    if pri ~= nil and pri >= 0 then
        default_level = pri
    else
        default_level = 1
    end
end

function _M.trim(s)
    return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

--function format(level, msg)
--    str = "[ULOG GATEWAY LOG-".. level .. "] " .. msg
--    return str
--end

local function log(level, ...)
    local format
    local args = {...}

    if level >= _M.default_level then
        format = table.remove(args, 1)

        if type(format) ~= 'string' then
            print("expected argument to be a stirng")
            return
        end

        local msg
        if #args == 0 then
            msg = format
        else
            msg = string.format(format, unpack(args))
        end

        if _M.default_level >= _M._LEVELS.debug and level <= _M._LEVELS.error then
            msg = string.format('[ULOG GATEWAY] [%s] %s', s_levels[level] , msg)
            print(msg)
        end
    end
end

function _M.disable()
    _M.old_level = _M.default_level
    _M.default_level = 0xFF
end

function _M.enable()
    _M.default_level = _M.old_level
end


return setmetatable(_M, {
    __call = function(t, ...)
        local args = unpack({...})
        print('[logger] ' .. args)
    end,
    __tostring = function(t)
        return 'logger object'
    end,
    __index = function(t, key)
        if _M._LEVELS[key] then
            return function(...)
                log(_M._LEVELS[key], ...)
            end
        else
            print('[ERROR] WRONG Method')
        end
        return rawget(t, key)
    end
})
