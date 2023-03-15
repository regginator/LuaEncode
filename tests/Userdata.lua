local LuaEncode = require("src/LuaEncode")

local Table = {
    WithMetatable = newproxy(true),
    WithoutMetatable = newproxy()
}

print(LuaEncode(Table, {
    Prettify = true,
}))

--[[
Output:

{
    WithMetatable = newproxy(true),
    WithoutMetatable = newproxy()
}
]]
