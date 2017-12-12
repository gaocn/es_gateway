--
-- User: ╦ънднд
-- Date: 2017/12/7
-- Description: 
--
package.path = package.path ..';..\\?.lua';


local version = require "es_gateway.utils.version"

args = {
    all=false
}
version.execute(args)

args.all =true
version.execute(args)

