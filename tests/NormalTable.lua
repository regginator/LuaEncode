local LuaEncode = require("src/LuaEncode")

local Table = {
    foo = "bar",
    baz = {
        1,
        "one",
        true,
        false,
        [90] = "ninety",
        ["hi mom"] = "hello world",
    },
    qux = function()
        return "\"hi!\""
    end,
}

local Encoded = LuaEncode(Table, {
    PrettyPrinting = true, -- `false` by default
    IndentCount = 4, -- `0` by default
    FunctionsReturnRaw = true, -- `false` by default
})

print(Encoded)

--[[
Output:

{
    qux = "hi!",
    baz = {
        1,
        "one",
        true,
        false,
        [90] = "ninety",
        ["hi mom"] = "hello world"
    },
    foo = "bar"
}
]]
