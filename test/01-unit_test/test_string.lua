--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/15
-- Description: 
--

package.path = package.path ..';..\\?.lua';

local logger = require "es_gateway.utils.logger"
local str_helper = require "es_gateway.utils.string"



local url1 = '/_plugin/admin/show'
local url2 = '/_plugin/_sql'
local url3 = '/_plugin/admin/ups/add'
local url4 = '/_plugin/admin/ups/delete'
local url5 = '/_plugin/admin/ups/update'
local url6 = '/_plugin/admin/ups/show'

pat1 = '/_plugin'
pat1_1 = '_plugin'
pat2 = '/_sql'
pat3 = '/admin'
pat4 = '/ups'


logger.debug("1st level uri: %s", url1)
if str_helper.startswith(url1, pat1) then
    res = str_helper.lstrip(url1, pat1)
    logger.debug("2nd level uri: %s", res)
    if str_helper.startswith(res, pat3) then
        res = str_helper.lstrip(res, pat3)
        logger.debug("3rd level uri: %s", res)
    else
        logger.debug("Illegal pligun apis")
    end
else
    logger.debug("Illegal pligun apis")
end

print(str_helper.rstrip(url6, '/sow'))


logger.debug("1st level uri: %s", url1)
if str_helper.startswith(url1, pat1_1) then
    res = str_helper.lstrip(url1, pat1_1)
    logger.debug("2nd level uri: %s", res)
else
    logger.debug("Illegal pligun apis")
end