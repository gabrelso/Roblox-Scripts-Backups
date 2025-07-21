if getgenv().Aiming then return getgenv().Aiming end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local Heartbeat = RunService.Heartbeat
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

local Drawingnew = Drawing.new
local Color3fromRGB = Color3.fromRGB
local Vector2new = Vector2.new
local WorldToViewportPoint = CurrentCamera.WorldToViewportPoint
local FindFirstChild = Instance.new("Part").FindFirstChild
local FindFirstChildWhichIsA = Instance.new("Part").FindFirstChildWhichIsA
local tableinsert = table.insert
local tableremove = table.remove
local mathrandom = math.random

getgenv().Aiming = {
    Enabled = true,
    ShowFOV = true,
    FOV = 60,
    FOVSides = 12,
    FOVColour = Color3fromRGB(231, 84, 128),
    VisibleCheck = true,
    HitChance = 100,
    Selected = nil,
    SelectedPart = nil,
    TargetPart = {"Head", "HumanoidRootPart"},
    Ignored = {
        Teams = {},
        Players = {LocalPlayer}
    }
}

local Aiming = getgenv().Aiming

local circle = Drawingnew("Circle")
circle.Transparency = 1
circle.Thickness = 2
circle.Color = Aiming.FOVColour
circle.Filled = false
Aiming.FOVCircle = circle

function Aiming.GetClosestTargetPartInFOV(Character)
    local TargetParts = Aiming.TargetPart
    local ClosestPart, ClosestPartPosition, ShortestDistance = nil, nil, 1/0

    local function CheckTargetPart(TargetPart)
        if typeof(TargetPart) == "string" then
            TargetPart = FindFirstChild(Character, TargetPart)
        end
        if not TargetPart then return end

        local PartPos, _ = WorldToViewportPoint(CurrentCamera, TargetPart.Position)
        local Magnitude = (Vector2new(PartPos.X, PartPos.Y) - Vector2new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)).Magnitude

        if Magnitude < ShortestDistance and Magnitude <= circle.Radius then
            ClosestPart, ClosestPartPosition = TargetPart, PartPos
            ShortestDistance = Magnitude
        end
    end

    if typeof(TargetParts) == "table" then
        for _, PartName in ipairs(TargetParts) do
            CheckTargetPart(PartName)
        end
    elseif typeof(TargetParts) == "string" then
        CheckTargetPart(TargetParts)
    end

    return ClosestPart, ClosestPartPosition
end

function Aiming.IsIgnoredTeam(Player)
    for _, v in ipairs(Aiming.Ignored.Teams) do
        if v.Team == Player.Team and v.TeamColor == Player.TeamColor then
            return true
        end
    end
    return false
end

function Aiming.IsIgnoredPlayer(Player)
    for _, p in ipairs(Aiming.Ignored.Players) do
        if p == Player or (typeof(p) == "number" and p == Player.UserId) then
            return true
        end
    end
    return false
end

function Aiming.GetClosestPlayerInFOV()
    local ClosestPlayer, ClosestTargetPart, ShortestDistance = nil, nil, 1/0

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer or Aiming.IsIgnoredPlayer(Player) or Aiming.IsIgnoredTeam(Player) then continue end

        local Character = Player.Character
        if Character then
            local TargetPart, _ = Aiming.GetClosestTargetPartInFOV(Character)
            if TargetPart then
                if mathrandom() > (Aiming.HitChance / 100) then
                    Aiming.Selected, Aiming.SelectedPart = nil, nil
                    return
                end
                ClosestPlayer, ClosestTargetPart = Player, TargetPart
                break
            end
        end
    end

    Aiming.Selected, Aiming.SelectedPart = ClosestPlayer, ClosestTargetPart
end

Heartbeat:Connect(function()
    circle.Visible = Aiming.ShowFOV
    circle.Radius = (Aiming.FOV * 3)
    circle.Position = Vector2new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
    circle.NumSides = Aiming.FOVSides
    circle.Color = Aiming.FOVColour
    Aiming.GetClosestPlayerInFOV()
end)

function Aiming.Check()
    return Aiming.Enabled and Aiming.Selected ~= LocalPlayer and Aiming.SelectedPart ~= nil
end

Aiming.CheckSilentAim = Aiming.Check

function Aiming.TeamCheck(toggle)
    if toggle then
        tableinsert(Aiming.Ignored.Teams, {
            Team = LocalPlayer.Team,
            TeamColor = LocalPlayer.TeamColor
        })
    else
        for i, v in ipairs(Aiming.Ignored.Teams) do
            if v.Team == LocalPlayer.Team and v.TeamColor == LocalPlayer.TeamColor then
                tableremove(Aiming.Ignored.Teams, i)
                break
            end
        end
    end
end

return Aiming
