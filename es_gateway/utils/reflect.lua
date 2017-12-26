--
-- User: 高文文
-- Date: 2017/12/19
-- Description: 
--
-- string.find(s, pattern[, init[, plain]]),返回两个值：查找字符串的起止下标
-- s:源字符串；pattern:匹配模式；init:起始位置，可选；plain:默认为false表示开启模式匹配，true表示关闭模式匹配只做简单的字符串查找
local find = string.find


local _M = {}

--- Try to load a module
-- Will not throw an error if the module was not found, but will throw an error
--  if the loading failed  for another reason(syntax errors).
-- @param module_name Path of  the module  to load(eg: es_gateway.plugins.request_termination)
--
--例如：未发现模块返结果如下
--false module 'test.02-integrated_test.est_response' not found:
--no field package.preload['test.02-integrated_test.est_response']
--no file '/home/sm01/openresty-1.11.2/nginx/conf/lua/test/02-integrated_test/est_response.lua'
--no file '/home/sm01/openresty-1.11.2/site/lualib/test/02-integrated_test/est_response.lua'
--no file '/home/sm01/openresty-1.11.2/site/lualib/test/02-integrated_test/est_response/init.lua'
--no file '/home/sm01/openresty-1.11.2/lualib/test/02-integrated_test/est_response.lua'
--no file '/home/sm01/openresty-1.11.2/lualib/test/02-integrated_test/est_response/init.lua'
function _M.load_module_if_exists(module_name)
    --pcall以一种"保护模式"来调用第一个参数。可以捕获函数执行过程中的任何错误
    local status, res = pcall(require, module_name)
    if  status  then
        return true, res
    elseif type(res) == 'string' and  find(module_name, "module '" .. module_name .. "' not found" , nil, true)  then
        --Heree we match any character because if a module has a dash '-'  in its name, we would need  to escape it.
        return false,  res
    else
        error(res)
    end
end



return _M