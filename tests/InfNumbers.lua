local LuaEncode = require("src/LuaEncode")

local os_clock = os.clock

local InfNumTable = {math.huge, -math.huge}
local Table = {}
for Index = 1, 10000 do
    Table[Index] = InfNumTable
end

local StartTime = os_clock()
LuaEncode(Table)
local EndTime = os_clock()

print("LuaEncode: Took " .. string.format("%.4f", EndTime - StartTime) .. " (seconds) to serialize table")
