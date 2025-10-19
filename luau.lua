-- Getting Player + Players + camera
local players = game:GetService("Players")
local player = players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- Services
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Uis = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TextChatService = game:GetService("TextChatService")
local TeleportService = game:GetService("TeleportService")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")

-- Ingame Events
local changeSettings = game:FindService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ChangeSetting")
local PositionRemote = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GunFramework"):WaitForChild("Remotes"):WaitForChild("Position")
local FireRemote = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GunFramework"):WaitForChild("Remotes"):WaitForChild("Fire")
local GunBuyEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GunBuy")
local BuyEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Buy")
local BlackMarketBuyEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BMBuy")

-- Applying Script for rejoinning or server hop
local autoRunScript = [[
	local idRemote = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GunFramework"):WaitForChild("Remotes"):WaitForChild("RequestCode")
	if idRemote then
		getgenv().ServerId = idRemote:InvokeServer()
	end	
]]
queueonteleport(autoRunScript)

-- Adding Id Listener For Silent Aim Blatant Mode
getgenv().ServerId = nil

local old
old = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()
	local args = {...}

	if not checkcaller() and method == "FireServer" and self == FireRemote then
		getgenv().ServerId = args[1]
	end
	return old(self, ...)
end)

-- Getting executor status
local supportedMethods = {
    "hookfunction",
    "hookmetamethod",
    "newcclosure",
    "getnamecallmethod",
    "setreadonly",
    "islclosure",
    "getrawmetatable",
    "setmetatable",
	"Drawing"
}

local executorSupport = {}

for _, methodName in ipairs(supportedMethods) do
    local methodFunc = getgenv()[methodName]
    if typeof(methodFunc) == "function" then
        executorSupport[methodName] = true
	elseif typeof(methodFunc) == "table" then
        executorSupport[methodName] = true
	else
		executorSupport[methodName] = false
    end
end

local failedUncTest = false
local supportedFeaturesCounter = 0

-- Print results
for method, isSupported in pairs(executorSupport) do
    print(method .. ": " .. (isSupported and "✅ Supported" or "❌ Not supported"))
	if method == false then
		failedUncTest = true
	else
		supportedFeaturesCounter += 1
	end
end

-- Watching for server id to use for silent aim
local ID = nil
local Success, Error = pcall(function()
	local old
	old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		local method = getnamecallmethod()
		local args = { ... }

		if not checkcaller() and method == "FireServer" and tostring(self) == "Fire" then
			ID = args[1]
		end	
	
		return old(self, ...)
	end))
end)

if Success then
	print("Successfully Loaded User Contents")
else
	warn("Failed to get silent aim features, your executor most likely does not support this")
end

-- Boosting Libary In Secure Mode
getgenv().SecureMode = true

-- Loading Ui Libary + Icons
local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()  
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

-- Creating ui window
local Window = Starlight:CreateWindow({
    Name = "Vortex Hub",
    Subtitle = "Game = Street Life Remasterd | Undetected Status = 🟢",
    Icon = 88829788766057,

	LoadingEnabled = false,
    LoadingSettings = {
        Title = "Vortex Hub Loading",
        Subtitle = "Thanks For Choosing Vortex Hub",
    },

	FileSettings = {
		ConfigFolder = "Vortex Hub - Street Life Remasterd"
	},
})

Starlight:SetTheme("Orca")

local promptStatus = nil
local promptInfo = nil

if failedUncTest then
	promptStatus = "🔴"
	promptInfo = "Your executor does not support " .. supportedFeaturesCounter .. "/" .. "9 of the features required, Read more in the detections tab"
else
	promptStatus = "🟢"
	promptInfo = "Your executor passed the unc test and supports " .. supportedFeaturesCounter .. "/" .. "9 of the features required."
end

local starLightDestroyed = false

-- Showing user what methods his executor supports and doesnt support
Window:PromptDialog({
    Name = "Executor Status: " .. promptStatus,
    Content = promptInfo,
    Type = 1,
    Actions = { 
        Primary = {
            Name = "Continue",
            Icon = NebulaIcons:GetIcon("check", "Material"),
            Callback = function()
				Starlight:Notification({
    				Title = "Welcome " .. player.Name,
    				Icon = NebulaIcons:GetIcon('sparkle', 'Material'),
   					Content = "Vortex Hub Sucessfully Loaded",
					Duration = 10,
				}, "INDEX")
            end
        }, 
        {
            Name = "Destroy Ui",
            Callback = function()
				Starlight:Destroy()
				starLightDestroyed = true
            end
        },
    }
})

if starLightDestroyed then return end

-- Grabbing Player Essentials
local enabledFeatures = {}

getgenv().char = player.Character or Player.CharacterAdded:wait()
getgenv().hum = getgenv().char:WaitForChild("Humanoid")
getgenv().root = getgenv().char:WaitForChild("HumanoidRootPart")

-- Tab sections table
local tabSections = {
	mainTabSection = Window:CreateTabSection("Main"),
	extraTabSection = Window:CreateTabSection("Extra"),
	infoTabSection = Window:CreateTabSection("Info"),
}

-- Tabs table
local tabs = {
	generalTab = tabSections.mainTabSection:CreateTab({
		Name = "General",
		Icon = NebulaIcons:GetIcon('user-round', 'Lucide'),
		Columns = 2,
	}, "INDEX"),

	visualsTab = tabSections.mainTabSection:CreateTab({
		Name = "Visuals",
		Icon = NebulaIcons:GetIcon('eye', 'Lucide'),
		Columns = 2,
	}, "INDEX"),

	combatTab = tabSections.mainTabSection:CreateTab({
		Name = "Combat",
		Icon = NebulaIcons:GetIcon('swords', 'Lucide'),
		Columns = 2,
	}, "INDEX"),

	modsTab = tabSections.mainTabSection:CreateTab({
		Name = "Mods",
		Icon = NebulaIcons:GetIcon('file-code', 'Lucide'),
		Columns = 2,
	}, "INDEX"),

	farmTab = tabSections.mainTabSection:CreateTab({
		Name = "Farms",
		Icon = NebulaIcons:GetIcon('cannabis', 'Lucide'),
		Columns = 2,
	}, "INDEX"),

	shopTab = tabSections.mainTabSection:CreateTab({
		Name = "Shop",
		Icon = NebulaIcons:GetIcon('store', 'Lucide'),
		Columns = 2,
	}, "INDEX"),

	miscTab = tabSections.extraTabSection:CreateTab({
		Name = "Misc",
		Icon = NebulaIcons:GetIcon('circle-plus', 'Lucide'),
		Columns = 2,
	}, "INDEX"),

	settingsTab = tabSections.extraTabSection:CreateTab({
		Name = "Settings",
		Icon = NebulaIcons:GetIcon('settings', 'Lucide'),
		Columns = 2,
	}, "INDEX"),

	detectionTab = tabSections.infoTabSection:CreateTab({
		Name = "Detections",
		Icon = NebulaIcons:GetIcon('shield-alert', 'Lucide'),
		Columns = 2,
	}, "INDEX"),
}

-- Group boxes table
local groupBoxes = {
	mainGroup1 = tabs.generalTab:CreateGroupbox({
		Name = "LocalPlayer Modifications",
		Column = 1,
	}, "INDEX"),

	mainGroup2 = tabs.generalTab:CreateGroupbox({
		Name = "Global Modifications",
		Column = 2,
	}, "INDEX"),

	mainGroup3 = tabs.generalTab:CreateGroupbox({
		Name = "Respawn Utilities",
		Column = 1,
	}, "INDEX"),

	mainGroup4 = tabs.generalTab:CreateGroupbox({
		Name = "Troll / Fun",
		Column = 2,
	}, "INDEX"),

	visualsGroup1 = tabs.visualsTab:CreateGroupbox({
		Name = "Players Esp",
		Column = 1,
	}, "INDEX"),

	visualsGroup2 = tabs.visualsTab:CreateGroupbox({
		Name = "General Esp",
		Column = 2,
	}, "INDEX"),

	visualsGroup3 = tabs.visualsTab:CreateGroupbox({
		Name = "Player Esp Configurations",
		Column = 1,
	}, "INDEX"),

	visualsGroup4 = tabs.visualsTab:CreateGroupbox({
		Name = "General Esp Configurations",
		Column = 2,
	}, "INDEX"),

	combatGroup1 = tabs.combatTab:CreateGroupbox({
		Name = "Aim Assist",
		Column = 1,
	}, "INDEX"),

	combatGroup2 = tabs.combatTab:CreateGroupbox({
		Name = "Silent Aim",
		Column = 2,
	}, "INDEX"),

	combatGroup3 = tabs.combatTab:CreateGroupbox({
		Name = "Miscellaneous",
		Column = 1,
	}, "INDEX"),

	modsGroup1 = tabs.modsTab:CreateGroupbox({
		Name = "Gun Modifications",
		Column = 1,
	}, "INDEX"),

	farmsGroup1 = tabs.farmTab:CreateGroupbox({
		Name = "Job Farms",
		Column = 1,
	}, "INDEX"),

	farmsGroup2 = tabs.farmTab:CreateGroupbox({
		Name = "More Coming Soon",
		Column = 2,
	}, "INDEX"),

	shopGroup1 = tabs.shopTab:CreateGroupbox({
		Name = "Armory",
		Column = 1,
	}, "INDEX"),

	shopGroup2 = tabs.shopTab:CreateGroupbox({
		Name = "Merchant",
		Column = 2,
	}, "INDEX"),

	shopGroup3 = tabs.shopTab:CreateGroupbox({
		Name = "Utilities",
		Column = 1,
	}, "INDEX"),

	shopGroup4 = tabs.shopTab:CreateGroupbox({
		Name = "Black Market (Gamepass Required)",
		Column = 2,
	}, "INDEX"),

	settingsGroup1 = tabs.settingsTab:CreateGroupbox({
		Name = "General Settings",
		Column = 1,
	}, "INDEX"),

	miscGroup1 = tabs.miscTab:CreateGroupbox({
		Name = "Bank",
		Column = 1,
	}, "INDEX"),

	settingsGroup2 = tabs.settingsTab:CreateGroupbox({
		Name = "Extra Settings / Info",
		Column = 2,
	}, "INDEX"),

	detectionGroup1 = tabs.detectionTab:CreateGroupbox({
		Name = "Features not supported or possibly detected below",
		Column = 1,
	}, "INDEX"),
	
	detectionGroup2 = tabs.detectionTab:CreateGroupbox({
		Name = "Executor unc status / Features required for the script",
		Column = 2,
	}, "INDEX"),
}

-- Detections tab configurations
local detectionFeatures = {}

detectionFeatures.yellowStatus = groupBoxes.detectionGroup1:CreateLabel({
	Name = "🟡 = Possibly Detected"
}, "Index")

detectionFeatures.redStatus = groupBoxes.detectionGroup1:CreateLabel({
	Name = "🔴 = Executor Not Supported"
}, "INDEX")

detectionFeatures.walkSpeedFeature = groupBoxes.detectionGroup1:CreateLabel({
	Name = "WalkSpeed Boost : 🟡"
}, "INDEX")

detectionFeatures.jumpPowerFeature = groupBoxes.detectionGroup1:CreateLabel({
	Name = "JumpPower Enabled : 🟡"
}, "INDEX")

if not executorSupport["hookmetamethod"] then
	detectionFeatures.infStaminaFeature = groupBoxes.detectionGroup1:CreateLabel({
		Name = "Infinite Stamina : 🟡"
	}, "INDEX")

	detectionFeatures.silentAimFeature1 = groupBoxes.detectionGroup1:CreateLabel({
		Name = "Silent Aim : 🔴"
	}, "INDEX")

	detectionFeatures.killAuraFeature1 = groupBoxes.detectionGroup1:CreateLabel({
		Name = "Kill Aura : 🔴"
	}, "INDEX")
end

detectionFeatures.infJumpFeature = groupBoxes.detectionGroup1:CreateLabel({
	Name = "Infinite Jump : 🟡",
}, "INDEX")

detectionFeatures.infBoostFeature = groupBoxes.detectionGroup1:CreateLabel({
	Name = "Infinite Boost : 🟡",
}, "INDEX")

detectionFeatures.flyFeature = groupBoxes.detectionGroup1:CreateLabel({
	Name = "Fly : 🟡",
}, "INDEX")

detectionFeatures.vehicleFlyFeature = groupBoxes.detectionGroup1:CreateLabel({
	Name = "Vehicle Fly : 🟡",
}, "INDEX")

detectionFeatures.generalEspSectionFeature = groupBoxes.detectionGroup1:CreateLabel({
	Name = "General Esp Section : 🟡"
}, "INDEX")

if not Drawing and typeof(Drawing.new) ~= "function" then
	detectionFeatures.playerEspFeature = groupBoxes.detectionGroup1:CreateLabel({
		Name = "Players Esp : 🔴",
	}, "INDEX")

	detectionFeatures.aimAssistFovFeature = groupBoxes.detectionGroup1:CreateLabel({
		Name = "Aim Assist Fov : 🔴",
	}, "INDEX")
end

detectionFeatures.silentAimFeature2 = groupBoxes.detectionGroup1:CreateLabel({
	Name = "Silent Aim : 🟡",
}, "INDEX")

detectionFeatures.killAuraFeature2 = groupBoxes.detectionGroup1:CreateLabel({
	Name = "Kill Aura : 🟡"
}, "INDEX")

-- Executor unc status section
for method, status in pairs(executorSupport) do
	local methodStatus = nil
	if status then
		methodStatus = "✅"
	else
		methodStatus = "❌"
	end
	local stringName = method .. " = " .. methodStatus

	detectionFeatures.method = groupBoxes.detectionGroup2:CreateLabel({
		Name = stringName	
	}, "INDEX")
end

-- Settings Configurations
local settingsFeatures = {}
settingsFeatures.storedKeybind = "K"
settingsFeatures.storedTheme = "Orca"
settingsFeatures.storedLegacyTheme = ""

-- Minimize Ui KeyBind
settingsFeatures.minimizeUiKeybind = groupBoxes.settingsGroup1:CreateInput({
	Name = "Minimize Ui Keybind",
	Icon = NebulaIcons:GetIcon('keyboard', 'Lucide'),
	CurrentValue = "K",
	PlaceholderText = "Enter Key Here",
	Enter = true,
	Callback = function(Text)
		if Text ~= nil and Text ~= "" then
			settingsFeatures.storedKeybind = Text
		end
	end
}, "INDEX")

-- Applying changes to the script from the users selected minimized keybind
settingsFeatures.applyMinimizeKeybind = groupBoxes.settingsGroup1:CreateButton({
	Name = "Apply Minimize Key",
	Icon = NebulaIcons:GetIcon('chevron-right', 'Lucide'),
	Callback = function()
		local success, result = pcall(function()
			return Enum.KeyCode[settingsFeatures.storedKeybind]
		end)

		if success and result and settingsFeatures.storedKeybind ~= nil then
			for i = 1, 10 do
				Starlight.WindowKeybind = settingsFeatures.storedKeybind
				task.wait()
			end

			Starlight:Notification({
				Title = "Sucessfully Applied Changes",
				Icon = NebulaIcons:GetIcon('circle-check-big','Lucide'),
				Content = "If any issues please open support ticket via discord",
			}, "INDEX")
		else
			Starlight:Notification({
				Title = "Error: Key enterd is invalid",
				Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
				Content = "",
			}, "INDEX")
		end
	end
}, "INDEX")

-- Theme Selection
settingsFeatures.themeLabel = groupBoxes.settingsGroup1:CreateLabel({
	Name = "Theme Selections",
}, "INDEX")

settingsFeatures.themeDropdown = settingsFeatures.themeLabel:AddDropdown({
	Options = {"Starlight", "Orca", "Glacier", "Pacific", "Crimson", "Neo", "Nebula"},
	CurrentOptions = {"Orca"},
	Placeholder = "Select Ui Theme",
	Callback = function(Options)
		if Options then
			settingsFeatures.storedTheme = Options[1]
		end
	end,
}, "INDEX")

settingsFeatures.applyThemeDropdown = groupBoxes.settingsGroup1:CreateButton({
	Name = "Apply Theme",
	Icon = NebulaIcons:GetIcon('chevron-right', 'Lucide'),
	Callback = function()
		if settingsFeatures.storedTheme then
			Starlight:SetTheme(settingsFeatures.storedTheme)
		end
	end
}, "INDEX")

-- Legacy Theme Selections
settingsFeatures.legacyThemeLabel = groupBoxes.settingsGroup1:CreateLabel({
	Name = "Legacy Theme Selection",
}, "INDEX")

settingsFeatures.legacyThemeDropdown = settingsFeatures.legacyThemeLabel:AddDropdown({
	Options = {"Evergreen", "Ubuntu", "Luna", "OperaGX", "BBot", "Hollywood Fluent"},
	CurrentOptions = {"Evergreen"},
	Placeholder = "None",
	Callback = function(Options)
		if Options then
			settingsFeatures.storedLegacyTheme = Options
		end
	end
}, "INDEX")

settingsFeatures.applyLegacyThemeDropdown = groupBoxes.settingsGroup1:CreateButton({
	Name = "Legacy Themes",
	Icon = NebulaIcons:GetIcon('chevron-right', 'Lucide'),
	Callback = function()
		if settingsFeatures.storedLegacyTheme[1] then
			Starlight:SetTheme(settingsFeatures.storedLegacyTheme[1])
		end
	end
}, "INDEX")

-- License key timer
local stringTimer = "License Duration: 0"
local lastStringTimer = nil
local keepUpdatingLicense = true

-- Function to update license timer
local function updateLicenseTime()
	local secondsLeft = LRM_SecondsLeft or 86400
	local timeLeft = 0

	if secondsLeft >= 86400 then
		timeLeft = math.floor(secondsLeft / 86400)
		stringTimer = "License Duration: " .. timeLeft .. " Days"
	elseif secondsLeft >= 3600 then
		timeLeft = math.floor(secondsLeft / 3600)
		stringTimer = "License Duration: " .. timeLeft .. " Hours"
	elseif secondsLeft >= 60 then
		timeLeft = math.floor(secondsLeft / 60)
		stringTimer = "License Duration: " .. timeLeft .. " Minutes"
	else
		stringTimer = "License Duration: Expired"
	end
end

-- Initial license timer label setup
updateLicenseTime()
settingsFeatures.licenseTimer = groupBoxes.settingsGroup2:CreateLabel({
	Name = stringTimer,
}, "INDEX")

task.spawn(function()
	while keepUpdatingLicense do
		updateLicenseTime()

		if stringTimer ~= lastStringTimer then
			settingsFeatures.licenseTimer:Set({ Name = stringTimer })
			lastStringTimer = stringTimer
		end

		task.wait(1)
	end
end)

-- Total executions label
local totalExecutions = LRM_TotalExecutions or 0

settingsFeatures.scriptExecutionsLabel = groupBoxes.settingsGroup2:CreateLabel({
	Name = "Total Executions: " .. totalExecutions,
}, "INDEX")

-- Discord Id Label
local discordID = LRM_LinkedDiscordID or "Uknown"
settingsFeatures.discordIdLabel = groupBoxes.settingsGroup2:CreateLabel({
	Name = "Discord ID: " .. discordID,
}, "INDEX")

-- Unloading script button
settingsFeatures.unLoadUiButton = groupBoxes.settingsGroup2:CreateButton({
	Name = "Unload Ui",
	Icon = NebulaIcons:GetIcon('code-xml', 'Lucide'),
	Callback = function()
		Starlight:Destroy()
	end
}, "INDEX")

-- Rejoin Server With Server Id
settingsFeatures.rejoinServer = groupBoxes.settingsGroup2:CreateButton({
	Name = "Rejoin Server With Essentials (Recommended)",
	Icon = NebulaIcons:GetIcon('server', 'Lucide'),
	Callback = function()
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
	end
}, "INDEX")

-- General tab features
local mainGroupFeatures = {}

-- Speed Modification
local speedMod = {}
speedMod.speedConn = nil
speedMod.conn1 = nil
speedMod.setWalkSpeed = 29

-- Enable Speed Function
function speedMod:EnabledSpeedBoost()
	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	local function applySpeed()
		if self.speedConn then
			self.speedConn:Disconnect()
			self.speedConn = nil
		end

		getgenv().hum.WalkSpeed = self.setWalkSpeed
		self.speedConn = getgenv().hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if getgenv().hum.WalkSpeed ~= self.setWalkSpeed then
				getgenv().hum.WalkSpeed = self.setWalkSpeed
			end
		end)
	end

	applySpeed()

	enabledFeatures["applySpeed"] = applySpeed
end

-- Disable Speed Function
function speedMod:DisableSpeedBoost()
	if enabledFeatures["applySpeed"] then
		enabledFeatures["applySpeed"] = nil
	end

	if self.speedConn then
		self.speedConn:Disconnect()
		self.speedConn = nil
	end

	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	getgenv().hum.WalkSpeed = 16
end

-- WalkSpeed Toggle Enable/Disable
mainGroupFeatures.walkSpeedToggle = groupBoxes.mainGroup1:CreateToggle({
	Name = "Enable Speed Boost",
	CurrentValue = false,
	Style = 1,
	Callback = function(State)
		if State then
			speedMod:EnabledSpeedBoost()
		else
			speedMod:DisableSpeedBoost()
		end
	end
}, "INDEX")

-- WalkSpeed Value Slider
mainGroupFeatures.walkSpeedSlider = groupBoxes.mainGroup1:CreateSlider({
	Name = "WalkSpeed Value",
	Icon = NebulaIcons:GetIcon('zap', "Lucide"),
	Range = {16, 29},
	Increment = 1,
	Callback = function(Value)
		if Value ~= nil and tonumber(Value) > 0 then
			speedMod.setWalkSpeed = tonumber(Value)
		else
			Starlight:Notification({
				Title = "WalkSpeed Value Is Nil",
				Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
				Content = "If the issue persists please open a support ticket via discord",
			}, "INDEX")
		end
	end	
}, "INDEX")

-- Jump Modification
local jumpMod = {}
jumpMod.jumpConn = nil
jumpMod.conn1 = nil
jumpMod.setJumpValue = 50

-- Enable Jump Modification Function
function jumpMod:EnableJumpBoost()
	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	local function applyJumpPower()
		if self.jumpConn then
			self.jumpConn:Disconnect()
			self.jumpConn = nil
		end

		getgenv().hum.JumpPower = self.setJumpValue
		self.jumpConn = getgenv().hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
			if getgenv().hum.JumpPower ~= self.setJumpValue then
				getgenv().hum.JumpPower = self.setJumpValue
			end
		end)
	end

	applyJumpPower()

	enabledFeatures["applyJumpPower"] = applyJumpPower
end

-- Disabling Jump Modification Function
function jumpMod:DisableJumpBoost()
	if enabledFeatures["applyJumpPower"] then
		enabledFeatures["applyJumpPower"] = nil
	end

	if self.jumpConn then
		self.jumpConn:Disconnect()
		self.jumpConn = nil
	end

	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	getgenv().hum.JumpPower = 0
end

