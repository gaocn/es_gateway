--
-- User: 高文文
-- Date: 2017/12/6
-- Description:
--
--
---###############################################################
--                      GLOBAL CONFIGURATIONS                    #
--################################################################

local base_dir = [[/home/sm01/openresty-1.11.2/]]

---###############################################################
--    retrieve working directory of es_gateway automatically     #
--      then set @{base_dir}                                     #
--################################################################
local sh =  require "es_gateway.utils.cmd.shell"
local shell = sh.shell

local ok = shell("pwd")
if ok then
    base_dir = ok .. "/"
    print("Base_dir: ", ok);
    else
    error("Can not fetch home directory of Openresty!")
end

--
--################################################################
--

local plugins = {
    "request_termination",
    "traffic_limit",
}

local  plugin_map = {}
for i = 1, #plugins do
    plugin_map[plugins[1]] = true
end

local gateway_conf = {
    ---
    -- GATEWAY NGINX PATH
    --
    nginx_bin_path = base_dir  .. "nginx/sbin",
    nginx_pid = base_dir  .. "nginx/logs/nginx.pid",
    conf_dir = base_dir,
    nginx_dir = base_dir  .. "nginx/",
    conf = base_dir  .. "nginx/conf/nginx.conf",
    nginx_search_paths = {
        base_dir  .. "nginx/sbin",  -- 用于搜索nginx可执行文件
        base_dir,  -- 用于搜索default_nginx.sh脚本
    },

    ---
    -- GATEWAY system_id and es_cluster infomation location
    --
    init_config = base_dir  .. "config",

    ---
    --GATEWAY [auto genterated] nginx configuration file path according to @see {init_config}
    --
    upstream_conf_path = base_dir  .. "nginx/conf/es_cluster_upstream.conf",

    ---
    -- ACCESS CONTROL LIST of upstream servers[ES Servers]'s API and indices, Request Method
    --
    acl_conf = base_dir  .. "lualib/es_gateway/api.acl",

    ---
    -- lua share dict declaringn in nginx.conf
    -- make sure following 'lua shared dict' declared in nginx.conf
    --
    system_cluster_map = ngx.shared.system_cluster_map,
    acl_table = ngx.shared.acl_table,
    upstreams = ngx.shared.upstreams,

    ULOG_TRIBE_CLUSTER_NAME  = 'tribe',

    ---
    -- PLUGINS MAP
    --
    PLUGIN_AVAILABLE = plugin_map,

    ---
    --  DATABASE CONFIGURATOINS
    --
    db_type     = "mysql",
    db_ip       = "localhost",
    db_port     = "3306",
    db_schema   = "gateway",
    db_username = "root",
    db_password = "mysql",
}


return setmetatable(gateway_conf, {
    __tostring = function(tb)
        return "This is es_gateway global configuration！"
    end
})