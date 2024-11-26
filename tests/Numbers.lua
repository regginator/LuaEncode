--!nocheck
local LuaEncode = string.sub(_VERSION, 1, 4) == "Luau" and require("../src/LuaEncode") or require("src/LuaEncode")

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
