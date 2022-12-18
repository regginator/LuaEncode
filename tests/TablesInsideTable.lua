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
    PrettyPrinting = true,
    IndentCount = 4
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