-- Jump power toggle
mainGroupFeatures.jumpPowerToggle = groupBoxes.mainGroup1:CreateToggle({
	Name = "Enable Jump Power",
	CurrentValue = false,
	Style = 1,
	Callback = function(State)
		if State then
			jumpMod:EnableJumpBoost()
		else
			jumpMod:DisableJumpBoost()
		end
	end	
}, "INDEX")

-- Jump power value slider
mainGroupFeatures.jumpPowerSlider = groupBoxes.mainGroup1:CreateSlider({
	Name = "JumpPower Value",
	Icon = NebulaIcons:GetIcon('dumbbell', 'Lucide'),
	Range = {30, 100},
	Increment = 1,
	Callback = function(Value)
		if Value ~= nil and tonumber(Value) > 0 then
			jumpMod.setJumpValue = tonumber(Value)
		else
			Starlight:Notification({
				Title = "JumpPower Value is nil",
				Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
				Content = "if the issue persists please open a support ticket via discord",
			}, "INDEX")
		end
	end
}, "INDEX")

-- Inf jump modification
local infJumpMod = {}
infJumpMod.jumpConn = nil

-- Inf jump function
function infJumpMod:EnabledInfJump()
	local function applyInfJump()
		if self.jumpConn then
			self.jumpConn:Disconnect()
			self.jumpConn = nil
		end

		getgenv().infJumpDebounce = false
		self.jumpConn = Uis.JumpRequest:Connect(function()
			if not getgenv().infJumpDebounce then
				getgenv().infJumpDebounce = true
				getgenv().hum:ChangeState(Enum.HumanoidStateType.Jumping)
				task.wait()
				getgenv().infJumpDebounce = false
			end
		end)
	end

	applyInfJump()

	enabledFeatures["applyInfJump"] = applyInfJump
end

-- Disable inf jump function
function infJumpMod:DisableInfJump()
	if enabledFeatures["applyInfJump"] then
		enabledFeatures["applyInfJump"] = nil
	end

	if self.jumpConn then
		self.jumpConn:Disconnect()
		self.jumpConn = nil
	end
end

-- Inf jump toggle
mainGroupFeatures.infJumpToggle = groupBoxes.mainGroup1:CreateToggle({
	Name = "Inf Jump",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			infJumpMod:EnabledInfJump()
		else
			infJumpMod:DisableInfJump()
		end
	end
}, "INDEX")

-- Inf stamina modification
local staminaMod = {}
staminaMod.stamConn = nil
staminaMod.conn1 = nil
staminaMod.storedValue = 100

-- Enable inf stamina function
function staminaMod:EnableInfStamina()
	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	if hookmetamethod and not getgenv().StaminaSpoofed then
		getgenv().StaminaSpoofed = true

		local oldIndex
		oldIndex = hookmetamethod(game, "__index", function(self, key)
			if not checkcaller() and self:IsA("Model") and self == getgenv().char and key == "Stamina" then
				return 100
			end
			return oldIndex(self, key)
		end)
	end

	local function applyInfStamina()
		if self.stamConn then
			self.stamConn:Disconnect()
			self.stamConn = nil
		end

		getgenv().char:SetAttribute("Stamina", 100)
		self.stamConn = getgenv().char:GetAttributeChangedSignal("Stamina"):Connect(function()
			if getgenv().char:GetAttribute("Stamina") ~= 100 then
				getgenv().char:SetAttribute("Stamina", 100)
			end
		end)
		getgenv().char:SetAttribute("Stamina", 100)
	end

	self.storedValue = getgenv().char:GetAttribute("Stamina")
	applyInfStamina()

	enabledFeatures["applyInfStamina"] = applyInfStamina
end

-- Disabling infinite stamina function
function staminaMod:DisableInfStamina()
	if enabledFeatures["applyInfStamina"] then
		enabledFeatures["applyInfStamina"] = nil
	end

	if self.stamConn then
		self.stamConn:Disconnect()
		self.stamConn = nil
	end

	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	local defaultValue = self.storedValue or 100
	if defaultValue and getgenv().char then
		getgenv().char:SetAttribute("Stamina", defaultValue)
	end
end

-- Infinite stamina toggle
mainGroupFeatures.infStaminaToggle = groupBoxes.mainGroup1:CreateToggle({
	Name = "Infinite Stamina",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			staminaMod:EnableInfStamina()
		else
			staminaMod:DisableInfStamina()
		end
	end
}, "INDEX")

-- Infinite Boost Modification
local boostMod = {}
boostMod.conn1 = nil

-- Enable Inf Boost Function
function boostMod:EnableInfBoost()
	local function applyInfBoost()
		if self.conn1 then
			self.conn1:Disconnect()
			self.conn1 = nil
		end

		getgenv().char:SetAttribute("Boost", true)
		self.conn1 = getgenv().char:GetAttributeChangedSignal("Boost"):Connect(function()
			if not getgenv().char:GetAttribute("Boost") then
				getgenv().char:SetAttribute("Boost", true)
			end
		end)
	end

	applyInfBoost()

	enabledFeatures["applyInfBoost"] = applyInfBoost
end

-- Disable Inf Boost Function
function boostMod:DisableInfBoost()
	if enabledFeatures["applyInfBoost"] then
		enabledFeatures["applyInfBoost"] = nil
	end

	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	getgenv().char:SetAttribute("Boost", false)
end

-- Infinite Boost Toggle
mainGroupFeatures.infBoostToggle = groupBoxes.mainGroup1:CreateToggle({
	Name = "Infinite Boost",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			boostMod:EnableInfBoost()
		else
			boostMod:DisableInfBoost()
		end
	end
}, "INDEX")

-- Chams modifications
local chamsMod = {}
chamsMod.colorFill = Color3.fromRGB(255, 255, 255)
chamsMod.colorOutline = Color3.fromRGB(255, 255, 255)
chamsMod.storedDefault = {}

-- Enable Chams Function
function chamsMod:EnableChams()
	local function applyChams()
		if getgenv().char:FindFirstChild("Chams") then
			getgenv().char:FindFirstChild("Chams"):Destroy()
		end

		local new = Instance.new("Highlight")
		new.Name = "Chams"
		new.Parent = getgenv().char
		new.FillColor = self.colorFill
		new.OutlineColor = self.colorOutline
		new.FillTransparency = 0.5
		new.OutlineTransparency = 0

		for index, part in pairs(char:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				self.storedDefault[part] = part.Transparency
				part.Transparency = 0.5
			end
		end
	end

	applyChams()

	enabledFeatures["applyChams"] = applyChams
end

-- Disable Chams Function
function chamsMod:DisableChams()
	if enabledFeatures["applyChams"] then
		enabledFeatures["applyChams"] = nil
	end

	if getgenv().char:FindFirstChild("Chams") then
		getgenv().char:FindFirstChild("Chams"):Destroy()
	end

	for _, part in ipairs(char:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			local original = self.storedDefault[part]
			if original ~= nil then
				part.Transparency = original
			end
		end
	end

	self.storedDefault = {}
end

-- Chams Toggle
mainGroupFeatures.chamsToggle = groupBoxes.mainGroup1:CreateToggle({
	Name = "Enable Chams",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			chamsMod:EnableChams()
		else
			chamsMod:DisableChams()
		end
	end
}, "INDEX")

-- Chams ColorPicker
mainGroupFeatures.chamsColorLabel = groupBoxes.mainGroup1:CreateLabel({
	Name = "Chams Color Value",
}, "INDEX")

mainGroupFeatures.chamsColorPicker = mainGroupFeatures.chamsColorLabel:AddColorPicker({
	CurrentValue = chamsMod.colorFill,
	Callback = function(ColorValue)
		if ColorValue ~= nil then
			local char = player.Character or player.CharacterAdded:Wait()
			if char:FindFirstChild("Chams") then
				char.Chams.FillColor = ColorValue
				chamsMod.colorFill = ColorValue

				char.Chams.OutlineColor = ColorValue
				chamsMod.colorOutline = ColorValue
			end
		end
	end,
}, "INDEX")

-- Fly Method (pc or mobile) Configuration
local pcFlyMethod = true
local mobileFlyMethod = false

-- fly modification
local flyMod = {}
flyMod.FLYING = false
flyMod.flySpeed = 0.5
flyMod.vehicleSpeed = 1
flyMod.flyKeyDown = nil
flyMod.flyKeyUp = nil

-- Start fly Function
function flyMod:EnableFly(vFly)
	local function applyFly(vFly)
		if self.flyConn then
			self.flyConn:Disconnect()
			self.flyConn = nil
		end

		if self.flyKeyDown then
			self.flyKeyDown:Disconnect()
			self.flyKeyDown = nil
		end

		if self.flyKeyUp then
			self.flyKeyUp:Disconnect()
			self.flyKeyUp = nil
		end

		local CONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
		local lCONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
		local SPEED = 0

		local function fly()
			self.FLYING = true

			local BG = Instance.new("BodyGyro")
			BG.P = 9e4
			BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			BG.CFrame = getgenv().root.CFrame
			BG.Parent = getgenv().root
			BG.Name = "BG"

			local BV = Instance.new("BodyVelocity")
			BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
			BV.Velocity = Vector3.zero
			BV.Parent = getgenv().root
			BV.Name = "BV"

			task.spawn(function()
				repeat task.wait()
					local cam = workspace.CurrentCamera
					if not vFly and getgenv().hum then
						getgenv().hum.PlatformStand = true
					end

					if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
						SPEED = 50
					elseif SPEED ~= 0 then
						SPEED = 0
					end

					if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
						BV.Velocity = ((cam.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((cam.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - cam.CFrame.p)) * SPEED
						lCONTROL = {F=CONTROL.F, B=CONTROL.B, L=CONTROL.L, R=CONTROL.R}
					elseif SPEED ~= 0 then
						BV.Velocity = ((cam.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((cam.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - cam.CFrame.p)) * SPEED
					else
						BV.Velocity = Vector3.zero
					end
				until not self.FLYING

				CONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
				lCONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
				SPEED = 0
				BG:Destroy()
				BV:Destroy()
				if getgenv().hum then getgenv().hum.PlatformStand = false end
			end)
		end

		self.flyKeyDown = Uis.InputBegan:Connect(function(Input, gpe)
			if Input.KeyCode == Enum.KeyCode.W then
				CONTROL.F = (vFly and self.vehicleSpeed or self.flySpeed)
			elseif Input.KeyCode == Enum.KeyCode.S then
				CONTROL.B = - (vFly and self.vehicleSpeed or self.flySpeed)
			elseif Input.KeyCode == Enum.KeyCode.A then
				CONTROL.L = - (vFly and self.vehicleSpeed or self.flySpeed)
			elseif Input.KeyCode == Enum.KeyCode.D then
				CONTROL.R = (vFly and self.vehicleSpeed or self.flySpeed)
			elseif Input.KeyCode == Enum.KeyCode.E then
				CONTROL.Q = (vfly and self.vehicleSpeed or self.flySpeed)*7
			elseif Input.KeyCode == Enum.KeyCode.Q then
				CONTROL.E = -(vFly and self.vehicleSpeed or self.flySpeed)*7
			end
			pcall(function() camera.CameraType = Enum.CameraType.Track end)
		end)

		self.flyKeyUp = Uis.InputEnded:Connect(function(Input, gpe)
			if Input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0
			elseif Input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0
			elseif Input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0
			elseif Input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0
			elseif Input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 0
			elseif Input.KeyCode == Enum.KeyCode.Q then CONTROL.E = 0 end
		end)

		fly()
	end

	applyFly(vFly)

	enabledFeatures["applyFly"] = function()
		applyFly(vFly)
	end
end

-- Disable fly Function
function flyMod:DisableFly()
	self.FLYING = false

	if enabledFeatures["applyFly"] then
		enabledFeatures["applyFly"] = nil
	end

	if self.flyConn then
		self.flyConn:Disconnect()
		self.flyConn = nil
	end

	if self.flyKeyDown then
		self.flyKeyDown:Disconnect()
		self.flyKeyDown = nil
	end

	if self.flyKeyUp then
		self.flyKeyUp:Disconnect()
		self.flyKeyUp = nil
	end

	if getgenv().hum then
		getgenv().hum.PlatformStand = false
	end

	if getgenv().root:FindFirstChild("BG") then getgenv().root:FindFirstChild("BG"):Destroy() end
	if getgenv().root:FindFirstChild("BV") then getgenv().root:FindFirstChild("BV"):Destroy() end

	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

-- Mobile fly modifications
local mobileFlyMod = {}
mobileFlyMod.velocityHandlerName = "Vell"
mobileFlyMod.gyroHandlerName = "boogyro"
mobileFlyMod.mfly1 = nil
mobileFlyMod.flySpeed = 1
mobileFlyMod.vehicleSpeed = 1

-- Enable Mobile Fly Function
function mobileFlyMod:EnableFly(vFly)
	local function applyMobileFly(vFly)
		flyMod.FLYING = true

		if self.mfly1 then
			self.mfly1:Disconnect()
			self.mfly1 = nil
		end

		local camera = workspace.CurrentCamera
		local v3none = Vector3.zero
		local v3zero = Vector3.new(0, 0, 0)
		local v3inf = Vector3.new(9e9, 9e9, 9e9)

		local controlModule = require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
		local bv = Instance.new("BodyVelocity")
		bv.Name = self.velocityHandlerName
		bv.Parent = getgenv().root
		bv.MaxForce = v3zero
		bv.Velocity = v3zero

		local bg = Instance.new("BodyGyro")
		bg.Name = self.gyroHandlerName
		bg.Parent = getgenv().root
		bg.MaxTorque = v3inf
		bg.P = 1000
		bg.D = 50

		self.mfly1 = RunService.RenderStepped:Connect(function()
			camera = workspace.CurrentCamera
			if getgenv().hum and getgenv().root and getgenv().root:FindFirstChild(self.velocityHandlerName) and getgenv().root:FindFirstChild(self.gyroHandlerName) then
				local hum = getgenv().hum
				local velocityHandler = getgenv().root:FindFirstChild(self.velocityHandlerName)
				local gyroHandler = getgenv().root:FindFirstChild(self.gyroHandlerName)

				velocityHandler.MaxForce = v3inf
				gyroHandler.MaxTorque = v3inf
				if not vFly then hum.PlatformStand = true end
				gyroHandler.CFrame = camera.CoordinateFrame
				velocityHandler.Velocity = v3none

				local direction = controlModule:GetMoveVector()
				if direction.X > 0 then
					velocityHandler.Velocity = velocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vFly and self.vehicleSpeed or self.flySpeed) * 30))
				end
				if direction.X < 0 then
					velocityHandler.Velocity = velocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vFly and self.vehicleSpeed or self.flySpeed) * 30))
				end
				if direction.Z > 0 then
					velocityHandler.Velocity = velocityHandler.Velocity - camera.CFrame.LookVector *  (direction.Z * ((vFly and self.vehicleSpeed or self.flySpeed) * 30))
				end
				if direction.Z < 0 then
					velocityHandler.Velocity = velocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vFly and self.vehicleSpeed or self.flySpeed) * 30))
				end
			end
		end)
	end

	applyMobileFly(vFly)

	enabledFeatures["applyMobileFly"] = function()
		applyMobileFly(vFly)
	end
end

-- Disable Mobile Fly Function
function mobileFlyMod:DisableFly()
	flyMod.FLYING = false

	if enabledFeatures["applyMobileFly"] then
		enabledFeatures["applyMobileFly"] = nil
	end

	if self.mfly1 then
		self.mfly1:Disconnect()
		self.mfly1 = nil
	end
	
	if getgenv().root:FindFirstChild(self.velocityHandlerName) then
		getgenv().root:FindFirstChild(self.velocityHandlerName):Destroy()
	end

	if getgenv().root:FindFirstChild(self.gyroHandlerName) then
		getgenv().root:FindFirstChild(self.gyroHandlerName):Destroy()
	end

	if getgenv().hum then
		getgenv().hum.PlatformStand = false
	end

	if getgenv().root:FindFirstChild(self.gyroHandlerName) then getgenv().root:FindFirstChild(self.gyroHandlerName):Destroy() end
	if getgenv().root:FindFirstChild(self.velocityHandlerName) then getgenv().root:FindFirstChild(self.velocityHandlerName):Destroy() end
end

-- Giving user tip on fly mods
mainGroupFeatures.flyModTipsLabel = groupBoxes.mainGroup2:CreateLabel({
	Name = "Fly Tip: avoid hitting objects",
}, "INDEX")

-- Creating pc or mobile dropdown congirugration
mainGroupFeatures.flyMethodLabel = groupBoxes.mainGroup2:CreateLabel({
	Name = "Choose Fly Method",
}, "INDEX")

mainGroupFeatures.flyMethodDropdown = mainGroupFeatures.flyMethodLabel:AddDropdown({
	Options = {"Pc", "Mobile"},
	CurrentOptions = {"Pc"},
	Placeholder = "Pc by default",
	Callback = function(Options)
		if Options[1] == "Pc" then
			pcFlyMethod = true
			mobileFlyMethod = false
		elseif Options[1] == "Mobile" then
			pcFlyMethod = false
			mobileFlyMethod = true
		else
			pcFlyMethod = true
			mobileFlyMethod = false
		end
	end
}, "INDEX")

-- Fly toggle
mainGroupFeatures.flyToggle = groupBoxes.mainGroup2:CreateToggle({
	Name = "Fly",
	CurrentValue = false,
	Style = 1,
	Callback = function(State)
		if State then
			if pcFlyMethod then
				flyMod:EnableFly(false)
			elseif mobileFlyMethod then
				mobileFlyMod:EnableFly(false)
			else
				flyMod:EnableFly(true)
			end
		else
			flyMod:DisableFly()
			mobileFlyMod:DisableFly()
		end
	end
}, "INDEX")

-- Fly Speed Slider
mainGroupFeatures.flySpeedSlider = groupBoxes.mainGroup2:CreateSlider({
	Name = "Fly Speed",
	Icon = NebulaIcons:GetIcon('wind', 'Lucide'),
	Range = {0.1, 0.5},
	Increment = 0.1,
	Callback = function(Value)
		if Value ~= nil then
			flyMod.flySpeed = Value
		end
	end
}, "INDEX")

-- Vehicle Fly Toggle
mainGroupFeatures.vehicleFlyToggle = groupBoxes.mainGroup2:CreateToggle({
	Name = "Vehicle Fly",
	CurrentValue = false,
	Style = 1,
	Callback = function(State)
		if State then
			if pcFlyMethod then
				flyMod:EnableFly(true)
			elseif mobileFlyMethod then
				mobileFlyMod:EnableFly(true)
			else
				flyMod:EnableFly(true)
			end
		else
			flyMod:DisableFly()
			mobileFlyMod:DisableFly()
		end
	end	
}, "INDEX")

-- Vehicle Fly Speed
mainGroupFeatures.vehicleFlySpeedSlider = groupBoxes.mainGroup2:CreateSlider({
	Name = "Vehicle Fly Speed",
	Icon = NebulaIcons:GetIcon('car', "Lucide"),
	Range = {1, 50},
	Increment = 1,
	Callback = function(Value)
		if Value ~= nil then
			flyMod.vehicleSpeed = Value
			mobileFlyMod.vehicleSpeed = Value
		end
	end
}, "INDEX")

-- Instant Interact Modification
local instantInteractMod = {}
instantInteractMod.storedDefault = {}
instantInteractMod.conn1 = nil

