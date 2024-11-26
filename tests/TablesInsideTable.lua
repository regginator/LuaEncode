--!nocheck
local LuaEncode = string.sub(_VERSION, 1, 4) == "Luau" and require("../src/LuaEncode") or require("src/LuaEncode")

local Table = {
    {
        hi = {
            "hello",
            1
        },
        bye = {
            "goodbye",
            2
        }
    },
    {
        3,
        4,
        5,
        {
            6
        }
    }
}

print(LuaEncode(Table, {
    Prettify = true,
}))
