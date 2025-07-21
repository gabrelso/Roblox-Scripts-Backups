-- NOT MINE, JUST A BACKUP

if getgenv().Aiming then return getgenv().Aiming end

-- // Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- // Variáveis
local Heartbeat = RunService.Heartbeat
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // Variáveis de Otimização
local Drawingnew = Drawing.new
local Color3fromRGB = Color3.fromRGB
local Vector2new = Vector2.new
local WorldToViewportPoint = CurrentCamera.WorldToViewportPoint
local FindFirstChild = Instance.new("Part").FindFirstChild
local FindFirstChildWhichIsA = Instance.new("Part").FindFirstChildWhichIsA
local tableinsert = table.insert
local tableremove = table.remove

-- // Variáveis do Silent Aim
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

-- // Criar círculo para o FOV
local circle = Drawingnew("Circle")
circle.Transparency = 1
circle.Thickness = 2
circle.Color = Aiming.FOVColour
circle.Filled = false
Aiming.FOVCircle = circle

-- // Atualizar o círculo
circle.Visible = Aiming.ShowFOV
circle.Radius = (Aiming.FOV * 3)
circle.Position = Vector2new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
circle.NumSides = Aiming.FOVSides
circle.Color = Aiming.FOVColour

-- // Função para obter a parte mais próxima dentro do FOV
function Aiming.GetClosestTargetPartInFOV(Character)
    local TargetParts = Aiming.TargetPart
    local ClosestPart, ClosestPartPosition, ShortestDistance = nil, nil, 1/0

    local function CheckTargetPart(TargetPart)
        if typeof(TargetPart) == "string" then
            TargetPart = FindFirstChild(Character, TargetPart)
        end
        if not TargetPart then return end

        local PartPos, OnScreen = WorldToViewportPoint(CurrentCamera, TargetPart.Position)
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

-- // Função para obter o jogador mais próximo dentro do FOV
function Aiming.GetClosestPlayerInFOV()
    local ClosestPlayer, ClosestTargetPart, ShortestDistance = nil, nil, 1/0

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer or Aiming.Ignored.Players[Player] then continue end

        local Character = Player.Character
        if Character then
            local TargetPart, _ = Aiming.GetClosestTargetPartInFOV(Character)

            if TargetPart then
                ClosestPlayer, ClosestTargetPart = Player, TargetPart
                break
            end
        end
    end

    Aiming.Selected, Aiming.SelectedPart = ClosestPlayer, ClosestTargetPart
end

-- // Atualizar FOV e encontrar jogador mais próximo no Heartbeat
Heartbeat:Connect(function()
    Aiming.GetClosestPlayerInFOV()
end)

-- // Verificar se o Silent Aim pode ser usado
function Aiming.Check()
    return Aiming.Enabled and Aiming.Selected ~= LocalPlayer and Aiming.SelectedPart ~= nil
end
Aiming.CheckSilentAim = Aiming.Check
