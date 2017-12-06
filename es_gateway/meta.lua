--
-- User: ╦ънднд
-- Date: 2017/12/6
-- Description: 
--
local version = setmetatable({
    major = 1,
    minor = 11,
    patch = 2,
}, {
    __tostring = function(t)
        return string.format("%d.%d.%d%s", t.majot, t.minor, t.patch, t.suffix or "")
    end
})

return {
    _NAME = "es_gateway",
    _VERSION = tostring(version),
    _VERSION_TABLE = version,

    -- third-party dependencies required version, as they would be specified
    _DEPENDENCIES = {
        openresty = {"1.11.2.2"}
    }
}

