<!-- Links -->
[stars]: https://github.com/regginator/LuaEncode/stargazers
[fork]: https://github.com/regginator/LuaEncode/fork
[latest-release]: https://github.com/regginator/LuaEncode/releases/latest
[license]: https://github.com/regginator/LuaEncode/blob/master/LICENSE.txt
[commits]: https://github.com/regginator/LuaEncode/commits
[wally]: https://wally.run/package/regginator/luaencode

[roblox-marketplace]: https://create.roblox.com/marketplace/asset/12791121865/LuaEncode
[discord]: https://latte.to/discord
[github]: https://github.com/regginator
[twitter]: https://twitter.com/jitlua

<!-- Badges -->
[badges/stars]: https://img.shields.io/github/stars/regginator/LuaEncode?label=Stars&logo=GitHub
[badges/fork]: https://img.shields.io/github/forks/regginator/LuaEncode?label=Fork&logo=GitHub
[badges/latest-release]: https://img.shields.io/github/v/release/regginator/LuaEncode?label=Latest%20Release
[badges/last-modified]: https://img.shields.io/github/last-commit/regginator/LuaEncode?label=Last%20Modifed
[badges/license]: https://img.shields.io/github/license/regginator/LuaEncode?label=License
[badges/wally]: https://img.shields.io/badge/wally.run-regginator%2Fluaencode-%23ad4646?style=flat"

<!-- Social icons -->
[social/roblox-marketplace]: gh-assets/roblox-marketplace-icon.svg
[social/discord]: gh-assets/discord-icon.svg
[social/github]: gh-assets/github-icon.svg
[social/twitter]: gh-assets/twitter-icon.svg

<div align="center">

# LuaEncode

Optimal Table Serialization for Native Luau/Lua 5.1+

[![Stars][badges/stars]][stars] [![Fork][badges/fork]][fork] [![Latest Release][badges/latest-release]][latest-release] [![Last Modified][badges/last-modified]][commits] [![License][badges/license]][license] [![Wally][badges/wally]][wally]

[![Roblox Marketplace][social/roblox-marketplace]][roblox-marketplace] [![Latte Softworks Discord][social/discord]][discord] [![My GitHub][social/github]][github] [![My Twitter][social/twitter]][twitter]

</div>

___

## 🎉 About

LuaEncode is a simple, user-friendly library developers can use for **serialization** of [Luau](https://luau-lang.org)/[Lua](https://lua.org) tables and data structures. This natively supports both Luau (Vanilla *or* [Roblox](https://roblox.com)'s implementation), and Lua 5.1+

### 🌟 Features

* Full serialization and output of basic types `number`, `string`, `table`, `boolean`, and `nil` for key/values.
* Fast, optimized, and efficient!
* Flexible and user-friendly API.
* Pretty-printing and custom indentation configuration.
* Compatible with *all* custom Roblox DataTypes (e.g. `Instance`, `UDim2`, `Vector3`, `DateTime`, etc..) - **See [Custom Roblox Lua DataType Coverage](#custom-roblox-lua-datatype-coverage) for more info.**
* Built with complete, secure iteration and value reading in mind.
* **Built-in** duplicate/cyclic detection and [stack limit](#api).
* Raw keys/value input with [`FunctionsReturnRaw`](#api).

___

## ⚙️ Installation

* ### GitHub Releases

    You can download the [`LuaEncode.lua`](https://github.com/regginator/LuaEncode/releases/latest/download/LuaEncode.lua) or [`LuaEncode.rbxm`](https://github.com/regginator/LuaEncode/releases/latest/download/LuaEncode.rbxm) module for the [latest GitHub release](https://github.com/regginator/LuaEncode/releases/latest), and use the module as desired!

* ### Rojo/Wally

    If you're familiar with [Rojo](https://rojo.space) or [Wally](https://wally.run), you can either clone the repository and build the model yourself, or import in your `Wally.toml` as a dependency:

    ```toml
    LuaEncode = "regginator/luaencode@1.2.2"
    ```

* ### Roblox Marketplace

    You can use the [LuaEncode module on the Roblox Marketplace](https://roblox.com/library/12791121865) directly, and it'll always be updated via its ID:

    ```lua
    local LuaEncode = require(12791121865)
    ```

* ### Loadstring by Release URL

    If you're using a script utility with direct access to `loadstring()`, you can use the following line to import the module into your project:

    ```lua
    local LuaEncode = loadstring(game:HttpGet("https://github.com/regginator/LuaEncode/releases/latest/download/LuaEncode.lua"))()
    ```

___

## 🚀 Basic Usage

```lua
local LuaEncode = require("path/to/LuaEncode")

local Table = {
    foo = "bar",
    baz = {
        1,
        2,
        3,
        [5] = 5,
    },
    qux = function()
        return "\"hi!\""
    end,
}

local Encoded = LuaEncode(Table, {
    Prettify = true, -- `false` by default (when this is true, IndentCount is also 4!)
    FunctionsReturnRaw = true, -- `false` by default
})

print(Encoded)
```

<details open>
<summary>Expected Output</summary>
<br />
<ul>

```lua
{
    qux = "hi!",
    baz = {
        1,
        2,
        3,
        [5] = 5
    },
    foo = "bar"
}
```

</ul>
</details>

___

## 🔨 API

```lua
LuaEncode(inputTable: {[any]: any}, options: {[string]:any}): string
```

### Options

| Argument           | Type                | Description                         |
|:-------------------|:--------------------|:------------------------------------|
| Prettify     | `<boolean?:false>`  | Whether or not the output should use [pretty printing](https://en.wikipedia.org/wiki/Prettyprint#Programming_code_formatting). |
| IndentCount        | `<number?:0>`       | The amount of "spaces" that should be indented per entry. (*Note: If `Prettify` is set to true and this is unspecified, it'll be set to `4` automatically.*) |
| OutputWarnings     | `<boolean?:true>`   | If "warnings" should be placed to the output (as comments); It's recommended to keep this enabled, however this can be disabled at ease. |
| StackLimit         | `<number?:500>`     | The limit to the stack level before recursive encoding cuts off, and stops execution. This is used to prevent stack overflow errors and such. You could use `math.huge` here if you *really* wanted. |
| FunctionsReturnRaw | `<boolean?:false>`  | If functions in said table return back a "raw" value to place in the output as the key/value. |
| UseInstancePaths   | `<boolean?:true>`  | If `Instance` reference objects should return their Lua-accessable path for encoding. If the instance is parented under `nil` or isn't under `game`/`workspace`, it'll always fall back to `Instance.new(ClassName)` as before. |

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

## 🏛️ License

```txt
MIT License

Copyright (c) 2022-2023 Reggie <reggie@latte.to>

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
