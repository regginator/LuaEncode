local LuaEncode = require("src/LuaEncode")

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

--[[
Output:

{
    {
        bye = {
            "goodbye",
            2
        },
        hi = {
            "hello",
            1
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
]]
