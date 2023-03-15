local LuaEncode = require("src/LuaEncode")

local Table = {}
Table[1] = Table

print(LuaEncode(Table, {
    Prettify = true,
}))

--[=[
Output:

{
    {--[[LuaEncode: Duplicate reference (of parent)]]}
}
]=]
