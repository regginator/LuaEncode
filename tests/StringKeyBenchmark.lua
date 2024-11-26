--!nocheck
local LuaEncode = string.sub(_VERSION, 1, 4) == "Luau" and require("../src/LuaEncode") or require("src/LuaEncode")

local Table = {}
for Index = 1, 100 do
    Table[string.rep("qwertyuiopasdfghjklzxcvbnm", Index)] = true
end

-- Tracking how long LuaEncode takes to serialize
local StartTime = os.clock()
LuaEncode(Table) -- Calling w/out options
local EndTime = os.clock()

print("LuaEncode: Took " .. string.format("%.4f", EndTime - StartTime) .. " (seconds) to serialize table")
