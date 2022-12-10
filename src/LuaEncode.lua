-- LuaEncode - Utility Module for Optimal Serialization of Lua Tables in Luau/Lua 5.1+
-- https://github.com/regginator/LuaEnocde | reggie <3

local Type = typeof or type -- For custom Roblox engine data-type support via `typeof`, if it exists

-- Simple "utility" function for directly checking the type on values, with their input, variable name,
-- and desired type name(s) to check
local function CheckType(inputData, dataName, ...)
    local DesiredTypes = {...}
    local InputDataType = Type(inputData)

    if not table.find(DesiredTypes, InputDataType) then
        error(string.format(
            "LuaEncode: Incorrect type for `%s`: `%s` expected, got `%s`",
            dataName,
            table.concat(DesiredTypes, ", "), -- For if multiple types are accepted
            InputDataType
        ), 0)
    end

    return inputData -- Return back input directly
end

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
    CheckType(inputTable, "inputTable", "table") -- Check inputTable type
    CheckType(options, "options", "table", "nil") -- Check options type (if included, can be nil)

    -- Set default values if missing (fyi, `nil` accepted in CheckType is intentional,
    -- lets us handle directly IF whatever value is actually nil)
    options = CheckType(options, "options", "table", "nil") or {}
    local PrettyPrinting = CheckType(options.PrettyPrinting, "options.PrettyPrinting", "boolean", "nil") or false
    local IndentCount = CheckType(options.IndentCount, "options.IndentCount", "number", "nil") or 0
    local FunctionsReturnRaw = CheckType(options.FunctionsReturnRaw, "options.FunctionsReturnRaw", "boolean", "nil") or false
    local StackLevel = CheckType(options._StackLevel, "options._StackLevel", "number", "nil") or 1

    -- Stack overflow/output abuse or whatever
    if StackLevel >= 300 then
        return string.format("{--[[LuaEncode: Stack level limit of `300` reached]]}")
    end

    -- Easy-to-reference values for specific args
    local NewEntryString = (PrettyPrinting and "\n") or ""
    local ValueSeperator = (PrettyPrinting and ", ") or ","

    -- For pretty printing (which is optional, and false by default) we need to keep track
    -- of the current stack, then repeat InitialIndentString by that count
    local InitialIndentString = string.rep(" ", IndentCount) -- If 0 this will just be ""
    local IndentString = (PrettyPrinting and string.rep(InitialIndentString, StackLevel)) or InitialIndentString

    local EndingString = (#IndentString > 0 and string.sub(IndentString, 1, -IndentCount - 1)) or ""

    -- Setup output
    local Output = "{"
    local KeyIndex = 1

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
            return tostring(value), true
        end

        TypeCases["nil"] = function(value)
            return "nil", true
        end

        TypeCases["function"] = function(value)
            -- If `FunctionsReturnRaw` is set as true, we'll call the function here itself, expecting
            -- a raw value to add as the key/value, you may want to do this for custom userdata or
            -- function closures. Thank's for listening to my Ted Talk!
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
            local EnumValues = {
                ["Enum.Axis.X"] = value.X, -- These return bools
                ["Enum.Axis.Y"] = value.Y,
                ["Enum.Axis.Z"] = value.Z,
            }

            for EnumValue, IsEnabled in next, EnumValues do
                if IsEnabled then
                    table.insert(EncodedArgs, EnumValue)
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

        -- DockWidgetPluginGuiInfo.new() | Properties seem to throw an error on index if the scope isn't a Studio
        -- plugin, so we're wrapping everything in a pcall JIC.
        TypeCases["DockWidgetPluginGuiInfo"] = function(value)
            local Success, ErrorOrValue = pcall(function()
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
                )
            end)

            if Success then
                return ErrorOrValue, true
            else
                local Padding = "" do
                    ErrorOrValue:gsub("%](=*)%]", function(match)
                        if match >= Padding then
                            Padding = match .. "="
                        end
                    end)
                end

                return string.format(
                    "DockWidgetPluginGuiInfo.new(--[%s[Error on serialization: %q]%s])",
                    Padding,
                    ErrorOrValue,
                    Padding
                ), true
            end
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

        -- Faces.new() | Similar to Axes.new()
        TypeCases["Faces"] = function(value)
            local EncodedArgs = {}
            local EnumValues = {
                ["Enum.NormalId.Top"] = value.Top, -- These return bools
                ["Enum.NormalId.Bottom"] = value.Bottom,
                ["Enum.NormalId.Left"] = value.Left,
                ["Enum.NormalId.Right"] = value.Right,
                ["Enum.NormalId.Back"] = value.Back,
                ["Enum.NormalId.Front"] = value.Front,
            }

            for EnumValue, IsEnabled in next, EnumValues do
                if IsEnabled then
                    table.insert(EncodedArgs, EnumValue)
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
            -- TODO: Add flag (false by default) named "InstancesReturnPaths" for treating Instance refs as
            -- their Lua-accessable paths. (e.g `workspace:FindFirstChild("Part")` instead of `Instance.new("Part")`)
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

        -- Random.new()
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

        -- Region3.new() | Roblox doesn't provide read properties for min/max on `Region3`, but they
        -- do on Region3int16.. Anyway, we CAN calculate the min/max of a Region3 from just .CFrame
        -- and .Size.. Thanks to wally for linking me the thread for this method lol
        TypeCases["Region3"] = function(value)
            local ValueCFrame = value.CFrame
            local ValueSize = value.Size

            -- These both are returned CFrames, we need to use Minimum.Position/Maximum.Position for the
            -- min/max args to Region3.new()
            local Minimum = ValueCFrame * CFrame.new(-ValueSize / 2)
            local Maximum = ValueCFrame * CFrame.new(ValueSize / 2)

            return string.format(
                "Region3.new(%s)",
                table.concat(
                    {
                        TypeCase("Vector3", Minimum.Position), -- min
                        TypeCase("Vector3", Maximum.Position) -- max
                    },
                    ValueSeperator
                )
            ), true
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

    for Key, Value in next, inputTable do
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
