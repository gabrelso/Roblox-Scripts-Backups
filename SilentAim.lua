if getgenv().Aiming then return getgenv().Aiming end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local Heartbeat = RunService.Heartbeat
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Drawingnew = Drawing.new
local Color3fromRGB = Color3.fromRGB
local Vector2new = Vector2.new
local GetGuiInset = GuiService.GetGuiInset
local Randomnew = Random.new
local mathfloor = math.floor
local CharacterAdded = LocalPlayer.CharacterAdded
local CharacterAddedWait = CharacterAdded.Wait
local WorldToViewportPoint = CurrentCamera.WorldToViewportPoint
local RaycastParamsnew = RaycastParams.new
local EnumRaycastFilterTypeBlacklist = Enum.RaycastFilterType.Blacklist
local Raycast = Workspace.Raycast
local GetPlayers = Players.GetPlayers
local Instancenew = Instance.new
local IsDescendantOf = Instancenew("Part").IsDescendantOf
local FindFirstChildWhichIsA = Instancenew("Part").FindFirstChildWhichIsA
local FindFirstChild = Instancenew("Part").FindFirstChild
local tableremove = table.remove
local tableinsert = table.insert

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
        Teams = {
            {
                Team = LocalPlayer.Team,
                TeamColor = LocalPlayer.TeamColor,
            },
        },
        Players = {
            LocalPlayer,
            91318356
        }
    }
}
local Aiming = getgenv().Aiming

local circle = Drawingnew("Circle")
circle.Transparency = 1
circle.Thickness = 2
circle.Color = Aiming.FOVColour
circle.Filled = false
Aiming.FOVCircle = circle

function Aiming.UpdateFOV()
    if not circle then return end
    circle.Visible = Aiming.ShowFOV
    circle.Radius = (Aiming.FOV * 3)
    circle.Position = Vector2new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
    circle.NumSides = Aiming.FOVSides
    circle.Color = Aiming.FOVColour
    return circle
end

local CalcChance = function(percentage)
    percentage = mathfloor(percentage)
    local chance = mathfloor(Randomnew().NextNumber(Randomnew(), 0, 1) * 100) / 100
    return chance <= percentage / 100
end

function Aiming.IsPartVisible(Part, PartDescendant)
    local Character = LocalPlayer.Character or CharacterAddedWait(CharacterAdded)
    local Origin = CurrentCamera.CFrame.Position
    local _, OnScreen = WorldToViewportPoint(CurrentCamera, Part.Position)
    if OnScreen then
        local raycastParams = RaycastParamsnew()
        raycastParams.FilterType = EnumRaycastFilterTypeBlacklist
        raycastParams.FilterDescendantsInstances = {Character, CurrentCamera}
        local Result = Raycast(Workspace, Origin, Part.Position - Origin, raycastParams)
        if Result then
            local PartHit = Result.Instance
            local Visible = (not PartHit or IsDescendantOf(PartHit, PartDescendant))
            return Visible
        end
    end
    return false
end

function Aiming.IgnorePlayer(Player)
    local Ignored = Aiming.Ignored
    local IgnoredPlayers = Ignored.Players
    for _, IgnoredPlayer in ipairs(IgnoredPlayers) do
        if IgnoredPlayer == Player then return false end
    end
    tableinsert(IgnoredPlayers, Player)
    return true
end

function Aiming.UnIgnorePlayer(Player)
    local Ignored = Aiming.Ignored
    local IgnoredPlayers = Ignored.Players
    for i, IgnoredPlayer in ipairs(IgnoredPlayers) do
        if IgnoredPlayer == Player then
            tableremove(IgnoredPlayers, i)
            return true
        end
    end
    return false
end

function Aiming.IgnoreTeam(Team, TeamColor)
    local Ignored = Aiming.Ignored
    local IgnoredTeams = Ignored.Teams
    for _, IgnoredTeam in ipairs(IgnoredTeams) do
        if IgnoredTeam.Team == Team and IgnoredTeam.TeamColor == TeamColor then return false end
    end
    tableinsert(IgnoredTeams, {Team, TeamColor})
    return true
end

function Aiming.UnIgnoreTeam(Team, TeamColor)
    local Ignored = Aiming.Ignored
    local IgnoredTeams = Ignored.Teams
    for i, IgnoredTeam in ipairs(IgnoredTeams) do
        if IgnoredTeam.Team == Team and IgnoredTeam.TeamColor == TeamColor then
            tableremove(IgnoredTeams, i)
            return true
        end
    end
    return false
