-- Runs each test for Luau, Lua 5.1, and LuaJIT

local fs = require("@lune/fs")
local process = require("@lune/process")

local function Run(command: string)
    return process.spawn(command, {}, {
        shell = true,
    })
end

-- Get all modules we need to test and run thru
local Modules = {}
for _, FileName in fs.readDir("tests") do
    if fs.isFile(`tests/{FileName}`) then
        Modules[FileName] = `tests/{FileName}`
    end
end

-- Run all modules in each runtime, and format output
for FileName, Module in Modules do
    print(`------------------- BEGINNING TESTS FOR "{FileName}" -------------------\n`)

    local Commands = {
        `luau {Module}`,
        `lua5.1 {Module}`,
        `luajit {Module}`,
    }

    for _, Command in Commands do
        print(`    > {Command}`)
        local Result = Run(Command)

        local NewOutput = ""
        for _, Line in string.split(Result.stdout .. "\n" .. Result.stderr, "\n") do
            NewOutput ..= "    " .. Line .. "\n"
        end

        print(NewOutput)
    end
end
