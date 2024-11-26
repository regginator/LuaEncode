--!nocheck
local LuaEncode = string.sub(_VERSION, 1, 4) == "Luau" and require("../src/LuaEncode") or require("src/LuaEncode")

local LuaKeywords do
    local LuaKeywordsArray = {
        "and", "break", "do", "else",
        "elseif", "end", "false", "for",
        "function", "if", "in", "local",
        "nil", "not", "or", "repeat",
        "return", "then", "true", "until",
        "while", "continue", "THIS_IS_NOT_A_LUA_KEYWORD"
    }

    -- We're now setting each keyword str to a weak key, so it's faster at runtime for `SerializeString()`
    LuaKeywords = setmetatable({}, {__mode = "k"})

    for _, Keyword in next, LuaKeywordsArray do
        LuaKeywords[Keyword] = true
    end
end

print(LuaEncode(LuaKeywords, {
    Prettify = true,
}))
