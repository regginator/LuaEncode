# LuaEncode
Utility Function for Optimal Serialization of Lua Tables in Luau/Lua 5.1+

___

## About & Features
This is a simple utility function developers can use for **serialization** of [Luau](https://luau-lang.org)/[Lua](https://lua.org) tables/data-structures. This script natively supports both Luau, and Lua 5.1+.

### Features:
- Full serialization and output of basic types `number`, `string`, `table`, `boolean`, and `nil` for keys/values.
- "Pretty Printing" & custom indentation config.
- **(Currently Unimplemented)** `typeof()` support for custom Roblox datatypes such as `Instance`, `UDim`, `Vector`, `DateTime`, etc..
- Raw key/value set with `FunctionsReturnRaw`. (See API below for more info)

___

## Installation
- ### GitHub Releases
    You can download the [`LuaEncode.lua`](https://github.com/regginator/LuaEncode/releases/latest/download/LuaEncode.lua) or [`LuaEncode.rbxm`](https://github.com/regginator/LuaEncode/releases/latest/download/LuaEncode.rbxm) module for the [latest GitHub release](https://github.com/regginator/LuaEncode/releases/latest), and immediately use the module!
- ### Rojo/Wally
    If you're familiar with [Rojo](https://rojo.space) or [Wally](https://wally.run), you can just clone the repository use those tools to build the module just how you would with anything else.

    - Rojo
        ```sh
        rojo build default.project.json -o LuaEncode.rbxm
        ```
    - In Your Project Deps w/ Wally
        ```toml
        [dependencies]
        LuaEncode = "regginator/LuaEncode@0.1.0"
        ```
- ### Git Submodule
    If you're familiar with [Git Submodules](https://gist.github.com/gitaarik/8735255), you can import the repo into your project as per use case.

___

## Usage
```lua
-- Basic usage example
-- github.com/regginator/LuaEncode

local LuaEncode = require(script.LuaEncode)

local SomeTable = {
    foo = "bar",
    baz = {
        ["hi mom"] = "hello world",
        [5] = "qux",
        [{123, 456, 789}] = {
            1,
            2,
            "goodbye"
        },
        syn = "tax",
        "example",
    },
}

local Encoded = LuaEncode({
    Table = SomeTable,
    FunctionsReturnRaw = true, -- `false` by default
    PrettyPrint = true, -- `false` by default
    IndentCount = 4, -- `0` by default
})

print(Encoded)
```

Expected Output:
```lua
{
    baz = {
        "example",
        syn = "tax",
        [{123, 456, 789}] = {
            1,
            2,
            "goodbye"
        },
        [5] = "qux",
        ["hi mom"] = "hello world"
    },
    foo = "bar"
}
```

___

## API
```lua
<string> LuaEncode(<table?: {}> args)
```
| Argument | Type | Description |
|----------|------|-------------|
| Table | `<table?: {}>` | Input table to serialize and return. |
| FunctionsReturnRaw | `<bool?: false>` | If functions in said table return back a "raw" value to place in the output as the key/value. |
| PrettyPrint | `<bool?: false>` | Whether or not the output should use "pretty printing". |
| IndentCount | `<number?: 0>` | The amount of "spaces" that should be indented per entry. |

___

## License
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
