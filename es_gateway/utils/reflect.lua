--
-- User: ������
-- Date: 2017/12/19
-- Description: 
--
-- string.find(s, pattern[, init[, plain]]),��������ֵ�������ַ�������ֹ�±�
-- s:Դ�ַ�����pattern:ƥ��ģʽ��init:��ʼλ�ã���ѡ��plain:Ĭ��Ϊfalse��ʾ����ģʽƥ�䣬true��ʾ�ر�ģʽƥ��ֻ���򵥵��ַ�������
local find = string.find


local _M = {}

--- Try to load a module
-- Will not throw an error if the module was not found, but will throw an error
--  if the loading failed  for another reason(syntax errors).
-- @param module_name Path of  the module  to load(eg: es_gateway.plugins.request_termination)
--
--���磺δ����ģ�鷵�������
--false module 'test.02-integrated_test.est_response' not found:
--no field package.preload['test.02-integrated_test.est_response']
--no file '/home/sm01/openresty-1.11.2/nginx/conf/lua/test/02-integrated_test/est_response.lua'
--no file '/home/sm01/openresty-1.11.2/site/lualib/test/02-integrated_test/est_response.lua'
--no file '/home/sm01/openresty-1.11.2/site/lualib/test/02-integrated_test/est_response/init.lua'
--no file '/home/sm01/openresty-1.11.2/lualib/test/02-integrated_test/est_response.lua'
--no file '/home/sm01/openresty-1.11.2/lualib/test/02-integrated_test/est_response/init.lua'
function _M.load_module_if_exists(module_name)
    --pcall��һ��"����ģʽ"�����õ�һ�����������Բ�����ִ�й����е��κδ���
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