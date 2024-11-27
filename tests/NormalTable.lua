--!nocheck
local LuaEncode = string.sub(_VERSION, 1, 4) == "Luau" and require("../src/LuaEncode") or require("src/LuaEncode")

local Table = {
    foo = "bar",
    baz = {
        1,
        2,
        3,
        [5] = 5,
    },
    qux = function()
        return "\"hi!\""
    end,
}

print(LuaEncode(Table, {
    Prettify = true, -- `false` by default (when this is true, IndentCount is also 4!)
    FunctionsReturnRaw = true, -- `false` by default
}))
print()
print(LuaEncode(Table))
