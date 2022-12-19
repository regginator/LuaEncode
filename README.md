<div align="center">
    <!-- Title/Desc -->
    <h1>LuaEncode</h1>
    <h4>Optimal Serialization of Lua Tables in Native Luau/Lua 5.1+</h4>
    <p>
        <!-- PROJECT INFO START -->
        <!-- Repo stars -->
        <a href="https://github.com/regginator/LuaEncode/stargazers">
            <img src="https://img.shields.io/github/stars/regginator/LuaEncode?label=Stars&logo=GitHub" alt="Repo Stars">
        </a>
        <!-- Repo forks -->
        <a href="https://github.com/regginator/LuaEncode/fork">
            <img src="https://img.shields.io/github/forks/regginator/LuaEncode?label=Fork&logo=GitHub" alt="Repo Forks">
        </a>
        <!-- Latest release -->
        <a href="https://github.com/regginator/LuaEncode/releases/latest">
            <img src="https://img.shields.io/github/v/release/regginator/LuaEncode?label=Latest%20Release" alt="Latest Release" />
        </a>
        <!-- License info -->
        <a href="https://github.com/regginator/LuaEncode/blob/master/LICENSE.txt">
            <img src="https://img.shields.io/github/license/regginator/LuaEncode?label=License" alt="License" />
        </a>
        <!-- Last modified (latest commit) -->
        <a href="https://github.com/regginator/LuaEncode/commits">
            <img src="https://img.shields.io/github/last-commit/regginator/LuaEncode?label=Last%20Modifed" alt="Last Modified" />
        </a>
        <!-- Package on wally.run -->
        <a href="https://wally.run/package/regginator/luaencode">
            <img src="https://img.shields.io/badge/wally.run-regginator%2Fluaencode-%23ad4646?style=flat" alt="Package on wally.run" />
        </a>
        <!-- PROJECT INFO END -->
        <br />
        <!-- SOCIAL LINKS START -->
        <!-- Latte Softworks Discord -->
        <a href="https://latte.to/invite">
            <img src="https://img.shields.io/discord/892211155303538748?color=%235865F2&label=Latte%20Softworks&logo=Discord&logoColor=%23FFFFFF" alt="Latte Softworks Discord" />
        </a>
        <!-- Twitter (@jitlua) -->
        <a href="https://twitter.com/jitlua">
            <img src="https://img.shields.io/twitter/follow/jitlua?color=1d9bf0&label=Follow%20%40jitlua&logo=Twitter&logoColor=ffffff&style=flat" alt="Follow @jitlua (Twitter)" />
        </a>
        <!-- GitHub (@regginator) -->
        <a href="https://github.com/regginator">
            <img src="https://img.shields.io/github/followers/regginator?label=Follow%20%40regginator&logo=GitHub" alt="Follow @regginator (GitHub)" />
        </a>
        <!-- SOCIAL LINKS END -->
    </p>
</div>

___

## About

This is a fairly simple, user-friendly utility module developers can use for **serialization** of [Luau](https://luau-lang.org)/[Lua](https://lua.org) tables/data structures. This natively supports both Luau (Vanilla *or* [Roblox](https://roblox.com)), and Lua 5.1+

### Features

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

    If you're familiar with [Rojo](https://rojo.space) or [Wally](https://wally.run), you can either clone the repository and build the model yourself, or import in your `Wally.toml` as a dependency:

  * As a dependency in `Wally.toml`:

    ```toml
    LuaEncode = "regginator/luaencode@1.1.0"
    ```

  * Rojo: (Building manually)

    ```sh
    rojo build -o LuaEncode.rbxm
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

### Options

| Argument           | Type                | Description                         |
|:-------------------|:--------------------|:------------------------------------|
| PrettyPrinting     | `<boolean?:false>`  | Whether or not the output should use "pretty printing". |
| IndentCount        | `<number?:0>`       | The amount of "spaces" that should be indented per entry. |
| OutputWarnings     | `<boolean?:true>`   | If "warnings" should be outputted to the console or output (as comments); It's recommended to keep this enabled. |
| StackLimit         | `<number?:500>`     | The limit to the stack level before recursive encoding cuts off, and stops execution. This is used to prevent stack overflows and infinite cyclic references. You could use `math.huge` here if you really wanted. |
| FormatCyclicTables | `<boolean?:true>`   | If LuaEncode should format the codegen with a function wrapping the real table output, assigning any cyclic definitions. This ONLY occurs when there are cyclics in the table, and still returns the expected value in almost ALL use cases. |
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

```txt
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
