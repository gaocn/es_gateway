--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/19
-- Description: 
--
local ngx_balancer  =   require "ngx.balancer"
local constants  = require "es_gateway.gateway_conf"
local reflect = require "es_gateway.utils.reflect"
local DaoFactory = require "es_gateway.dao.factory"
local gateway_conf = require "es_gateway.gateway_conf"
local singletons = require "es_gateway.singletons"

local ngx                = ngx
local header             = ngx.header
local get_last_failure   = ngx_balancer.get_last_failure
local set_current_peer   = ngx_balancer.set_current_peer
local set_timeouts       = ngx_balancer.set_timeouts
local get_more_tries     = ngx_balancer.set_more_tries

local function load_plugins(gateway_conf, dao)
    local in_db_plugins, sorted_plugins = {}, {}

    ngx.log(ngx.DEBUG, "Discovering used plugins")

    local rows, err = dao:find_all()
    if not rows then
        return nil, err
    end

    for _, plugin_name in ipairs(rows) do
        ngx.log(ngx.DEBUG, "in_db_plugin:  " .. plugin_name)
        in_db_plugins[plugin_name] = true
    end

    --check  all plugins in DB are enebled/disabled
    for plugin,_ in pairs(in_db_plugins)  do
        if not gateway_conf.PLUGIN_AVAILABLE[plugin] then
            return nil, plugin .. " plugin is in use but not enabled"
        end
    end

    --load installed  plugins
    for plugin in pairs(gateway_conf.PLUGIN_AVAILABLE) do
        local ok, handler = reflect.load_module_if_exists('es_gateway.plugins.' .. plugin .. ".handler")
        if not ok then
            return nil, plugin .. " plugin is enabled but not  installed;\n" .. handler
        end

        local ok, schema =  reflect.load_module_if_exists('es_gateway.plugins.' .. plugin .. '.schema')
        if not ok then
            return nil, "no configuration  schema  found for plugin: " .. plugin
        end

        ngx.log(ngx.DEBUG, "Loading plugin: " .. plugin)

        sorted_plugins[#sorted_plugins+1] = {
            name = plugin,
            handler = handler(),
            schema = schema
        }
    end

    --sort plugins bu order of priority
    table.sort(sorted_plugins, function(a, b)
        local priority_a = a.handler.PRIORITY
        local priority_b = b.handler.PRIORITY
        return  priority_a > priority_b
    end)

    return sorted_plugins
end

function test_load_plugin()
    local plugins, err =  load_plugins(gateway_conf, DaoFactory)
    if not plugins then
        ngx.log(ngx.WARN, "Can Not Load Plugins")
    end

    for _,v in ipairs(plugins) do
        if type(v) == 'table' then
            for k, p in  pairs(v) do
                print(tostring(k), ' ', tostring(p))
            end
        end
    end
end


-- public context handlers
local GATEWAY  = {}

function GATEWAY.init()

    -- populate singletons
    singletons.configuration = gateway_conf
    singletons.loaded_plugins  = assert(load_plugins(gateway_conf, DaoFactory))

    -- build router

end

function GATEWAY.init_worker()

    for _, plugins in ipairs(singletons.loaded_plugins) do
        plugins.handler.init_worker()
    end

end


function GATEWAY.ssl_certificate()

end

function GATEWAY.rewrite()

end

function GATEWAY.access()

end

function GATEWAY.header.filter()
    local ctx = ngx.ctx

end

function GATEWAY.body_filter()
    local ctx = ngx.ctx

end

function GATEWAY.log()

end


return setmetatable(GATEWAY,{

    __index = {
        -- for test
        --test_load_plugin = test_load_plugin
    }
})