-- Enable Instant Interact Function
function instantInteractMod:EnableInstantInteract()
	local function applyInstantInteract()
		if self.conn1 then
			self.conn1:Disconnect()
			self.conn1 = nil
		end

		for _, prompt in pairs(workspace:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") then
				self.storedDefault[prompt] = prompt.HoldDuration
				prompt.HoldDuration = 0
			end
		end

		self.conn1 = workspace.DescendantAdded:Connect(function(newprompt)
			if newprompt:IsA("ProximityPrompt") then
				self.storedDefault[newprompt] = newprompt.HoldDuration
				newprompt.HoldDuration = 0
			end
		end)
	end

	applyInstantInteract()

	enabledFeatures["applyInstantInteract"] = applyInstantInteract
end

-- Disable Instant Interact Function
function instantInteractMod:DisableInstantInteract()
	if enabledFeatures["applyInstantInteract"] then
		enabledFeatures["applyInstantInteract"] = nil
	end

	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	for _, prompt in pairs(workspace:GetDescendants()) do
		local original = self.storedDefault[prompt]
		if original ~= nil then
			prompt.HoldDuration = original
		end
	end

	self.storedDefault = {}
end

-- Instant Interact Toggle
mainGroupFeatures.instantInteractToggle = groupBoxes.mainGroup2:CreateToggle({
	Name = "Instant Interact",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			instantInteractMod:EnableInstantInteract()
		else
			instantInteractMod:DisableInstantInteract()
		end
	end
}, "INDEX")

-- Combat Log Modification
local combatLogMod = {}
combatLogMod.conn1 = nil

-- Disable Combat Log Function
function combatLogMod:Disable()
	local function disableCombatLog()
		if self.conn1 then
			self.conn1:Disconnect()
			self.conn1 = nil
		end

		getgenv().char:SetAttribute("Combat", false)
		self.conn1 = getgenv().char:GetAttributeChangedSignal("Combat"):Connect(function()
			if getgenv().char:GetAttribute("Combat") then
				getgenv().char:SetAttribute("Combat", false)
			end
		end)
	end

	disableCombatLog()

	enabledFeatures["disableCombatLog"] = disableCombatLog
end

-- Restoring Combat Log State Function
function combatLogMod:Restore()
	if enabledFeatures["disableCombatLog"] then
		enabledFeatures["disableCombatLog"] = nil
	end

	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end
end

-- Disable Combat Log Toggle
mainGroupFeatures.disableCombatLogToggle = groupBoxes.mainGroup2:CreateToggle({
	Name = "Disable Combat Log",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			combatLogMod:Disable()
		else
			combatLogMod:Restore()
		end
	end	
}, "INDEX")

-- Critical Modification
local criticalMod = {}

-- Disabling Critical Handler Function
function criticalMod:Disable()
	local handler = player.PlayerScripts:FindFirstChild("CriticalHandler")

	handler.Enabled = false
end

-- Disable Critical Handler Toggle
local criticalHandler = player.PlayerScripts:FindFirstChild("CriticalHandler")
mainGroupFeatures.criticalHandlerToggle = groupBoxes.mainGroup2:CreateToggle({
	Name = "Disable Ciritcal State",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			criticalHandler.Enabled = false
		else
			criticalHandler.Enabled = true
		end
	end
}, "INDEX")

-- Respawn Gender Dropdown
local respawnGender = "Boy"
mainGroupFeatures.respawnGenderLabel = groupBoxes.mainGroup3:CreateLabel({
	Name = "Respawn Gender:"
}, "INDEX")

mainGroupFeatures.respawnGenderDropdown = mainGroupFeatures.respawnGenderLabel:AddDropdown({
	Options = {"Boy", "Girl"},
	CurrentOptions = {"Boy"},
	Placeholder = "Boy by default",
	Callback = function(Options)
		if Options ~= nil then
			respawnGender = Options[1]
		end
	end
}, "INDEX")

-- Respawn Player Button
mainGroupFeatures.respawnPlayerButton = groupBoxes.mainGroup3:CreateButton({
	Name = "Repsawn Player",
	Icon = NebulaIcons:GetIcon('skull', 'Lucide'),
	Callback = function()
		changeSettings:FireServer('Gender', respawnGender)
	end
}, "INDEX")

-- Respawn Last Location Modification
local respawnMod = {}
respawnMod.ENABLED = false
respawnMod.conn1 = nil
respawnMod.currentPosition = nil
respawnMod.teleporting = false

-- Respawn Last Location Function
function respawnMod:Enable()
	self.ENABLED = true

	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	local debounce = false
	self.conn1 = RunService.Heartbeat:Connect(function()
		if debounce then return end
		debounce = true

		if self.teleporting then debounce = false return end

		if getgenv().char and getgenv().hum and getgenv().hum.Health > 0 then
			self.currentPosition = getgenv().char:GetPivot().Position
		else
			self.teleporting = true
		end

		task.wait(0.5)
		debounce = false
	end)
end

-- Disable Respawn Last Location
function respawnMod:Disable()
	self.ENABLED = false

	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	self.currentPosition = nil
end

-- Respawn Last Location Toggle
mainGroupFeatures.respawnLastLocationToggle = groupBoxes.mainGroup3:CreateToggle({
	Name = "Respawn Last Location",
	Icon = NebulaIcons:GetIcon('map-pinned', 'Lucide'),
	Style = 2,
	Callback = function(State)
		if State then
			respawnMod:Enable()
		else
			respawnMod:Disable()
		end
	end
}, "INDEX")

-- Instant Respawn Modification
local instantRespawnMod = {}
-- Instant Respawn Essentials
instantRespawnMod.conn1 = nil

-- Instant Health Respawn Essentials
instantRespawnMod.conn2 = nil
instantRespawnMod.healthValue = 0

-- Apply Instant Respawn Function
function instantRespawnMod:EnableInstantRespawn()
	local function applyInstantRespawn()
		if self.conn1 then
			self.conn1:Disconnect()
			self.conn1 = nil
		end

		local debounce = false
		self.conn1 = getgenv().hum.HealthChanged:Connect(function(health)
			if debounce then return end
			debounce = true

			if health <= 0 then
				changeSettings:FireServer("Gender", respawnGender)
				task.wait(1)
			end

			debounce = false
		end)
	end

	applyInstantRespawn()

	enabledFeatures["applyInstantRespawn"] = applyInstantRespawn
end

-- Disable Instant Respawn Function
function instantRespawnMod:DisableInstantRespawn()
	if enabledFeatures["applyInstantRespawn"] then
		enabledFeatures["applyInstantRespawn"] = nil
	end

	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end
end

-- Apply Health Instant Respawn Function
function instantRespawnMod:EnableHealthInstantRespawn()
	local function applyHealthInstantRespawn()
		if self.conn2 then
			self.conn2:Disconnect()
			self.conn2 = nil
		end

		local debounce = false
		self.conn2 = getgenv().hum.HealthChanged:Connect(function(health)
			if debounce then return end
			debounce = true

			if health <= self.healthValue then
				changeSettings:FireServer("Gender", respawnGender)
				task.wait(1)
			end

			debounce = false
		end)
	end

	applyHealthInstantRespawn()

	enabledFeatures["applyHealthInstantRespawn"] = applyHealthInstantRespawn
end

-- Disable Health Instant Respawn Function
function instantRespawnMod:DisableHealthInstantRespawn()
	if enabledFeatures["applyHealthInstantRespawn"] then
		enabledFeatures["applyHealthInstantRespawn"] = nil
	end

	if self.conn2 then
		self.conn2:Disconnect()
		self.conn2 = nil
	end
end

-- Instant Respawn Toggle
mainGroupFeatures.instantRespawnToggle = groupBoxes.mainGroup3:CreateToggle({
	Name = "Instant Respawn",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			instantRespawnMod:EnableInstantRespawn()
		else
			instantRespawnMod:DisableInstantRespawn()
		end
	end
}, "INDEX")

-- Instant Respawn Health Toggle
mainGroupFeatures.instantRespawnHealthToggle = groupBoxes.mainGroup3:CreateToggle({
	Name = "Instant Respawn Health",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			instantRespawnMod:EnableHealthInstantRespawn()
		else
			instantRespawnMod:DisableHealthInstantRespawn()
		end
	end	
}, "INDEX")

-- Instant Respawn Health Slider
mainGroupFeatures.instantRespawnHealthSlider = groupBoxes.mainGroup3:CreateSlider({
	Name = "Health Value",
	Icon = NebulaIcons:GetIcon('heart-pulse', 'Lucide'),
	Range = {1, 100},
	Increment = 1,
	Callback = function(Value)
		if Value ~= nil then
			instantRespawnMod.healthValue = tonumber(Value)
		end
	end
}, "INDEX")

-- Respawn Job Locations Label
local jobRespawnLocation = nil
mainGroupFeatures.respawnJobLocationsLabel = groupBoxes.mainGroup3:CreateLabel({
	Name = "Respawn Job Locations",
}, "INDEX")

-- Respawn Job Locations Dropdown
mainGroupFeatures.respawnJobLocationsDropdown = mainGroupFeatures.respawnJobLocationsLabel:AddDropdown({
	Options = {"Cleaning Job", "Box Job", "Chiken Job", "Ice Cream Job"},
	CurrentOptions = {"Cleaning Job"},
	Placeholder = "None Selected",
	Callback = function(Options)
		if Options ~= nil then
			jobRespawnLocation = Options[1]
		end
	end
}, "INDEX")

-- Respawn Job Location Button
mainGroupFeatures.respawnJobLocationButton = groupBoxes.mainGroup3:CreateButton({
	Name = "Respawn to job location",
	Icon = NebulaIcons:GetIcon('skull', 'Lucide'),
	Callback = function()
		if jobRespawnLocation == "Cleaning Job" then
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(282.178, 52.338, -181.974))
				task.wait(0.1)
			end
		elseif jobRespawnLocation == "Box Job" then
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(202.65505981445312, 52.358360290527344, 340.4278564453125))
				task.wait(0.1)
			end
		elseif jobRespawnLocation == "Chiken Job" then
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(517.5667114257812, 52.41231155395508, -386.2080078125))
				task.wait(0.1)
			end
		elseif jobRespawnLocation == "Ice Cream Job" then
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(897.9568481445312, 52.381080627441406, -471.9384460449219))
				task.wait(0.1)
			end
		else
			Starlight:Notification({
				Title = "No Respawn Location Found",
				Icon = NebulaIcons:GetIcon('ban', 'Lucide'),
				Content = "Please Select A Job Location"
			}, "INDEX")
		end
	end
}, "INDEX")

-- Respawn Main Locations Label
local mainRespawnLocation = nil
mainGroupFeatures.mainRespawnLocationLabel = groupBoxes.mainGroup3:CreateLabel({
	Name = "Respawn Main Locations",
}, "INDEX")

-- Respawn Main Locations Dropdown
mainGroupFeatures.mainRespawnLocationDropdown = mainGroupFeatures.mainRespawnLocationLabel:AddDropdown({
	Options = {"Gun Store", "Gun Store 2", "Car Dealer", "Merchant", "BlackMarket", "Clothing Store", "Drip Store", "Tatto Shop", "Arcade", "Studio"},
	CurrentOptions = {"Gun Store"},
	Placeholder = "None Selected",
	Callback = function(Options)
		if Options ~= nil then
			mainRespawnLocation = Options[1]
		end
	end
}, "INDEX")

-- Respawn Main Locations Button
mainGroupFeatures.mainRespawnLocationButton = groupBoxes.mainGroup3:CreateButton({
	Name = "Respawn Main Location",
	Icon = NebulaIcons:GetIcon('skull', 'Lucide'),
	Callback = function()
		if mainRespawnLocation == "Gun Store" then
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(645.5441284179688, 52.36677551269531, -402.4419250488281))
				task.wait(0.1)
			end
		elseif mainRespawnLocation == "Gun Store 2" then
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(27.14072036743164, 70.31893920898438, 600.211669921875))
				task.wait(0.1)
			end
		elseif mainRespawnLocation == "Car Dealer" then
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(556.3231811523438, 52.356101989746094, 34.13007354736328))
				task.wait(0.1)
			end
		elseif mainRespawnLocation == "Merchant" then
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(859.8814086914062, 52.26061248779297, -714.8486938476562))
				task.wait(0.1)
			end
		elseif mainRespawnLocation == "BlackMarket" then
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(272.2831115722656, 52.37848663330078, -692.0216064453125))
				task.wait(0.1)
			end
		elseif mainRespawnLocation == "Clothing Store" then
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(649.3258056640625, 52.571773529052734, -71.7509765625))
				task.wait(0.1)
			end
		elseif mainRespawnLocation == "Drip Store" then
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(303.4788513183594, 52.44342803955078, -75.33184051513672))
				task.wait(0.1)
			end
		elseif mainRespawnLocation == "Tatto Shop" then
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(945.9849853515625, 70.33518981933594, 580.034423828125))
				task.wait(0.1)
			end
		elseif mainRespawnLocation == "Arcade" then
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(546.278564453125, 52.740516662597656, -422.2215270996094))
				task.wait(0.1)
			end
		elseif mainRespawnLocation == "Studio" then
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(902.6936645507812, 53.22939682006836, -47.54987716674805))
				task.wait(0.1)
			end
		else
			Starlight:Notification({
				Title = "No Respawn Location Found",
				Icon = NebulaIcons:GetIcon('ban', 'Lucide'),
				Content = "Please Select A Main Location"
			}, "INDEX")
		end
	end
}, "INDEX")

-- Save Respawn Location Button
local savedRespawnLocation = nil
mainGroupFeatures.saveRespawnLocationButton = groupBoxes.mainGroup3:CreateButton({
	Name = "Save Respawn Position",
	Icon = NebulaIcons:GetIcon('save', 'Lucide'),
	Callback = function()
		savedRespawnLocation = getgenv().char:GetPivot()

		Starlight:Notification({
			Title = "Saved Respawn Position",
			Icon = NebulaIcons:GetIcon('circle-check-big', 'Lucide'),
			Content = "",
		}, "INDEX")
	end
}, "INDEX")

-- Respawn Saved Location Button
mainGroupFeatures.respawnSavedLocationButton = groupBoxes.mainGroup3:CreateButton({
	Name = "Respawn Saved Position",
	Icon = NebulaIcons:GetIcon('map-pin', 'Lucide'),
	Callback = function()
		changeSettings:FireServer("Gender", respawnGender)
		task.wait(0.5)
		for i = 1, 5 do
			getgenv().char:PivotTo(savedRespawnLocation)
			task.wait(0.1)
		end
	end
}, "INDEX")

-- Free Cam Modifications
local freeCamConnections = {}
freeCamConnections.conn1 = nil
freeCamConnections.conn2 = nil
freeCamConnections.conn3 = nil
freeCamConnections.conn4 = nil
freeCamConnections.conn5 = nil
freeCamConnections.startFreeCam = nil
freeCamConnections.stopFreeCam = nil
freeCamConnections.ENABLED = nil

