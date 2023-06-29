-- Just so the command is slightly quicker for me lol

local process = require("@lune/process")

local function Run(command: string)
    print(`> {command}`)

    return process.spawn(command, {}, {
        shell = true,
        stdio = "inherit",
    })
end

Run("rojo serve serve.project.json")
