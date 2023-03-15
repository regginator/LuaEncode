local LuaEncode = require("src/LuaEncode")

local Table = {
    math.huge,
    -math.huge,
    math.pi,
    9e9,
    9e999,
    1,
    2,
    3
}

print(LuaEncode(Table, {
    Prettify = true,
}))

--[[
Output:

{
    math.huge,
    -math.huge,
    3.141592653589793,
    9000000000,
    math.huge,
    1,
    2,
    3
}
]]
