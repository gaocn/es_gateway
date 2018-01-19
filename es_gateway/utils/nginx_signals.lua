--
-- User: 高文文
-- Date: 2017/12/6
-- Description:
--     used to send signals to nginx process, such as: reload, stop , start,
--

local pl_path = require "pl.path"
local meta = require "es_gateway.meta"
local gw_conf = require "es_gateway.gateway_conf"
local kill = require "es_gateway.utils.kill"
local logger = require "es_gateway.utils.logger"
local verison = require "es_gateway.utils.version"
local sh =  require "es_gateway.utils.cmd.shell"
local shell = sh.shell
local fmt = string.format


local nginx_bin_name = "nginx"
local nginx_helper_shell_name = "default_nginx.sh"
local nginx_search_paths = gw_conf.nginx_search_paths
--{
--    "/home/sm01/openresty-1.11.2/nginx/sbin",
--    "/home/sm01/openresty-1.11.2"
--}

local nginx_version_pattern = "^nginx version: openresty/([%d%.]+)$"
local nginx_compatible = unpack(meta._DEPENDENCIES.openresty)


-- @func trim_and_delete_LF: trim space and delete LF from string
--   @param s: stirng
-- @returns
--   @param o: cmd output  
--local function trim_and_delete_LF(s)
--    return string.gsub(s, "^%s*(.-)%s*[\n]*$", "%1")
--end

-- @func shell: Perform a shell command and return its output
--   @param c: command
-- @returns
--   @param o: output, or nil if error
-- NOTES: out_file_name out path is: /home/sm01/openresty-1.11.2/lua.output
--local function shell (c)
--    if not c then
--        logger.warn("shell cmd is nil")
--        return nil
--    end
--    local out_file_name = "lua.output"
--    local ok = os.execute (fmt("%s > %s 2>&1", c, out_file_name))
--    local fd
--    local o
--    if ok then
--        fd = assert(io.open(out_file_name))
--        o = fd:read ("*a")
--        fd:close ()
--    end
--
--     delete out_file_name
--    os.remove(out_file_name)
--    if not o then
--        return nil
--    end
--    return trim_and_delete_LF(o)
--end

--
--  @func is_openresty: Test if this openresty verison is compatiable with meta._DEPENDENCIES.openresty
--    @param bin_path:string
--  @returns
--    @param : boolean
-- [CMD]
--    #>./nginx/sbin/nginx -v
--    nginx version: openresty/1.11.2.2
-- NOTES: io.shell: print cmd output. DEPENDENCY: io.ext.lua
-- 
local function is_openresty(bin_path)
    local cmd = fmt("%s -v", bin_path)
    logger.debug("CMD: %s", cmd)

    local out = shell(cmd)
    if out then
        logger.debug("%s: '%s'", cmd, out)
        local version_match = string.match(out, nginx_version_pattern)

        if not version_match or nginx_compatible ~= version_match then
            logger.warn("Incompatiable OpenResty found at %s. ULOG GATEWAY requires version" ..
                     " %s, got %s", bin_path, tostring(nginx_compatible), version_match)
            return false
        end
        return true
    end
    logger.debug("OpenResty 'nginx' executable not found at %s", bin_path)
end

-- 
-- @func find_nginx_bin: find nginx bin path 
-- @returns
--   @param found: nginx bin path, if not found, reutrn nil and error message.
-- 
local function find_nginx_bin()
    logger.debug("Search for OpenResty 'nginx' executable")
    
    local found
    for _, path in ipairs(nginx_search_paths) do 
        local path_to_check = pl_path.join(path, nginx_bin_name)
        if pl_path.exists(path_to_check) and is_openresty(path_to_check) then
            found = path_to_check
            logger.debug("found OpenResty 'nginx' executable at %s", found)
            break
        end
    end

    if not found then
        return nil, ("could not find OpenResty 'nginx' executable. Kong requires" ..
                 " version %s"):format(tostring(nginx_compatible))
    end
    return found
end

