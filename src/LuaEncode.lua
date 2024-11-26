-- LuaEncode - Table Serialization Library for Pure Luau/Lua 5.1+
-- Copyright (c) 2022-2023 reggie@latte.to | MIT License
-- https://github.com/regginator/LuaEncode

--!optimize 2
--!native

local table, ipairs, string, next, pcall, game, workspace, tostring, tonumber, getmetatable =
      table, ipairs, string, next, pcall, game, workspace, tostring, tonumber, getmetatable

local string_format = string.format
local string_char = string.char
local string_gsub = string.gsub
local string_match = string.match
local string_rep = string.rep
local string_sub = string.sub
local string_gmatch = string.gmatch

local table_find = table.find
local table_concat = table.concat
local table_insert = table.insert

local Type = typeof or type

-- Used for checking direct getfield syntax; Lua keywords can't be used as keys without being a str
-- FYI; `continue` is Luau only (in Lua it's actually a global function)
local LuaKeywords do
    local LuaKeywordsArray = {
        "and", "break", "do", "else",
        "elseif", "end", "false", "for",
        "function", "if", "in", "local",
        "nil", "not", "or", "repeat",
        "return", "then", "true", "until",
        "while", "continue"
    }

    -- Lookup table for each keyword
    LuaKeywords = {}
    for _, Keyword in next, LuaKeywordsArray do
        LuaKeywords[Keyword] = true
    end
end

-- Lua 5.1 doesn't have table.find
table_find = table_find or function(inputTable, valueToFind) -- Ignoring the `init` arg, unneeded for us
    for Key, Value in ipairs(inputTable) do
        if Value == valueToFind then
            return Key
        end
    end

    return
end

-- Simple function for directly checking the type on values, with their input, variable name,
-- and desired type name(s) to check
local function CheckType(inputData, dataName, ...)
    local DesiredTypes = {...}
    local InputDataType = Type(inputData)

    if not table_find(DesiredTypes, InputDataType) then
        error(string_format(
            "LuaEncode: Incorrect type for `%s`: `%s` expected, got `%s`",
            dataName,
            table_concat(DesiredTypes, ", "), -- For if multiple types are accepted
            InputDataType
        ), 0)
    end

    return inputData -- Return back input directly
end

-- This re-serializes a string back into Lua, for the interpreter AND humans to read. This fixes
-- `string_format("%q")` only outputting in system encoding, instead of explicit Lua byte escapes
local SerializeString do
    -- These are control characters to be encoded in a certain way in Lua rather than just a byte escape
    local SpecialCharacters = {
        ["\""] = "\\\"",
        ["\\"] = "\\\\",
        -- Special ASCII control char codes
        ["\a"] = "\\a",
        ["\b"] = "\\b",
        ["\t"] = "\\t",
        ["\n"] = "\\n",
        ["\v"] = "\\v",
        ["\f"] = "\\f",
        ["\r"] = "\\r",
    }

    -- We need to assign all extra normal byte escapes for runtime optimization
    for Index = 0, 255 do
        local Character = string_char(Index)

        if not SpecialCharacters[Character] and (Index < 32 or Index > 126) then
            SpecialCharacters[Character] = "\\" .. Index
        end
    end

    function SerializeString(inputString)
        -- FYI; We can't do "\0-\31" in Lua 5.1 (Only Luau/Lua 5.2+) due to an embedded zeros in pattern
        -- issue. See: https://stackoverflow.com/a/22962409
        return table_concat({ '"', string_gsub(inputString, "[%z\\\"\1-\31\127-\255]", SpecialCharacters), '"' })
    end
end

-- Escape warning messages and such for comment block inserts
local function CommentBlock(inputString)
    local Padding = ""
    for Match in string_gmatch(inputString, "%](=*)%]") do
        if #Match >= #Padding then
            Padding = Match .. "="
        end
    end

    return "--[" .. Padding .. "[" .. inputString .. "]" .. Padding .. "]"
end

local EvaluateInstancePath do
    local function IsService(object)
        -- Logically, if an object is actually under a service, that service *has* to already exist, as we've
        -- presumably evaluated to said path
        local FindServiceSuccess, ServiceObject = pcall(game.FindService, game, object.ClassName)
        if FindServiceSuccess and ServiceObject then
            return true
        end

        return false
    end

    -- Evaluates an instances' accessable "path" with just it's ref, and if the root parent is nil/isn't
    -- under `game` or `workspace`, returns nil.
    function EvaluateInstancePath(object)
        local ObjectPointer = object

        -- Input itself doesn't exist?
        if not ObjectPointer then
            return
        end

        local Path = ""

        while ObjectPointer do
            local ObjectName = ObjectPointer.Name
            local ObjectClassName = ObjectPointer.ClassName
            local ObjectParent = ObjectPointer.Parent

            if ObjectParent == game and IsService(ObjectPointer) then
                -- ^^ Then we'll use GetService directly, since it's actually a service under the DataModel

                Path = ":GetService(" .. SerializeString(ObjectClassName) .. ")" .. Path
            elseif not LuaKeywords[ObjectName] and string_match(ObjectName, "^[A-Za-z_][A-Za-z0-9_]*$") then
                -- ^^ Like the `string` DataType, this means means we can index the name directly in Lua
                -- without an explicit string
                Path = "." .. ObjectName .. Path
            else
                Path = "[" .. SerializeString(ObjectName) .. "]" .. Path
            end

            if ObjectParent == game then
                Path = "game" .. Path
                return Path
            elseif ObjectParent == workspace then
                Path = "workspace" .. Path
                return Path
            end

            -- Advance ObjectPointer, whether it exists or not (JUMPBACK)
            ObjectPointer = ObjectParent
        end

        -- Fall back to no ret.. Only objects parented under game/workspace will be serialized
        return
    end
end

--[[
LuaEncode(inputTable: {[any]: any}, options: {[string]: any}): string

    ---------- OPTIONS: ----------

    Prettify <boolean:false> | Whether or not the output should use pretty printing

    IndentCount <number:0> | The amount of "spaces" that should be indented per entry (*Note:
    If `Prettify` is set to true and this is unspecified, it'll be set to `4` automatically*)

    OutputWarnings <boolean:true> | If "warnings" should be placed to the output (as
    comments); It's recommended to keep this enabled, however this can be disabled at ease

    StackLimit <number:500> | The limit to the stack level before recursive encoding cuts
    off, and stops execution. This is used to prevent stack overflow errors and such. You
    could use `math.huge` here if you really wanted

    FunctionsReturnRaw <boolean:false> | If functions in said table return back a "raw"
    value to place in the output as the key/value

    UseInstancePaths <boolean:true> | If `Instance` reference objects should return their
    Lua-accessable path for encoding. If the instance is parented under `nil` or isn't under
    `game`/`workspace`, it'll always fall back to `Instance.new(ClassName)` as before

    SerializeMathHuge <boolean:true> | If numbers calculated as "infinite" (or negative-inf)
    numbers should be serialized with "math.huge". (uses the `math` import, as opposed to just
    a direct data type) If false, "`1/0`" or "`-1/0`" will be serialized, which is supported
    on all target versions

]]

local function LuaEncode(inputTable, options)
    options = options or {}

    -- Check main args
    CheckType(inputTable, "inputTable", "table")
    CheckType(options, "options", "table")

    -- Check options
    CheckType(options.Prettify, "options.Prettify", "boolean", "nil")
    CheckType(options.PrettyPrinting, "options.PrettyPrinting", "boolean", "nil") -- Alias for `Options.Prettify`
    CheckType(options.IndentCount, "options.IndentCount", "number", "nil")
    CheckType(options.OutputWarnings, "options.OutputWarnings", "boolean", "nil")
    --CheckType(options.CycleInserts, "options.CycleInserts", "boolean", "nil")
    --CheckType(options.StackLimit, "options.StackLimit", "number", "nil")
    CheckType(options.FunctionsReturnRaw, "options.FunctionsReturnRaw", "boolean", "nil")
    CheckType(options.UseInstancePaths, "options.UseInstancePaths", "boolean", "nil")
    CheckType(options.SerializeMathHuge, "options.SerializeMathHuge", "boolean", "nil")
    
    CheckType(options._StackLevel, "options._StackLevel", "number", "nil")

    -- Because no if-else-then exp. in Lua 5.1+ (only Luau), for optional boolean values we need to check
    -- if it's nil first, THEN fall back to whatever it's actually set to if it's not nil
    local Prettify = (options.Prettify == nil and options.PrettyPrinting == nil and false) or (options.Prettify ~= nil and options.Prettify) or (options.PrettyPrinting and options.PrettyPrinting)
    local IndentCount = options.IndentCount or (Prettify and 4) or 0
    local OutputWarnings = (options.OutputWarnings == nil and true) or options.OutputWarnings
    --local CycleInserts = (options.CycleInserts == nil and false) or options.CycleInserts
    --local StackLimit = options.StackLimit or 500
    local FunctionsReturnRaw = (options.FunctionsReturnRaw == nil and false) or options.FunctionsReturnRaw
    local UseInstancePaths = (options.UseInstancePaths == nil and true) or options.UseInstancePaths
    local SerializeMathHuge = (options.SerializeMathHuge == nil and true) or options.SerializeMathHuge

    -- Internal options:

    -- Stack level for indent formatting
    local StackLevel = options._StackLevel or 1

    --[=[
    -- Stack overflow/output abuse etc; default StackLimit is 500
    if StackLevel >= StackLimit then
        return "{--[[LuaEncode: Stack level limit of " .. StackLimit .. " reached]]}"
    end
    ]=]

    -- Lazy serialization reference values
    local PositiveInf = (SerializeMathHuge and "math.huge") or "1/0"
    local NegativeInf = (SerializeMathHuge and "-math.huge") or "-1/0"
    local NewEntryString = (Prettify and "\n") or ""
    local ValueSeperator = (Prettify and ", ") or ","
    local BlankSeperator = (Prettify and " ") or ""

    -- For pretty printing (which is optional) we need to keep track of the current stack level, then
    -- repeat IndentString by that count
    local IndentStringBase = string_rep(" ", IndentCount) -- If 0 this will just be ""

    -- Calculated in the walk loop, based on the current StackLevel
    local IndentString = nil
    local EndingIndentString = nil

    --IndentString = (Prettify and string_rep(IndentString, StackLevel)) or IndentString
    --local EndingIndentString = (#IndentString > 0 and string_sub(IndentString, 1, -IndentCount - 1)) or ""

    -- For number key values, we want to explicitly serialize the index num ONLY when it needs to be
    local KeyNumIndex = 1

    -- Cases for encoding values, then end setup. Functions are all expected to return a (EncodedKey: string, EncloseInBrackets: boolean)
    local TypeCases = {} do
        -- Basic func for getting the direct value of an encoded type without weird table.pack()[1] syntax
        local function TypeCase(typeName, value)
            -- Each of these funcs return a tuple, so it'd be annoying to do case-by-case
            local EncodedValue = TypeCases[typeName](value, false) -- False to label as NOT `isKey`
            return EncodedValue
        end

        -- For "tuple" args specifically, so there isn't a bunch of re-used code
        local function Args(...)
            local EncodedValues = {}

            for _, Arg in next, {...} do
                table_insert(EncodedValues, TypeCase(
                    Type(Arg),
                    Arg
                ))
            end

            return table_concat(EncodedValues, ValueSeperator)
        end

        -- For certain Roblox DataTypes, we use a custom serialization method for filling out params etc
        local function Params(newData, params)
            return "(function(v, p) for pn, pv in next, p do v[pn] = pv end return v end)(" ..
                table_concat({newData, TypeCase("table", params)}, ValueSeperator) ..
                ")"
        end

        TypeCases["number"] = function(value, isKey)
            -- If the number isn't the current real index of the table, we DO want to
            -- explicitly define it in the serialization no matter what for accuracy
            if isKey and value == KeyNumIndex then
                -- ^^ What's EXPECTED unless otherwise explicitly defined, if so, return no encoded num
                KeyNumIndex = KeyNumIndex + 1
                return nil, true
            end

            -- Lua's internal `tostring` handling will denote positive/negativie-infinite number TValues as "inf", which
            -- makes certain numbers not encode properly. We also just want to make the output precise
            if value == 1/0 then
                return PositiveInf
            elseif value == -1/0 then
                return NegativeInf
            end

            -- Return fixed-formatted precision num
            return string_format("%.14g", value)
        end

        TypeCases["string"] = function(value, isKey)
            if isKey and not LuaKeywords[value] and string_match(value, "^[A-Za-z_][A-Za-z0-9_]*$") then
                -- ^^ Then it's a syntaxically-correct variable, doesn't need explicit string def
                return value, true
            end

            return SerializeString(value)
        end

        -- This is NOT used for normal table depth, really only Roblox data types that use tables as
        -- arguments for constructor functions
        TypeCases["table"] = function(value, isKey)
            --[=[
            -- Check duplicate/cyclic references
            do
                local VisitedTable = VisitedTables[value]
                if VisitedTable then
                    return string_format(
                        "{--[[LuaEncode: Duplicate reference%s]]}",
                        (value == inputTable and " (of parent)") or ""
                    )
                end

                VisitedTables[value] = true
            end
            ]=]

            local NewOptions = setmetatable({}, {__index = options}) do
                NewOptions.Prettify = (isKey and false) or Prettify
                NewOptions.IndentCount = (isKey and ((not Prettify and IndentCount) or 1)) or IndentCount
                NewOptions._StackLevel = (isKey and 1) or StackLevel + 1
            end

            return LuaEncode(value, NewOptions)
        end

        TypeCases["boolean"] = function(value)
            return value and "true" or "false"
        end

        TypeCases["nil"] = function(value)
            return "nil"
        end

        TypeCases["function"] = function(value)
            -- If `FunctionsReturnRaw` is set as true, we'll call the function here itself, expecting
            -- a raw value for FunctionsReturnRaw to add as the key/value, you may want to do this for custom userdata or
            -- function closures. Thank's for listening to my Ted Talk!
            if FunctionsReturnRaw then
                return value()
            end

            -- If all else, force key func to return nil; can't handle a func val..
            return "function() --[[LuaEncode: `options.FunctionsReturnRaw` false; can't serialize functions]] return end"
        end

        ---------- ROBLOX CUSTOM DATATYPES BELOW ----------

        TypeCases["Axes"] = function(value)
            local EncodedArgs = {}
            local EnumValues = {
                ["Enum.Axis.X"] = value.X,
                ["Enum.Axis.Y"] = value.Y,
                ["Enum.Axis.Z"] = value.Z,
            }

            for EnumValue, IsEnabled in next, EnumValues do
                if IsEnabled then
                    table_insert(EncodedArgs, EnumValue)
                end
            end

            return "Axes.new(" .. table_concat(EncodedArgs, ValueSeperator) .. ")"
        end

        TypeCases["BrickColor"] = function(value)
            -- BrickColor.Number (Its enum ID) will be slightly more efficient in all cases in deser,
            -- so we'll use it if Options.Prettify is false
            return "BrickColor.new(" ..
                (Prettify and TypeCase("string", value.Name)) or value.Number ..
                ")"
        end

        TypeCases["CFrame"] = function(value)
            return "CFrame.new(" .. Args(value:components()) .. ")"
        end

        TypeCases["CatalogSearchParams"] = function(value)
            return Params("CatalogSearchParams.new()", {
                SearchKeyword = value.SearchKeyword,
                MinPrice = value.MinPrice,
                MaxPrice = value.MaxPrice,
                SortType = value.SortType, -- EnumItem
                CategoryFilter = value.CategoryFilter, -- EnumItem
                BundleTypes = value.BundleTypes, -- table
                AssetTypes = value.AssetTypes -- table
            })
        end

        TypeCases["Color3"] = function(value)
            -- Using floats for RGB values, most accurate for direct serialization
            return "Color3.new(" .. Args(value.R, value.G, value.B)
        end

        TypeCases["ColorSequence"] = function(value)
            return "ColorSequence.new(" .. TypeCase("table", value.Keypoints) .. ")"
        end

        TypeCases["ColorSequenceKeypoint"] = function(value)
            return "ColorSequenceKeypoint.new(" .. Args(value.Time, value.Value) .. ")"
        end

        -- We're using fromUnixTimestamp to serialize the object
        TypeCases["DateTime"] = function(value)
            -- Always an int, we don't need to do anything special
            return "DateTime.fromUnixTimestamp(" .. value.UnixTimestamp .. ")"
        end

        -- Properties seem to throw an error on index if the scope isn't a Studio plugin, so we're
        -- directly getting values! (so fun!!!!)
        TypeCases["DockWidgetPluginGuiInfo"] = function(value)
            -- e.g.: "InitialDockState:Right InitialEnabled:0 InitialEnabledShouldOverrideRestore:0 FloatingXSize:0 FloatingYSize:0 MinWidth:0 MinHeight:0"
            local ValueString = tostring(value)

            return "DockWidgetPluginGuiInfo.new(" ..
                Args(
                    -- InitialDockState (Enum.InitialDockState)
                    Enum.InitialDockState[string_match(ValueString, "InitialDockState:(%w+)")], -- Enum.InitialDockState.Right
                    -- InitialEnabled and InitialEnabledShouldOverrideRestore (boolean as number; `0` or `1`)
                    string_match(ValueString, "InitialEnabled:(%w+)") == "1", -- false
                    string_match(ValueString, "InitialEnabledShouldOverrideRestore:(%w+)") == "1", -- false
                    -- FloatingXSize/FloatingYSize (numbers)
                    tonumber(string_match(ValueString, "FloatingXSize:(%w+)")), -- 0
                    tonumber(string_match(ValueString, "FloatingYSize:(%w+)")), -- 0
                    -- MinWidth/MinHeight (numbers)
                    tonumber(string_match(ValueString, "MinWidth:(%w+)")), -- 0
                    tonumber(string_match(ValueString, "MinHeight:(%w+)")) -- 0
                ) ..
                ")"
        end

        -- e.g. `Enum.UserInputType`
        TypeCases["Enum"] = function(value)
            return "Enum." .. tostring(value)
        end

        -- e.g. `Enum.UserInputType.Gyro`
        TypeCases["EnumItem"] = function(value)
            return tostring(value) -- Returns the full enum index for now (e.g. "Enum.UserInputType.Gyro")
        end

        -- i.e. the `Enum` global return
        TypeCases["Enums"] = function(value)
            return "Enum"
        end

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
                    table_insert(EncodedArgs, EnumValue)
                end
            end

            return "Faces.new(" .. table_concat(EncodedArgs, ValueSeperator) .. ")"
        end

        TypeCases["FloatCurveKey"] = function(value)
            return "FloatCurveKey.new(" .. Args(value.Time, value.Value, value.Interpolation) .. ")"
        end

        TypeCases["Font"] = function(value)
            return "Font.new(" .. Args(value.Family, value.Weight, value.Style) .. ")"
        end

        -- Instance refs can be evaluated to their paths (optional), but if parented to
        -- nil or some DataModel not under `game`, it'll just return nil
        TypeCases["Instance"] = function(value)
            if UseInstancePaths then
                local InstancePath = EvaluateInstancePath(value)
                if InstancePath then
                    return InstancePath
                end

                -- ^^ Now, if the path isn't accessable, falls back to the return below anyway
            end

            return "nil" .. BlankSeperator .. CommentBlock("Instance.new(" .. TypeCase("string", value.ClassName) .. ")")
        end

        TypeCases["NumberRange"] = function(value)
            return "NumberRange.new(" .. Args(value.Min, value.Max) .. ")"
        end

        TypeCases["NumberSequence"] = function(value)
            return "NumberSequence.new(" .. TypeCase("table", value.Keypoints) .. ")"
        end

        TypeCases["NumberSequenceKeypoint"] = function(value)
            return "NumberSequenceKeypoint.new(" .. Args(value.Time, value.Value, value.Envelope) .. ")"
        end

        TypeCases["OverlapParams"] = function(value)
            return Params("OverlapParams.new()", {
                FilterDescendantsInstances = value.FilterDescendantsInstances,
                FilterType = value.FilterType,
                MaxParts = value.MaxParts,
                CollisionGroup = value.CollisionGroup,
                RespectCanCollide = value.RespectCanCollide
            })
        end

        TypeCases["PathWaypoint"] = function(value)
            return "PathWaypoint.new(" .. Args(value.Position, value.Action, value.Label) .. ")"
        end

        TypeCases["PhysicalProperties"] = function(value)
            return "PhysicalProperties.new(" ..
                Args(
                    value.Density,
                    value.Friction,
                    value.Elasticity,
                    value.FrictionWeight,
                    value.ElasticityWeight
                ) ..
                ")"
        end

        TypeCases["Random"] = function()
            return "Random.new()"
        end

        TypeCases["Ray"] = function(value)
            return "Ray.new(" .. Args(value.Origin, value.Direction) .. ")"
        end

        TypeCases["RaycastParams"] = function(value)
            return Params("RaycastParams.new()", {
                FilterDescendantsInstances = value.FilterDescendantsInstances,
                FilterType = value.FilterType,
                IgnoreWater = value.IgnoreWater,
                CollisionGroup = value.CollisionGroup,
                RespectCanCollide = value.RespectCanCollide
            })
        end

        TypeCases["Rect"] = function(value)
            return "Rect.new(" .. Args(value.Min, value.Max) .. ")"
        end

        -- Roblox doesn't provide read properties for min/max on `Region3`, but they do on Region3int16.. Anyway,
        -- we CAN calculate the min/max of a Region3 from just .CFrame and .Size.. Thanks to wally for linking me
        -- the thread for this method lol
        TypeCases["Region3"] = function(value)
            local ValueCFrame = value.CFrame
            local ValueSize = value.Size

            return "Region3.new(" ..
                Args(
                    ValueCFrame * CFrame.new(-ValueSize / 2), -- Minimum
                    ValueCFrame * CFrame.new(ValueSize / 2) -- Maximum
                ) ..
                ")"
        end

        TypeCases["Region3int16"] = function(value)
            return "Region3int16.new(" .. Args(value.Min, value.Max) .. ")"
        end

        TypeCases["TweenInfo"] = function(value)
            return "TweenInfo.new(" ..
                Args(
                    value.Time,
                    value.EasingStyle,
                    value.EasingDirection,
                    value.RepeatCount,
                    value.Reverses,
                    value.DelayTime
                ) ..
                ")"
        end

        -- CURRENTLY UNDOCUMENTED*
        TypeCases["RotationCurveKey"] = function(value)
            return "RotationCurveKey.new(" .. Args(value.Time, value.Value, value.Interpolation) .. ")"
        end

        TypeCases["UDim"] = function(value)
            return "UDim.new(" .. Args(value.Scale, value.Offset) .. ")"
        end

        TypeCases["UDim2"] = function(value)
            return "UDim2.new(" ..
                Args(
                    -- Not directly using X and Y UDims for better output (i.e. would be
                    -- UDim2.new(UDim.new(1, 0), UDim.new(1, 0)) if I did)
                    value.X.Scale,
                    value.X.Offset,
                    value.Y.Scale,
                    value.Y.Offset
                ) ..
                ")"
        end

        TypeCases["Vector2"] = function(value)
            return "Vector2.new(" .. Args(value.X, value.Y) .. ")"
        end

        TypeCases["Vector2int16"] = function(value)
            return "Vector2int16.new(" .. Args(value.X, value.Y) .. ")"
        end

        TypeCases["Vector3"] = function(value)
            return "Vector3.new(" .. Args(value.X, value.Y, value.Z) .. ")"
        end

        TypeCases["Vector3int16"] = function(value)
            return "Vector3int16.new(" .. Args(value.X, value.Y, value.Z) .. ")"
        end

        -- With userdata, just encode directly
        TypeCases["userdata"] = function(value)
            if getmetatable(value) ~= nil then -- Has mt
                return "newproxy(true)"
            else
                return "newproxy()" -- newproxy() defaults to false (no mt)
            end
        end
    end

    -- Setup for final output, which will be concat together
    local Output = {}

    local TablePointer = inputTable
    local NextKey = nil -- Used with TableStack so the TablePointer loop knows where to continue from upon stack pop

    -- Stack array for table depth
    local TableStack = {} -- [Depth: number] = {TablePointer: table, NextKey: any, KeyNumIndex: number}

    -- ALSO used for cycle detection
    local VisitedTables = {}

    while TablePointer do
        -- Update StackLevel for formatting
        StackLevel = #TableStack + 1
        IndentString = (Prettify and string_rep(IndentStringBase, StackLevel)) or IndentStringBase
        EndingIndentString = (#IndentString > 0 and string_sub(IndentString, 1, -IndentCount - 1)) or ""

        -- Only append an opening brace to the table if this isn't just a continution up the stack
        if not VisitedTables[TablePointer] then
            Output[#Output+1] = "{" 
        end
        VisitedTables[TablePointer] = true

        -- Just because of control flow restrictions with Lua compatibility
        local SkipStackPop = false 

        for Key, Value in next, TablePointer, NextKey do
            local KeyType = Type(Key)
            local ValueType = Type(Value)

            local ValueIsTable = ValueType == "table"
    
            if TypeCases[KeyType] and TypeCases[ValueType] then
                if Prettify then
                    Output[#Output+1] = NewEntryString .. IndentString
                end
    
                local ValueWasEncoded = false -- Keeping track of this for adding a "," to the output if needed
    
                -- Evaluate output for key
                local KeyEncodedSuccess, EncodedKeyOrError, DontEncloseKeyInBrackets = pcall(TypeCases[KeyType], Key, true) -- The `true` represents if it's a key or not, here it is
    
                -- Evaluate output for value, ignoring 2nd arg (`DontEncloseInBrackets`) because this isn't the key
                local ValueEncodedSuccess, EncodedValueOrError do
                    if not ValueIsTable then
                        ValueEncodedSuccess, EncodedValueOrError = pcall(TypeCases[ValueType], Value, false)
                    end
                end
    
                -- Ignoring `if EncodedKeyOrError` because the key doesn't actually need to ALWAYS
                -- be explicitly encoded, like if it's a number of the current key index!
                if KeyEncodedSuccess and (ValueIsTable or (ValueEncodedSuccess and EncodedValueOrError)) then
                    -- Append explicit key if necessary
                    if EncodedKeyOrError then 
                        if DontEncloseKeyInBrackets then
                            Output[#Output+1] = EncodedKeyOrError
                        else
                            Output[#Output+1] = table_concat({"[", EncodedKeyOrError, "]"})
                        end
    
                        Output[#Output+1] = Prettify and " = " or "="
                    end
    
                    -- Of course, recursive tables are handled differently and use the stack system
                    if ValueIsTable then
                        if not VisitedTables[Value] then
                            TableStack[#TableStack+1] = {TablePointer, Key, KeyNumIndex}

                            TablePointer = Value
                            NextKey = nil
                            KeyNumIndex = 1
    
                            SkipStackPop = true
                            break
                        else
                            EncodedValueOrError = string_format(
                                "{--[[LuaEncode: Duplicate reference%s]]}",
                                (Value == inputTable and " (of parent)") or ""
                            )
                        end
                    end

                    -- Append value like normal
                    Output[#Output+1] = EncodedValueOrError
    
                    ValueWasEncoded = true
                elseif OutputWarnings then -- Then `Encoded(Key/Value)OrError` is the error msg
                    -- ^^ Then either the key or value wasn't properly checked or encoded, and there
                    -- was an error we need to log!
                    local ErrorMessage = string_format(
                        "LuaEncode: Failed to encode %s of DataType `%s`: %s",
                        (not KeyEncodedSuccess and "key") or (not ValueEncodedSuccess and "value") or "key/value",
                        ValueType,
                        (not KeyEncodedSuccess and SerializeString(EncodedKeyOrError)) or (not ValueEncodedSuccess and SerializeString(EncodedValueOrError)) or "(Failed to get error message)"
                    )
    
                    Output[#Output+1] = CommentBlock(ErrorMessage)
                end
    
                if next(TablePointer, Key) == nil then
                    -- If there isn't another value after the current index, add ending formatting
                    Output[#Output+1] = NewEntryString .. EndingIndentString
                elseif ValueWasEncoded then
                    Output[#Output+1] = ","
                end
            end
        end

        -- Vanilla Lua control flow is fun
        if not SkipStackPop then
            Output[#Output+1] = "}"

            if #TableStack > 0 then
                local TableUp = TableStack[#TableStack]
                TableStack[#TableStack] = nil -- Pop off the table stack
    
                TablePointer, NextKey, KeyNumIndex = TableUp[1], TableUp[2], TableUp[3]
    
                -- We also need to add a comma for the next entry, since this was skipped for table depth continuation earlier 
                Output[#Output+1] = ","
            else
                break
            end
        end
    end

    return table_concat(Output)
end

return LuaEncode
