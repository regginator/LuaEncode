--!nocheck
local LuaEncode = string.sub(_VERSION, 1, 4) == "Luau" and require("../src/LuaEncode") or require("src/LuaEncode")

local Table = {
    {
        "Hello",
        AnotherTable = {},
        ["This can't be indexed raw"] = {}
    },
}

Table.Self = Table
Table[2] = Table[1].AnotherTable
Table["3"] = Table[1]["This can't be indexed raw"]

print(LuaEncode(Table, {
    Prettify = true,
    InsertCycles = true,
}))
print()
print(LuaEncode(Table, {
    InsertCycles = true,
}))
