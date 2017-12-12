--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/6
-- Description:
--    Usage: es_gateway version, with api: /version or -a, will print
--           the version of all underlying dependencies.
--    Options:
--           -a, --all     get version of all dependencies.
--

local meta = require "es_gateway.meta"

local lapp = [[
Usage: es_gateway version, with api: /version or -a, will print
       the version of all underlying dependencies.
Options:
  -a, --all     get version of all dependencies.
]]

local str = [[
es_gateway: %s
ngx_lua: %s
nginx: %s
Lua: %s]]

ngx_config_ngx_lua_version = '5.1.2'
ngx_config_nginx_version = '2.11.2'
jit_version = '5.2'

local function execute(args)
    if args.all then
        print(string.format(
        str,
        meta._VERSION,
        ngx_config_ngx_lua_version,
        ngx_config_nginx_version,
        jit_version
        ))
    else
        print(meta._VERSION)
    end
end


return {
    lapp = lapp,
    execute = execute
}
