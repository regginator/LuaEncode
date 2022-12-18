local LuaEncode = require("src/LuaEncode")

local Table = {}
Table[1] = Table

print(LuaEncode(Table, {
    DetectCyclics = true
}))

--[[
Output:

{}
]]
