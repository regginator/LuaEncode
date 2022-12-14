local LuaEncode = require("src/LuaEncode")

local Table = {
    math.huge,
    math.pi,
    9e9,
    9e999,
    1,
    2,
    3
}

print(LuaEncode(Table, {
    PrettyPrinting = true,
    IndentCount = 4
}))

--[[
Output:

{
    math.huge,
    3.141592653589793,
    9000000000,
    math.huge,
    1,
    2,
    3
}
]]