-- Enable Free Cam Function
function freeCamConnections:applyFreeCam()
	local pi    = math.pi
	local abs   = math.abs
	local clamp = math.clamp
	local exp   = math.exp
	local rad   = math.rad
	local sign  = math.sign
	local sqrt  = math.sqrt
	local tan   = math.tan

	local Players = game:GetService("Players")
	local StarterGui = game:GetService("StarterGui")
	local UserInputService = game:GetService("UserInputService")
	local Workspace = game:GetService("Workspace")
	local Settings = UserSettings()
	local GameSettings = Settings.GameSettings

	local LocalPlayer = Players.LocalPlayer
	if not LocalPlayer then
		freeCamConnections.conn1 = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
		LocalPlayer = Players.LocalPlayer
	end

	local Camera = Workspace.CurrentCamera
	freeCamConnections.conn2 = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		local newCamera = Workspace.CurrentCamera
		if newCamera then
			Camera = newCamera
		end
	end)

	local FFlagUserExitFreecamBreaksWithShiftlock
	do
		local success, result = pcall(function()
			return UserSettings():IsUserFeatureEnabled("UserExitFreecamBreaksWithShiftlock")
		end)
		FFlagUserExitFreecamBreaksWithShiftlock = success and result
	end

	local FFlagUserShowGuiHideToggles
	do
		local success, result = pcall(function()
			return UserSettings():IsUserFeatureEnabled("UserShowGuiHideToggles")
		end)
		FFlagUserShowGuiHideToggles = success and result
	end

	local FREECAM_ENABLED_ATTRIBUTE_NAME = "FreecamEnabled"
	local TOGGLE_INPUT_PRIORITY = Enum.ContextActionPriority.Low.Value
	local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value
	local FREECAM_MACRO_KB = {Enum.KeyCode.LeftShift, Enum.KeyCode.P}

	local NAV_GAIN = Vector3.new(1, 1, 1)*64
	local PAN_GAIN = Vector2.new(0.75, 1)*8
	local FOV_GAIN = 300

	local PITCH_LIMIT = rad(90)

	local VEL_STIFFNESS = 1.5
	local PAN_STIFFNESS = 1.0
	local FOV_STIFFNESS = 4.0

	local Spring = {} do
		Spring.__index = Spring

		function Spring.new(freq, pos)
			local self = setmetatable({}, Spring)
			self.f = freq
			self.p = pos
			self.v = pos*0
			return self
		end

		function Spring:Update(dt, goal)
			local f = self.f*2*pi
			local p0 = self.p
			local v0 = self.v

			local offset = goal - p0
			local decay = exp(-f*dt)

			local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
			local v1 = (f*dt*(offset*f - v0) + v0)*decay

			self.p = p1
			self.v = v1

			return p1
		end

		function Spring:Reset(pos)
			self.p = pos
			self.v = pos*0
		end
	end

	local cameraPos = Vector3.new()
	local cameraRot = Vector2.new()
	local cameraFov = 0

	local velSpring = Spring.new(VEL_STIFFNESS, Vector3.new())
	local panSpring = Spring.new(PAN_STIFFNESS, Vector2.new())
	local fovSpring = Spring.new(FOV_STIFFNESS, 0)

	local Input = {} do
		local thumbstickCurve do
			local K_CURVATURE = 2.0
			local K_DEADZONE = 0.15

			local function fCurve(x)
				return (exp(K_CURVATURE*x) - 1)/(exp(K_CURVATURE) - 1)
			end

			local function fDeadzone(x)
				return fCurve((x - K_DEADZONE)/(1 - K_DEADZONE))
			end

			function thumbstickCurve(x)
				return sign(x)*clamp(fDeadzone(abs(x)), 0, 1)
			end
		end

		local gamepad = {
			ButtonX = 0,
			ButtonY = 0,
			DPadDown = 0,
			DPadUp = 0,
			ButtonL2 = 0,
			ButtonR2 = 0,
			Thumbstick1 = Vector2.new(),
			Thumbstick2 = Vector2.new(),
		}

		local keyboard = {
			W = 0,
			A = 0,
			S = 0,
			D = 0,
			E = 0,
			Q = 0,
			Up = 0,
			Down = 0,
			LeftShift = 0,
			RightShift = 0,
		}

		local mouse = {
			Delta = Vector2.new(),
			MouseWheel = 0,
		}

		local NAV_GAMEPAD_SPEED  = Vector3.new(1, 1, 1)
		local NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
		local PAN_MOUSE_SPEED    = Vector2.new(1, 1)*(pi/64)
		local PAN_GAMEPAD_SPEED  = Vector2.new(1, 1)*(pi/8)
		local FOV_WHEEL_SPEED    = 1.0
		local FOV_GAMEPAD_SPEED  = 0.25
		local NAV_ADJ_SPEED      = 0.75
		local NAV_SHIFT_MUL      = 0.25

		local navSpeed = 1

		function Input.Vel(dt)
			navSpeed = clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)

			local kGamepad = Vector3.new(
				thumbstickCurve(gamepad.Thumbstick1.X),
				thumbstickCurve(gamepad.ButtonR2) - thumbstickCurve(gamepad.ButtonL2),
				thumbstickCurve(-gamepad.Thumbstick1.Y)
			)*NAV_GAMEPAD_SPEED

			local kKeyboard = Vector3.new(
				keyboard.D - keyboard.A,
				keyboard.E - keyboard.Q,
				keyboard.S - keyboard.W
			)*NAV_KEYBOARD_SPEED

			local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

			return (kGamepad + kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
		end

		function Input.Pan(dt)
			local kGamepad = Vector2.new(
				thumbstickCurve(gamepad.Thumbstick2.Y),
				thumbstickCurve(-gamepad.Thumbstick2.X)
			)*PAN_GAMEPAD_SPEED
			local kMouse = mouse.Delta*PAN_MOUSE_SPEED
			mouse.Delta = Vector2.new()
			return kGamepad + kMouse
		end

		function Input.Fov(dt)
			local kGamepad = (gamepad.ButtonX - gamepad.ButtonY)*FOV_GAMEPAD_SPEED
			local kMouse = mouse.MouseWheel*FOV_WHEEL_SPEED
			mouse.MouseWheel = 0
			return kGamepad + kMouse
		end

		do
			local function Keypress(action, state, input)
				keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
				return Enum.ContextActionResult.Sink
			end

			local function GpButton(action, state, input)
				gamepad[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
				return Enum.ContextActionResult.Sink
			end

			local function MousePan(action, state, input)
				local delta = input.Delta
				mouse.Delta = Vector2.new(-delta.y, -delta.x)
				return Enum.ContextActionResult.Sink
			end

			local function Thumb(action, state, input)
				gamepad[input.KeyCode.Name] = input.Position
				return Enum.ContextActionResult.Sink
			end

			local function Trigger(action, state, input)
				gamepad[input.KeyCode.Name] = input.Position.z
				return Enum.ContextActionResult.Sink
			end

			local function MouseWheel(action, state, input)
				mouse[input.UserInputType.Name] = -input.Position.z
				return Enum.ContextActionResult.Sink
			end

			local function Zero(t)
				for k, v in pairs(t) do
					t[k] = v*0
				end
			end

			function Input.StartCapture()
				ContextActionService:BindActionAtPriority("FreecamKeyboard", Keypress, false, INPUT_PRIORITY,
					Enum.KeyCode.W,
					Enum.KeyCode.A,
					Enum.KeyCode.S,
					Enum.KeyCode.D,
					Enum.KeyCode.E,
					Enum.KeyCode.Q,
					Enum.KeyCode.Up, Enum.KeyCode.Down
				)
				ContextActionService:BindActionAtPriority("FreecamMousePan",          MousePan,   false, INPUT_PRIORITY, Enum.UserInputType.MouseMovement)
				ContextActionService:BindActionAtPriority("FreecamMouseWheel",        MouseWheel, false, INPUT_PRIORITY, Enum.UserInputType.MouseWheel)
				ContextActionService:BindActionAtPriority("FreecamGamepadButton",     GpButton,   false, INPUT_PRIORITY, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY)
				ContextActionService:BindActionAtPriority("FreecamGamepadTrigger",    Trigger,    false, INPUT_PRIORITY, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2)
				ContextActionService:BindActionAtPriority("FreecamGamepadThumbstick", Thumb,      false, INPUT_PRIORITY, Enum.KeyCode.Thumbstick1, Enum.KeyCode.Thumbstick2)
			end

			function Input.StopCapture()
				navSpeed = 1
				Zero(gamepad)
				Zero(keyboard)
				Zero(mouse)
				ContextActionService:UnbindAction("FreecamKeyboard")
				ContextActionService:UnbindAction("FreecamMousePan")
				ContextActionService:UnbindAction("FreecamMouseWheel")
				ContextActionService:UnbindAction("FreecamGamepadButton")
				ContextActionService:UnbindAction("FreecamGamepadTrigger")
				ContextActionService:UnbindAction("FreecamGamepadThumbstick")
			end
		end
	end

	local function StepFreecam(dt)
		local vel = velSpring:Update(dt, Input.Vel(dt))
		local pan = panSpring:Update(dt, Input.Pan(dt))
		local fov = fovSpring:Update(dt, Input.Fov(dt))

		local zoomFactor = sqrt(tan(rad(70/2))/tan(rad(cameraFov/2)))

		cameraFov = clamp(cameraFov + fov*FOV_GAIN*(dt/zoomFactor), 1, 120)
		cameraRot = cameraRot + pan*PAN_GAIN*(dt/zoomFactor)
		cameraRot = Vector2.new(clamp(cameraRot.x, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.y%(2*pi))

		local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*NAV_GAIN*dt)
		cameraPos = cameraCFrame.p

		Camera.CFrame = cameraCFrame
		Camera.Focus = cameraCFrame 
		Camera.FieldOfView = cameraFov
	end

	local function CheckMouseLockAvailability()
		local devAllowsMouseLock = Players.LocalPlayer.DevEnableMouseLock
		local devMovementModeIsScriptable = Players.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable
		local userHasMouseLockModeEnabled = GameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch
		local userHasClickToMoveEnabled =  GameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove
		local MouseLockAvailable = devAllowsMouseLock and userHasMouseLockModeEnabled and not userHasClickToMoveEnabled and not devMovementModeIsScriptable

		return MouseLockAvailable
	end

	local PlayerState = {} do
		local mouseBehavior
		local mouseIconEnabled
		local cameraType
		local cameraFocus
		local cameraCFrame
		local cameraFieldOfView
		local screenGuis = {}
		local coreGuis = {
			Backpack = true,
			Chat = true,
			Health = true,
			PlayerList = true,
		}
		local setCores = {
			BadgesNotificationsActive = true,
			PointsNotificationsActive = true,
		}

		function PlayerState.Push()
			for name in pairs(coreGuis) do
				coreGuis[name] = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType[name])
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], false)
			end
			for name in pairs(setCores) do
				setCores[name] = StarterGui:GetCore(name)
				StarterGui:SetCore(name, false)
			end
			local playergui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
			if playergui then
				for _, gui in pairs(playergui:GetChildren()) do
					if gui:IsA("ScreenGui") and gui.Enabled then
						screenGuis[#screenGuis + 1] = gui
						gui.Enabled = false
					end
				end
			end

			cameraFieldOfView = Camera.FieldOfView
			Camera.FieldOfView = 70

			cameraType = Camera.CameraType
			Camera.CameraType = Enum.CameraType.Custom

			cameraCFrame = Camera.CFrame
			cameraFocus = Camera.Focus

			mouseIconEnabled = UserInputService.MouseIconEnabled
			UserInputService.MouseIconEnabled = false

			if FFlagUserExitFreecamBreaksWithShiftlock and CheckMouseLockAvailability() then
				mouseBehavior = Enum.MouseBehavior.Default
			else
				mouseBehavior = UserInputService.MouseBehavior
			end
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end

		function PlayerState.Pop()
			for name, isEnabled in pairs(coreGuis) do
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], isEnabled)
			end
			for name, isEnabled in pairs(setCores) do
				StarterGui:SetCore(name, isEnabled)
			end
			for _, gui in pairs(screenGuis) do
				if gui.Parent then
					gui.Enabled = true
				end
			end

			Camera.FieldOfView = cameraFieldOfView
			cameraFieldOfView = nil

			Camera.CameraType = cameraType
			cameraType = nil

			Camera.CFrame = cameraCFrame
			cameraCFrame = nil

			Camera.Focus = cameraFocus
			cameraFocus = nil

			UserInputService.MouseIconEnabled = mouseIconEnabled
			mouseIconEnabled = nil

			UserInputService.MouseBehavior = mouseBehavior
			mouseBehavior = nil
		end
	end

	local function StartFreecam()
		if FFlagUserShowGuiHideToggles then
			script:SetAttribute(FREECAM_ENABLED_ATTRIBUTE_NAME, true)
		end

		local cameraCFrame = Camera.CFrame
		cameraRot = Vector2.new(cameraCFrame:toEulerAnglesYXZ())
		cameraPos = cameraCFrame.p
		cameraFov = Camera.FieldOfView

		velSpring:Reset(Vector3.new())
		panSpring:Reset(Vector2.new())
		fovSpring:Reset(0)

		PlayerState.Push()
		freeCamConnections.conn3 = RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
		Input.StartCapture()
	end

	self.startFreeCam = StartFreecam

	local function StopFreecam()
		if FFlagUserShowGuiHideToggles then
			script:SetAttribute(FREECAM_ENABLED_ATTRIBUTE_NAME, false)
		end

		Input.StopCapture()
		freeCamConnections.conn4 = RunService:UnbindFromRenderStep("Freecam")
		PlayerState.Pop()
	end

	self.stopFreeCam = StopFreecam

	do
		self.ENABLED = false

		local function ToggleFreecam()
			if self.ENABLED then
				StopFreecam()
			else
				StartFreecam()
			end
			self.ENABLED = not self.ENABLED
		end

		local function CheckMacro(macro)
			for i = 1, #macro - 1 do
				if not UserInputService:IsKeyDown(macro[i]) then
					return
				end
			end
			ToggleFreecam()
		end

		local function HandleActivationInput(action, state, input)
			if state == Enum.UserInputState.Begin then
				if input.KeyCode == FREECAM_MACRO_KB[#FREECAM_MACRO_KB] then
					CheckMacro(FREECAM_MACRO_KB)
				end
			end
			return Enum.ContextActionResult.Pass
		end

		ContextActionService:BindActionAtPriority("FreecamToggle", HandleActivationInput, false, TOGGLE_INPUT_PRIORITY, FREECAM_MACRO_KB[#FREECAM_MACRO_KB])

		if FFlagUserShowGuiHideToggles then
			script:SetAttribute(FREECAM_ENABLED_ATTRIBUTE_NAME, self.ENABLED)
			freeCamConnections.conn5 = script:GetAttributeChangedSignal(FREECAM_ENABLED_ATTRIBUTE_NAME):Connect(function()
				local attributeValue = script:GetAttribute(FREECAM_ENABLED_ATTRIBUTE_NAME)

				if typeof(attributeValue) ~= "boolean" then
					script:SetAttribute(FREECAM_ENABLED_ATTRIBUTE_NAME, self.ENABLED)
					return
				end

				if attributeValue ~= self.ENABLED then
					if attributeValue then
						StartFreecam()
						self.ENABLED = true
					else
						StopFreecam()
						self.ENABLED = false
					end
				end
			end)
		end
	end
end

freeCamConnections:applyFreeCam()

-- Free Cam Label
mainGroupFeatures.freeCamLabel = groupBoxes.mainGroup4:CreateLabel({
	Name = "Freecam: Shift+P"
}, "INDEX")

-- Spectate Player Modification
local spectatePlayerMod = {}
spectatePlayerMod.chosenPlayer = nil
spectatePlayerMod.conn1 = nil
spectatePlayerMod.conn2 = nil
spectatePlayerMod.currentTarget = nil

-- Start Spectate Function
function spectatePlayerMod:Enable()
	local function startSpectating()
		if self.conn1 then
			self.conn1:Disconnect()
			self.conn1 = nil
		end

		if self.conn2 then
			self.conn2:Disconnect()
			self.conn2 = nil
		end

		if self.chosenPlayer ~= nil then
			for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
				if plr.Name:lower() == self.chosenPlayer:lower() then
					self.currentTarget = plr
					break
				end
			end
		end

		local cam = workspace.CurrentCamera
		if self.currentTarget and self.currentTarget.Character:FindFirstChild("Humanoid") then
			cam.CameraSubject = self.currentTarget.Character:FindFirstChild("Humanoid")

			self.conn1 = cam:GetPropertyChangedSignal("CameraSubject"):Connect(function()
				if self.currentTarget and self.currentTarget.Character and self.currentTarget.Character:FindFirstChild("Humanoid") then
					cam.CameraSubject = self.currentTarget.Character:FindFirstChild("Humanoid")
				end
			end)

			self.conn2 = self.currentTarget.CharacterAdded:Connect(function(newChar)
				repeat task.wait() until newChar:FindFirstChild("Humanoid")
				if self.currentTarget == game:GetService("Players"):FindFirstChild(self.currentTarget.Name) then
					cam.CameraSubject = newChar:FindFirstChild("Humanoid")
				end
			end)
		else
			Starlight:Notification({
				Title = "Target Not Found",
				Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
				Content = "",
			}, "INDEX")
			return
		end
	end

	startSpectating()

	enabledFeatures["startSpectating"] = startSpectating
end

-- Disable Spectate Function
function spectatePlayerMod:Disable()
	if enabledFeatures["startSpectating"] then
		enabledFeatures["startSpectating"] = nil
	end

	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	if self.conn2 then
		self.conn2:Disconnect()
		self.conn2 = nil
	end

	self.currentTarget = nil

	local cam = workspace.CurrentCamera
	if getgenv().hum then
		cam.CameraSubject = getgenv().hum
		cam.CameraType = Enum.CameraType.Custom
	end
end

-- Spectate Player Name
mainGroupFeatures.spectatePlayerNameInput = groupBoxes.mainGroup4:CreateInput({
	Name = "Player Name:",
	Icon = NebulaIcons:GetIcon('pencil', 'Lucide'),
	CurrentValue = "",
	PlaceholderText = ". . .",
	Enter = true,
	Tooltip = "Players name might not be what it shows, look at the menu for all names on player",
	Callback = function(Text)
		if Text ~= nil and Text ~= "" and Text ~= ". . ." then
			spectatePlayerMod.chosenPlayer = Text
		end
	end
}, "INDEX")

-- Spectate Player Toggle
mainGroupFeatures.spectatePlayerToggle = groupBoxes.mainGroup4:CreateToggle({
	Name = "Spectate Chosen Player",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			spectatePlayerMod:Enable()
		else
			spectatePlayerMod:Disable()
		end
	end
}, "INDEX")

-- Spam Text Modification
local spamTextMod = {}
spamTextMod.spamText = nil
spamTextMod.spamTextDebounce = false
spamTextMod.conn1 = nil

-- Start To Spam Text Function
function spamTextMod:Enable()
	local function applySpamText()
		if self.conn1 then
			self.conn1:Disconnect()
			self.conn1 = nil
		end

		if self.spamText then
			self.conn1 = RunService.Heartbeat:Connect(function()
				if self.spamTextDebounce then return end
				self.spamTextDebounce = true

				local general = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
				general:SendAsync(self.spamText)
			
				local waitTime = math.random(5, 10)
				task.wait(waitTime)

				self.spamTextDebounce = false
			end)
		else
			Starlight:Notification({
				Title = "Text Invalid",
				Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
				Content = ""
			}, "Index")
		end
	end

	applySpamText()

	enabledFeatures["applySpamText"] = applySpamText
end

-- Disable Spam Text Mod Function
function spamTextMod:Disable()
	if enabledFeatures["applySpamText"] then
		enabledFeatures["applySpamText"] = nil
	end

	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end
end

-- Spam Text Input / Grabbing The Text To Spam
mainGroupFeatures.spamTextInput = groupBoxes.mainGroup4:CreateInput({
	Name = "Text: ",
	Icon = NebulaIcons:GetIcon('case-sensitive', 'Lucide'),
	CurrentValue = "",
	PlaceholderText = ". . .",
	Enter = true,
	Callback = function(Text)
		if Text ~= nil and Text ~= "" and Text ~= ". . ." then
			spamTextMod.spamText = Text
		else
			spamTextMod.spamText = nil
		end
	end
}, "INDEX")

-- Spam Text Toggle
mainGroupFeatures.spamTextToggle = groupBoxes.mainGroup4:CreateToggle({
	Name = "Spam Text",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			spamTextMod:Enable()
		else
			spamTextMod:Disable()
		end
	end
}, "INDEX")

-- Visuals Tab Features
local visualGroupFeatures = {}

-- Player Esp Modifications
local playerEspMod = {}

-- Esp Toggles
playerEspMod.NAME = false
playerEspMod.BOX = false
playerEspMod.FILLED_BOX = false
playerEspMod.HEALTH = false
playerEspMod.DISTANCE = false
playerEspMod.SKELETON = false
playerEspMod.TRACERS = false
playerEspMod.WEAPON = false

-- Esp Configs
playerEspMod.NAME_COLOR = Color3.fromRGB(255, 255, 255)
playerEspMod.BOX_COLOR = Color3.fromRGB(255, 255, 255)
playerEspMod.BOX_FILLED = false
playerEspMod.HEALTH_COLOR = Color3.fromRGB(0, 255, 0)
playerEspMod.DISTANCE_COLOR = Color3.fromRGB(255, 255, 255)
playerEspMod.SKELETON_COLOR = Color3.fromRGB(255, 255, 255)
playerEspMod.TRACERS_COLOR = Color3.fromRGB(255, 255, 255)
playerEspMod.TRACERS_FROM_HEAD = false
playerEspMod.WEAPON_COLOR = Color3.fromRGB(255, 255, 255)

-- Esp Tables
playerEspMod.nameDrawings = {}
playerEspMod.boxDrawings = {}
playerEspMod.healthDrawings = {}
playerEspMod.distanceDrawings = {}
playerEspMod.skeletonDrawings = {}
playerEspMod.tracersDrawings = {}
playerEspMod.weaponDrawings = {}

-- Esp Connections
playerEspMod.conn1 = nil

-- Clearing Esp Table Function
local function clearEspTable(espTable)
	for key, drawing in pairs(espTable) do
		if drawing then
			drawing:Remove()
		end
		espTable[key] = nil
	end
end

-- Clearing Skeleton Esp Table
local function clearSkeletonEspTable(espTable)
	for key, drawing in pairs(espTable) do
		if type(drawing) == "table" then
			for _, subDrawing in pairs(drawing) do
				if subDrawing then
					subDrawing:Remove()
				end
			end
		elseif drawing then
			drawing:Remove()
		end
		espTable[key] = nil
	end
end

-- Creating Name Esp
local function updateNameEsp(plr, pos, drawing, uid)
	if not drawing then
		drawing = Drawing.new("Text")
		drawing.Font = 1
		drawing.Size = 16
		drawing.Center = true
		drawing.Outline = true
		playerEspMod.nameDrawings[uid] = drawing
	end

	drawing.Text = plr.Name
	drawing.Color = playerEspMod.NAME_COLOR
	drawing.Position = Vector2.new(pos.X, pos.Y - 35)
	drawing.Visible = true
end

-- Creating Box Esp
local function updateBoxEsp(plr, plrRoot, drawing, uid, camera)
	local head = plr.Character:FindFirstChild("Head")
	if not head then return end

	local minVec, maxVec = Vector2.new(math.huge, math.huge), Vector2.new(-math.huge, -math.huge)
	local points = {
		Vector3.new(2, 3, 1),
		Vector3.new(-2, 3, 1),
		Vector3.new(2, -3, 1),
		Vector3.new(-2, -3, 1),
		Vector3.new(2, 3, -1),
		Vector3.new(-2, 3, -1),
		Vector3.new(2, -3, -1),
		Vector3.new(-2, -3, -1)
	}

	for _, offset in pairs(points) do
		local worldPos = plrRoot.Position + offset
		local screenPos, onScreen = camera:WorldToViewportPoint(worldPos)

		if onScreen then
			minVec = Vector2.new(math.min(minVec.X, screenPos.X), math.min(minVec.Y, screenPos.Y))
			maxVec = Vector2.new(math.max(maxVec.X, screenPos.X), math.max(maxVec.Y, screenPos.Y))
		end
	end

	local boxPos = minVec
	local boxSize = maxVec - minVec

	if not drawing then
		drawing = Drawing.new("Square")
		drawing.Thickness = 1.5
		drawing.Transparency = 0.8
		playerEspMod.boxDrawings[uid] = drawing
	end

	drawing.Color = playerEspMod.BOX_COLOR
	drawing.Filled = playerEspMod.BOX_FILLED
	drawing.Position = boxPos
	drawing.Size = boxSize
	drawing.Visible = true
end

-- Create Health Esp
local function updateHealthEsp(plr, plrRoot, drawing, uid, camera)
	local hum = plr.Character:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	local health = hum.Health
	local maxHealth = hum.MaxHealth
	if maxHealth <= 0 then return end

	local healthPercent = math.clamp(health / maxHealth, 0, 1)

	local minVec, maxVec = Vector2.new(math.huge, math.huge), Vector2.new(-math.huge, -math.huge)
	local points = {
		Vector3.new(2, 3, 1),
		Vector3.new(-2, 3, 1),
		Vector3.new(2, -3, 1),
		Vector3.new(-2, -3, 1),
		Vector3.new(2, 3, -1),
		Vector3.new(-2, 3, -1),
		Vector3.new(2, -3, -1),
		Vector3.new(-2, -3, -1)
	}

	for _, offset in pairs(points) do
		local worldPos = plrRoot.Position + offset
		local screenPos, onScreen = camera:WorldToViewportPoint(worldPos)

		if onScreen then
			minVec = Vector2.new(math.min(minVec.X, screenPos.X), math.min(minVec.Y, screenPos.Y))
			maxVec = Vector2.new(math.max(maxVec.X, screenPos.X), math.max(maxVec.Y, screenPos.Y))
		end
	end

	local boxPos = minVec
	local boxSize = maxVec - minVec
	local barHeight = boxSize.Y
	local barWidth = 3
	local filledHeight = barHeight * healthPercent
	local barPos = Vector2.new(boxPos.X - 6, boxPos.Y)

	if not drawing then
		drawing = Drawing.new("Square")
		drawing.Thickness = 1
		drawing.Filled = true
		playerEspMod.healthDrawings[uid] = drawing
	end

	drawing.Size = Vector2.new(barWidth, filledHeight)
	drawing.Position = Vector2.new(barPos.X, barPos.Y + (barHeight - filledHeight))
	drawing.Color = playerEspMod.HEALTH_COLOR
	drawing.Visible = true
end

-- Creating Distance Esp
local function updateDistanceEsp(plr, plrRoot, drawing, uid, camera)
	if not drawing then
		drawing = Drawing.new("Text")
		drawing.Font = 1
		drawing.Size = 16
		drawing.Center = true
		drawing.Outline = true
		playerEspMod.distanceDrawings[uid] = drawing
	end

	local worldPosBelow = plrRoot.Position - Vector3.new(0, 4, 0)
	local screenPos, onScreen = camera:WorldToViewportPoint(worldPosBelow)

	if onScreen then
		local distance = math.floor((plrRoot.Position - getgenv().root.Position).Magnitude)
		drawing.Text = tostring(distance) .. " Studs"
		drawing.Color = playerEspMod.DISTANCE_COLOR
		drawing.Position = Vector2.new(screenPos.X, screenPos.Y)
		drawing.Visible = true
	else
		drawing.Visible = false
	end
end

-- Creating Skeleton Esp
local function updateSkeletonEsp(plr, drawing, camera)
	local character = plr.Character
	if not character then return end

	local parts = {
		"Head",
		"UpperTorso",
		"LowerTorso",
		"LeftUpperArm",
		"LeftLowerArm",
		"LeftHand",
		"RightUpperArm",
		"RightLowerArm",
		"RightHand",
		"LeftUpperLeg",
		"LeftLowerLeg",
		"LeftFoot",
		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot",
	}

	for _, partName in ipairs(parts) do
		if not character:FindFirstChild(partName) then
			return
		end
	end

	local connections = {
		{"Head", "UpperTorso"},
		{"UpperTorso", "LeftUpperArm"},
		{"LeftUpperArm", "LeftLowerArm"},
		{"LeftLowerArm", "LeftHand"},
		{"UpperTorso", "RightUpperArm"},
		{"RightUpperArm", "RightLowerArm"},
		{"RightLowerArm", "RightHand"},
		{"UpperTorso", "LowerTorso"},
		{"LowerTorso", "LeftUpperLeg"},
		{"LeftUpperLeg", "LeftLowerLeg"},
		{"LeftLowerLeg", "LeftFoot"},
		{"LowerTorso", "RightUpperLeg"},
		{"RightUpperLeg", "RightLowerLeg"},
		{"RightLowerLeg", "RightFoot"},
	}

	for i, connection in ipairs(connections) do
		local part1 = character[connection[1]]
		local part2 = character[connection[2]]

		local pos1, onScreen1 = camera:WorldToViewportPoint(part1.Position)
		local pos2, onScreen2 = camera:WorldToViewportPoint(part2.Position)

		if onScreen1 and onScreen2 then
			if not drawing[i] then
				local line = Drawing.new("Line")
				line.Thickness = 1.5
				line.Transparency = 0.8
				drawing[i] = line
			end

			local line = drawing[i]
			line.From = Vector2.new(pos1.X, pos1.Y)
			line.To = Vector2.new(pos2.X, pos2.Y)
			line.Color = playerEspMod.SKELETON_COLOR
			line.Visible = true
		elseif drawing[i] then
			drawing[i].Visible = false
		end
	end
end

-- Creating Tracers Esp
local function updateTracersEsp(plrRoot, drawing, uid, camera)
	local screenPos, onScreen = camera:WorldToViewportPoint(plrRoot.Position)
	if not onScreen then
		if drawing then
			drawing.Visible = false
		end
		return
	end

	local startPos

	if playerEspMod.TRACERS_FROM_HEAD then
		if getgenv().char and getgenv().char:FindFirstChild("Head") then
			local headPos, headOnScreen = camera:WorldToViewportPoint(getgenv().char.Head.Position)

			if headOnScreen then
				startPos = Vector2.new(headPos.X, headPos.Y)
			else
				startPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
			end
		else
			startPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
		end
	else
		startPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
	end

	if not drawing then
		drawing = Drawing.new("Line")
		drawing.Thickness = 1.5
		drawing.Transparency = 0.8
		playerEspMod.tracersDrawings[uid] = drawing
	end

	drawing.From = startPos
	drawing.To = Vector2.new(screenPos.X, screenPos.Y)
	drawing.Color = playerEspMod.TRACERS_COLOR
	drawing.Visible = true
end

-- Creating Weapon Esp
local function updateWeaponEsp(plr, pos, drawing, uid)
	if not drawing then
		drawing = Drawing.new("Text")
		drawing.Font = 1
		drawing.Size = 14
		drawing.Center = true
		drawing.Outline = true
		playerEspMod.weaponDrawings[uid] = drawing
	end

	local tool
	pcall(function()
		tool = plr.Character:FindFirstChildOfClass("Tool")
	end)

	if tool then
		drawing.Text = "Weapon: " .. tool.Name
	else
		drawing.Text = "Weapon: None"
	end

	drawing.Color = playerEspMod.WEAPON_COLOR
	drawing.Position = Vector2.new(pos.X, pos.Y - 55)
	drawing.Visible = true
end

-- Enabling Esp Function
function playerEspMod:EnableEsp()
	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	if Drawing and typeof(Drawing.new) == "function" then
		local debounce = false
		self.conn1 = RunService.RenderStepped:Connect(function()
			for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local plrRoot = plr.Character.HumanoidRootPart
					local camera = workspace.CurrentCamera
					local pos, onScreen = camera:WorldToViewportPoint(plrRoot.Position + Vector3.new(0, 3, 0))
					local uid = plr.UserId

					local nameDrawing = self.nameDrawings[uid]
					local boxDrawing = self.boxDrawings[uid]
					local healthDrawing = self.healthDrawings[uid]
					local distanceDrawing = self.distanceDrawings[uid]
					local tracersDrawing = self.tracersDrawings[uid]
					local weaponDrawing = self.weaponDrawings[uid]

					if onScreen then
						if self.NAME then
							updateNameEsp(plr, pos, nameDrawing, uid)
						elseif self.nameDrawings[uid] then
							self.nameDrawings[uid].Visible = false
						end

						if self.BOX then
							updateBoxEsp(plr, plrRoot, boxDrawing, uid, camera)
						elseif self.boxDrawings[uid] then
							self.boxDrawings[uid].Visible = false
						end

						if self.HEALTH then
							updateHealthEsp(plr, plrRoot, healthDrawing, uid, camera)
						elseif self.healthDrawings[uid] then
							self.healthDrawings[uid].Visible = false
						end

						if self.DISTANCE then
							updateDistanceEsp(plr, plrRoot, distanceDrawing, uid, camera)
						elseif self.distanceDrawings[uid] then
							self.distanceDrawings[uid].Visible = false
						end

						if self.SKELETON then
							if not self.skeletonDrawings[uid] then
								self.skeletonDrawings[uid] = {}
							end
							updateSkeletonEsp(plr, self.skeletonDrawings[uid], camera)
						elseif self.skeletonDrawings[uid] then
							for _, line in pairs(self.skeletonDrawings[uid]) do
								line.Visible = false
							end
						end

						if self.TRACERS then
							updateTracersEsp(plrRoot, tracersDrawing, uid, camera)
						elseif self.tracersDrawings[uid] then
							self.tracersDrawings[uid].Visible = false
						end

						if self.WEAPON then
							updateWeaponEsp(plr, pos, weaponDrawing, uid)
						elseif self.weaponDrawings[uid] then
							self.weaponDrawings[uid].Visible = false
						end
					else
						if nameDrawing then
							nameDrawing.Visible = false
						end

						if boxDrawing then
							boxDrawing.Visible = false
						end
						
						if healthDrawing then
							healthDrawing.Visible = false
						end

						if distanceDrawing then
							distanceDrawing.Visible = false
						end

						if self.skeletonDrawings[uid] then
							for _, line in pairs(self.skeletonDrawings[uid]) do
								line.Visible = false
							end
						end

						if tracersDrawing then
							tracersDrawing.Visible = false
						end

						if weaponDrawing then
							weaponDrawing.Visible = false
						end
					end
				else
					local uid = plr.UserId
					if self.nameDrawings[uid] then
						self.nameDrawings[uid]:Remove()
						self.nameDrawings[uid] = nil
					end

					if self.boxDrawings[uid] then
						self.boxDrawings[uid]:Remove()
						self.boxDrawings[uid] = nil
					end

					if self.healthDrawings[uid] then
						self.healthDrawings[uid]:Remove()
						self.healthDrawings[uid] = nil
					end

					if self.distanceDrawings[uid] then
						self.distanceDrawings[uid]:Remove()
						self.distanceDrawings[uid] = nil
					end
					
					if self.skeletonDrawings[uid] then
						for _, line in pairs(self.skeletonDrawings[uid]) do
							if line then
								line:Remove()
							end
						end
						self.skeletonDrawings[uid] = nil
					end

					if self.tracersDrawings[uid] then
						self.tracersDrawings[uid]:Remove()
						self.tracersDrawings[uid] = nil
					end

					if self.weaponDrawings[uid] then
						self.weaponDrawings[uid]:Remove()
						self.weaponDrawings[uid] = nil
					end
				end
			end

			if not self.NAME then
				clearEspTable(self.nameDrawings)
			end

			if not self.BOX then
				clearEspTable(self.boxDrawings)
			end

			if not self.HEALTH then
				clearEspTable(self.healthDrawings)
			end

			if not self.DISTANCE then
				clearEspTable(self.distanceDrawings)
			end

			if not self.SKELETON then
				clearSkeletonEspTable(self.skeletonDrawings)
			end
			
			if not self.TRACERS then
				clearEspTable(self.tracersDrawings)
			end

			if not self.WEAPON then
				clearEspTable(self.weaponDrawings)
			end
		end)
	else
		Starlight:Notification({
			Title = "Error: Your Executor Doesnt Support This Features",
			Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
			Content = "Executor Supported Features Will Be labeld In Detections Tab"
		}, "INDEX")
	end
end

-- Disabling Esp Function
function playerEspMod:DisableEsp()
	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	clearEspTable(self.nameDrawings)
	clearEspTable(self.boxDrawings)
	clearEspTable(self.healthDrawings)
	clearEspTable(self.distanceDrawings)
	clearSkeletonEspTable(self.skeletonDrawings)
	clearEspTable(self.tracersDrawings)
	clearEspTable(self.weaponDrawings)
end

-- Creating Esp Toggle
visualGroupFeatures.espToggle = groupBoxes.visualsGroup1:CreateToggle({
	Name = "Esp Master Toggle",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			playerEspMod:EnableEsp()
		else
			playerEspMod:DisableEsp()
		end
	end
}, "INDEX")

-- Esp Toggle Keybind
visualGroupFeatures.espKeybindToggle = visualGroupFeatures.espToggle:AddBind({
	HoldToInteract = false,
	CurrentValue = nil,
	SyncToggleState = true,
	Callback = function(bind)
	end
}, "INDEX")

-- Name Esp Toggle
visualGroupFeatures.nameEspToggle = groupBoxes.visualsGroup1:CreateToggle({
	Name = "Name",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			playerEspMod.NAME = true
		else
			playerEspMod.NAME = false
		end
	end
}, "INDEX")

-- Box Esp Toggle
visualGroupFeatures.boxEspToggle = groupBoxes.visualsGroup1:CreateToggle({
	Name = "Box",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			playerEspMod.BOX = true
		else
			playerEspMod.BOX = false
		end
	end	
}, "INDEX")

-- Box Esp Filled Toggle
visualGroupFeatures.boxEspFilledToggle = groupBoxes.visualsGroup1:CreateToggle({
	Name = "Box Filled",
	CurrentValue = false,
	Style = 1,
	Callback = function(State)
		if State then
			playerEspMod.BOX_FILLED = true
		else
			playerEspMod.BOX_FILLED = false
		end
	end
}, "INDEX")

-- Health Esp Toggle
visualGroupFeatures.healthEspToggle = groupBoxes.visualsGroup1:CreateToggle({
	Name = "Health",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			playerEspMod.HEALTH = true
		else
			playerEspMod.HEALTH = false
		end
	end
}, "INDEX")

-- Distance Esp Toggle
visualGroupFeatures.distanceEspToggle = groupBoxes.visualsGroup1:CreateToggle({
	Name = "Distance",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			playerEspMod.DISTANCE = true
		else
			playerEspMod.DISTANCE = false
		end
	end
}, "INDEX")

-- Skeleton Esp Toggle
visualGroupFeatures.skeletonEspToggle = groupBoxes.visualsGroup1:CreateToggle({
	Name = "Skeleton",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			playerEspMod.SKELETON = true
		else
			playerEspMod.SKELETON = false
		end
	end
}, "INDEX")

-- Tracers Esp Toggle
visualGroupFeatures.tracersEspToggle = groupBoxes.visualsGroup1:CreateToggle({
	Name = "Tracers",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			playerEspMod.TRACERS = true
		else
			playerEspMod.TRACERS = false
		end
	end
}, "INDEX")

-- Tracers From Head Esp Toggle
visualGroupFeatures.tracersFromHeadToggle = groupBoxes.visualsGroup1:CreateToggle({
	Name = "Tracers From Head",
	CurrentValue = false,
	Style = 1,
	Callback = function(State)
		if State then
			playerEspMod.TRACERS_FROM_HEAD = true
		else
			playerEspMod.TRACERS_FROM_HEAD = false
		end
	end
}, "INDEX")

-- Weapon Esp Toggle
visualGroupFeatures.weaponEspToggle = groupBoxes.visualsGroup1:CreateToggle({
	Name = "Weapon",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			playerEspMod.WEAPON = true
		else
			playerEspMod.WEAPON = false
		end
	end
}, "INDEX")

-- Name Esp Color Label + Dropdown
visualGroupFeatures.nameEspColorLabel = groupBoxes.visualsGroup3:CreateLabel({
	Name = "Name Color",
}, "INDEX")

visualGroupFeatures.nameEspColorPicker = visualGroupFeatures.nameEspColorLabel:AddColorPicker({
	CurrentValue = Color3.fromRGB(255, 255, 255),
	Callback = function(Color)
		playerEspMod.NAME_COLOR = Color
	end
}, "INDEX")

-- Box Esp Color Label + Dropdown
visualGroupFeatures.boxColorLabel = groupBoxes.visualsGroup3:CreateLabel({
	Name = "Box Color",
}, "INDEX")

visualGroupFeatures.boxColorPicker = visualGroupFeatures.boxColorLabel:AddColorPicker({
	CurrentValue = Color3.fromRGB(255, 255, 255),
	Callback = function(Color)
		playerEspMod.BOX_COLOR = Color
	end
}, "INDEX")

-- Health Esp Color Label + Dropdown
visualGroupFeatures.healthColorLabel = groupBoxes.visualsGroup3:CreateLabel({
	Name = "Health Color",
}, "INDEX")

visualGroupFeatures.healthColorPicker = visualGroupFeatures.healthColorLabel:AddColorPicker({
	CurrentValue = Color3.fromRGB(0, 255, 0),
	Callback = function(Color)
		playerEspMod.HEALTH_COLOR = Color
	end
}, "INDEX")

-- Disatnce Esp Color Label + Dropdown
visualGroupFeatures.distanceColorLabel = groupBoxes.visualsGroup3:CreateLabel({
	Name = "Distance Color",
}, "INDEX")

visualGroupFeatures.distnaceColorPicker = visualGroupFeatures.distanceColorLabel:AddColorPicker({
	CurrentValue = Color3.fromRGB(255, 255, 255),
	Callback = function(Color)
		playerEspMod.DISTANCE_COLOR = Color
	end
}, "INDEX")

-- Skeleton Esp Color Label + Dropdown
visualGroupFeatures.skeletonColorLabel = groupBoxes.visualsGroup3:CreateLabel({
	Name = "Skeleton",
}, "INDEX")

visualGroupFeatures.skeletonColorPicker = visualGroupFeatures.skeletonColorLabel:AddColorPicker({
	CurrentValue = Color3.fromRGB(255, 255, 255),
	Callback = function(Color)
		playerEspMod.SKELETON_COLOR = Color
	end
}, "INDEX")

-- Tracers Esp Color Label + Dropdown
visualGroupFeatures.tracersColorLabel = groupBoxes.visualsGroup3:CreateLabel({
	Name = "Tracers Color",
}, "INDEX")

visualGroupFeatures.tracersColorPicker = visualGroupFeatures.tracersColorLabel:AddColorPicker({
	CurrentValue = Color3.fromRGB(255, 255, 255),
	Callback = function(Color)
		playerEspMod.TRACERS_COLOR = Color
	end
}, "INDEX")

-- Weapons Esp Color Label + Dropdown
visualGroupFeatures.weaponColorLabel = groupBoxes.visualsGroup3:CreateLabel({
	Name = "Weapon Color",
}, "INDEX")

visualGroupFeatures.weaponColorPicker = visualGroupFeatures.weaponColorLabel:AddColorPicker({
	CurrentValue = Color3.fromRGB(255, 255, 255),
	Callback = function(Color)
		playerEspMod.WEAPON_COLOR = Color
	end
}, "INDEX")

-- Car Esp Modifications
local generalEspMod = {}
-- Owned Car Esp Essentials
generalEspMod.carHighlight = nil
generalEspMod.conn1 = nil
generalEspMod.conn2 = nil
generalEspMod.CAR_COLOR = Color3.fromRGB(255, 0, 0)

-- Cars Esp Essentials
generalEspMod.carsHighlight = {}
generalEspMod.carsConnections = {}
generalEspMod.newCarConnections = {}
generalEspMod.CARS_COLOR = Color3.fromRGB(255, 0, 0)

-- Rent A Scooter Esp Essentials
generalEspMod.scootersHighlight = {}
generalEspMod.scooterConnections = {}
generalEspMod.newScooterConnections = {}
generalEspMod.SCOOTER_COLOR = Color3.fromRGB(255, 0, 0)

-- Robable Cars Esp Essentials
generalEspMod.robCarHighlight = {}
generalEspMod.robCarConnections = {}
generalEspMod.conn3 = nil
generalEspMod.ROBCAR_COLOR = Color3.fromRGB(255, 0, 0)

-- Search Trash Esp Essentials
generalEspMod.trashHighlight = {}
generalEspMod.trashConnections = {}
generalEspMod.conn4 = nil
generalEspMod.TRASH_COLOR = Color3.fromRGB(255, 0, 0)

-- Owned Car ESP Function
function generalEspMod:EnableOwnedCarEsp()
	local vehicleFolder = workspace:WaitForChild("Vehicles")
	local waitForCar

	local function createEsp(car)
		if self.carHighlight then
			self.carHighlight:Destroy()
			self.carHighlight = nil
		end

		local highlight = Instance.new("Highlight")
		highlight.Name = "CarEsp"
		highlight.FillColor = self.CAR_COLOR
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.3
		highlight.OutlineTransparency = 0.5
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Adornee = car
		highlight.Parent = car

		self.carHighlight = highlight
	end

	local function trackCar(car)
		if self.conn2 then
			self.conn2:Disconnect()
			self.conn2 = nil
		end

		createEsp(car)

		self.conn2 = car.AncestryChanged:Connect(function(_, parent)
			if not parent then
				if self.carHighlight then
					self.carHighlight:Destroy()
					self.carHighlight = nil
				end
				waitForCar()
			end
		end)
	end

	waitForCar = function()
		if self.conn1 then
			self.conn1:Disconnect()
			self.conn1 = nil
		end

		local carName = player.Name .. "'s Car"
		for _, car in pairs(vehicleFolder:GetChildren()) do
			if car.Name == carName then
				trackCar(car)
				return
			end
		end

		self.conn1 = vehicleFolder.ChildAdded:Connect(function(car)
			if car.Name == carName then
				trackCar(car)
				if self.conn1 then
					self.conn1:Disconnect()
					self.conn1 = nil
				end
			end
		end)
	end

	local function applyCarEsp()
		waitForCar()
	end

	applyCarEsp()
end

-- Disable Owned Car Esp Function
function generalEspMod:DisableOwnedCarEsp()
	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	if self.conn2 then
		self.conn2:Disconnect()
		self.conn2 = nil
	end

	if self.carHighlight then
		self.carHighlight:Destroy()
		self.carHighlight = nil
	end

	self.currentCar = nil
end

-- Cars Esp Function
function generalEspMod:EnableCarsEsp()
	local vehicleFolder = workspace:WaitForChild("Vehicles")

	local function createEsp(car)
		if self.carsHighlight[car] then
			return
		end

		local highlight = Instance.new("Highlight")
		highlight.Name = "CarEsp"
		highlight.FillColor = self.CARS_COLOR
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.3
		highlight.OutlineTransparency = 0.5
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Adornee = car
		highlight.Parent = car

		self.carsHighlight[car] = highlight

		local conn = car.AncestryChanged:Connect(function(_, parent)
			if not parent then
				if self.carsHighlight[car] then
					self.carsHighlight[car]:Destroy()
					self.carsHighlight[car] = nil
				end
				if self.carsConnections[car] then
					self.carsConnections[car]:Disconnect()
					self.carsConnections[car] = nil
				end
			end
		end)

		self.carsConnections[car] = conn
	end

	local function applyCarsEsp()
		for _, car in pairs(vehicleFolder:GetChildren()) do
			if not self.carsHighlight[car] then
				createEsp(car)
			end
		end

		if not self.newCarConnections["ChildAdded"] then
			self.newCarConnections["ChildAdded"] = vehicleFolder.ChildAdded:Connect(function(car)
				createEsp(car)
			end)
		end
	end

	applyCarsEsp()
end

-- Disabling Cars Esp Function
function generalEspMod:DisableCarsEsp()
	for car, conn in pairs(self.carsConnections) do
		if conn then
			conn:Disconnect()
		end
	end
	self.carsConnections = {}

	for car, highlight in pairs(self.carsHighlight) do
		if highlight then
			highlight:Destroy()
		end
	end
	self.carsHighlight = {}

	if self.newCarConnections["ChildAdded"] then
		self.newCarConnections["ChildAdded"]:Disconnect()
		self.newCarConnections["ChildAdded"] = nil
	end
end

-- Rent A Scooter Esp Function
function generalEspMod:EnableScooterEsp()
	local scootersFolder = workspace.Map.Scooters

	local function createEsp(scooter)
		if self.scootersHighlight[scooter] then
			return
		end

		local highlight = Instance.new("Highlight")
		highlight.Name = "CarEsp"
		highlight.FillColor = self.SCOOTER_COLOR
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.3
		highlight.OutlineTransparency = 0.5
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Adornee = scooter
		highlight.Parent = scooter

		self.scootersHighlight[scooter] = highlight

		local conn = scooter.AncestryChanged:Connect(function(_, parent)
			if not parent then
				if self.scootersHighlight[scooter] then
					self.scootersHighlight[scooter]:Destroy()
					self.scootersHighlight[scooter] = nil
				end
				if self.scooterConnections[scooter] then
					self.scooterConnections[scooter]:Disconnect()
					self.scooterConnections[scooter] = nil
				end
			end
		end)

		self.scooterConnections[scooter] = conn
	end

	local function applyScootersEsp()
		for _, scooter in pairs(scootersFolder:GetChildren()) do
			if not self.scootersHighlight[scooter] then
				createEsp(scooter)
			end
		end

		if not self.newScooterConnections["ChildAdded"] then
			self.newScooterConnections["ChildAdded"] = scootersFolder.ChildAdded:Connect(function(scooter)
				createEsp(scooter)
			end)
		end
	end

	applyScootersEsp()
end

-- Disabling Scooters Esp Function
function generalEspMod:DisableScooterEsp()
	for scooter, conn in pairs(self.scooterConnections) do
		if conn then
			conn:Disconnect()
		end
	end
	self.scooterConnections = {}

	for scooter, highlight in pairs(self.scootersHighlight) do
		if highlight then
			highlight:Destroy()
		end
	end
	self.scootersHighlight = {}

	if self.newScooterConnections["ChildAdded"] then
		self.newScooterConnections["ChildAdded"]:Disconnect()
		self.newScooterConnections["ChildAdded"] = nil
	end
end

-- Robable Car Esp Function
function generalEspMod:EnableRobCarEsp()
	local folder = workspace.Map.Interactions

	local function createEsp(car)
		if self.robCarHighlight[car] then return end

		local highlight = Instance.new("Highlight")
		highlight.Name = "CarEsp"
		highlight.FillColor = generalEspMod.ROBCAR_COLOR
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.3
		highlight.OutlineTransparency = 0.5
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Adornee = car
		highlight.Parent = car

		self.robCarHighlight[car] = highlight
	end

	local function removeEsp(car)
		if self.robCarHighlight[car] then
			self.robCarHighlight[car]:Destroy()
			self.robCarHighlight[car] = nil
		end
	end

	local function trackCar(car)
		if self.robCarConnections[car] then
			self.robCarConnections[car]:Disconnect()
			self.robCarConnections[car] = nil
		end

		local function updateHighlight()
			local window = car:FindFirstChild("Window")
			if not window then
				removeEsp(car)
				return
			end
			local hPart = window:FindFirstChild("H")
			if not hPart then
				removeEsp(car)
				return
			end
			local prompt = hPart:FindFirstChildWhichIsA("ProximityPrompt")
			if prompt and prompt.Enabled then
				createEsp(car)
			else
				removeEsp(car)
			end
		end

		updateHighlight()

		local prompt = car:FindFirstChild("Window") and car.Window:FindFirstChild("H") and car.Window.H:FindFirstChildWhichIsA("ProximityPrompt")
		if prompt then
			self.robCarConnections[car] = prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
				updateHighlight()
			end)
		else
			self.robCarConnections[car] = car.AncestryChanged:Connect(function(_, parent)
				if not parent then
					removeEsp(car)
					if self.robCarConnections[car] then
						self.robCarConnections[car]:Disconnect()
						self.robCarConnections[car] = nil
					end
				end
			end)
		end

		if not self.robCarConnections[car] then
			self.robCarConnections[car] = car.AncestryChanged:Connect(function(_, parent)
				if not parent then
					removeEsp(car)
					if self.robCarConnections[car] then
						self.robCarConnections[car]:Disconnect()
						self.robCarConnections[car] = nil
					end
				end
			end)
		end
	end

	local function applyEsp()
		for _, car in pairs(folder:GetChildren()) do
			if car:IsA("Model") and car.Name == "Car Rob" then
				trackCar(car)
			end
		end

		if not self.conn3 then
			self.conn3 = folder.ChildAdded:Connect(function(car)
				if car:IsA("Model") and car.Name == "Car Rob" then
					trackCar(car)
				end
			end)
		end
	end

	applyEsp()
end

-- Disabling Robable Car Esp Function
function generalEspMod:DisableRobCarEsp()
    if self.conn3 then
        self.conn3:Disconnect()
        self.conn3 = nil
    end

    if self.robCarConnections then
        for car, conn in pairs(self.robCarConnections) do
            if conn then
                conn:Disconnect()
            end
            self.robCarConnections[car] = nil
        end
    end

    if self.robCarHighlight then
        for car, highlight in pairs(self.robCarHighlight) do
            if highlight then
                highlight:Destroy()
            end
            self.robCarHighlight[car] = nil
        end
    end
end

-- Search Trash Esp Function
function generalEspMod:EnableSearchTrashEsp()
	local folder = workspace.Map.Interactions

	local function createEsp(trash)
		if self.trashHighlight[trash] then return end

		local highlight = Instance.new("Highlight")
		highlight.Name = "TrashEsp"
		highlight.FillColor = self.TRASH_COLOR
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.3
		highlight.OutlineTransparency = 0.5
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Adornee = trash
		highlight.Parent = trash

		self.trashHighlight[trash] = highlight
	end

	local function removeEsp(trash)
		if self.trashHighlight[trash] then
			self.trashHighlight[trash]:Destroy()
			self.trashHighlight[trash] = nil
		end
	end

	local function trackTrash(trash)
		if self.trashConnections[trash] then
			self.trashConnections[trash]:Disconnect()
			self.trashConnections[trash] = nil
		end

		local function updateHighlight()
			local prompt = trash:FindFirstChild("Handler")
			if prompt and prompt.Enabled then
				createEsp(trash)
			else
				removeEsp(trash)
			end
		end

		updateHighlight()

		local prompt = trash:FindFirstChild("Handler")
		if prompt then
			self.trashConnections[trash] = prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
				updateHighlight()
			end)
		end

		if not self.trashConnections[trash] then
			self.trashConnections[trash] = trash.AncestryChanged:Connect(function(_, parent)
				if not parent then
					removeEsp(trash)
					if self.trashConnections[trash] then
						self.trashConnections[trash]:Disconnect()
						self.trashConnections[trash] = nil
					end
				end
			end)
		end
	end

	local function applyEsp()
		for _, trash in pairs(folder:GetChildren()) do
			if trash.Name == "Search Trash" then
				trackTrash(trash)
			end
		end

		if not self.conn4 then
			self.conn4 = folder.ChildAdded:Connect(function(trash)
				if trash.Name == "Search Trash" then
					trackTrash(trash)
				end
			end)
		end
	end

	applyEsp()
end

-- Disabling Search Trash Esp
function generalEspMod:DisableTrashEsp()
	if self.conn4 then
		self.conn4:Disconnect()
		self.conn4 = nil
	end

	if self.trashConnections then
		for trash, conn in pairs(self.trashConnections) do
			if conn then
				conn:Disconnect()
			end
			self.trashConnections[trash] = nil
		end
	end

	if self.trashHighlight then
		for trash, obj in pairs(self.trashHighlight) do
			if obj then
				obj:Destroy()
			end
			self.trashHighlight[trash] = nil
		end
	end
end

-- Owned Car Esp Toggle
visualGroupFeatures.carEspToggle = groupBoxes.visualsGroup2:CreateToggle({
	Name = "Owned Car",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			generalEspMod:EnableOwnedCarEsp()
		else
			generalEspMod:DisableOwnedCarEsp()
		end
	end
}, "INDEX")

-- All Cars Esp Toggle
visualGroupFeatures.carsEspToggle = groupBoxes.visualsGroup2:CreateToggle({
	Name = "Cars",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			generalEspMod:EnableCarsEsp()
		else
			generalEspMod:DisableCarsEsp()
		end
	end
}, "INDEX")

-- Rent A Scooter Esp Toggle
visualGroupFeatures.rentAScooterEspToggle = groupBoxes.visualsGroup2:CreateToggle({
	Name = "Rent A Scooter",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			generalEspMod:EnableScooterEsp()
		else
			generalEspMod:DisableScooterEsp()
		end
	end
}, "INDEX")

-- Rob Car Esp Toggle
visualGroupFeatures.robCarEspToggle = groupBoxes.visualsGroup2:CreateToggle({
	Name = "Robable Cars",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			generalEspMod:EnableRobCarEsp()
		else
			generalEspMod:DisableRobCarEsp()
		end
	end
}, "INDEX")

-- Trash Esp Toggle
visualGroupFeatures.trashEspToggle = groupBoxes.visualsGroup2:CreateToggle({
	Name = "Searchable Trash",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			generalEspMod:EnableSearchTrashEsp()
		else
			generalEspMod:DisableTrashEsp()
		end
	end
}, "INDEX")

-- Owned Car Esp Color Label + Dropdown
visualGroupFeatures.ownedCarColorLabel = groupBoxes.visualsGroup4:CreateLabel({
	Name = "Onwed Car",
}, "INDEX")

visualGroupFeatures.ownedCarColorPicker = visualGroupFeatures.ownedCarColorLabel:AddColorPicker({
	CurrentValue = Color3.fromRGB(255, 0, 0),
	Callback = function(Color)
		generalEspMod.CAR_COLOR = Color

		if generalEspMod.carHighlight then
			generalEspMod.carHighlight.FillColor = Color
		end
	end
}, "INDEX")

-- Cars Esp Color Label + Dropdown
visualGroupFeatures.carsColorLabel = groupBoxes.visualsGroup4:CreateLabel({
	Name = "Cars",
}, "INDEX")

visualGroupFeatures.carsColorPicker = visualGroupFeatures.carsColorLabel:AddColorPicker({
	CurrentValue = Color3.fromRGB(255, 0, 0),
	Callback = function(Color)
		generalEspMod.CARS_COLOR = Color

		if generalEspMod.carsHighlight then
			for _, highlight in pairs(generalEspMod.carsHighlight) do
				highlight.FillColor = Color
			end
		end
	end
}, "INDEX")

-- Rent A Scooter Color Label + Dropdown
visualGroupFeatures.scooterColorLabel = groupBoxes.visualsGroup4:CreateLabel({
	Name = "Rent A Scooter",
}, "INDEX")

visualGroupFeatures.scooterColorPicker = visualGroupFeatures.scooterColorLabel:AddColorPicker({
	CurrentValue = Color3.fromRGB(255, 0, 0),
	Callback = function(Color)
		generalEspMod.SCOOTER_COLOR = Color

		if generalEspMod.scootersHighlight then
			for _, highlight in pairs(generalEspMod.scootersHighlight) do
				highlight.FillColor = Color
			end
		end
	end
}, "INDEX")

-- Robable Cars Color Label + Dropdown
visualGroupFeatures.robableCarsColorLabel = groupBoxes.visualsGroup4:CreateLabel({
	Name = "Robable Cars",
}, "INDEX")

visualGroupFeatures.robableCarsColorPicker = visualGroupFeatures.robableCarsColorLabel:AddColorPicker({
	CurrentValue = Color3.fromRGB(255, 0, 0),
	Callback = function(Color)
		generalEspMod.ROBCAR_COLOR = Color

		if generalEspMod.robCarHighlight then
			for _, highlight in pairs(generalEspMod.robCarHighlight) do
				highlight.FillColor = Color
			end
		end
	end
}, "INDEX")

-- Search Trash Color Label + Dropdown
visualGroupFeatures.trashColorLabel = groupBoxes.visualsGroup4:CreateLabel({
	Name = "Searchable Trash",
}, "INDEX")

visualGroupFeatures.trashColorPicker = visualGroupFeatures.trashColorLabel:AddColorPicker({
	CurrentValue = Color3.fromRGB(255, 0, 0),
	Callback = function(Color)
		generalEspMod.TRASH_COLOR = Color

		if generalEspMod.trashHighlight then
			for _, highlight in pairs(generalEspMod.trashHighlight) do
				highlight.FillColor = Color
			end
		end
	end
}, "INDEX")

-- Combat Features
local combatFeatures = {}

-- Aim Assist Modification
local aimAssistMod = {}

-- Aim Assist Configurations
aimAssistMod.STRENGTH = 0.01
aimAssistMod.DISTANCE = 100
aimAssistMod.HITPART = "Head"
aimAssistMod.VISIBLE_CHECK = false

-- Aim Assist Connections
aimAssistMod.conn1 = nil

-- Fov Configurations
aimAssistMod.FOV = nil
aimAssistMod.FOV_ENABLED = false
aimAssistMod.FOV_RADIUS	= 100
aimAssistMod.FOV_COLOR = Color3.fromRGB(255, 255, 255)

-- Enabling Aim Assist Function
function aimAssistMod:EnableAimAssist()
	local function applyAimAssist()
		if self.conn1 then
			self.conn1:Disconnect()
			self.conn1 = nil
		end

		local function updateFov()
			if not self.FOV then
				local circle = Drawing.new("Circle")
				circle.Filled = false
				circle.Color = self.FOV_COLOR
				circle.Transparency = 1
				circle.Thickness = 2
				circle.NumSides = 100
				circle.Radius = self.FOV_RADIUS
				self.FOV = circle
			end

			local cam = workspace.CurrentCamera
			local viewportSize = cam.ViewportSize
			local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
			self.FOV.Position = center
			self.FOV.Visible = true
		end

		local function findTarget()
			local cam = workspace.CurrentCamera
			local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

			local target = nil
			local maxDistance = self.FOV_RADIUS
			local maxPosition = self.DISTANCE

			for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local plrRoot = plr.Character:FindFirstChild("HumanoidRootPart")
					if not plrRoot then continue end

					local screenPos, onScreen = cam:WorldToViewportPoint(plrRoot.Position)
					if not onScreen then continue end

					if self.VISIBLE_CHECK then
						local rayOrigin = cam.CFrame.Position
						local rayDirection = (plrRoot.Position - rayOrigin).Unit * 5000

						local raycastParams = RaycastParams.new()
						raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
						raycastParams.FilterDescendantsInstances = {player.Character}
						raycastParams.IgnoreWater = true

						local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

					
						if rayResult and rayResult.Instance and not plr.Character:IsAncestorOf(rayResult.Instance) then
							continue
						end
					end

					local screenVec = Vector2.new(screenPos.X, screenPos.Y)
					local distance = (screenVec - center).Magnitude
					local posDistance = (plrRoot.Position - getgenv().root.Position).Magnitude

					if distance < maxDistance and posDistance < maxPosition then
						maxDistance = distance
						maxPosition = posDistance
						target = plr
					end
				end
			end
			return target
		end

		self.conn1 = RunService.RenderStepped:Connect(function()
			if self.FOV_ENABLED then
				updateFov()
			else
				if self.FOV then
					self.FOV.Visible = false
					self.FOV:Remove()
					self.FOV = nil
				end
			end

			local target = findTarget()
			if target and target.Character and target.Character:FindFirstChild(self.HITPART) then
				local cam = workspace.CurrentCamera
				local targetPart = target.Character:FindFirstChild(self.HITPART)
				if cam and targetPart then
					local camPos = cam.CFrame.Position
					local targetDir = (targetPart.Position - camPos).Unit
					local desiredLook = CFrame.new(camPos, camPos + targetDir)
					local convertedStrength = math.clamp(self.STRENGTH / 10, 0.01, 1)
					cam.CFrame = cam.CFrame:Lerp(desiredLook, convertedStrength)
				end
			end
		end)
	end

	applyAimAssist()

	enabledFeatures["applyAimAssist"] = applyAimAssist
end

-- Disabling Aim Assist Function
function aimAssistMod:DisableAimAssist()
	if enabledFeatures["applyAimAssist"] then
		enabledFeatures["applyAimAssist"] = nil
	end

	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	if self.FOV then
		self.FOV:Remove()
		self.FOV = nil
	end
end

-- Aim Assist Toggle
combatFeatures.aimAssistToggle = groupBoxes.combatGroup1:CreateToggle({
	Name = "Enable Aim Assist",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			aimAssistMod:EnableAimAssist()
		else
			aimAssistMod:DisableAimAssist()
		end
	end
}, "INDEX")

-- Aim Assist Toggle Keybind
combatFeatures.aimAssistKeybind = combatFeatures.aimAssistToggle:AddBind({
	HoldToInteract = false,
	CurrentValue = nil,
	SyncToggleState = true,
	Callback = function(bind)
	end
}, "INDEX")

-- Aim Assist Hit Part Label + Dropdown
combatFeatures.aimAssistHitPartLabel = groupBoxes.combatGroup1:CreateLabel({
	Name = "Hit Part",
}, "INDEX")

combatFeatures.aimAssistHitPartDropdown = combatFeatures.aimAssistHitPartLabel:AddDropdown({
	Options = {"Head", "UpperTorso", "LowerTorso", "RightFoot", "LeftFoot", "RightHand", "LeftHand"},
	CurrentOptions = {"Head"},
	Placeholder = "Head By Default",
	Callback = function(Options)
		if Options[1] ~= nil and getgenv().char:FindFirstChild(Options[1]) then
			aimAssistMod.HITPART = Options[1]
		end
	end,
}, "INDEX")

-- Aim Assist Size
combatFeatures.aimAssistSize = groupBoxes.combatGroup1:CreateSlider({
	Name = "Aim Assist Size",
	Icon = NebulaIcons:GetIcon('circle', 'Lucide'),
	Range = {20, 300},
	Increment = 1,
	Callback = function(Value)
		if Value ~= nil and tonumber(Value) > 0 then
			aimAssistMod.FOV_RADIUS = tonumber(Value)
			if aimAssistMod.FOV then
				aimAssistMod.FOV.Radius = tonumber(Value)
			end
		end
	end
}, "INDEX")

-- Aim Assist Strength
combatFeatures.aimAssistStrength = groupBoxes.combatGroup1:CreateSlider({
	Name = "Strength",
	Icon = NebulaIcons:GetIcon('magnet', 'Lucide'),
	Range = {0.01, 10},
	Increment = 0.01,
	Callback = function(Value)
		if Value ~= nil and tonumber(Value) > 0 then
			aimAssistMod.STRENGTH = tonumber(Value)
		end
	end
}, "INDEX")

-- Aim Assist Distance
combatFeatures.aimAssistStrength = groupBoxes.combatGroup1:CreateSlider({
	Name = "Distance",
	Icon = NebulaIcons:GetIcon('map-pin', 'Lucide'),
	Range = {100, 5000},
	Increment = 1,
	Callback = function(Value)
		if Value ~= nil and tonumber(Value) > 0 then
			aimAssistMod.DISTANCE = tonumber(Value)
		end
	end
}, "INDEX")

-- Aim Assist Visible Check Toggle
combatFeatures.aimAssistVisibleCheckToggle = groupBoxes.combatGroup1:CreateToggle({
	Name = "Visible Check",
	CurrentValue = false,
	Callback = function(State)
		if State then
			aimAssistMod.VISIBLE_CHECK = true
		else
			aimAssistMod.VISIBLE_CHECK = false
		end
	end
}, "INDEX")

-- Enable Aim Assist Fov Toggle
combatFeatures.aimAssistFovToggle = groupBoxes.combatGroup1:CreateToggle({
	Name = "Show Fov (Optional)",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			aimAssistMod.FOV_ENABLED = true
		else
			aimAssistMod.FOV_ENABLED = false
		end
	end
}, "INDEX")

-- Aim Assist Fov Color Label + Color Picker
combatFeatures.aimAssistFovColorLabel = groupBoxes.combatGroup1:CreateLabel({
	Name = "Fov Color",
}, "INDEX")

combatFeatures.aimAssistFovColorPicker = combatFeatures.aimAssistFovColorLabel:AddColorPicker({
	CurrentValue = Color3.fromRGB(255, 255, 255),
	Callback = function(Color)
		aimAssistMod.FOV_COLOR = Color
		if aimAssistMod.FOV then
			aimAssistMod.FOV.Color = Color
		end
	end
}, "INDEX")

-- Silent Aim Modification
local silentAimMod = {}

-- Silent Aim Essentials
silentAimMod.enabled = false
silentAimMod.direction = nil
silentAimMod.conn1 = nil
silentAimMod.conn2 = nil
silentAimMod.conn3 = nil
silentAimMod.conn4 = nil
silentAimMod.conn5 = nil

-- Raycast Params Essentials
silentAimMod.params = nil
silentAimMod.whitelist = {}
silentAimMod.playerList = {}
silentAimMod.newPlayerConnections = {}

-- Silent Aim Configurations
silentAimMod.LEGIT = true
silentAimMod.HITPART = "Head"
silentAimMod.WALLBANG = false
silentAimMod.FOV_ENABLED = false

-- Silent Aim Fov Configs
silentAimMod.FOV = nil
silentAimMod.ADJUST = 0
silentAimMod.RADIUS = 100
silentAimMod.FOV_COLOR = Color3.fromRGB(255, 255, 255)
silentAimMod.FOV_VISIBLE = true

-- Enable Silent Aim Function
function silentAimMod:Enable()
	self.enabled = true

	-- Disabling Connections
	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	if self.conn2 then
		self.conn2:Disconnect()
		self.conn2 = nil
	end

	if self.conn3 then
		self.conn3:Disconnect()
		self.conn3 = nil
	end

	if self.conn4 then
		self.conn4:Disconnect()
		self.conn4 = nil
	end

	for _, conn in pairs(self.newPlayerConnections) do
		if conn then
			conn:Disconnect()
		end
	end
	self.newPlayerConnections = {}

	-- Updating Fov / Creating Fov
	local function updateFov()
		if not self.FOV then
			local circle = Drawing.new("Circle")
			circle.Filled = false
			circle.Color = self.FOV_COLOR
			circle.Transparency = 1
			circle.Thickness = 2
			circle.NumSides = 100
			circle.Radius = self.RADIUS
			
			self.FOV = circle
		end

		if self.FOV_ENABLED then
			self.FOV.Color = self.FOV_COLOR
			self.FOV.Position = Vector2.new(mouse.X, mouse.Y + self.ADJUST)
			self.FOV.Visible = self.FOV_VISIBLE
		end
	end

	-- Finding Enemy
	local function findTarget()
		local target = nil
		if self.FOV_ENABLED and self.FOV then

			camera = workspace.CurrentCamera
			local mousePos = Vector2.new(mouse.X, mouse.Y + self.ADJUST)
			local maxFovDistance = self.RADIUS
			local maxDistance = math.huge

			for _, plr in pairs(players:GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and getgenv().root then
					local plrRoot = plr.Character:FindFirstChild("HumanoidRootPart")
					local plrHum = plr.Character:FindFirstChild("Humanoid")
					if plrHum and plrHum.Health > 0 and not (plr.Character:FindFirstChild("OnboardingHighlight") or plr.Character:FindFirstChild("SafeField")) then
						local distance = (plrRoot.Position - getgenv().root.Position).Magnitude
						if distance < maxDistance then
							local screenPos, onScreen = camera:WorldToViewportPoint(plrRoot.Position)
							if onScreen then
								local screenVec = Vector2.new(screenPos.X, screenPos.Y)
								local fovDistance = (screenVec - mousePos).Magnitude
								if fovDistance <= self.RADIUS and fovDistance < maxFovDistance then
									maxFovDistance = fovDistance
									target = plr
								end
							end
						end
					end
				end
			end
		else
			local maxDistance = math.huge
			for _, plr in pairs(players:GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and getgenv().root then
					local plrChar = plr.Character
					local plrHum = plr.Character:FindFirstChild("Humanoid")
					if not (plrChar:FindFirstChild("OnboardingHighlight") or plrChar:FindFirstChild("SafeField")) and plrHum and plrHum.Health > 0 then
						local distance = (plrChar.HumanoidRootPart.Position - getgenv().root.Position).Magnitude
						if distance < maxDistance then
							maxDistance = distance
							target = plr
						end
					end
				end
			end
		end
		return target
	end

	-- Creating Raycast For Hook
	self.whitelist = {}
	self.params = RaycastParams.new()
	for _, plr in pairs(players:GetPlayers()) do
		if plr ~= player then
			if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local plrChar = plr.Character
				if not (plrChar:FindFirstChild("OnboardingHighlight") or plrChar:FindFirstChild("SafeField")) then
					table.insert(self.whitelist, plrChar)
				end
			end

			self.newPlayerConnections[plr] = plr.CharacterAdded:Connect(function(newChar)
				if newChar and newChar:FindFirstChild("HumanoidRootPart") then
					if not (newChar:FindFirstChild("OnboardingHighlight") or newChar:FindFirstChild("SafeField")) then
						table.insert(self.whitelist, newChar)
					end
				end
			end)
		end
	end

	-- Listening For New Players That Join The Game
	self.conn1 = players.PlayerAdded:Connect(function(newPlr)
		if newPlr ~= player then
			if newPlr.Character and newPlr.Character:FindFirstChild("HumanoidRootPart") then
				local newChar = newPlr.Character
				if not (newChar:FindFirstChild("OnboardingHighlight") or newChar:FindFirstChild("SafeField")) then
					table.insert(self.whitelist, newChar)
				end
			end

			self.newPlayerConnections[newPlr] = newPlr.CharacterAdded:Connect(function(newChar)
				if newChar and newChar:FindFirstChild("HumanoidRootPart") then
					if not (newChar:FindFirstChild("OnboardingHighlight") or newChar:FindFirstChild("SafeField")) then
						table.insert(self.whitelist, newChar)
					end
				end
			end)
		end
	end)

	-- Updating Enemy Direction
	local debounce = false
	self.conn2 = RunService.Heartbeat:Connect(function()
		if debounce then return end
		debounce = true

		local target = findTarget()
		if target and target.Character and target.Character:FindFirstChild(self.HITPART) and getgenv().root then
			self.direction = (target.Character:FindFirstChild(self.HITPART).Position - getgenv().root.Position).Unit * 5000
		end

		debounce = false
	end)

	-- Updating Fov
	self.conn3 = RunService.RenderStepped:Connect(function()
		if self.FOV_ENABLED then
			updateFov()
		else
			if self.FOV then
				self.FOV:Remove()
				self.FOV = nil
			end
		end
	end)

	-- Hooking Remote Raycast For Silent Aim
	if hookmetamethod then
		if self.LEGIT then
			local hookDebounce = false
			repeat
				if hookDebounce then return end
				hookDebounce = true

				silentAimMod.params.FilterDescendantsInstances = self.whitelist
				silentAimMod.params.FilterType = Enum.RaycastFilterType.Whitelist

				local old
				old = hookmetamethod(workspace, "__namecall", function(self, ...)
					local method = getnamecallmethod()
					local args = {...}

					if silentAimMod.enabled and silentAimMod.LEGIT and not checkcaller() and method == "Raycast" and self == workspace then
						if silentAimMod.direction then
							args[2] = silentAimMod.direction
						end
						
						if silentAimMod.WALLBANG then
							args[3] = silentAimMod.params
						end
					end

					return old(self, table.unpack(args))
				end)

				task.wait(5)
				hookDebounce = false
			until not (self.enabled or self.LEGIT)
		elseif not self.LEGIT then
			if not getgenv().ServerId then
				repeat
					local old
					old = hookmetamethod(game, "__namecall", function(self, ...)
						local method = getnamecallmethod()
						local args = {...}

						if not checkcaller() and method == "FireServer" and self == FireRemote then
							getgenv().ServerId = args[1]
						end

						return old(self, ...)
					end)
					task.wait(5)
				until getgenv().ServerId
			end

			self.conn4 = Uis.InputBegan:Connect(function(Input, Gpe)
				if Gpe or self.LEGIT then return end

				local gunId = nil
				local hitPart = nil

				if getgenv().char:FindFirstChildOfClass("Tool") and getgenv().char:FindFirstChildOfClass("Tool"):GetAttribute("Id") then
					gunId = getgenv().char:FindFirstChildOfClass("Tool"):GetAttribute("Id")
				end

				local target = findTarget()
				if target and target.Character and target.Character:FindFirstChild(self.HITPART) then
					hitPart = target.Character:FindFirstChild(self.HITPART)
				end

				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					PositionRemote:FireServer(getgenv().ServerId, gunId, hitPart)
				elseif Input.UserInputType == Enum.UserInputType.Touch then
					PositionRemote:FireServer(getgenv().ServerId, gunId, hitPart)
				end
			end)
		end
	end
end

-- Disable Silent Aim Function 
function silentAimMod:Disable()
	self.enabled = false

	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	if self.conn2 then
		self.conn2:Disconnect()
		self.conn2 = nil
	end

	if self.conn3 then
		self.conn3:Disconnect()
		self.conn3 = nil
	end

	if self.conn4 then
		self.conn4:Disconnect()
		self.conn4 = nil
	end

	if self.FOV then
		self.FOV:Remove()
		self.FOV = nil
	end

	for _, conn in pairs(self.newPlayerConnections) do
		if conn then
			conn:Disconnect()
		end
	end
	self.newPlayerConnections = {}
end

-- Silent Aim Toggle
combatFeatures.silentAimToggle = groupBoxes.combatGroup2:CreateToggle({
	Name = "Enable Silent Aim",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			silentAimMod:Enable()
		else
			silentAimMod:Disable()
		end
	end
}, "INDEX")

-- Silent Aim Keybind Toggle
combatFeatures.silentAimKeybindToggle = combatFeatures.silentAimToggle:AddBind({
	HoldToInteract = false,
	CurrentValue = nil,
	Callback = function(Value)
	end
}, "INDEX")

-- Silent Aim Method Label + Dropdown
combatFeatures.silentAimMethodLabel = groupBoxes.combatGroup2:CreateLabel({
	Name = "Method (Must Renable Silent Aim To Apply)",
}, "INDEX")

combatFeatures.silentAimMethodDropdown = combatFeatures.silentAimMethodLabel:AddDropdown({
	Options = {"Legit", "Blatant"},
	CurrentOptions = {"Legit"},
	Placeholder = "Legit By Default",
	Callback = function(Options)
		if Options ~= nil then
			if Options[1] == "Legit" then
				silentAimMod.LEGIT = true
			elseif Options[1] == "Blatant" then
				silentAimMod.LEGIT = false
			else
				silentAimMod.LEGIT = true
			end
		end
	end
}, "INDEX")

-- Silent Aim Hit Part Label + Dropdown
combatFeatures.silentAimHitPartLabel = groupBoxes.combatGroup2:CreateLabel({
	Name = "Hit Part",
}, "INDEX")

combatFeatures.silentAimHitPartDropdown = combatFeatures.silentAimHitPartLabel:AddDropdown({
	Options = {"Head", "UpperTorso", "LowerTorso", "RightFoot", "LeftFoot", "RightHand", "LeftHand"},
	CurrentOptions = {"Head"},
	Placeholder = "Head By Default",
	Callback = function(Options)
		if Options ~= nil and Options[1] and getgenv().char:FindFirstChild(Options[1]) then
			silentAimMod.HITPART = Options[1]
		else
			Starlight:Notification({
				Title = "Error: Could Not Find HitPart",
				Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
				Content = "Make sure your player is loaded within the game and others, if the issue persists open a support ticket via discord",
			}, "INDEX")
		end
	end
}, "INDEX")

-- Silent Aim Wallbang Toggle
combatFeatures.silentAimWallbangToggle = groupBoxes.combatGroup2:CreateToggle({
	Name = "Wallbang (Legit Mode Only)",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			silentAimMod.WALLBANG = true
		else
			silentAimMod.WALLBANG = false
		end
	end
}, "INDEX")

-- Silent Aim Fov Toggle
combatFeatures.silentAimFovToggle = groupBoxes.combatGroup2:CreateToggle({
	Name = "Enable Fov",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		silentAimMod.FOV_ENABLED = State
	end
}, "INDEX")

-- Silent Aim Show Fov Toggle
combatFeatures.silentAimShowFovToggle = groupBoxes.combatGroup2:CreateToggle({
	Name = "Show Fov (Optional)",
	CurrentValue = true,
	Style = 2,
	Callback = function(State)
		if State then
			silentAimMod.FOV_VISIBLE = true
		else
			silentAimMod.FOV_VISIBLE = false
		end
	end
}, "INDEX")

-- Silent Aim Fov Adjustment
combatFeatures.silentAimFovAdjustSlider = groupBoxes.combatGroup2:CreateSlider({
	Name = "Fov Adjustment Value (prefferd 60)",
	Icon = NebulaIcons:GetIcon('mouse-pointer-2', 'Lucide'),
	Range = {0, 100},
	Increment = 1,
	CurrentValue = 60,
	Callback = function(Value)
		if Value ~= nil and tonumber(Value) >= 0 then
			silentAimMod.ADJUST = tonumber(Value)
		end
	end
}, "INDEX")

-- Silent Aim Fov Size
combatFeatures.silentAimFovSizeSlider = groupBoxes.combatGroup2:CreateSlider({
	Name = "Fov Size",
	Icon = NebulaIcons:GetIcon('circle', 'Lucide'),
	Range = {20, 300},
	Increment = 1,
	CurrentValue = 120,
	Callback = function(Value)
		if Value ~= nil and tonumber(Value) > 0 then
			silentAimMod.RADIUS = tonumber(Value)
			if silentAimMod.FOV then
				silentAimMod.FOV.Radius = tonumber(Value)
			end
		end
	end
}, "INDEX")

-- Silent Aim Fov Color Label + Dropdown
combatFeatures.silentAimFovColorLabel = groupBoxes.combatGroup2:CreateLabel({
	Name = "Fov Color",
}, "INDEX")

combatFeatures.silentAimFovColorPicker = combatFeatures.silentAimFovColorLabel:AddColorPicker({
	CurrentValue = Color3.fromRGB(255, 255, 255),
	Callback = function(Color)
		silentAimMod.FOV_COLOR = Color
		if silentAimMod.FOV then
			silentAimMod.FOV.Color = Color
		end
	end
}, "INDEX")

-- Misc Modifications
local miscMod = {}

-- Kill Aura Essentials
miscMod.enableHook1 = false
miscMod.conn1 = nil

-- Kill Aura Configs
miscMod.RANGE = 10000

-- Target Player Essentials
miscMod.enableHook2 = false
miscMod.conn2 = nil
miscMod.plrName = nil

-- Enable Kill Aura Function
function miscMod:EnableKillAura()
	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	local function getGunId()
		local target = nil
		if getgenv().char and getgenv().root and getgenv().char:FindFirstChildOfClass("Tool") and getgenv().char:FindFirstChildOfClass("Tool"):GetAttribute("Id") then
			target = getgenv().char:FindFirstChildOfClass("Tool"):GetAttribute("Id")
		end
		if not target then
			local bag = player:FindFirstChild("Backpack")
			if bag then
				for _, tool in pairs(bag:GetChildren()) do
					if tool:IsA("Tool") and tool:GetAttribute("Id") then
						target = tool:GetAttribute("Id")
					end
				end
			end
		end
		return target
	end

	local function findTarget()
		local target = nil
		local maxDistance = self.RANGE
		for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local plrChar = plr.Character
				if not (plrChar:FindFirstChild("OnboardingHighlight") or plrChar:FindFirstChild("SafeField")) then
					local distance = (plrChar:FindFirstChild("HumanoidRootPart").Position - getgenv().root.Position).Magnitude
					if distance < maxDistance then
						maxDistance = distance
						target = plr
					end
				end
			end
		end
		return target
	end

	if not getgenv().ServerId and hookmetamethod then
		self.enableHook1 = true

		Starlight:Notification({
			Title = "Server Id Not Found",
			Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
			Content = "Hooking to game, please shoot a gun to get the server id then you can use kill aura",
		}, "INDEX")
		
		repeat
			local old
			old = hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod()
				local args = {...}

				if not checkcaller() and method == "FireServer" and self == FireRemote then
					getgenv().ServerId = args[1]
				end
				return old(self, ...)
			end)

			task.wait(5)
		until getgenv().ServerId or self.enableHook1 == false
	end

	local debounce = false
	local gunId = nil
	self.conn1 = RunService.Heartbeat:Connect(function()
		if debounce then return end
		debounce = true

		if not gunId then
			gunId = getGunId()
		end
		
		local target = findTarget()
		if target and target.Character and target.Character:FindFirstChild("Head") and gunId then
			PositionRemote:FireServer(getgenv().ServerId, gunId, target.Character.Head)
		end

		task.wait(0.5)

		debounce = false
	end)
end

-- Disable Kill Aura Function
function miscMod:DisableKillAura()
	self.enableHook1 = false

	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end
end

-- Enable Target Player Function
function miscMod:EnableTargetPlayer()
	if self.conn2 then
		self.conn2:Disconnect()
		self.conn2 = nil
	end

	if not getgenv().ServerId and hookmetamethod then
		self.enableHook2 = true

		Starlight:Notification({
			Title = "Server Id Not Found",
			Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
			Content = "Hooking to game, please shoot a gun to get the server Id to auto kill targeted player",
		}, "INDEX")
		
		repeat
			local old
			old = hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod()
				local args = {...}

				if not checkcaller() and method == "FireServer" and self == FireRemote then
					getgenv().ServerId = args[1]
				end
				return old(self, ...)
			end)

			task.wait(5)
		until getgenv().ServerId or self.enableHook2 == false
	end

	local function getGunId()
		local target = nil
		if getgenv().char and getgenv().root and getgenv().char:FindFirstChildOfClass("Tool") and getgenv().char:FindFirstChildOfClass("Tool"):GetAttribute("Id") then
			target = getgenv().char:FindFirstChildOfClass("Tool"):GetAttribute("Id")
		end
		if not target then
			local bag = player:FindFirstChild("Backpack")
			if bag then
				for _, tool in pairs(bag:GetChildren()) do
					if tool:IsA("Tool") and tool:GetAttribute("Id") then
						target = tool:GetAttribute("Id")
					end
				end
			end
		end
		return target
	end

	local debounce = false
	local gunId = nil
	self.conn2 = RunService.Heartbeat:Connect(function()
		if debounce then return end
		debounce = true

		if not gunId then
			gunId = getGunId()
		end

		if self.plrName then
			for _, plr in pairs(game:GetService("Players"):GetChildren()) do
				if plr.Name == self.plrName then
					if plr.Character and plr.Character:FindFirstChild("Head") then
						PositionRemote:FireServer(getgenv().ServerId, gunId, plr.Character.Head)
					end
				end
			end
		end

		task.wait(0.5)

		debounce = false
	end)
end

-- Disable Target Player Function
function miscMod:DisableTargetPlayer()
	self.enableHook2 = false

	if self.conn2 then
		self.conn2:Disconnect()
		self.conn2 = nil
	end
end

-- Kill Aura Toggle
combatFeatures.killAuraToggle = groupBoxes.combatGroup3:CreateToggle({
	Name = "Kill Aura",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			miscMod:EnableKillAura()
		else
			miscMod:DisableKillAura()
		end
	end
}, "INDEX")

-- Kill Aura Distance Slider
combatFeatures.killAuraDistanceSlider = groupBoxes.combatGroup3:CreateSlider({
	Name = "Kill Aura Distance",
	Icon = NebulaIcons:GetIcon('scan', 'Lucide'),
	Range = {100, 10000},
	CurrentValue = 10000,
	Increment = 100,
	Callback = function(Value)
		if Value ~= nil and tonumber(Value) > 0 then
			miscMod.RANGE = Value
		end
	end
}, "INDEX")

-- Kill Targeted Player Toggle
combatFeatures.killTargetedPlayerToggle = groupBoxes.combatGroup3:CreateToggle({
	Name = "Kill Targeted Player",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			miscMod:EnableTargetPlayer()
		else
			miscMod:DisableTargetPlayer()
		end
	end
}, "INDEX")

-- Find Target Player Text input
combatFeatures.targetedPlayerTextInput = groupBoxes.combatGroup3:CreateInput({
	Name = "Target Player",
	Icon = NebulaIcons:GetIcon('circle-user', 'Lucide'),
	CurrentValue = "",
	PlaceholderText = "Enter Players Name",
	Enter = true,
	Tooltip = "Players name might not be what it shows, look at the menu for all names on player",
	Callback = function(Text)
		if Text ~= nil and Text ~= "" then
			local foundPlayer = nil
			for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
				if string.lower(player.Name) == string.lower(Text) then
					foundPlayer = player
					break
				end
			end

			if foundPlayer then
				miscMod.plrName = foundPlayer.Name
			else
				Starlight:Notification({
					Title = "Not Found Player",
					Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
					Content = "",
				}, "INDEX")
			end
		end
	end
}, "INDEX")

-- Mods Tab Features
local modsFeatures = {}

-- Gun Modifications
local gunMod = {}

-- Inf Ammo Essentials
gunMod.conn1 = nil
gunMod.charConn = nil
gunMod.gunConnections = {}
gunMod.storedAmmoValue = {}
gunMod.infAmmoEnabled = true

-- Enable Inf Ammo Function
function gunMod:EnableInfAmmo()
	self.infAmmoEnabled = true

	local function applyInfAmmo()
		if self.charConn then
			self.charConn:Disconnect()
			self.charConn = nil
		end

		if self.conn1 then
			self.conn1:Disconnect()
			self.conn1 = nil
		end

		for _, conn in pairs(self.gunConnections) do
			if conn.ammoConn then
				conn.ammoConn:Disconnect()
				conn.ammoConn = nil
			end
			if conn.removeConn then
				conn.removeConn:Disconnect()
				conn.removeConn = nil
			end
		end
		self.gunConnections = {}

		local bag = player:WaitForChild("Backpack")
		local function handleWeapon(tool)
			if tool:IsA("Tool") and tool:GetAttribute("Ammo_Client") ~= nil then
				if not self.storedAmmoValue[tool] then
					self.storedAmmoValue[tool] = tool:GetAttribute("Ammo_Client")
				end
				tool:SetAttribute("Ammo_Client", math.huge)

				local ammoConn = tool:GetAttributeChangedSignal("Ammo_Client"):Connect(function()
					if tool:GetAttribute("Ammo_Client") < 10e9 and self.infAmmoEnabled then
						tool:SetAttribute("Ammo_Client", math.huge)
					elseif not self.infAmmoEnabled then
						if ammoConn then
							ammoConn:Disconnect()
							ammoConn = nil
						end
					end
				end)

				local removeConn = tool.AncestryChanged:Connect(function(_, parent)
					if not parent then
						local conn = self.gunConnections[tool]
						if conn then
							if conn.ammoConn then
								conn.ammoConn:Disconnect()
								conn.ammoConn = nil
							end
							if conn.removeConn then
								conn.removeConn:Disconnect()
								conn.removeConn = nil
							end
							self.gunConnections[tool] = nil
						end
					end
				end)

				self.gunConnections[tool] = {
					ammoConn = ammoConn,
					removeConn = removeConn
				}
			end
		end

		for _, tool in pairs(bag:GetChildren()) do
			if tool:IsA("Tool") and tool:GetAttribute("Ammo_Client") ~= nil then
				handleWeapon(tool)
			end
		end

		for _, tool in pairs(getgenv().char:GetChildren()) do
			if tool:IsA("Tool") and tool:GetAttribute("Ammo_Client") ~= nil then
				handleWeapon(tool)
			end
		end

		self.charConn = getgenv().char.ChildAdded:Connect(handleWeapon)
		self.conn1 = bag.ChildAdded:Connect(handleWeapon)
	end

	applyInfAmmo()

	enabledFeatures["applyInfAmmo"] = applyInfAmmo
end

-- Disable Inf Ammo Function
function gunMod:DisableInfAmmo()
	self.infAmmoEnabled = false

	if enabledFeatures["applyInfAmmo"] then
		enabledFeatures["applyInfAmmo"] = nil
	end

	if self.charConn then
		self.charConn:Disconnect()
		self.charConn = nil
	end

	if self.conn1 then
		self.conn1:Disconnect()
		self.conn1 = nil
	end

	for _, obj in pairs(self.gunConnections) do
		for _, conn in pairs(obj) do
			if conn then
				conn:Disconnect()
			end
		end
	end
	self.gunConnections = {}

	local bag = player:WaitForChild("Backpack")
	if self.storedAmmoValue then
		for _, tool in pairs(bag:GetChildren()) do
			if tool:IsA("Tool") and tool:GetAttribute("Ammo_Client") ~= nil and self.storedAmmoValue[tool] then
				local ammo = self.storedAmmoValue[tool]
				if ammo then
					tool:SetAttribute("Ammo_Client", ammo)
				end
			end
		end

		for _, tool in pairs(getgenv().char:GetChildren()) do
			if tool:IsA("Tool") and tool:GetAttribute("Ammo_Client") ~= nil and self.storedAmmoValue[tool] then
				local ammo = self.storedAmmoValue[tool]
				if ammo then
					tool:SetAttribute("Ammo_Client", ammo)
				end
			end
		end
	end
	self.storedAmmoValue = {}
end

-- Inf Ammo Toggle
modsFeatures.infAmmoToggle = groupBoxes.modsGroup1:CreateToggle({
	Name = "Infinite Ammo",
	Style = 2,
	Callback = function(State)
		if State then
			gunMod:EnableInfAmmo()
		else
			gunMod:DisableInfAmmo()
		end
	end
}, "INDEX")

-- farm Features
local farmFeatures = {}

-- Farm Modifications
local farmMod = {}

-- Job Farm Essentials
farmMod.selectedFarm = ""
farmMod.jobMethod = "Pathfinding"
farmMod.jobEnabled = false
farmMod.jobConn = nil

-- Enable Auto Farm Function
function farmMod:EnableJobFarms()
	local function pathMethod(destination)
		local path = PathfindingService:CreatePath({
			AgentRadius = 1,
			AgentHeight = 5,
			AgentCanJump = false,
		})

		local pathCreated = false

		for i = 1, 5 do
			local success, error = pcall(function()
				path:ComputeAsync(getgenv().root.Position, destination)
			end)

			if success then
				if path.Status == Enum.PathStatus.Success then
					pathCreated = true
					break
				end
			else
				local reason = "Reason ", error
				Starlight:Notification({
					Title = "Path Failed Retrying . . .",
					Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
					Content = reason,
				}, "INDEX")
			end
			task.wait(1)
		end

		if pathCreated then
			local waypoints = path:GetWaypoints()
			if waypoints then
				for i = 1, #waypoints do
					if self.jobEnabled then
						local pos = waypoints[i].Position
						getgenv().hum:MoveTo(pos)
						getgenv().hum.MoveToFinished:Wait()
					else
						break
					end
				end
				return true
			else
				changeSettings:FireServer("Gender", respawnGender)
				task.wait(0.5)
				for i = 1, 5 do
					getgenv().char:PivotTo(CFrame.new(281.6108093261719, 52.33769989013672, -186.5670928955078))
					task.wait(0.1)
				end
				return false
			end
		else
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(281.6108093261719, 52.33769989013672, -186.5670928955078))
				task.wait(0.1)
			end
			return false
		end
	end

	local function tweenMethod(destination)
		local path = PathfindingService:CreatePath({
			AgentRadius = 1,
			AgentHeight = 5,
			AgentCanJump = false,
		})

		local pathCreated = false

		for i = 1, 5 do
			local success, error = pcall(function()
				path:ComputeAsync(getgenv().root.Position, destination)
			end)

			if success then
				if path.Status == Enum.PathStatus.Success then
					pathCreated = true
					break
				end
			else
				local reason = "Reason ", error
				Starlight:Notification({
					Title = "Path Failed Retrying . . .",
					Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
					Content = reason,
				}, "INDEX")
			end
			task.wait(1)
		end

		if pathCreated then
			local waypoints = path:GetWaypoints()
			if waypoints then
				for i = 1, #waypoints, 3 do
					if self.jobEnabled then
						local pos = waypoints[i].Position + Vector3.new(0, 3, 0)
						local offset = pos - getgenv().root.Position
						for _, part in pairs(getgenv().char:GetChildren()) do
							if part:IsA("BasePart") then
								local goal = {CFrame = part.CFrame + offset}
								TweenService:Create(part, TweenInfo.new(0.45, Enum.EasingStyle.Linear), goal):Play()
							end
						end
						task.wait(0.47)
					else
						break
					end
				end
				return true
			else
				changeSettings:FireServer("Gender", respawnGender)
				task.wait(0.5)
				for i = 1, 5 do
					getgenv().char:PivotTo(CFrame.new(281.6108093261719, 52.33769989013672, -186.5670928955078))
					task.wait(0.1)
				end
				return false
			end
		else
			changeSettings:FireServer("Gender", respawnGender)
			task.wait(0.5)
			for i = 1, 5 do
				getgenv().char:PivotTo(CFrame.new(281.6108093261719, 52.33769989013672, -186.5670928955078))
				task.wait(0.1)
			end
			return false
		end
	end

	local function isPlayerNearJob()
		local jobLocation
		if self.selectedFarm == "Cleaning Job" then
			jobLocation = Vector3.new(281.6108093261719, 52.33769989013672, -186.5670928955078)
		else
			return false
		end

		local distance = (getgenv().root.Position - jobLocation).Magnitude
		if distance < 10 then
			return true
		else
			return false
		end
	end

	local function interactForJob()
		local prompt
		pcall(function()
			prompt = workspace.Map.Jobs.CleanNPC.Model.UpperTorso.Interact
		end)

		if not prompt then
			Starlight:Notification({
				Title = "Failed to get npc prompt",
				Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
				Content = "Please open a support ticket via discord if the issue persists",
			}, "INDEX")
			return false
		end

		local bag = player:FindFirstChild("Backpack")
		if bag then
			prompt.MaxActivationDistance = math.huge
			for i = 1, 10 do
				fireproximityprompt(prompt)
				
				task.wait(1)
				if bag:FindFirstChild("Mop") then
					break
				end
				if getgenv().char:FindFirstChild("Mop") then
					break
				end
				task.wait(1)
			end
			prompt.MaxActivationDistance = 7.5
			return true
		else
			Starlight:Notification({
				Title = "Not found player backpack",
				Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
				Content = "Please open a support ticket via discord if the issue persists",
			}, "INDEX")
			return false
		end
	end

	local function getJobRole()
		local jobTool = nil
		if getgenv().char:FindFirstChild("Mop") then
			jobTool = getgenv().char:FindFirstChild("Mop")
		end
		if jobTool then return true end

		if isPlayerNearJob() then
			if interactForJob() then
				return true
			else
				return false
			end
		else
			local pathStatus = false
			if self.jobMethod == "Pathfinding" then
				pathStatus = pathMethod(Vector3.new(281.6108093261719, 52.33769989013672, -186.5670928955078))
			elseif self.jobMethod == "TweenService" then
				pathStatus = tweenMethod(Vector3.new(281.6108093261719, 52.33769989013672, -186.5670928955078))
			end

			if pathStatus and interactForJob() then
				return true
			else
				return false
			end
		end
	end

	local function findCleaningSpot()
		local target = nil
		local maxDistance = math.huge
		local folder = workspace:FindFirstChild("Map"):FindFirstChild("Jobs"):FindFirstChild("CleanNPC"):FindFirstChild("Clean")
		if folder then
			for _, obj in pairs(folder:GetChildren()) do
				for _, prompt in pairs(obj:GetChildren()) do
					if prompt:IsA("ProximityPrompt") and prompt.Enabled == true then
						local distance = (obj.Position - getgenv().root.Position).Magnitude
						if distance < maxDistance then
							maxDistance = distance
							target = prompt
						end
					end
				end
			end
		end
		return target
	end

	local function cleanSpot()
		local target = findCleaningSpot()
		if target and self.jobEnabled then
			local pos = target.Parent.Position
			if pos and self.jobMethod == "Pathfinding" then
				if not pathMethod(pos) then return false end

				for i = 1, 5 do
					if target.Enabled then
						fireproximityprompt(target)
					else
						break
					end
				end

				local counter = 0
				repeat
					counter += 1
					task.wait(0.1)
				until target.Parent.Transparency == 1 or counter > 60

				return true
			elseif pos and self.jobMethod == "TweenService" then
				if not tweenMethod(pos) then return false end

				for i = 1, 5 do
					if target.Enabled then
						fireproximityprompt(target)
					else
						break
					end
				end

				local counter = 0
				repeat
					counter += 1
					task.wait(0.1)
				until target.Parent.Transparency == 1 or counter > 60

				return true
			end
		end
		return false
	end

	local function applyJobFarm()
		if self.jobConn then
			self.jobConn:Disconnect()
			self.jobConn = nil
		end	

		self.jobEnabled = true
		local debounce = false
		if getJobRole() then
			self.jobConn = RunService.Heartbeat:Connect(function()
				if debounce then return end
				debounce = true

				cleanSpot()

				debounce = false
			end)
		end
	end

	applyJobFarm()

	enabledFeatures["applyJobFarm"] = applyJobFarm
