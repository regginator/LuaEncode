local LuaEncode = require("src/LuaEncode")

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

local Encoded = LuaEncode(Table, {
    Prettify = true, -- `false` by default (when this is true, IndentCount is also 4!)
    FunctionsReturnRaw = true, -- `false` by default
})

print(Encoded)
