--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/6
-- Description: 
--
local version = setmetatable({
    major = 1,
    minor = 11,
    patch = 2,
    suffix = "suffix"
}, {
    __tostring = function(t)
        return string.format("%d.%d.%d%s", t.major, t.minor, t.patch, t.suffix)
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

