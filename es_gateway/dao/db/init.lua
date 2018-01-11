--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/25
-- Description: 
--

local _M = {}

function _M.new_db(name)
    local db_mt = {
        db_name        = name,
        init           = function()  return  true end,
        init_worker    = function() return  true end,
        infos          = function() error("infos() not implemented") end,
        query          = function() error("query() not implemented") end,
        insert         = function() error("insert() not implemented") end,
        update         = function() error("update() not implemented") end,
        delete         = function() error("delete() not implemented") end,
        find           = function() error("find() not implemented") end,
        find_all       = function() error("find_all() not implemented") end,
        count          = function() error("count() not implemented") end,
        drop_table     = function() error("drop_table() not implemented") end,
        truncate_table = function() error("truncate_table() not implemented") end,
    }
    db_mt.__index = db_mt
    db_mt.super = {
        new = function()
            return setmetatable({}, db_mt)
        end
    }
    return setmetatable(db_mt, {__index = db_mt.super })
end

return _M