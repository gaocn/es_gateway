--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/6
-- Description:
--    use lua pl.utils to execute Linux cmd to kill process with pid_file
--

local pl_path  = require "pl.path"
local logger = require "es_gateway.utils.logger"

local cmd_tmpl = [[kill %s `cat %s` > /dev/null 2&>1]]


--[[
--   signal -0: do nothing
--
 ]]
local function kill(pid_file, args)
    logger.debug("sending signal to pid at: %s", pid_file)
    local cmd = string.format(cmd_tmpl, args or "-0", pid_file)

    if pl_path.exists(pid_file) then
        logger.debug("cmd is: %s", cmd)
        local code = os.execute(cmd)
        return code
    else
        logger.warn("no pid file at: %s", pid_file)
        return false
    end
end

--[[
-- if process is running or sucessfully killed, then os.execute() return true
 ]]
local function is_running(pid_file)
    -- do our own pid_file exists check here because
    -- we want to return 'nil' in case of NOT running,
    -- and not '0' like 'kill' would return
    if pl_path.exists(pid_file) then
        return kill(pid_file) == true
    end
end

return {
    kill = kill,
    is_running = is_running
}

