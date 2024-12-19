-- NOT MINE, JUST A BACKUP

if getgenv().FurryHBELoaded ~= nil then
	return
end
getgenv().FurryHBELoaded = false

if not game:IsLoaded() then
	game.Loaded:Wait()
end

if not getgenv().MTAPIMutex then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/RectangularObject/MT-Api-v2/main/__source/mt-api%20v2.lua", true))()
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/gabrelso/LinoriaLib/refs/heads/main/Library.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/gabrelso/LinoriaLib/refs/heads/main/addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/gabrelso/LinoriaLib/refs/heads/main/addons/ThemeManager.lua"))()

SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)
SaveManager:SetFolder("FurryHBE")

getgenv().AutoRun = false

local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera
local WorldToViewportPoint = Camera.WorldToViewportPoint
local lPlayer = Players.LocalPlayer
local players = {}
local entities = {}
local teamModule = nil

local function autoRun()
    while Toggles.autoRunToggle.Value == true do task.wait(0.3)
        local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.WalkSpeed == 16 then
            humanoid.WalkSpeed = 24
        end
    end
end

local function updatePlayers()
	if not getgenv().FurryHBELoaded then return end
	for _, v in pairs(players) do
		task.spawn(function()
			v:Update()
			task.wait(0.5)
		end)
	end
end

RunService:BindToRenderStep("furryWalls", Enum.RenderPriority.Camera.Value - 1, function()
	if not getgenv().FurryHBELoaded then return end
	Camera = Workspace.CurrentCamera
	for _, v in pairs(players) do
		task.spawn(function()
			v:UpdateESP()
			task.wait(0.5)
		end)
	end
end)

local mainWindow = Library:CreateWindow("Squares' Hitbox Extender")
local mainTab = mainWindow:AddTab("Main")
local mainGroupbox = mainTab:AddLeftGroupbox("Hitbox Extender")
local espGroupbox = mainTab:AddLeftGroupbox("ESP")
local ignoresGroupbox = mainTab:AddRightGroupbox("Ignores")
local collisionsGroupbox = mainTab:AddRightGroupbox("Collisions // Keybinds")

local miscTab = mainWindow:AddTab("Misc")
local gameGroupbox = miscTab:AddLeftGroupbox("Game")

local emergencyTab = mainWindow:AddTab("Emergency")
local emergencyGroupbox = emergencyTab:AddLeftGroupbox("Fixes")
local settingsTab = mainWindow:AddTab("Settings")

ThemeManager:ApplyToTab(settingsTab) 
SaveManager:BuildConfigSection(settingsTab)

