-- LuaEncode - Utility function for Optimal Serialization of Lua Tables in Luau/Lua 5.1+
-- https://github.com/regginator/LuaEnocde | reggie <3

--[[
<string> LuaEncode(<table?> args):

    Table: <table?> | Input table to serialize and return.

    FunctionsReturnRaw: <bool?> | If functions in said table return back a "raw"
    value to place in the output as the key/value.

    PrettyPrint: <bool?> | Whether or not the output should use "pretty printing".

    IndentCount: <number?> | The amount of "spaces" that should be indented
    per entry.
]]
local function LuaEncode(args)
    -- Set default value(s) if missing
    args = args or {}
    local Table = args.Table or {}
    local FunctionsReturnRaw = args.FunctionsReturnRaw or false
    local PrettyPrint = args.PrettyPrint or false
    local IndentCount = args.IndentCount or 0
    local StackLevel = args._StackLevel or 1

    -- Easy-to-reference values for specific args
    local IndentString = string.rep(" ", IndentCount) -- If 0 this will just be ""
    local NewEntryString = (PrettyPrint == true and "\n") or ""

    -- For pretty printing (which is optional, and false by default) we need to keep track
    -- of the current stack, then repeat IndentString by that count
    IndentString = (PrettyPrint == true and string.rep(IndentString, StackLevel)) or IndentString

    -- Setup output
    local Output = "{" .. NewEntryString
    if PrettyPrint == true then
        -- Newlines are made at the end of the loop, if PrettyPrint is true we need
        -- to indent at the beginning too
        Output = Output .. IndentString
    end

    local KeyIndex = 1
    for Key, Value in next, Table do
        -- With pretty printing/formatting, values without an explict key still need to be
        -- indented correctly, to do that we need to keep track of if an explicit key has
        -- been added or not (In KeyTypeCases this will be shown in use)
        local ExplicitlyDefinedKeyAdded = false

        -- Cases (C-Like) for encoding values, then end setup. Using cases so no elseif bs!
        local KeyTypeCases = {
            ["number"] = function()
                -- If the number isn't the current real index of the table, we DO want to
                -- explicitly define it in the serialization no matter what for accuracy
                if Key == KeyIndex then
                    -- ^^ What's EXPECTED unless otherwise explicitly defined, if it is, see below
                    KeyIndex = KeyIndex + 1
                else
                    KeyIndex = Key -- Set it to actual key idx now
                    Output = Output .. string.format("[%d]", Key)
                    ExplicitlyDefinedKeyAdded = true
                end
            end,
            ["string"] = function()
                if string.match(Key, "^[A-Za-z_][A-Za-z0-9_]*$") then
                    -- ^^ Then it's a syntaxically-correct variable, doesn't need explicit string def
                    Output = Output .. Key
                else
                    -- To be safe, we just set it to an explicit string key definition
                    Output = Output .. string.format("[%q]", Key)
                end

                ExplicitlyDefinedKeyAdded = true
            end,
            ["table"] = function()
                -- Recursively add table as key, with same arguments as input
                Output = Output .. string.format(
                    "[%s]",
                    LuaEncode({
                        Table = Key,
                        FunctionsReturnRaw = FunctionsReturnRaw,
                        PrettyPrint = false, -- Overriding because it'd look worse pretty printed in a key
                        -- If PrettyPrint is already false in the real args, set the indent to whatever
                        -- the REAL IndentCount is set to
                        IndentCount = (PrettyPrint == false and IndentCount) or 1,
                        _StackLevel = 1, -- Stack lvl is the **LOWEST** because it's the key to a value
                    })
                )

                ExplicitlyDefinedKeyAdded = true
            end,
            ["boolean"] = function()
                Output = Output .. string.format(
                    "[%s]",
                    (Key == true and "true") or (Key == false and "false")
                )

                ExplicitlyDefinedKeyAdded = true
            end,
            ["nil"] = function()
                Output = Output .. string.format("[%s]", "nil")
                ExplicitlyDefinedKeyAdded = true
            end,
            ["function"] = function()
                -- If `FunctionsReturnRaw` is set as true, we'll call the function here itself, expecting
                -- a raw value to add as the key, you may want to do this for custom userdata or function
                -- closures. Thank's for listening to my Ted Talk!
                if FunctionsReturnRaw then
                    Output = Output .. tostring(Key())
                end

                ExplicitlyDefinedKeyAdded = true
            end,
        }

        local ValueTypeCases = {
            ["number"] = function()
                -- Nothing else to do, normal number value
                Output = Output .. Value
            end,
            ["string"] = function()
                -- We can just use `%q` for the value here, escapes and handles everything directly!
                Output = Output .. string.format("%q", Value)
            end,
            ["table"] = function()
                -- Recursively add table as value, even easier than the key lol
                Output = Output .. LuaEncode({
                    Table = Value,
                    FunctionsReturnRaw = FunctionsReturnRaw,
                    PrettyPrint = PrettyPrint,
                    IndentCount = IndentCount,
                    _StackLevel = StackLevel + 1, -- Stack lvl is 1 higher bc of recursion
                })
            end,
            ["boolean"] = function()
                Output = Output .. ((Value == true and "true") or (Value == false and "false"))
            end,
            ["nil"] = function()
                Output = Output .. "nil"
            end,
            ["function"] = function()
                -- Same as for the key, but for values (See `KeyTypeCases["function"] for more info)
                Output = Output .. tostring(Value())
            end,
        }

        local KeyType = type(Key)
        local ValueType = type(Value)

        if KeyTypeCases[KeyType] and ValueTypeCases[ValueType] then
            KeyTypeCases[KeyType]()

            -- Set key eq to, IF an explicit key has been added
            if ExplicitlyDefinedKeyAdded then
                Output = Output .. ((PrettyPrint == true and " = ") or "=")
            end

            ValueTypeCases[ValueType]()
        end

        -- If there's another value after the current index, add a ","!
        if next(Table, Key) then
            Output = Output .. "," .. NewEntryString .. IndentString
        else
            Output = Output .. NewEntryString
        end
    end

    -- Aaaaand close it on up!
    Output = Output .. ((#IndentString > 0 and string.sub(IndentString, 1, -IndentCount - 1)) or "") ..  "}"
    return Output
end

return LuaEncode