end

function Aiming.TeamCheck(Toggle)
    if Toggle then
        return Aiming.IgnoreTeam(LocalPlayer.Team, LocalPlayer.TeamColor)
    end
    return Aiming.UnIgnoreTeam(LocalPlayer.Team, LocalPlayer.TeamColor)
end

function Aiming.IsIgnoredTeam(Player)
    local Ignored = Aiming.Ignored
    local IgnoredTeams = Ignored.Teams
    for _, IgnoredTeam in ipairs(IgnoredTeams) do
        if Player.Team == IgnoredTeam.Team and Player.TeamColor == IgnoredTeam.TeamColor then return true end
    end
    return false
end

function Aiming.IsIgnored(Player)
    local Ignored = Aiming.Ignored
    local IgnoredPlayers = Ignored.Players
    for _, IgnoredPlayer in ipairs(IgnoredPlayers) do
        if typeof(IgnoredPlayer) == "number" and Player.UserId == IgnoredPlayer then return true end
        if IgnoredPlayer == Player then return true end
    end
    return Aiming.IsIgnoredTeam(Player)
end

function Aiming.Raycast(Origin, Destination, UnitMultiplier)
    if typeof(Origin) == "Vector3" and typeof(Destination) == "Vector3" then
        if not UnitMultiplier then UnitMultiplier = 1 end
        local Direction = (Destination - Origin).Unit * UnitMultiplier
        local Result = Raycast(Workspace, Origin, Direction)
        if Result then
            local Normal = Result.Normal
            local Material = Result.Material
            return Direction, Normal, Material
        end
    end
    return nil
end

function Aiming.Character(Player)
    return Player.Character
end

function Aiming.CheckHealth(Player)
    local Character = Aiming.Character(Player)
    local Humanoid = FindFirstChildWhichIsA(Character, "Humanoid")
    local Health = (Humanoid and Humanoid.Health or 0)
    return Health > 0
end

function Aiming.Check()
    return (Aiming.Enabled == true and Aiming.Selected ~= LocalPlayer and Aiming.SelectedPart ~= nil)
end
Aiming.checkSilentAim = Aiming.Check

function Aiming.GetClosestPlayerToCursor()
    local TargetPart = nil
    local ClosestPlayer = nil
    local Chance = CalcChance(Aiming.HitChance)
    local ShortestDistance = math.huge
    if not Chance then
        Aiming.Selected = LocalPlayer
        Aiming.SelectedPart = nil
        return LocalPlayer
    end
    local centerX, centerY = CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2
    local centerVector2 = Vector2new(centerX, centerY)
    for _, Player in ipairs(GetPlayers(Players)) do
        local Character = Aiming.Character(Player)
        if not Aiming.IsIgnored(Player) and Character then
            local TargetPartTemp = nil
            if typeof(Aiming.TargetPart) == "table" then
                local shortestPartDist = math.huge
                for _, partName in ipairs(Aiming.TargetPart) do
                    local part = FindFirstChild(Character, partName)
                    if part then
                        local screenPos, onScreen = WorldToViewportPoint(CurrentCamera, part.Position)
                        if onScreen then
                            local dist = (Vector2new(screenPos.X, screenPos.Y) - centerVector2).Magnitude
                            if dist < shortestPartDist then
                                shortestPartDist = dist
                                TargetPartTemp = part
                            end
                        end
                    end
                end
            elseif typeof(Aiming.TargetPart) == "string" then
                TargetPartTemp = FindFirstChild(Character, Aiming.TargetPart)
            end
            if TargetPartTemp and Aiming.CheckHealth(Player) then
                local screenPos, onScreen = WorldToViewportPoint(CurrentCamera, TargetPartTemp.Position)
                if onScreen then
                    local distFromCenter = (Vector2new(screenPos.X, screenPos.Y) - centerVector2).Magnitude
                    if distFromCenter <= circle.Radius then
                        if distFromCenter < ShortestDistance then
                            if Aiming.VisibleCheck and not Aiming.IsPartVisible(TargetPartTemp, Character) then
                                goto continue
                            end
                            ClosestPlayer = Player
                            ShortestDistance = distFromCenter
                            TargetPart = TargetPartTemp
                        end
                    end
                end
            end
        end
        ::continue::
    end
    Aiming.Selected = ClosestPlayer
    Aiming.SelectedPart = TargetPart
end

Heartbeat:Connect(function()
    Aiming.UpdateFOV()
    Aiming.GetClosestPlayerToCursor()
end)

return Aiming