mainGroupbox:AddToggle("extenderToggled", { Text = "Toggle" }):OnChanged(updatePlayers)
mainGroupbox:AddSlider("extenderSize", { Text = "Size", Min = 2, Max = 100, Default = 10, Rounding = 1 }):OnChanged(updatePlayers)
mainGroupbox:AddSlider("extenderTransparency", { Text = "Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2 }):OnChanged(updatePlayers)
mainGroupbox:AddInput("customPartName", { Text = "Custom Part Name", Default = "HeadHB" }):OnChanged(updatePlayers)
mainGroupbox:AddDropdown("extenderPartList", { Text = "Body Parts", AllowNull = true, Multi = true, Values = { "Custom Part", "Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Default = "HumanoidRootPart" }):OnChanged(updatePlayers)

espGroupbox:AddToggle("espHighlightToggled", { Text = "Chams" }):AddColorPicker("espHighlightColor1", { Title = "Fill Color", Default = Color3.fromRGB(0, 0, 0) }):AddColorPicker("espHighlightColor2", { Title = "Outline Color", Default = Color3.fromRGB(0, 0, 0) })
Toggles.espHighlightToggled:OnChanged(updatePlayers)
Options.espHighlightColor1:OnChanged(updatePlayers)
Options.espHighlightColor2:OnChanged(updatePlayers)
espGroupbox:AddToggle("espHighlightUseTeamColor", { Text = "Use Team Color For Chams" }):OnChanged(updatePlayers)
espGroupbox:AddDropdown("espHighlightDepthMode", { Text = "Chams Depth Mode", AllowNull = false, Multi = false, Values = { "Occluded", "AlwaysOnTop" }, Default = "Occluded" }):OnChanged(updatePlayers)
espGroupbox:AddSlider("espHighlightFillTransparency", { Text = "Chams Fill Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2 }):OnChanged(updatePlayers)
espGroupbox:AddSlider("espHighlightOutlineTransparency", { Text = "Chams Outline Transparency", Min = 0, Max = 1, Default = 0, Rounding = 2 }):OnChanged(updatePlayers)

collisionsGroupbox:AddLabel("Toggle UI"):AddKeyPicker("menuKeybind", { Default = "End", NoUI = true, Text = "Menu Keybind" })
collisionsGroupbox:AddLabel("Force Update"):AddKeyPicker("forceUpdateKeybind", { Default = "Home", NoUI = true, Text = "Force Update Keybind"})
Options.forceUpdateKeybind:OnClick(updatePlayers)
Library.ToggleKeybind = Options.menuKeybind

ignoresGroupbox:AddToggle("extenderSitCheck", { Text = "Ignore Sitting Players" }):OnChanged(updatePlayers)
ignoresGroupbox:AddToggle("extenderFFCheck", { Text = "Ignore Forcefielded Players" }):OnChanged(updatePlayers)
ignoresGroupbox:AddToggle("ignoreSelectedPlayersToggled", { Text = "Ignore Selected Players" }):OnChanged(updatePlayers)
ignoresGroupbox:AddDropdown("ignorePlayerList", { Text = "Players", AllowNull = true, Multi = true, Values = {} }):OnChanged(updatePlayers)
ignoresGroupbox:AddToggle("ignoreOwnTeamToggled", { Text = "Ignore Own Team" }):OnChanged(updatePlayers)
ignoresGroupbox:AddToggle("ignoreSelectedTeamsToggled", { Text = "Ignore Selected Teams" }):OnChanged(updatePlayers)
ignoresGroupbox:AddDropdown("ignoreTeamList", { Text = "Teams", AllowNull = true, Multi = true, Values = {} }):OnChanged(updatePlayers)

collisionsGroupbox:AddToggle("collisionsToggled", { Text = "Enable Collisions" }):OnChanged(updatePlayers)


gameGroupbox:AddLabel("Anti AFK is always enabled")

gameGroupbox:AddToggle("autoRunToggle", { Text = "Auto Run" }):OnChanged(autoRun)

SaveManager:LoadAutoloadConfig()

local function updateList(list)
	list:SetValues()
	list:Display()
end

if game.GameId == 504234221 then -- Vampire Hunters 3
	teamModule = require(ReplicatedStorage.Scripts.Modules.PlayerModule)
end
if game.GameId == 1934496708 then -- Project: SCP
	teamModule = require(Workspace:WaitForChild("Teams"))
end

local function addPlayer(player)
	table.insert(Options.ignorePlayerList.Values, player.Name)
	updateList(Options.ignorePlayerList)
	players[player] = {}
	local playerIdx = players[player]
	local playerChar = player.Character
	local defaultProperties = {}

	local function isTeammate()
		if game.GameId == 718936923 then -- Neighborhood War
			if not lPlayer.Character or not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then return true end
			return lPlayer.Character.HumanoidRootPart.Color == playerChar.HumanoidRootPart.Color
		elseif game.PlaceId == 633284182 then -- Fireteam
			if not player:FindFirstChild("PlayerData") or not player.PlayerData:FindFirstChild("TeamValue") then return true end
			return lPlayer.PlayerData.TeamValue.Value == player.PlayerData.TeamValue.Value
		elseif game.PlaceId == 2029250188 then -- Q-Clash
			if not lPlayer.Character or not playerChar then return true end
			return lPlayer.Character.Parent == playerChar.Parent
		elseif game.PlaceId == 2978450615 then -- Paintball Reloaded
			return getrenv()._G.PlayerProfiles.Data[lPlayer.Name].Team == getrenv()._G.PlayerProfiles.Data[player.Name].Team
		elseif game.GameId == 1934496708 then -- Project: SCP
			if Workspace.FriendlyFire.Value then return false end
			return (not player.Team or player.Team.Name == "LOBBY" or lPlayer.Team.Name == "LOBBY" or player.Team.Name == "Admin" or lPlayer.Team == player.Team) or
			teamModule[lPlayer.Team.Name] == teamModule[player.Team.Name] or
			((teamModule[lPlayer.Team.Name] == "CI" and teamModule[player.Team.Name] == "CD") or
			(teamModule[player.Team.Name] == "CI" and teamModule[lPlayer.Team.Name] == "CD"))
		elseif game.PlaceId == 2622527242 then -- SCP rBreach
			if not player.Team or player.Team.Name == "Intro" or player.Team.Name == "Spectator" or player.Team.Name == "Not Playing" or lPlayer.Team == player.Team then return true end
			local lPlayerTeamName = lPlayer.Team.Name
			local playerTeamName = player.Team.Name
			local selfTeam
			local playerTeam
			if lPlayerTeamName == "Class-D Personnel" or lPlayerTeamName == "Chaos Insurgency" then
				selfTeam = "Chads"
			end
			if lPlayerTeamName == "Facility Personnel" or lPlayerTeamName == "Security Department" or lPlayerTeamName == "Mobile Task Force" then
				selfTeam = "Crayon Eaters"
			end
			if lPlayerTeamName == "SCPs" or lPlayerTeamName == "Serpent's Hand" then
				selfTeam = "Menaces to Society"
			end
			if lPlayerTeamName == "Global Occult Coalition" then
				selfTeam = "Who?"
			end
			if lPlayerTeamName == "Unusual Incidents Unit" then
				selfTeam = "Who2?"
			end
			if playerTeamName == "Class-D Personnel" or playerTeamName == "Chaos Insurgency" then
				playerTeam = "Chads"
			end
			if playerTeamName == "Facility Personnel" or playerTeamName == "Security Department" or playerTeamName == "Mobile Task Force" then
				playerTeam = "Crayon Eaters"
			end
			if playerTeamName == "SCPs" or playerTeamName == "Serpent's Hand" then
				playerTeam = "Menaces to Society"
			end
			if playerTeamName == "Global Occult Coalition" then
				playerTeam = "Who?"
			end
			if playerTeamName == "Unusual Incidents Unit" then
				selfTeam = "Who2?"
			end
			if selfTeam == "Who2?" or playerTeam == "Who2?" then
				if selfTeam == "Crayon Eaters" or playerTeam == "Crayon Eaters" or selfTeam == "Who?" or playerTeam == "Who?" then
					return true
				end
			end
			return selfTeam == playerTeam
		elseif game.PlaceId == 8770868695 then -- Anomalous Activities: First Contact
			if not lPlayer.Character or not playerChar or not player.Team or player.Team.Name == "Dead" or player.Team.Name == "Inactive" then return true end
			return lPlayer.Character.Parent == playerChar.Parent
		elseif game.PlaceId == 5884786982 then -- Escape The Darkness
			if not lPlayer.Character or not playerChar then return true end
			return lPlayer.Character.name ~= "Killer" and playerChar.Name ~= "Killer"
		elseif game.GameId == 2162282815 then -- Rush Point
			if not player:FindFirstChild("SelectedTeam") then return true end
			return player.SelectedTeam.Value == lPlayer.SelectedTeam.Value
		elseif game.PlaceId == 1240644540 then -- Vampire Hunters 3
			if not teamModule or not teamModule.IsPlayerSurvivor then return true end
			return teamModule.IsPlayerSurvivor(nil, player) == true and teamModule.IsPlayerSurvivor(nil, lPlayer) == true
		elseif game.PlaceId == 10236714118 then -- Return of Humans vs Zombies
			if not player:FindFirstChild("PlayerData") or not player.PlayerData:FindFirstChild("Team") then return true end
			return lPlayer.PlayerData.Team.Value == player.PlayerData.Team.Value
		end
		return lPlayer.Team == player.Team
	end

	local function isDead()
		if not playerChar then return true end
		local humanoid = playerChar:FindFirstChildWhichIsA("Humanoid")
		if game.PlaceId == 6172932937 then -- Energy Assault
			return player.ragdolled.Value
		elseif game.GameId == 718936923 then -- Neighborhood War
			return playerChar:FindFirstChild("Dead") ~= nil
		end
		return humanoid and humanoid:GetState() == Enum.HumanoidStateType.Dead
	end

	local function isSitting()
		local humanoid = playerChar:FindFirstChildWhichIsA("Humanoid")
		return Toggles.extenderSitCheck.Value and humanoid ~= nil and humanoid.Sit == true
	end

	local function isFFed()
		if not playerChar then return false end
		if game.PlaceId == 4991214437 or game.PlaceId == 6652350934 then -- town
			return playerChar.Head.Material == Enum.Material.ForceField
		end
		local ff = playerChar:FindFirstChildWhichIsA("ForceField")
		return Toggles.extenderFFCheck.Value and playerChar ~= nil and ff ~= nil and ff.Visible == true
	end

	local function isIgnored()
		if not playerChar then return true end
		return Toggles.ignoreOwnTeamToggled.Value and isTeammate() or
		Toggles.ignoreSelectedTeamsToggled.Value and table.find(Options.ignoreTeamList:GetActiveValues(), tostring(player.Team)) or
		Toggles.ignoreSelectedPlayersToggled.Value and table.find(Options.ignorePlayerList:GetActiveValues(), tostring(player.Name))
	end

	-- hbe

	local debounce = false
	local function setup(part)
		defaultProperties[part.Name] = {}
		local properties = defaultProperties[part.Name]
		properties.Size = part.Size
		properties.Transparency = part.Transparency
		properties.Massless = part.Massless
		properties.CanCollide = part.CanCollide
		properties.CollisionGroupId = part.CollisionGroupId
		local getSizeHook = part:AddGetHook("Size", properties.Size)
		local getTransparencyHook = part:AddGetHook("Transparency", properties.Transparency)
		local getMasslessHook = part:AddGetHook("Massless", properties.Massless)
		local getCanCollideHook = part:AddGetHook("CanCollide", properties.CanCollide)
		--[[ local getCollisionGroupHook = part:AddGetHook("CollisionGroupId", properties.CollisionGroupId) ]]
		local setSizeHook = part:AddSetHook("Size", function(_, value)
			properties.Size = value
			getSizeHook:Modify("Size", properties.Size)
			if Toggles.extenderToggled.Value then
				local size = Options.extenderSize.Value
				return Vector3.new(size, size, size)
			end
			return properties.Size
		end)
		local setTransparencyHook = part:AddSetHook("Transparency", function(_, value)
			properties.Transparency = value
			getTransparencyHook:Modify("Transparency", properties.Transparency)
			if Toggles.extenderToggled.Value then
				return Options.extenderTransparency.Value
			end
			return properties.Transparency
		end)
		local setMasslessHook = part:AddSetHook("Massless", function(_, value)
			properties.Massless = value
			getMasslessHook:Modify("Massless", properties.Massless)
			if Toggles.extenderToggled.Value then
				if part.Name ~= "HumanoidRootPart" then
					return true
				end
			end
			return properties.Massless
		end)
		local setCanCollideHook = part:AddSetHook("CanCollide", function(_, value)
			properties.CanCollide = value
			getCanCollideHook:Modify("CanCollide", properties.CanCollide)
			if Toggles.extenderToggled.Value and not Toggles.collisionsToggled.Value then
				if part.Name == "Head" or part.Name == "HumanoidRootPart" then
					return false
				end
			end
			return properties.CanCollide
		end)
		--[[ local setCollisionGroupId = part:AddSetHook("CollisionGroupId", function(_, value)
			properties.CollisionGroupId = value
			getCollisionGroupHook:Modify("CollisionGroupId", properties.CollisionGroupId)
			if Toggles.extenderToggled.Value and not Toggles.collisionsToggled.Value then
				return PhysicsService:GetCollisionGroupId("furryCollisions")
			end
			return properties.CollisionGroupId
		end) ]]
		local changed = part.Changed:Connect(function(property) -- __namecall isn't replicated to the client when called from a serverscript
			if debounce then return end
			if properties[property] then
				if properties[property] ~= part[property] then
					properties[property] = part[property]
				end
				playerIdx:Update()
			end
		end)
		part.Destroying:Connect(function()
			getSizeHook:Remove()
			getTransparencyHook:Remove()
			getMasslessHook:Remove()
			getCanCollideHook:Remove()
			--getCollisionGroupHook:Remove()
			setSizeHook:Remove()
			setTransparencyHook:Remove()
			setMasslessHook:Remove()
			setCanCollideHook:Remove()
			--setCollisionGroupId:Remove()
			changed:Disconnect()
		end)
	end

	local function isActive(part)
		local name = part.Name
		for _, v in pairs(Options.extenderPartList:GetActiveValues()) do
			if string.match(name, v) or (v == "Custom Part" and string.match(name, Options.customPartName.Value)) or
			(v == "Left Arm" and string.match(name, "Left") and (string.match(name, "Arm") or string.match(name, "Hand"))) or
			(v == "Right Arm" and string.match(name, "Right") and (string.match(name, "Arm") or string.match(name, "Hand"))) or
			(v == "Left Leg" and string.match(name, "Left") and (string.match(name, "Leg") or string.match(name, "Foot"))) or
			(v == "Right Leg" and string.match(name, "Right") and (string.match(name, "Leg") or string.match(name, "Foot"))) then
				return true
			end
		end
		return false
	end

	local function resize(part)
		if not defaultProperties[part.Name] then
			setup(part)
		end
		if Toggles.extenderToggled.Value and isActive(part) and not isIgnored() and not isSitting() and not isFFed() and not isDead() then
			if part.Name ~= "HumanoidRootPart" then
				part.Massless = true
			end
			if not Toggles.collisionsToggled.Value then
				--[[ if part.Name == "Head" or part.Name == "HumanoidRootPart" then
					part.CanCollide = false
				else
					part.CollisionGroupId = PhysicsService:GetCollisionGroupId("furryCollisions")
				end ]]
				part.CanCollide = false
			else
				part.CanCollide = defaultProperties[part.Name].CanCollide
				--[[ part.CollisionGroupId = defaultProperties[part.Name].CollisionGroupId ]]
			end
			local size = Options.extenderSize.Value
			part.Size = Vector3.new(size, size, size)
			part.Transparency = Options.extenderTransparency.Value
			if part.Name == "Head" then
				local face = part:FindFirstChild("face")
				if face then
					face.Transparency = Options.extenderTransparency.Value
				end
			end
		else
			part.Massless = defaultProperties[part.Name].Massless
			part.CanCollide = defaultProperties[part.Name].CanCollide
			part.Size = defaultProperties[part.Name].Size
			part.Transparency = defaultProperties[part.Name].Transparency
			if part.Name == "Head" then
				local face = part:FindFirstChild("face")
				if face then
					face.Transparency = defaultProperties["Head"].Transparency
				end
			end
			--[[ part.CollisionGroupId = defaultProperties[part.Name].CollisionGroupId ]]
		end
	end

	function playerIdx:Update()
		if not playerChar then return end
		debounce = true
		for _, v in pairs(playerChar:GetChildren()) do
			if v:IsA("BasePart") then
				resize(v)
				task.wait(0.5)
			end
		end
		debounce = false
	end

	-- esp

local function FindFirstChildMatching(parent, name)
		if not parent then return nil end
		for _, v in pairs(parent:GetChildren()) do
			if string.match(v.Name, name) then
				return v
			end
		end
	end

	local chams = Instance.new("Highlight")
	chams.Parent = game:GetService("CoreGui")

	function playerIdx:UpdateESP()
		if not playerChar or isIgnored() or isDead() then 
			chams.Enabled = false 
			return 
		end

		local target = FindFirstChildMatching(playerChar, "Torso")
		if target then
			local _, vis = WorldToViewportPoint(Camera, target.Position)
			if vis then
				if Toggles.espHighlightToggled.Value then
					chams.Adornee = playerChar
					if Toggles.espHighlightUseTeamColor.Value then
						chams.FillColor = player.TeamColor.Color
						chams.OutlineColor = player.TeamColor.Color
					else
						chams.FillColor = Options.espHighlightColor1.Value
						chams.OutlineColor = Options.espHighlightColor2.Value
					end
					chams.DepthMode = Enum.HighlightDepthMode[Options.espHighlightDepthMode.Value]
					chams.FillTransparency = Options.espHighlightFillTransparency.Value
					chams.OutlineTransparency = Options.espHighlightOutlineTransparency.Value
					chams.Enabled = true
				else
					chams.Enabled = false
				end
			else
				chams.Enabled = false
			end
		else
			chams.Enabled = false
		end
	end

	function playerIdx:DeleteVisuals()
		chams:Destroy()
	end


	-- jank fix for CharacterAdded firing too early
	local function WaitForFullChar(char)
		local startTime = tick()
		local humanoid = char:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then
			repeat
				if char == nil then
					return false
				end
				humanoid = char:FindFirstChildWhichIsA("Humanoid")
				task.wait()
			until humanoid or tick()-startTime >= 2
		end
		local loaded = false
		startTime = tick()
		repeat
			local limbs = 0
			for _, v in pairs(char:GetChildren()) do
				if humanoid:GetLimb(v) ~= Enum.Limb.Unknown then
					limbs += 1
				end
			end
			if limbs == 6 or limbs == 15 then
				loaded = true
			end
			task.wait()
		until loaded or tick()-startTime >= 3
		--print(char, "has fully loaded")
		return true
	end

	player.CharacterAdded:Connect(function(character)
		--print(player, "spawned")
		playerChar = character
		defaultProperties = {}
		if WaitForFullChar(character) then
			playerIdx:Update()
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")
			if humanoid then
				humanoid:GetPropertyChangedSignal("Health"):Connect(function()
					if humanoid.Health <= 0 then
						playerIdx:Update()
					end
				end)
				humanoid.StateChanged:Connect(function(_, newState)
					if newState == Enum.HumanoidStateType.Dead then
						playerIdx:Update()
					end
				end)
			end
			if character:FindFirstChildWhichIsA("ForceField") then
				--print(player, "ff'ed")
				playerIdx:Update()
			end
			character.ChildAdded:Connect(function(child)
				if game.GameId == 718936923 then -- Neighborhood War
					if child.Name == "Dead" then
						playerIdx:Update()
						return
					end
				end
				if child:IsA("ForceField") then
					--print(player, "ff'ed")
					playerIdx:Update()
				end
			end)
			character.ChildRemoved:Connect(function(child)
				if child:IsA("ForceField") then
					--print(player, "un-ff'ed")
					playerIdx:Update()
				end
			end)
			if game.PlaceId == 4991214437 or game.PlaceId == 6652350934 then -- town
				local head = playerChar:FindFirstChild("Head")
				head:GetPropertyChangedSignal("Material"):Connect(function()
					playerIdx:Update()
				end)
			end
		end
	end)
	player.CharacterRemoving:Connect(function()
		--print(player, "despawned")
		if playerIdx then
			defaultProperties = {}
		end
	end)
	player:GetPropertyChangedSignal("Team"):Connect(function(team)
		--print(player, "updated team to", team)
		playerIdx:Update()
	end)
	if game.PlaceId == 6172932937 then -- Energy Assault
		local ragdolled = player:WaitForChild("ragdolled")
		ragdolled.Changed:Connect(function()
			playerIdx:Update()
		end)
	end
	if game.GameId == 1934496708 then -- Project: SCP
		local ff = Workspace:WaitForChild("FriendlyFire")
		ff.Changed:Connect(function()
			playerIdx:Update()
		end)
	end
	if game.GameId == 2162282815 then -- Rush Point
		local mapFolder = Workspace:WaitForChild("MapFolder")
		local gamePlayers = mapFolder:WaitForChild("Players")
		for _,v in pairs(gamePlayers:GetChildren()) do
			if v.Name == player.Name then
				playerChar = v
			end
		end
		gamePlayers.ChildAdded:Connect(function(v)
			if v.Name == player.Name then
				playerChar = v
			end
		end)
	end
	if game.PlaceId == 4991214437 or game.PlaceId == 6652350934 then -- town
		if playerChar then
			local head = playerChar:FindFirstChild("Head")
			head:GetPropertyChangedSignal("Material"):Connect(function()
				playerIdx:Update()
			end)
		end
	end
end

local function removePlayer(player)
	if not players[player] then return end
	players[player]:DeleteVisuals()
	table.remove(Options.ignorePlayerList.Values, table.find(Options.ignorePlayerList.Values, player.Name))
	updateList(Options.ignorePlayerList)
	players[player] = nil
end

for _, player in ipairs(Players:GetPlayers()) do
	if player == lPlayer then
		continue
	end
	--print("found player", player.Name)
	addPlayer(player)
end
for _, team in pairs(Teams:GetTeams()) do
	if team:IsA("Team") then
		--print("found team", team.Name)
		table.insert(Options.ignoreTeamList.Values, team.Name)
		updateList(Options.ignoreTeamList)
	end
end
Players.PlayerAdded:Connect(function(player)
	--print(player.Name, "joined")
	addPlayer(player)
end)
Players.PlayerRemoving:Connect(function(player)
	--print(player.Name, "left")
	removePlayer(player)
end)
Teams.ChildAdded:Connect(function(team)
	if team:IsA("Team") then
		--print(team.Name, "created")
		table.insert(Options.ignoreTeamList.Values, team.Name)
		updateList(Options.ignoreTeamList)
	end
end)
Teams.ChildRemoved:Connect(function(team)
	if team:IsA("Team") then
		--print(team.Name, "deleted")
		table.remove(Options.ignoreTeamList.Values, table.find(Options.ignoreTeamList.Values, team.Name))
		updateList(Options.ignoreTeamList)
	end
end)

lPlayer:GetAttributeChangedSignal("Team"):Connect(function()
	updatePlayers()
end)
lPlayer.CharacterAdded:Connect(function()
	updatePlayers()
end)

emergencyGroupbox:AddButton("Fix Missing Players", function()
	local found = 0
	for _, player in ipairs(Players:GetPlayers()) do
		if players[player] or player == lPlayer then continue else
			found = found + 1
			addPlayer(player)
		end
	end
	if found > 0 then
		Library:Notify("Found " .. found .. " players")
	else
		Library:Notify("No missing players found")
	end
	updatePlayers()
end):AddTooltip("Attempts to find players that were not detected by the hbe (somehow)")

getgenv().FurryHBELoaded = true
updatePlayers()

local function antiAfk()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = function(self, ...)
        local method = getnamecallmethod()
        if tostring(self) == "AFK" and method == "FireServer" then
            return
        end
        return oldNamecall(self, ...)
    end
    setreadonly(mt, true)
end

if game.PlaceId == 13132367906 then
  antiAfk()
  else
    print("nué o EB")
end
