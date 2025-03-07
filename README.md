<!-- Links -->
[latest-release]: https://github.com/regginator/LuaEncode/releases/latest
[license]: https://github.com/regginator/LuaEncode/blob/master/LICENSE.txt
[commits]: https://github.com/regginator/LuaEncode/commits
[wally]: https://wally.run/package/regginator/luaencode

[roblox-marketplace]: https://create.roblox.com/marketplace/asset/12791121865/LuaEncode

<!-- Badges -->
[badges/latest-release]: https://img.shields.io/github/v/release/regginator/LuaEncode?label=Latest%20Release
[badges/last-modified]: https://img.shields.io/github/last-commit/regginator/LuaEncode?label=Last%20Modifed
[badges/license]: https://img.shields.io/github/license/regginator/LuaEncode?label=License
[badges/wally]: https://img.shields.io/badge/wally.run-regginator%2Fluaencode-%23ad4646?style=flat"

<!-- Social icons -->
[social/roblox-marketplace]: gh-assets/roblox-marketplace-icon.svg

# LuaEncode

Fast Table Serialization Library for Pure Luau/Lua 5.1+

[![Latest Release][badges/latest-release]][latest-release] [![Last Modified][badges/last-modified]][commits] [![License][badges/license]][license] [![Wally][badges/wally]][wally]

[![Roblox Marketplace][social/roblox-marketplace]][roblox-marketplace] 

___

## 🎉 About

LuaEncode is a simple library for serialization of Lua tables and data structures, with support for Roblox's engine data types. LuaEncode natively supports both Luau and Lua 5.1+

### 🌟 Features

* Serialization and output of basic types `number`, `string`, `table`, `boolean`, and `nil` for key/values
* Pretty-printing and custom indentation configuration
* Compatible with custom Roblox data types (e.g. `Instance`, `UDim2`, `Vector3`, `DateTime`, etc..) - See **[Roblox Engine Data Type Coverage](#roblox-engine-data-type-coverage)** for more info
* Securely iterates and reads values, with potentially untrusted inputs in-mind
* Manual cycle inserts in serialized codegen with [`InsertCycles`](#api)
* Raw key/value input with [`FunctionsReturnRaw`](#api)

___

## ⚙️ Installation

* ### Rojo/Wally

    If you're using [Rojo](https://rojo.space) and [Wally](https://wally.run/), you can import the package in your `wally.toml`:

    ```toml
    LuaEncode = "regginator/luaencode@1.4.3"
    ```

* ### Roblox Marketplace

    You can also grab the LuaEncode module from the Roblox Marketplace directly: <https://roblox.com/library/12791121865>

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
        return "\"hi!\"" -- With `FunctionsReturnRaw` set as true in options, this will output as 'qux = "hi!"'
    end,
}

local Encoded = LuaEncode(Table, {
    Prettify = true, -- false by default (when this is true, IndentCount is also 4!)
    FunctionsReturnRaw = true, -- false by default
})

print(Encoded)
```

<details open>
<summary>Output</summary>
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
LuaEncode(inputTable: {[any]: any}, options: {[string]: any}): string
```

### Options

| Argument           | Type                | Description                         |
|:-------------------|:--------------------|:------------------------------------|
| Prettify           | `<boolean:false>`  | Whether or not the output should use [pretty printing](https://en.wikipedia.org/wiki/Prettyprint#Programming_code_formatting) |
| IndentCount        | `<number:0>`       | The amount of "spaces" that should be indented per entry (*Note: If `Prettify` is set to true and this is unspecified, it'll be set to `4` automatically*) |
| InsertCycles       | `<boolean:false>`  | If there are cyclic references in your table, the output will be wrapped in an anonymous function that manually sets paths to those references. **NOTE: If a key in the index path to the cycle is a reference type (e.g. `table`, `function`), the codegen can't externally set that path, and will be ignored.** |
| OutputWarnings     | `<boolean:true>`   | If "warnings" should be placed to the output (as comments); it's recommended to keep this enabled, however it can be disabled at ease |
| FunctionsReturnRaw | `<boolean:false>`  | If functions in said table return back a "raw" value to place in the output as the key/value |
| UseInstancePaths   | `<boolean:true>`  | If `Instance` reference objects should return their Lua-accessable path for encoding. If the instance is parented under `nil` or isn't under `game`/`workspace`, it'll always fall back to `Instance.new(ClassName)` as before |
| SerializeMathHuge  | `<boolean:true> ` | If numbers calculated as "infinite" (or negative-inf) numbers should be serialized with "math.huge". (uses the `math` import, as opposed to just a direct data type) If false, "`1/0`" or "`-1/0`" will be serialized, which is supported on all target versions |

___

## Roblox Engine Data Type Coverage

*(See [AllRobloxTypes.server.lua](tests/RobloxTests/AllRobloxTypes.server.lua) for example input and (the current expected) output of ALL Roblox DataTypes.)*

✔ Implemented | ➖ Partially Implemented | ❌ Unimplemented | ⛔ Never

| DataType                                                                                                      | Serialized As                                     | Implemented |
|:--------------------------------------------------------------------------------------------------------------|:--------------------------------------------------|:-----------:|
| [Axes](https://create.roblox.com/docs/reference/engine/datatypes/Axes)                                        | `Axes.new()`                                      | ✔ |
| [BrickColor](https://create.roblox.com/docs/reference/engine/datatypes/BrickColor)                            | `BrickColor.new()`                                | ✔ |
| [buffer](https://create.roblox.com/docs/reference/engine/libraries/buffer)                                    | `buffer.create()`                                 | ✔ |
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

See file: [LICENSE](LICENSE)

```txt
MIT License

Copyright (c) 2022-2024 Reggie <reggie@latte.to>

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
