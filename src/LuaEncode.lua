-- LuaEncode - Utility Module for Optimal Serialization of Lua Tables in Luau/Lua 5.1+
-- https://github.com/regginator/LuaEnocde | reggie <3

local Type = typeof or type -- For custom Roblox engine data-type support via `typeof`, if it exists

--[[
<string> LuaEncode(<table> inputTable, <table?> options):

    ---------- SETTINGS: ----------

    PrettyPrinting <bool?:false> | Whether or not the output should use "pretty printing".

    IndentCount <number?:0> | The amount of "spaces" that should be indented
    per entry.

    FunctionsReturnRaw <bool?:false> | If functions in said table return back a "raw"
    value to place in the output as the key/value.

]]
local function LuaEncode(inputTable, options)
    -- Check inputTable type
    assert(
        Type(inputTable) == "table",
        string.format("LuaEncode: Argument #1 (`inputTable`): `table` expected, got `%s`", Type(inputTable))
    )

    -- Check options type (if included)
    assert(
        not options or Type(options) == "table",
        string.format("LuaEncode: Argument #2 (`options`, optional): `table` expected, got `%s`", Type(options))
    )

    -- Set default values if missing
    options = options or {}
    local PrettyPrinting = options.PrettyPrinting or false
    local IndentCount = options.IndentCount or 0
    local FunctionsReturnRaw = options.FunctionsReturnRaw or false
    local StackLevel = options._StackLevel or 1

    -- Easy-to-reference values for specific args
    local IndentString = string.rep(" ", IndentCount) -- If 0 this will just be ""
    local NewEntryString = (PrettyPrinting and "\n") or ""
    local ValueSeperator = (PrettyPrinting and ", ") or ","
    -- For pretty printing (which is optional, and false by default) we need to keep track
    -- of the current stack, then repeat IndentString by that count
    IndentString = (PrettyPrinting and string.rep(IndentString, StackLevel)) or IndentString
    local EndingString = (#IndentString > 0 and string.sub(IndentString, 1, -IndentCount - 1)) or ""

    -- Setup output
    local Output = "{"
    local KeyIndex = 1
    for Key, Value in next, inputTable do
        -- Cases (C-Like) for encoding values, then end setup. Using cases so no elseif bs!
        -- Functions are all expected to return a (<string> EncodedKey, <boolean?> EncloseInBrackets)
        local TypeCases = {} do
            -- Basic func for getting the direct value of an encoded type without weird table.pack()[1] syntax
            local function TypeCase(typeName, value)
                -- Each of these funcs return a tuple, so it'd be annoying to do case-by-case
                local EncodedValue = TypeCases[typeName](value, false)
                return EncodedValue
            end

            TypeCases["number"] = function(value, isKey)
                if isKey then
                    local CurrentKeyIndex = KeyIndex
                    KeyIndex = value + 1 -- Set it to the actual key idx now

                    -- If the number isn't the current real index of the table, we DO want to
                    -- explicitly define it in the serialization no matter what for accuracy
                    if value == CurrentKeyIndex then
                        -- ^^ What's EXPECTED unless otherwise explicitly defined, if so, return no encoded num
                        return nil
                    end
                end

                return tostring(value), true -- True return for 2nd arg means it SHOULD be enclosed with brackets, if it is a key
            end

            TypeCases["string"] = function(value, isKey)
                if isKey and string.match(value, "^[A-Za-z_][A-Za-z0-9_]*$") then
                    -- ^^ Then it's a syntaxically-correct variable, doesn't need explicit string def
                    return value, false -- `EncloseInBrackets` false because ^^^
                end

                return string.format("%q", value), true
            end

            TypeCases["table"] = function(value, isKey)
                -- Overriding if key because it'd look worse pretty printed in a key
                local NewPrettyPrinting = (isKey and false) or (not isKey and PrettyPrinting)

                -- If PrettyPrinting is already false in the real args, set the indent to whatever
                -- the REAL IndentCount is set to
                local NewIndentCount = (isKey and ((not PrettyPrinting and IndentCount) or 1)) or IndentCount

                -- If isKey, stack lvl is set to the **LOWEST** because it's the key to a value
                local NewStackLevel = (isKey and 1) or StackLevel + 1

                return LuaEncode(value, {
                    PrettyPrinting = NewPrettyPrinting,
                    IndentCount = NewIndentCount,
                    FunctionsReturnRaw = FunctionsReturnRaw,
                    _StackLevel = NewStackLevel,
                }), true
            end

            TypeCases["boolean"] = function(value)
                return (value == true and "true") or (value == false and "false"), true
            end

            TypeCases["nil"] = function(value)
                return "nil", true
            end

            TypeCases["function"] = function(value)
                -- If `FunctionsReturnRaw` is set as true, we'll call the function here itself, expecting
                -- a raw value to add as the key, you may want to do this for custom userdata or function
                -- closures. Thank's for listening to my Ted Talk!
                if FunctionsReturnRaw then
                    return value(), true
                end

                -- If all else, force key func to return nil; can't handle a func val..
                return "function() return end", true
            end

            ---------- ROBLOX CUSTOM DATATYPES BELOW ----------

            -- Axes.new()
            TypeCases["Axes"] = function(value)
                local EncodedArgs = {}
                local EnumRepresentations = {
                    [value.X] = "Enum.Axis.X",
                    [value.Y] = "Enum.Axis.Y",
                    [value.Z] = "Enum.Axis.Z",
                }

                for IsEnabled, EnumRepresentation in next, EnumRepresentations do
                    if IsEnabled == true then
                        -- Add enum representation to EncodedArgs
                        table.insert(EncodedArgs, EnumRepresentation)
                    end
                end

                return string.format(
                    "Axes.new(%s)",
                    table.concat(EncodedArgs, ValueSeperator)
                ), true
            end

            -- BrickColor.new()
            TypeCases["BrickColor"] = function(value)
                -- BrickColor.Name represents exactly what we want to encode
                return string.format("BrickColor.new(%q)", value.Name), true
            end

            -- CFrame.new()
            TypeCases["CFrame"] = function(value)
                return string.format(
                    "CFrame.new(%s)",
                    table.concat({value:components()}, ValueSeperator)
                ), true
            end

            -- CatalogSearchParams.new() | Doesn't support any further parameters by design
            TypeCases["CatalogSearchParams"] = function()
                return "CatalogSearchParams.new()"
            end

            -- Color3.new()
            TypeCases["Color3"] = function(value)
                -- Using floats for RGB values, most accurate for direct serialization
                return string.format(
                    "Color3.new(%s)",
                    table.concat({value.R, value.G, value.B}, ValueSeperator)
                ), true
            end

            -- ColorSequence.new(<ColorSequenceKeypoints>)
            TypeCases["ColorSequence"] = function(value)
                return string.format(
                    "ColorSequence.new(%s)",
                    TypeCase("table", value.Keypoints)
                ), true
            end

            -- ColorSequenceKeypoint.new()
            TypeCases["ColorSequenceKeypoint"] = function(value)
                return string.format(
                    "ColorSequenceKeypoint.new(%s)",
                    table.concat(
                        {
                            value.Time,
                            TypeCase("Color3", value.Value),
                        },
                        ValueSeperator
                    )
                ), true
            end

            -- DateTime.now()/DateTime.fromUnixTimestamp() | We're using fromUnixTimestamp to serialize the object
            TypeCases["DateTime"] = function(value)
                return string.format("DateTime.fromUnixTimestamp(%d)", value.UnixTimestamp), true
            end

            --[[
            -- Can't implement atm, properties throw an error on index if not a studio plugin; COULD
            -- implement a pcall check for support later, but this isn't priority

            -- DockWidgetPluginGuiInfo.new()
            TypeCases["DockWidgetPluginGuiInfo"] = function(value)
                return string.format(
                    "DockWidgetPluginGuiInfo.new(%s)",
                    table.concat(
                        {
                            "Enum.InitialDockState.Float", -- Have to override whatever it'd actually be.. api doesn't provide this..?
                            value.InitialEnabled,
                            value.InitialEnabledShouldOverrideRestore,
                            value.FloatingXSize,
                            value.FloatingYSize,
                            value.MinWidth,
                            value.MinHeight
                        },
                        ValueSeperator
                    )
                ), true
            end
            ]]

            -- ^^^, temporary solution like CatalogSearchParams
            TypeCases["DockWidgetPluginGuiInfo"] = function()
                return "DockWidgetPluginGuiInfo.new()"
            end

            -- Enum (e.g. `Enum.UserInputType`)
            TypeCases["Enum"] = function(value)
                return "Enum." .. tostring(value), true -- For now, this is the behavior of enums in tostring.. I have no other choice atm
            end

            -- EnumItem | e.g. `Enum.UserInputType.Gyro`
            TypeCases["EnumItem"] = function(value)
                return tostring(value), true -- Returns the full enum index for now (e.g. "Enum.UserInputType.Gyro")
            end

            -- Enums | i.e. the `Enum` global return
            TypeCases["Enums"] = function(value)
                return "Enum", true
            end

            -- Faces.new() | Similar to Axes.new
            TypeCases["Faces"] = function(value)
                local EncodedArgs = {}
                local EnumRepresentations = {
                    [value.Top] = "Enum.NormalId.Top",
                    [value.Bottom] = "Enum.NormalId.Bottom",
                    [value.Left] = "Enum.NormalId.Left",
                    [value.Right] = "Enum.NormalId.Right",
                    [value.Back] = "Enum.NormalId.Back",
                    [value.Front] = "Enum.NormalId.Front",
                }

                for IsEnabled, EnumRepresentation in next, EnumRepresentations do
                    if IsEnabled == true then
                        -- Add enum representation to EncodedArgs
                        table.insert(EncodedArgs, EnumRepresentation)
                    end
                end

                return string.format(
                    "Faces.new(%s)",
                    table.concat(EncodedArgs, ValueSeperator)
                ), true
            end

            -- FloatCurveKey.new()
            TypeCases["FloatCurveKey"] = function(value)
                return string.format(
                    "FloatCurveKey.new(%s)",
                    table.concat(
                        {
                            value.Time,
                            value.Value,
                            TypeCase("EnumItem", value.Interpolation),
                        },
                        ValueSeperator
                    )
                ), true
            end

            -- Font.new()
            TypeCases["Font"] = function(value)
                return string.format(
                    "Font.new(%s)",
                    table.concat(
                        {
                            string.format("%q", value.Family),
                            TypeCase("EnumItem", value.Weight),
                            TypeCase("EnumItem", value.Style),
                        },
                        ValueSeperator
                    )
                ), true
            end

            -- Instance.new() | For now "partially" implemented, will add options for path get in the future
            TypeCases["Instance"] = function(value)
                return string.format("Instance.new(%q)", value.ClassName), true
            end

            -- NumberRange.new()
            TypeCases["NumberRange"] = function(value)
                return string.format(
                    "NumberRange.new(%s)",
                    table.concat({value.Min, value.Max}, ValueSeperator)
                ), true
            end

            -- NumberSequence.new(<NumberSequenceKeypoints>)
            TypeCases["NumberSequence"] = function(value)
                return string.format(
                    "NumberSequence.new(%s)",
                    TypeCase("table", value.Keypoints)
                ), true
            end

            -- NumberSequenceKeypoint.new()
            TypeCases["NumberSequenceKeypoint"] = function(value)
                return string.format(
                    "NumberSequenceKeypoint.new(%s)",
                    table.concat(
                        {
                            value.Time,
                            value.Value,
                            value.Envelope,
                        },
                        ValueSeperator
                    )
                ), true
            end

            -- OverlapParams.new() | BY DESIGN, like CatalogSearchParams, doesn't support params in the
            -- new() call!
            TypeCases["OverlapParams"] = function()
                return "OverlapParams.new()", true
            end

            -- PathWaypoint.new()
            TypeCases["PathWaypoint"] = function(value)
                return string.format(
                    "PathWaypoint.new(%s)",
                    table.concat(
                        {
                            TypeCase("Vector3", value.Position),
                            TypeCase("EnumItem", value.Action),
                            string.format("%q", value.Label),
                        },
                        ValueSeperator
                    )
                ), true
            end

            -- PhysicalProperties.new()
            TypeCases["PhysicalProperties"] = function(value)
                return string.format(
                    "PhysicalProperties.new(%s)",
                    table.concat(
                        {
                            value.Density,
                            value.Friction,
                            value.Elasticity,
                            value.FrictionWeight,
                            value.ElasticityWeight,
                        },
                        ValueSeperator
                    )
                ), true
            end

            -- Random.new() | Roblox DOES NOT provide a property on `Random` DataTypes for getting the
            -- original input seed _yet_, so we have to let it decide for itself @ runtime.
            TypeCases["Random"] = function()
                return "Random.new()", true
            end

            -- Ray.new()
            TypeCases["Ray"] = function(value)
                return string.format(
                    "Ray.new(%s)",
                    table.concat(
                        {
                            TypeCase("Vector3", value.Origin),
                            TypeCase("Vector3", value.Direction),
                        },
                        ValueSeperator
                    )
                ), true
            end

            -- RaycastParams.new() | Yet more non-specific params!
            TypeCases["RaycastParams"] = function(value)
                return "RaycastParams.new()", true
            end

            -- Rect.new()
            TypeCases["Rect"] = function(value)
                return string.format(
                    "Rect.new(%s)",
                    table.concat(
                        {
                            TypeCase("Vector2", value.Min),
                            TypeCase("Vector2", value.Max),
                        },
                        ValueSeperator
                    )
                ), true
            end

            -- Region3.new() | Roblox doesn't provide read properties for min/max (the .new() params)
            -- on Region3 but THEY DO ON REGION3INT16..???
            TypeCases["Region3"] = function()
                return "Region3.new()", true
            end

            -- Region3int16.new()
            TypeCases["Region3int16"] = function(value)
                return string.format(
                    "Region3int16.new(%s)",
                    table.concat(
                        {
                            TypeCase("Vector3int16", value.Min),
                            TypeCase("Vector3int16", value.Max),
                        },
                        ValueSeperator
                    )
                ), true
            end

            -- TweenInfo.new()
            TypeCases["TweenInfo"] = function(value)
                return string.format(
                    "TweenInfo.new(%s)",
                    table.concat(
                        {
                            value.Time,
                            TypeCase("EnumItem", value.EasingStyle),
                            TypeCase("EnumItem", value.EasingDirection),
                            value.RepeatCount,
                            TypeCase("boolean", value.Reverses),
                            value.DelayTime,
                        },
                        ValueSeperator
                    )
                ), true
            end

            -- UDim.new()
            TypeCases["UDim"] = function(value)
                return string.format(
                    "UDim.new(%s)",
                    table.concat({value.Scale, value.Offset}, ValueSeperator)
                ), true
            end

            -- UDim2.new()
            TypeCases["UDim2"] = function(value)
                return string.format(
                    "UDim2.new(%s)",
                    table.concat(
                        {
                            -- Not directly using X and Y UDims for better output (i.e. would
                            -- be UDim2.new(UDim.new(1, 0), UDim.new(1, 0)) if I did)
                            value.X.Scale,
                            value.X.Offset,
                            value.Y.Scale,
                            value.Y.Offset,
                        },
                        ValueSeperator
                    )
                ), true
            end

            -- Vector2.new()
            TypeCases["Vector2"] = function(value)
                return string.format(
                    "Vector2.new(%s)",
                    table.concat({value.X, value.Y}, ValueSeperator)
                ), true
            end

            -- Vector2int16.new()
            TypeCases["Vector2int16"] = function(value)
                return string.format(
                    "Vector2int16.new(%s)",
                    table.concat({value.X, value.Y}, ValueSeperator)
                ), true
            end

            -- Vector3.new()
            TypeCases["Vector3"] = function(value)
                return string.format(
                    "Vector3.new(%s)",
                    table.concat({value.X, value.Y, value.Z}, ValueSeperator)
                ), true
            end

            -- Vector3int16.new()
            TypeCases["Vector3int16"] = function(value)
                return string.format(
                    "Vector3int16.new(%s)",
                    table.concat({value.X, value.Y, value.Z}, ValueSeperator)
                ), true
            end
        end

        local KeyType = Type(Key)
        local ValueType = Type(Value)

        if TypeCases[KeyType] and TypeCases[ValueType] then
            if PrettyPrinting then
                Output = Output .. NewEntryString .. IndentString
            end

            -- Go through and get key val
            local EncodedKey, EncloseInBrackets = TypeCases[KeyType](Key, true) -- The `true` represents if it's a key or not, here it is

            -- If the key should be explicity added, if it's a number idx or something, this will be nil
            if EncodedKey then
                if EncloseInBrackets then
                    Output = Output .. string.format("[%s]", EncodedKey)
                else
                    Output = Output .. EncodedKey
                end

                -- Set key equal to
                Output = Output .. ((PrettyPrinting and " = ") or "=")
            end

            -- Ignoring 2nd arg (`EncloseInBrackets`) because this isn't the key
            local EncodedValue = TypeCases[ValueType](Value, false) -- False because it's NOT the key, it's the value
            Output = Output .. EncodedValue

            -- If there's another value after the current index, add a ","!
            if next(inputTable, Key) then
                Output = Output .. ","
            else
                -- Ending string w indent and all
                Output = Output .. NewEntryString .. EndingString
            end
        end
    end

    -- And close it on up!
    Output = Output .. "}"
    return Output
end

return LuaEncode
