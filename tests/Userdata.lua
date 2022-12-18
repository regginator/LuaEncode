local LuaEncode = require("src/LuaEncode")

local Table = {
    WithMetatable = newproxy(true),
    WithoutMetatable = newproxy()
}

print(LuaEncode(Table, {
    PrettyPrinting = true,
    IndentCount = 4
}))

--[[
Output:

{
    WithMetatable = newproxy(true),
    WithoutMetatable = newproxy()
}
]]