local function find_nginx_helper_shell()
    logger.debug("Search for OpenResty helper shell[%s]", nginx_helper_shell_name)

    local found
    for _, path in ipairs(nginx_search_paths) do
        local path_to_check = pl_path.join(path, nginx_helper_shell_name)
        if pl_path.exists(path_to_check) then
            found = path_to_check
            logger.debug("found OpenResty helper shell[%s]", nginx_helper_shell_name)
            break
        end
    end

    if not found then
        return nil, fmt("can not found OpenResty helper shell[%s]", nginx_helper_shell_name)
    end
    return found
end


-- 
-- @func send_signal: send signal to nginx process(start, reload, stop)
--   @param nginx_pid_file: nginx pid file path
--   @parma signal: QUIT TERM ...
-- @returns
--   @params true if succeed, else return nil and error message
-- 
local function send_signal(nginx_pid_file, signal)
    if not kill.is_running(nginx_pid_file) then
        return nil, "nginx not running"
    end

    logger.debug("sending %s signal to nginx running at %s", signal,shell(fmt("cat %s", nginx_pid_file)))

    local code = kill.kill(nginx_pid_file, "-s " .. signal)
    if not code then
        return nil, "could not send signal"
    end
    return true
end

_M = {}

-- @func: start nginx process 
function _M.start(gateway_conf)
    local nginx_bin, err = find_nginx_bin()
    if not nginx_bin then
        return nil, err
    end

    if kill.is_running(gateway_conf.nginx_pid) then
        return nil, "nginx is already running in " .. gateway_conf.nginx_dir
    end

    local cmd = fmt("%s -p %s -c %s", nginx_bin, gateway_conf.nginx_dir, "nginx.conf")
    
    logger.debug("starting nginx: %s", cmd)

    local ok = os.execute(cmd)
    if not ok then
        return nil, "start nginx failed!"
    end

    logger.debug("nginx started!")
    return true
end

-- @func stop
-- [TERM] kill -9
function _M.stop(gateway_conf) 
    return send_signal(gateway_conf.nginx_pid, "TERM")
end

-- @ func quit: [QUIT]  kill 9 pid   gracefully kill process
-- 
function _M.quit(gateway_conf)
    return send_signal(gateway_conf.nginx_pid, "QUIT")
end


function _M.reload(gateway_conf)
    if not kill.is_running(gateway_conf.nginx_pid) then
        return nil, "nginx not running in dir: " .. gateway_conf.nginx_dir 
    end

    local nginx_bin, err = find_nginx_bin()
    if not nginx_bin then
        return nil, err
    end

    local cmd = fmt("%s -p %s -c %s -s %s", nginx_bin, gateway_conf.nginx_dir, gateway_conf.conf, "reload")

    logger.debug("reloading nginx: %s", cmd)

    local ok = os.execute(cmd)
    if not ok then
        return nil, "reload nginx failed!"
    end
    return true
end

-- @func nginx_shell_helper: use shell scripe 'default_nginx.sh ', 
--       to [stop|start|reload] nginx process
--   @param gateway_conf: ngin configuration
--   @param signal: start|stop|reload
-- @reutrns
--   @param true if execute shell successfully, else return nil and error message
-- NOTES: we should be careful when using shell command "stop"
function _M.nignx_shell_helper(gateway_conf, signal)
    local nginx_helper_shell_path, err = find_nginx_helper_shell()

    if not nginx_helper_shell_path then
        return nil, err
    end

    local nginx_is_running = kill.is_running(gateway_conf.nginx_pid)

    if signal == 'start' and nginx_is_running then
        return nil, "nginx is already running in " .. shell(fmt("cat %s", gateway_conf.nginx_pid))
    elseif signal == 'stop' and not nginx_is_running then
        return nil, "nginx is already stoped"
    elseif signal == 'reload' and not nginx_is_running then
        return nil, "nginx is already stoped"
    end

    cmd = fmt("%s %s", nginx_helper_shell_path, signal)

    logger.debug("execute nginx helper shell: %s", cmd)

    local ok = os.execute(cmd)

    if not ok then
        return nil, "execute nginx helper shell failed!"
    end
    return true
end

return setmetatable(_M, {
    __index = {
        -- for test
        shell = shell,
        send_signal = send_signal,
        is_openresty = is_openresty,
        find_nginx_bin = find_nginx_bin,
        find_nginx_helper_shell = find_nginx_helper_shell,
    }
})