end

-- Disable Selected Auto Farm Function
function farmMod:DisableJobFarms()
	self.jobEnabled = false

	if enabledFeatures["applyJobFarm"] then
		enabledFeatures["applyJobFarm"] = nil
	end

	if self.jobConn then
		self.jobConn:Disconnect()
		self.jobConn = nil
	end
end

-- Job Farms Label + Dropdown
farmFeatures.jobFarmLabel = groupBoxes.farmsGroup1:CreateLabel({
	Name = "Job Farm",
}, "INDEX")

farmFeatures.jobFarmDropdown = farmFeatures.jobFarmLabel:AddDropdown({
	Options = {"Cleaning Job"},
	CurrentOptions = {"Cleaning Job"},
	Placeholder = "None Selected",
	Callback = function(Options)
		if Options[1] then
			farmMod.selectedFarm = Options[1]
		end
	end
}, "INDEX")

-- Job Farm Method Label + Dropdown
farmFeatures.jobMethodLabel = groupBoxes.farmsGroup1:CreateLabel({
	Name = "Method"
}, "INDEX")

farmFeatures.jobMethodDropdown = farmFeatures.jobMethodLabel:AddDropdown({
	Options = {"Pathfinding", "TweenService"},
	CurrentOptions = {"Pathfinding"},
	Placeholder = "Pathfinding By Default",
	Callback = function(Options)
		if Options[1] then
			farmMod.jobMethod = Options[1]
		else
			farmMod.jobMethod = "Pathfinding"
		end
	end
}, "INDEX")

