local LuaEncode = require("src/LuaEncode")

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
