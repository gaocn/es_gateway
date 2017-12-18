--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/15
-- Description:
--      string utility functions
--

local _M = {}

function _M.escape_line(id)
    res, cnt = string.gsub(id,'%-','_')
    return res
end

--[[
  function: split string into an array
  eg: str = 'str1, str2, str3'
    split(str) => {'str1', 'str2', 'str3'}
]]--
function _M.split(str, sep)
    local sep = sep or "\t"
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(str, pattern , function(w) fields[#fields + 1] = _M.escape_line(w) end)
    return fields
end

-- @func escape_wildcard: replace lua wildcard'-' to'_', may be used to repace other wildcard
--   @param s: string to be processed
-- @returns
--   @param res: processed result
--
function _M.escape_wildcard(s)
    res, cnt = string.gsub(s,'%-','_')
    return res
end

--[[
    for request args like:
      "?ClientIP=10.230.135.128"
      "?stored_field=&ClientIP=10.233.87.241"
    we need to truncate request parameter 'ClientIP', after processing we get
      nil  "?stored_field"
]]--
function _M.truncate(txt, pat)
    if txt ~= nil then
        end_pos = string.find(txt, pat)
        if end_pos ~= nil then
            txt = string.sub(txt, 1, end_pos - 1)
        end
    end
    return txt
end

--[[
    find_last index of needle in hasystack
    find_last('ulog_kibana_ulog', '_') return 12
]]--
function _M.find_last(haystack, needle)
    local i=haystack:match(".*"..needle.."()")
    if i==nil then return nil else return i-1 end
end


function _M.startswith(txt, pat)
    if txt == nil or pat == nil then
        return nil, "txt or pat parameter is nil"
    end

    if string.find(txt, pat) ~= 1 then
        return false
    else
        return true
    end
end

function  _M.endswith(txt, pat)
    if txt == nil or pat == nil then
        return nil, "txt or pat parameter is nil"
    end

    rtxt = string.reverse(txt)
    rpat = string.reverse(pat)
    if string.find(rtxt, rpat) ~= 1 then
        return false
    else
        return true
    end
end


function _M.lstrip(txt, pat)
    if txt == nil or pat == nil then
        return nil, "txt or pat parameter is nil"
    end
    local res
    if _M.startswith(txt, pat) then
        res = string.sub(txt, #pat + 1)
        return res
    end
    return txt
end

function _M.rstrip(txt, pat)
    if txt == nil or pat == nil then
        return nil, "txt or pat parameter is nil"
    end
    local res
    if _M.endswith(txt, pat) then
        res = string.sub(txt, 1, #txt - #pat)
        return res
    end
    return txt
end

return _M