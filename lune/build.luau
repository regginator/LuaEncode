-- Handles building bins for GH tagged releases

local function Run(command: string)
    print(`> {command}`)

    return process.spawn(command, {}, {
        shell = true,
        stdio = "inherit",
    })
end

local function Copy(originalPath: string, newPath: string)
    fs.writeFile(newPath, fs.readFile(originalPath))
    print(`> Copied {originalPath} to {newPath}`)
end

-- Remove old build dir if it exists
if fs.isDir("build") then
    print("> Removing old \"build\" directory..")
    fs.removeDir("build")
end

fs.writeDir("build")

Copy("LICENSE.txt", "build/LICENSE,txt")
Copy("src/LuaEncode.lua", "build/LuaEncode.lua")

-- Minify and output LuaEncode.min
Run("darklua process -v src/LuaEncode.lua build/LuaEncode.min.lua")

-- Build models thru Rojo
Run("rojo build -o build/LuaEncode.rbxm")
Run("rojo build -o build/LuaEncode.rbxmx")
