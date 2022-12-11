# LuaEncode
Utility Function for Optimal Serialization of Lua Tables in Luau/Lua 5.1+

___

## About & Features
This is a simple utility function developers can use for **serialization** of [Luau](https://luau-lang.org)/[Lua](https://lua.org) tables/data structures. This script natively supports both Luau, and Lua 5.1+.

### Features:
* Full serialization and output of basic types `number`, `string`, `table`, `boolean`, and `nil` for keys/values.
* Flexible and user-friendly API.
* Pretty-printing & custom indentation configuration.
* `type()` **and** `typeof()` support for *full* custom Roblox DataType support (e.g. `Instance`, `UDim2`, `Vector3`, `DateTime`, etc..) - **See [Custom Roblox Lua DataType Coverage](#custom-roblox-lua-datatype-coverage) for more info.**
* Secure iteration and value reading, so you can also use this with something like user-generated input and "RemoteSpy" scripts.
* **Built in** cyclic detection and stack limits, [both optional flags](#api).
* Raw keys/values with `FunctionsReturnRaw`.

___

## Installation
* ### GitHub Releases
    You can download the [`LuaEncode.lua`](https://github.com/regginator/LuaEncode/releases/latest/download/LuaEncode.lua) or [`LuaEncode.rbxm`](https://github.com/regginator/LuaEncode/releases/latest/download/LuaEncode.rbxm) module for the [latest GitHub release](https://github.com/regginator/LuaEncode/releases/latest), and immediately use the module!
* ### Rojo/Wally
    If you're familiar with [Rojo](https://rojo.space) or [Wally](https://wally.run), you can just clone the repository use those tools to build the module just how you would with anything else.

    - In your project dependencies w/ Wally:
        ```toml
        [dependencies]
        LuaEncode = "regginator/luaencode@1.0.0"
        ```
    - Rojo: (Building manually)
        ```sh
        rojo build default.project.json -o LuaEncode.rbxm
        ```
* ### Git Submodule
    If you're familiar with [Git Submodules](https://gist.github.com/gitaarik/8735255), you can import the repo into your project as per use case.
* ### Loadstring by Release URL
    If you're using a script utility with direct access to `loadstring()`, you can use the following line to import the module into your project:
    ```lua
    local LuaEncode = loadstring(game:HttpGet("https://github.com/regginator/LuaEncode/releases/latest/download/LuaEncode.lua"))()
    ```
    *(Or with HttpService if using the Roblox API)*
    ```lua
    local HttpService = game:GetService("HttpService")
    local LuaEncode = loadstring(HttpService:GetAsync("https://github.com/regginator/LuaEncode/releases/latest/download/LuaEncode.lua"))()
    ```

___

## Basic Usage
```lua
local LuaEncode = require("src/LuaEncode")

local Table = {
    foo = "bar",
    baz = {
        1,
        "one",
        true,
        false,
        [90] = "ninety",
        ["hi mom"] = "hello world",
    },
    qux = function()
        return "\"hi!\""
    end,
}

local Encoded = LuaEncode(Table, {
    PrettyPrinting = true, -- `false` by default
    IndentCount = 4, -- `0` by default
    FunctionsReturnRaw = true, -- `false` by default
})

print(Encoded)
```

Expected Output:
```lua
{
    qux = "hi!",
    baz = {
        1,
        "one",
        true,
        false,
        [90] = "ninety",
        ["hi mom"] = "hello world"
    },
    foo = "bar"
}
```

___

## API
```lua
<string> LuaEncode(<table> inputTable, <table?> options)
```

#### Options:
| Argument           | Type                | Description                         |
|:-------------------|:--------------------|:------------------------------------|
| PrettyPrinting     | `<boolean?:false>`  | Whether or not the output should use "pretty printing". |
| IndentCount        | `<number?:0>`       | The amount of "spaces" that should be indented per entry. |
| StackLimit         | `<number?:199>`     | The limit to the stack level before recursive encoding cuts off, and stops execution. This is used to prevent stack overflows and infinite cyclic references. You could use `math.huge` here if you really wanted. |
| DetectCyclics      | `<boolean?:true>`   | If cyclics (table references "in" themselves) should actively be checked for, and prevented from recursively encoding. |
| FunctionsReturnRaw | `<boolean?:false>`  | If functions in said table return back a "raw" value to place in the output as the key/value. |
| UseInstancePaths   | `<boolean?:false>`  | If `Instance` reference objects should attempt to get its Lua-accessable path for encoding. If the instance is parented under `nil` or isn't under `game`/`workspace`, it'll always fall back to `Instance.new(ClassName)` as before. |

___

## Custom Roblox Lua DataType Coverage
*(See [AllRobloxTypes.server.lua](tests/AllRobloxTypes/AllRobloxTypes.server.lua) for example input and (the current expected) output of ALL Roblox DataTypes.)*

✔ Implemented | ➖ Partially Implemented | ❌ Unimplemented | ⛔ Never

| DataType                                                                                                      | Serialized As                                     | Implemented |
|:--------------------------------------------------------------------------------------------------------------|:--------------------------------------------------|:-----------:|
| [Axes](https://create.roblox.com/docs/reference/engine/datatypes/Axes)                                        | `Axes.new()`                                      | ✔ |
| [BrickColor](https://create.roblox.com/docs/reference/engine/datatypes/BrickColor)                            | `BrickColor.new()`                                | ✔ |
| [CFrame](https://create.roblox.com/docs/reference/engine/datatypes/CFrame)                                    | `CFrame.new()`                                    | ✔ |
| [CatalogSearchParams](https://create.roblox.com/docs/reference/engine/datatypes/CatalogSearchParams)          | `CatalogSearchParams.new()`                       | ✔ |
| [Color3](https://create.roblox.com/docs/reference/engine/datatypes/Color3)                                    | `Color3.new()`                                    | ✔ |
| [ColorSequence](https://create.roblox.com/docs/reference/engine/datatypes/ColorSequence)                      | `ColorSequence.new(<ColorSequenceKeypoints>)`     | ✔ |
| [ColorSequenceKeypoint](https://create.roblox.com/docs/reference/engine/datatypes/ColorSequenceKeypoint)      | `ColorSequenceKeypoint.new()`                     | ✔ |
| [DateTime](https://create.roblox.com/docs/reference/engine/datatypes/DateTime)                                | `DateTime.fromUnixTimestamp()`                    | ✔ |
| [DockWidgetPluginGuiInfo](https://create.roblox.com/docs/reference/engine/datatypes/DockWidgetPluginGuiInfo)  | `DockWidgetPluginGuiInfo.new()`                   | ✔ |
| [Enum](https://create.roblox.com/docs/reference/engine/datatypes/Enum)                                        | `Enum.<EnumType>`                                 | ✔ |
| [EnumItem](https://create.roblox.com/docs/reference/engine/datatypes/EnumItem)                                | `Enum.<EnumType>.<EnumItem>`                      | ✔ |
| [Enums](https://create.roblox.com/docs/reference/engine/datatypes/Enums)                                      | `Enum`                                            | ✔ |
| [Faces](https://create.roblox.com/docs/reference/engine/datatypes/Faces)                                      | `Faces.new()`                                     | ✔ |
| [FloatCurveKey](https://create.roblox.com/docs/reference/engine/datatypes/FloatCurveKey)                      | `FloatCurveKey.new()`                             | ✔ |
| [Font](https://create.roblox.com/docs/reference/engine/datatypes/Font)                                        | `Font.new()`                                      | ✔ |
| [Instance](https://create.roblox.com/docs/reference/engine/datatypes/Instance)                                | `Instance.new()`                                  | ✔ |
| [NumberRange](https://create.roblox.com/docs/reference/engine/datatypes/NumberRange)                          | `NumberRange.new()`                               | ✔ |
| [NumberSequence](https://create.roblox.com/docs/reference/engine/datatypes/NumberSequence)                    | `NumberSequence.new(<NumberSequenceKeypoints>)`   | ✔ |
| [NumberSequenceKeypoint](https://create.roblox.com/docs/reference/engine/datatypes/NumberSequenceKeypoint)    | `NumberSequenceKeypoint.new()`                    | ✔ |
| [OverlapParams](https://create.roblox.com/docs/reference/engine/datatypes/OverlapParams)                      | `OverlapParams.new()`                             | ✔ |
| [PathWaypoint](https://create.roblox.com/docs/reference/engine/datatypes/PathWaypoint)                        | `PathWaypoint.new()`                              | ✔ |
| [PhysicalProperties](https://create.roblox.com/docs/reference/engine/datatypes/PhysicalProperties)            | `PhysicalProperties.new()`                        | ✔ |
| [RBXScriptConnection](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection)          | `N/A`                                             | ⛔ |
| [RBXScriptSignal](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal)                  | `N/A`                                             | ⛔ |
| [Random](https://create.roblox.com/docs/reference/engine/datatypes/Random)                                    | `Random.new()`                                    | ✔ |
| [Ray](https://create.roblox.com/docs/reference/engine/datatypes/Ray#summary-constructors)                     | `Ray.new()`                                       | ✔ |
| [RaycastParams](https://create.roblox.com/docs/reference/engine/datatypes/RaycastParams)                      | `RaycastParams.new()`                             | ✔ |
| [RaycastResult](https://create.roblox.com/docs/reference/engine/datatypes/RaycastResult)                      | `N/A`                                             | ⛔ |
| [Rect](https://create.roblox.com/docs/reference/engine/datatypes/Rect#summary-constructors)                   | `Rect.new()`                                      | ✔ |
| [Region3](https://create.roblox.com/docs/reference/engine/datatypes/Region3)                                  | `Region3.new()`                                   | ✔ |
| [Region3int16](https://create.roblox.com/docs/reference/engine/datatypes/Region3int16)                        | `Region3int16.new()`                              | ✔ |
| [TweenInfo](https://create.roblox.com/docs/reference/engine/datatypes/TweenInfo)                              | `TweenInfo.new()`                                 | ✔ |
| [RotationCurveKey](https://create.roblox.com/docs/reference/engine/datatypes/RotationCurveKey)                | `RotationCurveKey.new()`                          | ✔ |
| [UDim](https://create.roblox.com/docs/reference/engine/datatypes/UDim)                                        | `UDim.new()`                                      | ✔ |
| [UDim2](https://create.roblox.com/docs/reference/engine/datatypes/UDim2)                                      | `UDim2.new()`                                     | ✔ |
| [Vector2](https://create.roblox.com/docs/reference/engine/datatypes/Vector2)                                  | `Vector2.new()`                                   | ✔ |
| [Vector2int16](https://create.roblox.com/docs/reference/engine/datatypes/Vector2int16)                        | `Vector2int16.new()`                              | ✔ |
| [Vector3](https://create.roblox.com/docs/reference/engine/datatypes/Vector3)                                  | `Vector3.new()`                                   | ✔ |
| [Vector3int16](https://create.roblox.com/docs/reference/engine/datatypes/Vector3int16)                        | `Vector3int16.new()`                              | ✔ |

*(Official Roblox DataType documentation [here](https://create.roblox.com/docs/reference/engine/datatypes))*

___

## License
```
MIT License

Copyright (c) 2022 Reggie <reggie@latte.to>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
