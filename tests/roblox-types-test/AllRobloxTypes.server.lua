local LuaEncode = require(script.LuaEncode)

local Table = {
    Axes.new(Enum.Axis.X),
    BrickColor.new("Pastel Blue"),
    CFrame.new(12, 67, 90),
    CatalogSearchParams.new(),
    Color3.fromRGB(24, 45, 79),
    ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
    }),
    ColorSequenceKeypoint.new(0, Color3.fromRGB(1, 1, 1)),
    DateTime.fromUnixTimestamp(123456),
    DockWidgetPluginGuiInfo.new(
        Enum.InitialDockState.Float,
        true,
        false,
        150,
        150,
        100,
        100
    ),
    Enum.UserInputType,
    Enum.UserInputType.Gyro,
    Enum,
    Faces.new(Enum.NormalId.Front),
    FloatCurveKey.new(1, 1, Enum.KeyInterpolationMode.Constant),
    Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    Instance.new("Part"),
    NumberRange.new(1, 10),
    NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    }),
    NumberSequenceKeypoint.new(0, 0),
    OverlapParams.new(),
    PathWaypoint.new(Vector3.new(1, 1, 1), Enum.PathWaypointAction.Walk),
    PhysicalProperties.new(1, 1, 1, 1, 1),
    Random.new(),
    Ray.new(Vector3.new(1, 1, 1), Vector3.new(2, 2, 2)),
    RaycastParams.new(),
    Rect.new(Vector2.new(1, 1), Vector2.new(2, 2)),
    Region3.new(Vector3.new(1, 1, 1), Vector3.new(2, 2, 2)),
    Region3int16.new(Vector3int16.new(1, 1, 1), Vector3int16.new(1, 1, 1)),
    TweenInfo.new(
        1,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut,
        0,
        false,
        0
    ),
    UDim.new(0, 100),
    UDim2.new(0, 100, 0, 100),
    Vector2.new(1, 1),
    Vector2int16.new(1, 1),
    Vector3.new(1, 1),
    Vector3int16.new(1, 1),
}

print(LuaEncode(Table, {
    PrettyPrinting = true,
    IndentCount = 4,
}))

--[=[
Output:

{
    Axes.new(Enum.Axis.X),
    BrickColor.new("Pastel Blue"),
    CFrame.new(12, 67, 90, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CatalogSearchParams.new(),
    Color3.new(0.0941176488995552, 0.1764705926179886, 0.30980393290519714),
    ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(0.003921568859368563, 0.003921568859368563, 0.003921568859368563)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    }),
    ColorSequenceKeypoint.new(0, Color3.new(0.003921568859368563, 0.003921568859368563, 0.003921568859368563)),
    DateTime.fromUnixTimestamp(123456),
    DockWidgetPluginGuiInfo.new(--[[Error on serialization: "'InitialEnabled' is not a valid member of DockWidgetPluginGuiInfo"]]),
    Enum.UserInputType,
    Enum.UserInputType.Gyro,
    Enum,
    Faces.new(Enum.NormalId.Front),
    FloatCurveKey.new(1, 1, Enum.KeyInterpolationMode.Constant),
    Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    Instance.new("Part"),
    NumberRange.new(1, 10),
    NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0, 0),
        NumberSequenceKeypoint.new(1, 1, 0)
    }),
    NumberSequenceKeypoint.new(0, 0, 0),
    OverlapParams.new(),
    PathWaypoint.new(Vector3.new(1, 1, 1), Enum.PathWaypointAction.Walk, ""),
    PhysicalProperties.new(1, 1, 1, 1, 1),
    Random.new(),
    Ray.new(Vector3.new(1, 1, 1), Vector3.new(2, 2, 2)),
    RaycastParams.new(),
    Rect.new(Vector2.new(1, 1), Vector2.new(2, 2)),
    Region3.new(Vector3.new(1, 1, 1), Vector3.new(2, 2, 2)),
    Region3int16.new(Vector3int16.new(1, 1, 1), Vector3int16.new(1, 1, 1)),
    TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0),
    UDim.new(0, 100),
    UDim2.new(0, 100, 0, 100),
    Vector2.new(1, 1),
    Vector2int16.new(1, 1),
    Vector3.new(1, 1, 0),
    Vector3int16.new(1, 1, 0)
}
]=]
