local LuaEncode = require(script.LuaEncode)

local function NewInstance(className, properties)
    local CreatedInstance = Instance.new(className)

    if properties then
        for Name, Value in next, properties do
            if Name ~= "Parent" then
                CreatedInstance[Name] = Value
            end
        end

        if properties.Parent then
            CreatedInstance.Parent = properties.Parent
        end
    end

    return CreatedInstance
end

local Table = {
    Baseplate = workspace:FindFirstChild("Baseplate"),
    SomePart = NewInstance("Part", {
        Parent = workspace,

        Name = "hellopart!",
        CFrame = CFrame.new(0, 4, 0),
        BrickColor = BrickColor.new("Cyan")
    }),
    SomePartWithWeirdName = NewInstance("Part", {
        Parent = workspace,

        Name = "LuaEncode is cool!",
        CFrame = CFrame.new(0, 4, 0),
        BrickColor = BrickColor.new("Cyan")
    }),
    Skybox = NewInstance("Sky", {
        Parent = game:GetService("Lighting"),
        Name = "CoolSky"
    }),
    InstanceWithNoParent = NewInstance("Part")
}

print(LuaEncode(Table, {
    PrettyPrinting = true,
    IndentCount = 4,
    UseInstancePaths = true
}))

--[[
Output:

{
    SomePart = workspace["hellopart!"],
    Baseplate = workspace.Baseplate,
    SomePartWithWeirdName = workspace["LuaEncode is cool!"],
    Skybox = game:GetService("Lighting").CoolSky,
    InstanceWithNoParent = Instance.new("Part")
}
]]
