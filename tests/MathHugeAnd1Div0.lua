--!nocheck
local LuaEncode = string.sub(_VERSION, 1, 4) == "Luau" and require("../src/LuaEncode") or require("src/LuaEncode")

local Table = {
    Positive = math.huge,
    Negative = -math.huge,
    1/0,
    -1/0,
}

print(LuaEncode(Table, {
    Prettify = true,
    SerializeMathHuge = true,
}))

print(LuaEncode(Table, {
    Prettify = true,
    SerializeMathHuge = false,
}))