-- Job Farm Toggle
farmFeatures.jobFarmToggle = groupBoxes.farmsGroup1:CreateToggle({
	Name = "Start Job",
	CurrentValue = false,
	Style = 2,
	Callback = function(State)
		if State then
			farmMod:EnableJobFarms()
		else
			farmMod:DisableJobFarms()
		end
	end
}, "INDEX")

-- Shop Tab Features
local shopFeatures = {}

-- Armory Modifications
local armoryMod = {}
armoryMod.selectedWeapon = nil
armoryMod.selectedAmmo = nil

-- List of all the purchasable weapons in the game
local weaponList = {}
weaponList["Ruger"] = 800
weaponList["Makarov"] = 1000
weaponList["Glock17"] = 1200
weaponList["Mac"] = 3000
weaponList["Tec-9"] = 3500
weaponList["UMP"] = 4800
weaponList["Shotgun"] = 5000
weaponList["Glock19X"] = 5000
weaponList["AUG"] = 5000
weaponList["Draco"] = 5200
weaponList["GlockSwitch"] = 5400
weaponList["ARPistol"] = 5000
weaponList["HoneyBadger"] = 5500
weaponList["AK-47"] = 6500
weaponList["Vector"] = 7000
weaponList["MP5"] = 7500
weaponList["TSR-15"] = 8000
weaponList["BinaryG17"] = 7000
weaponList["AKS-74U"] = 8500

