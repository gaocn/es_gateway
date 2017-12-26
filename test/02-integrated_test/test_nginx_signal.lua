
--
-- User: 高文文
-- Date: 2017/12/7
-- Description:
--   注意：发送信号的操作不能对root进程执行成功
--
package.path = package.path ..';..\\?.lua';

local logger = require "es_gateway.utils.logger"
local maganer = require "es_gateway.utils.nginx_signals"

gateway_conf = {
    nginx_bin_path = "/home/sm01/openresty-1.11.2/nginx/sbin",
    nginx_pid = "/home/sm01/openresty-1.11.2/nginx/logs/nginx.pid",
    conf_dir = "/home/sm01/openresty-1.11.2/",
    nginx_dir = "/home/sm01/openresty-1.11.2/nginx/",
    conf = "/home/sm01/openresty-1.11.2/nginx/conf/nginx.conf",
    nginx_search_paths = {
        "/home/sm01/openresty-1.11.2/nginx/sbin",
    }
}

-- test is_openresty
logger.debug("[TEST]is_openresty is called: %s", maganer.is_openresty(gateway_conf.nginx_bin_path .. "/nginx"))


-- test find_nginx_bin
-- ok, err = maganer.find_nginx_bin()
-- if not ok then
    -- logger.debug("[TEST] find_nginx_bin failed: %s", err)
-- else
    -- logger.debug("[TEST] find_nginx_bin successfully: %s", ok)
-- end

-- test find_nginx_helper_shell
-- ok, err = maganer.find_nginx_helper_shell()
-- if not ok then
    -- logger.debug("[TEST] find_nginx_helper_shell failed: %s", err)
-- else
    -- logger.debug("[TEST] find_nginx_helper_shell successfully: %s", ok)
-- end

-- test send_signal
-- ok, err = maganer.send_signal(gateway_conf.nginx_pid, "TERM")
-- ok, err = maganer.send_signal(gateway_conf.nginx_pid, "ERR")
-- if not ok then
    -- logger.debug("[TEST] send_signal failed: %s", err)
-- else
    -- logger.debug("[TEST] send_signal successfully")
-- end

-- test _M.nignx_shell_helper
-- ok, err = maganer.nignx_shell_helper(gateway_conf, "stop")
-- if not ok then
    -- logger.debug("[TEST] nignx_shell_helper failed: %s", err)
-- else
    -- logger.debug("[TEST] nignx_shell_helper successfully")
-- end

-- carefully use 'start' command in case of start nginx recursively!!!!!!!! 
-- ok, err = maganer.nignx_shell_helper(gateway_conf, "start")
-- if not ok then
    -- logger.debug("[TEST] nignx_shell_helper failed: %s", err)
-- else
    -- logger.debug("[TEST] nignx_shell_helper successfully")
-- end

-- ok, err = maganer.nignx_shell_helper(gateway_conf, "reload")
-- if not ok then
    -- logger.debug("[TEST] nignx_shell_helper failed: %s", err)
-- else
    -- logger.debug("[TEST] nignx_shell_helper successfully")
-- end


-- test _M.reload
-- ok, err = maganer.reload(gateway_conf)
-- if not ok then
    -- logger.debug("[TEST] reload failed: %s", err)
-- else
    -- logger.debug("[TEST] reload successfully")
-- end

-- test _M.stop
-- ok, err = maganer.stop(gateway_conf)
-- if not ok then
    -- logger.debug("[TEST] stop failed: %s", err)
-- else
    -- logger.debug("[TEST] stop successfully")
-- end

-- test _M.quit
-- ok, err = maganer.quit(gateway_conf)
-- if not ok then
    -- logger.debug("[TEST] quit failed: %s", err)
-- else
    -- logger.debug("[TEST] quit successfully")
-- end

-- test _M.start
ok, err = maganer.start(gateway_conf)
if not ok then
    logger.debug("[TEST] start failed: %s", err)
else
    logger.debug("[TEST] start successfully")
end


-- return setmetatable({gateway_conf = gateway_conf},{
--    __index = function(t, key) 
--        return rawget(key)
--    end
-- })