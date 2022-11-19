local LuaEncode = require("src/LuaEncode")

local CoolUserdata = newproxy(true)
local Table = {[CoolUserdata] = "hi"}
CoolUserdata = nil

print(LuaEncode(Table, {
    PrettyPrinting = true,
    IndentCount = 4,
}))
