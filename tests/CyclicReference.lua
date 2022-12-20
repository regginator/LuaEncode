local LuaEncode = require("src/LuaEncode")

local Table = {}
Table[1] = Table

print(LuaEncode(Table, {
    PrettyPrinting = true,
    IndentCount = 4
}))

--[=[
Output:

{
    {--[[LuaEncode: Duplicate reference (of parent)]]}
}
]=]