-- List of all purchasable ammo magazines in the game
local ammoList = {}
ammoList["Pistol Ammo"] = 50
ammoList["Rifle Ammo"] = 100
ammoList["SMG Ammo"] = 100
ammoList["Shotgun Ammo"] = 100

-- Buy Armory Guns Function
function armoryMod:BuyWeapon()
	if self.selectedWeapon ~= nil then
		local gunName = string.match(self.selectedWeapon, "^(.-) %|")
		if weaponList[gunName] then
			local gunPrice = weaponList[gunName]
			if gunName and gunPrice then
				GunBuyEvent:FireServer(gunName, gunPrice)
			else
				Starlight:Notification({
					Title = "Error: Failed to purchase gun",
					Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
					Content = "Please open a support ticket via discord if the issue persists"
				}, "INDEX")
			end
		else
			Starlight:Notification({
				Title = "Error: Failed to purchase gun",
				Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
				Content = "Please open a support ticket via discord if the issue persists"
			}, "INDEX")
		end
	else
		Starlight:Notification({
			Title = "Gun not found",
			Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
			Content = ""
		}, "INDEX")
	end
end

-- Buy Ammo Function
function armoryMod:BuyAmmo()
	if self.selectedAmmo ~= nil then
		local mag = string.match(self.selectedAmmo, "^(.-) %|")
		if ammoList[mag] then
			local magPrice = ammoList[mag]
			if mag and magPrice then
				GunBuyEvent:FireServer(mag, magPrice)
			else
				Starlight:Notification({
					Title = "Error: Failed to purchase ammo",
					Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
					Content = "Please open a support ticket via discord if the issue persists"
				}, "INDEX")
			end
		else
			Starlight:Notification({
				Title = "Error: Failed to purchase ammo",
				Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
				Content = "Please open a support ticket via discord if the issue persists"
			}, "INDEX")
		end
	else
		Starlight:Notification({
			Title = "Magazine not found",
			Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
			Content = ""
		}, "INDEX")
	end
