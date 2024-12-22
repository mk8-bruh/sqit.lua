local _PATH = ...

_VER = "1.0"

lib = require(_PATH..".scene")
lib.components = require(_PATH..".components")
lib.utils = require(_PATH..".utils")
lib.style = require(_PATH..".style")

return setmetatable({}, {
    __index = lib,
    __newindex = function() end,
    __call = lib.new,
    __metatable = {},
    __tostring = function() return ("[SQIT library, v%s]"):format( _VER) end
})
