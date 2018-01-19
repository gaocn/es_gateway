--
-- User: ¸ßÎÄÎÄ
-- Date: 2018/1/19
-- Description:
--

local fmt = string.format


local _M = {}

-- @func trim_and_delete_LF: trim space and delete LF from string
--   @param s: stirng
-- @returns
--   @param o: cmd output
local function trim_and_delete_LF(s)
    return string.gsub(s, "^%s*(.-)%s*[\n]*$", "%1")
end

-- @func shell: Perform a shell command and return its output
--   @param c: command
-- @returns
--   @param o: output, or nil if error
-- NOTES: out_file_name out path is: /home/sm01/openresty-1.11.2/lua.output
function _M.shell (c)
    if not c then
        logger.warn("shell cmd is nil")
        return nil
    end
    local out_file_name = "lua.output"
    local ok = os.execute (fmt("%s > %s 2>&1", c, out_file_name))
    local fd
    local o
    if ok then
        fd = assert(io.open(out_file_name))
        o = fd:read ("*a")
        fd:close ()
    end

    -- delete out_file_name
    os.remove(out_file_name)
    if not o then
        return nil
    end
    return trim_and_delete_LF(o)
end


return _M