end

-- Weapons Label + Dropdown (Including levels)
shopFeatures.displayWeaponsLabel = groupBoxes.shopGroup1:CreateLabel({
	Name = "Gun | Price | Level",
}, "INDEX")

shopFeatures.displayWeaponsDropdown = shopFeatures.displayWeaponsLabel:AddDropdown({
	Options = {"Ruger | $800 | 0", "Makarov | $1000 | 0", "Glock17 | $1200 | 0", "Mac | $3000 | 3", "Tec-9 | $3500 | 5", "UMP | $4800 | 5", "Shotgun | $5000 | 5", "Glock19X | $5000 | 3", "AUG | $5000 | 5", "Draco | $5200 | 5", "GlockSwitch | $5400 | 5", "ARPistol | $5000 | 5", "HoneyBadger | $5500 | 5", "AK-47 | $6500 | 5", "Vector | $7000 | 5", "MP5 | $7500 | 10", "TSR-15 | $8000 | 10", "BinaryG17 | $7000 | 10", "AKS-74U | $8500 | 15"},
	CurrentOptions = {""},
	Placeholder = "None Selected",
	Callback = function(Options)
		armoryMod.selectedWeapon = Options[1]
	end
}, "INDEX")

-- Buy Weapon Toggle
shopFeatures.buySelectedWeaponToggle = groupBoxes.shopGroup1:CreateButton({
	Name = "Buy Weapon",
	Icon = NebulaIcons:GetIcon('credit-card', 'Lucide'),
	Callback = function()
		armoryMod:BuyWeapon()
	end
}, "INDEX")

-- Ammo Mags Label + Dropdown
shopFeatures.displayAmmoLabel = groupBoxes.shopGroup1:CreateLabel({
	Name = "Ammo / Mag | Price",
}, "INDEX")

shopFeatures.displayAmmoDropdown = shopFeatures.displayAmmoLabel:AddDropdown({
	Options = {"Pistol Ammo | $50", "Rifle Ammo | $100", "SMG Ammo | $100", "Shotgun Ammo | $100"},
	CurrentOptions = {""},
	Placeholder = "None Selected",
	Callback = function(Options)
		armoryMod.selectedAmmo = Options[1]
	end
}, "INDEX")

-- Buy Ammo Mag Button
shopFeatures.buySelectedAmmoButton = groupBoxes.shopGroup1:CreateButton({
	Name = "Buy Mag",
	Icon = NebulaIcons:GetIcon('credit-card', 'Lucide'),
	Callback = function()
		armoryMod:BuyAmmo()
	end
}, "INDEX")

-- Purchase Mentos Bag Button
shopFeatures.mentosBagButton = groupBoxes.shopGroup2:CreateButton({
	Name = "Purchase Mentos Bag | $300",
	Icon = NebulaIcons:GetIcon('shopping-bag', 'Lucide'),
	Callback = function()
		BuyEvent:FireServer("MentosBag", 300)
	end
}, "INDEX")

-- Purchase C4 Button
shopFeatures.purchaseC4Button = groupBoxes.shopGroup2:CreateButton({
	Name = "Purchase C4 | $2000",
	Icon = NebulaIcons:GetIcon('bomb', 'Lucide'),
	Callback = function()
		BuyEvent:FireServer("C4", 2000)
	end
}, "INDEX")

-- Purchase Bat Button
shopFeatures.purchaseBatButton = groupBoxes.shopGroup2:CreateButton({
	Name = "Purchase Bat | $750",
	Icon = NebulaIcons:GetIcon('slash', "Lucide"),
	Callback = function()
		BuyEvent:FireServer("Bat", 750)
	end
}, "INDEX")

-- Purchase Credit Card
shopFeatures.purchaseCreditCardButton = groupBoxes.shopGroup2:CreateButton({
	Name = "Purchase Credit Card | $1000 (GAMEPASS)",
	Icon = NebulaIcons:GetIcon('credit-card', 'Lucide'),
	Callback = function()
		BuyEvent:FireServer("Blank", 1000)
	end
}, "INDEX")

-- Purchase Knife
shopFeatures.purchaseKnifeButton = groupBoxes.shopGroup2:CreateButton({
	Name = "Purcahse Knife | $500",
	Icon = NebulaIcons:GetIcon('pocket-knife', 'Lucide'),
	Callback = function()
		BuyEvent:FireServer("Knife", 500)
	end
}, "INDEX")

-- Purchase Duffle Bag
shopFeatures.purcahseDuffleBagButton = groupBoxes.shopGroup2:CreateButton({
	Name = "Purchase Duffle Bag | $500",
	Icon = NebulaIcons:GetIcon('backpack', "Lucide"),
	Callback = function()
		BuyEvent:FireServer('DuffleBag', 500)
	end
}, "INDEX")

-- Masks Ui's Modifications
local maskMod = {}
maskMod.selectedMask = nil

-- All the purchasable masks in the game
local maskList = {}
maskList["SkiMask"] = 50
maskList["Bandana"] = 50
maskList["HackerMask"] = 75
maskList["RedSki"] = 75
maskList["BlueSki"] = 75
maskList["Balaclava"] = 50
maskList["ClownMask"] = 75
maskList["GhostFace"] = 100
maskList["JasonMask"] = 100

-- Purchase Mask Function
function maskMod:PurchaseMask()
	if self.selectedMask then
		local maskName = string.match(self.selectedMask, "^(.-) %|")
		if maskName then
			local maskPrice = maskList[maskName]
			if maskName and maskPrice then
				BuyEvent:FireServer(maskName, maskPrice)
			else
				Starlight:Notification({
					Title = "Error Not Found Mask Price",
					Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
					Content = "If the issue persists open a support ticket via discord",
				}, "INDEX")
			end
		else
			Starlight:Notification({
				Title = "Error Not Found Mask",
				Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
				Content = "If the issue persists open a support ticket via discord",
			}, "INDEX")
		end
	else
		Starlight:Notification({
			Title = "Error Not Found Mask",
			Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
			Content = "If the issue persists open a support ticket via discord",
		}, "INDEX")
	end
end

-- Mask Ui's Label + Dropdown
shopFeatures.purchaseMaskLabel = groupBoxes.shopGroup3:CreateLabel({
	Name = "Masks | Price",
}, "INDEX")

shopFeatures.purchaseMaskDropdown = shopFeatures.purchaseMaskLabel:AddDropdown({
	Options = {"SkiMask | $50", "Bandana | $50", "HackerMask | $75", "RedSki | $75", "BlueSki | $75", "Balaclava | $50", "ClownMask | $75", "GhostFace | $100", "JasonMask | $100"},
	CurrentOptions = {""},
	Placeholder = "None Selected",
	Callback = function(Options)
		maskMod.selectedMask = Options[1]
	end	
}, "INDEX")

-- Purchase Mask Button
shopFeatures.purchaseMaskButton = groupBoxes.shopGroup3:CreateButton({
	Name = "Purchase Mask",
	Icon = NebulaIcons:GetIcon('hat-glasses', 'Lucide'),
	Callback = function()
		maskMod:PurchaseMask()
	end
}, "INDEX")

-- Thiece Ui Modification
local iceClubMod = {}
iceClubMod.selectedItem = nil

-- Thiece Ui / Ice Club Item List
local iceClubList = {}
iceClubList["Taco"] = 50
iceClubList["Water"] = 50
iceClubList["Pizza"] = 50
iceClubList["Dice"] = 50
iceClubList["MoneyGun"] = 2500

-- Purcahse Item From Thiece Ui / Ice Club List Function
function iceClubMod:PurchaseItem()
	if self.selectedItem ~= nil then
		local itemName = string.match(self.selectedItem, "^(.-) %|")
		if iceClubList[itemName] then
			local itemPrice = iceClubList[itemName]
			if itemName and itemPrice then
				BuyEvent:FireServer(itemName, itemPrice)
			else
				Starlight:Notification({
					Title = "Error Not Found Item Price",
					Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
					Content = "If the issue persists open a support ticket via discord",
				}, "INDEX")
			end
		else
			Starlight:Notification({
				Title = "Error Not Found Item",
				Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
				Content = "If the issue persists open a support ticket via discord",
			}, "INDEX")
		end
	else
		Starlight:Notification({
			Title = "Error Not Item",
			Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
			Content = "If the issue persists open a support ticket via discord",
		}, "INDEX")
	end
end

-- Ice Club Item Label + Dropdown
shopFeatures.iceClubItemLabel = groupBoxes.shopGroup3:CreateLabel({
	Name = "Item | Price"
}, "INDEX")

shopFeatures.iceClubItemDropdown = shopFeatures.iceClubItemLabel:AddDropdown({
	Options = {"Taco | $50", "Water | $50", "Pizza | $50", "Dice | $50", "MoneyGun | $2500"},
	CurrentOptions = {""},
	Placeholder = "None Selected",
	Callback = function(Options)
		iceClubMod.selectedItem = Options[1]
	end
}, "INDEX")

-- Purchase Ice Club Item
shopFeatures.prucahseIceClubItem = groupBoxes.shopGroup3:CreateButton({
	Name = "Purchase Item",
	Icon = NebulaIcons:GetIcon('credit-card', 'Lucide'),
	Callback = function()
		iceClubMod:PurchaseItem()
	end
}, "INDEX")

-- Purchase Black Market Guns Buttons
shopFeatures.bmGun1 = groupBoxes.shopGroup4:CreateButton({
	Name = "P320 | $3000",
	Icon = NebulaIcons:GetIcon('siren', 'Lucide'),
	Callback = function()
		BlackMarketBuyEvent:FireServer("P320", 3000)
	end
}, "INDEX")

shopFeatures.bmGun2 = groupBoxes.shopGroup4:CreateButton({
	Name = "M1911S | $3500",
	Icon = NebulaIcons:GetIcon('siren', 'Lucide'),
	Callback = function()
		BlackMarketBuyEvent:FireServer("M1911S", 3500)
	end
}, "INDEX")

shopFeatures.bmGun3 = groupBoxes.shopGroup4:CreateButton({
	Name = "G40EXT | $5000",
	Icon = NebulaIcons:GetIcon('siren', 'Lucide'),
	Callback = function()
		BlackMarketBuyEvent:FireServer("G40EXT", 5000)
	end
}, "INDEX")

shopFeatures.bmGun4 = groupBoxes.shopGroup4:CreateButton({
	Name = "G22Drum | $5000",
	Icon = NebulaIcons:GetIcon('siren', 'Lucide'),
	Callback = function()
		BlackMarketBuyEvent:FireServer("G22Drum", 5000)
	end
}, "INDEX")

shopFeatures.bmGun5 = groupBoxes.shopGroup4:CreateButton({
	Name = "Kiparis | $6000",
	Icon = NebulaIcons:GetIcon('siren', 'Lucide'),
	Callback = function()
		BlackMarketBuyEvent:FireServer("Kiparis", 6000)
	end
}, "INDEX")

shopFeatures.bmGun6 = groupBoxes.shopGroup4:CreateButton({
	Name = "Mac-Drum | $6500",
	Icon = NebulaIcons:GetIcon('siren', 'Lucide'),
	Callback = function()
		BlackMarketBuyEvent:FireServer("Mac-Drum", 6500)
	end
}, "INDEX")

shopFeatures.bmGun7 = groupBoxes.shopGroup4:CreateButton({
	Name = "Draco-Drum | $7500",
	Icon = NebulaIcons:GetIcon('siren', 'Lucide'),
	Callback = function()
		BlackMarketBuyEvent("Draco-Drum", 7500)
	end
}, "INDEX")

shopFeatures.bmGun8 = groupBoxes.shopGroup4:CreateButton({
	Name = "BinaryDraco | $8000",
	Icon = NebulaIcons:GetIcon('siren', 'Lucide'),
	Callback = function()
		BlackMarketBuyEvent('BinaryDraco', 8000)
	end
}, "INDEX")

shopFeatures.bmGun9 = groupBoxes.shopGroup4:CreateButton({
	Name = "CombatPDW | $9000",
	Icon = NebulaIcons:GetIcon('siren', 'Lucide'),
	Callback = function()
		BlackMarketBuyEvent:FireServer("CombatPDW", 9000)
	end
}, "INDEX")

shopFeatures.bmGun10 = groupBoxes.shopGroup4:CreateButton({
	Name = "ARPSwitch | $12000",
	Icon = NebulaIcons:GetIcon('siren', 'Lucide'),
	Callback = function()
		BlackMarketBuyEvent:FireServer("ARPSwitch", 12000)
	end
}, "INDEX")

shopFeatures.bmGun11 = groupBoxes.shopGroup4:CreateButton({
	Name = "FN 5.7 | $6500",
	Icon = NebulaIcons:GetIcon('siren', 'Lucide'),
	Callback = function()
		BlackMarketBuyEvent:FireServer("FN 5.7", 6500)
	end
}, "INDEX")

-- Listening For Players That Have Left The Game
getgenv().playerLeavingConnection = players.PlayerRemoving:Connect(function(oldPlr)
	-- Removing Player Esp Drawings
	local uid = oldPlr.UserId
	if playerEspMod.nameDrawings[uid] then
		playerEspMod.nameDrawings[uid]:Remove()
		playerEspMod.nameDrawings[uid] = nil
	end

	if playerEspMod.boxDrawings[uid] then
		playerEspMod.boxDrawings[uid]:Remove()
		playerEspMod.boxDrawings[uid] = nil
	end

	if playerEspMod.healthDrawings[uid] then
		playerEspMod.healthDrawings[uid]:Remove()
		playerEspMod.healthDrawings[uid] = nil
	end

	if playerEspMod.distanceDrawings[uid] then
		playerEspMod.distanceDrawings[uid]:Remove()
		playerEspMod.distanceDrawings[uid] = nil
	end

	if playerEspMod.skeletonDrawings[uid] then
		for _, line in pairs(playerEspMod.skeletonDrawings[uid]) do
			if line then
				line:Remove()
			end
		end
		playerEspMod.skeletonDrawings[uid] = nil
	end

	if playerEspMod.tracersDrawings[uid] then
		playerEspMod.tracersDrawings[uid]:Remove()
		playerEspMod.tracersDrawings[uid] = nil
	end

	if playerEspMod.weaponDrawings[uid] then
		playerEspMod.weaponDrawings[uid]:Remove()
		playerEspMod.weaponDrawings[uid] = nil
	end

	-- Removing Player From Silent Aim Whitelist Raycast
	local oldChar = oldPlr.Character
	if oldChar then
		for i = #silentAimMod.whitelist, 1, -1 do
			if silentAimMod.whitelist[i] == oldChar then
				table.remove(silentAimMod.whitelist, i)
			end
		end
	end

	if silentAimMod.newPlayerConnections[oldPlr] then
		silentAimMod.newPlayerConnections[oldPlr]:Disconnect()
	end
end)

-- Reapplying features upon player respawn
getgenv().mainConnection = player.CharacterAdded:Connect(function(newChar)
	-- Freesing Respawn Mod from updating if turned on
	respawnMod.teleporting = true

	-- Grabbing the new character + Parts
	getgenv().char = newChar
	getgenv().hum = getgenv().char:WaitForChild("Humanoid")
	getgenv().root = getgenv().char:WaitForChild("HumanoidRootPart")

	-- Applying player respawn to the last location if respawn mod enabled
	if respawnMod.ENABLED and respawnMod.currentPosition then
		repeat newChar:PivotTo(CFrame.new(respawnMod.currentPosition)) task.wait(0.1) until (respawnMod.currentPosition - getgenv().char:GetPivot().Position).Magnitude < 10
		respawnMod.teleporting = false
	end

	-- ReApplying all the previous functions after death that are still turned on
	if getgenv().char and getgenv().hum and getgenv().root then
		for index, func in pairs(enabledFeatures) do
			func()
		end
	else
		Starlight:Notification({
			Title = "Error: Failed to load features after respawn",
			Icon = NebulaIcons:GetIcon('triangle-alert', 'Lucide'),
			Content = "If the issue persists, Please open a support ticket via discord",
		}, "INDEX")
	end

	-- Resuming Mod update loop if enabled
	respawnMod.teleporting = false
end)

-- Disconnect all the connections when unloading the script
local function disconnectConnections(table)
	for index, conn in pairs(table) do
		if typeof(conn) == "RBXScriptConnection" then
			if conn.Connected then
				conn:Disconnect()
			end
			table[index] = nil
		end
	end
end

Starlight:OnDestroy(function()
	keepUpdatingLicense = false

	-- Disabling Character Respawn Listener
	if getgenv().mainConnection then
		getgenv().mainConnection:Disconnect()
	end

	-- Disabling New Player Listener
	if getgenv().playerJoinningConnection then
		getgenv().playerJoinningConnection:Disconnect()
	end

	-- Disabling Player Leaving Listener
	if getgenv().playerLeavingConnection then
		getgenv().playerLeavingConnection:Disconnect()
	end

	-- Disabling Speed Mod
	disconnectConnections(speedMod)
	speedMod:DisableSpeedBoost()

	-- Disabling Jump Mod
	disconnectConnections(jumpMod)
	jumpMod:DisableJumpBoost()

	-- Disabling Infinite Jump Mod
	disconnectConnections(infJumpMod)
	infJumpMod:DisableInfJump()
	
	-- Disabling Stamina Mod
	disconnectConnections(staminaMod)
	staminaMod:DisableInfStamina()

	-- Disabling Inf Boost Mod
	disconnectConnections(boostMod)
	boostMod:DisableInfBoost()

	-- Disabling Chams Modifications
	disconnectConnections(chamsMod)
	chamsMod:DisableChams()

	-- Disabling Fly Modifications
	disconnectConnections(flyMod)
	disconnectConnections(mobileFlyMod)
	flyMod:DisableFly()
	mobileFlyMod:DisableFly()

	-- Disabling Combat Log Modification
	disconnectConnections(combatLogMod)
	combatLogMod:Restore()

	-- Restoring Critical Handler Scripts State
	criticalHandler.Enabled = true

	-- Disabling Instant Respawn
	disconnectConnections(instantRespawnMod)
	instantRespawnMod:DisableInstantRespawn()
	instantRespawnMod:DisableHealthInstantRespawn()

	-- Disabling Free Cam
	if freeCamConnections.stopFreeCam and freeCamConnections.ENABLED then
		freeCamConnections.stopFreeCam()
	end
	disconnectConnections(freeCamConnections)
	RunService:UnbindFromRenderStep("Freecam")
	ContextActionService:UnbindAction("FreecamKeyboard")
	ContextActionService:UnbindAction("FreecamMousePan")
	ContextActionService:UnbindAction("FreecamMouseWheel")
	ContextActionService:UnbindAction("FreecamGamepadButton")
	ContextActionService:UnbindAction("FreecamGamepadTrigger")
	ContextActionService:UnbindAction("FreecamGamepadThumbstick")
	ContextActionService:UnbindAction("FreecamToggle")

	-- Disabling Spectate Player Mod
	disconnectConnections(spectatePlayerMod)
	spectatePlayerMod:Disable()

	-- Disabling Spam Text Connection
	disconnectConnections(spamTextMod)
	spamTextMod:Disable()

	-- Disabling Last Respawn Location
	disconnectConnections(respawnMod)
	respawnMod:Disable()

	-- Disabling Esp
	disconnectConnections(playerEspMod)
	playerEspMod:DisableEsp()

	-- Disabling General Esp
	disconnectConnections(generalEspMod)
	generalEspMod:DisableOwnedCarEsp()
	generalEspMod:DisableCarsEsp()
	generalEspMod:DisableScooterEsp()
	generalEspMod:DisableRobCarEsp()
	generalEspMod:DisableTrashEsp()

	-- Disabling Aim Assist
	disconnectConnections(aimAssistMod)
	aimAssistMod:DisableAimAssist()

	-- Disabling Silent Aim
	disconnectConnections(silentAimMod)
	silentAimMod:Disable()
	silentAimMod.enabled = false
	silentAimMod.direction = nil

	-- Disabling Misc Modifications
	disconnectConnections(miscMod)
	miscMod:DisableKillAura()
	miscMod:DisableTargetPlayer()

	-- Disabling Gun Mods
	disconnectConnections(gunMod)
	gunMod:DisableInfAmmo()

	-- Disabling Farm Modifications
	disconnectConnections(farmMod)
	farmMod:DisableJobFarms()

	-- Clearing Features Table
	enabledFeatures = nil
end)

-- Preventing the player from getting kick / anti-afk
if not getgenv().idleBlocked then
	getgenv().idleBlocked = true

	local virtualUser = game:GetService("VirtualUser")
	player.Idled:Connect(function()
		virtualUser:CaptureController()
		virtualUser:ClickButton2(Vector2.new())
	end)
end

-- Creating Configs Tab + Auto Load
--tabs.settingsTab:BuildConfigGroupbox(2)

--Starlight:LoadAutoloadConfig()
