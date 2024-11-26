--!nocheck
local LuaEncode = string.sub(_VERSION, 1, 4) == "Luau" and require("../src/LuaEncode") or require("src/LuaEncode")

local Table = {}
Table[1] = Table

print(LuaEncode(Table, {
    Prettify = true,
}))
