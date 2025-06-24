-- To bypass my key system simply set IsKeyValid to true like such (IsKeyValid = true)
-- Below is adonis anti cheat bypass wanna say huge thanks to the developer Zins who Published this on scriptblox hes the man

local g = getinfo or debug.getinfo
local d = false
local h = {}

local x, y

setthreadidentity(2)

for i, v in getgc(true) do
    if typeof(v) == "table" then
        local a = rawget(v, "Detected")
        local b = rawget(v, "Kill")
    
        if typeof(a) == "function" and not x then
            x = a
            
            local o; o = hookfunction(x, function(c, f, n)
                if c ~= "_" then
                    if d then
                        warn(`Adonis AntiCheat flagged\nMethod: {c}\nInfo: {f}`)
                    end
                end
                
                return true
            end)

            table.insert(h, x)
        end

        if rawget(v, "Variables") and rawget(v, "Process") and typeof(b) == "function" and not y then
            y = b
            local o; o = hookfunction(y, function(f)
                if d then
                    warn(`Adonis AntiCheat tried to kill (fallback): {f}`)
                end
            end)

            table.insert(h, y)
        end
    end
end

local o; o = hookfunction(getrenv().debug.info, newcclosure(function(...)
    local a, f = ...

    if x and a == x then
        if d then
            warn(`zins | adonis bypassed`)
        end

        return coroutine.yield(coroutine.running())
    end
    
    return o(...)
end))

setthreadidentity(7)

local ServerId = nil
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" and tostring(self) == "Fire" then
        ServerId = args[1]
        return old(self, ...)
    end
    return old(self, ...)
end)

local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/maxcomuk/Vortex-Hub/main/LunaUi.lua", true))()

local Window = Luna:CreateWindow({
	Name = "Street Life Remasterd - Vortex Hub V2.1",
	Subtitle = nil,
	LogoID = nil,
	LoadingTitle = "Vortex Hub Loading",
	LoadingSubtitle = "Enjoy your exploiting session",
})

-- Key System Configs
local HttpService = game:GetService("HttpService")
local IsKeyValid = false

-- Key File
local KeyFile = "Street_Life_Remasterd_Key.txt"
local ValidateKeyUrl = "https://work.ink/_api/v2/token/isValid/"

-- Load Saved Key
local function LoadSavedKey()
	if isfile and readfile and isfile(KeyFile) then
		return readfile(KeyFile)
	end
end

-- Save Key
local function SaveKey(key)
	if writefile then
		writefile(KeyFile, key)
	end
end

-- Validate Key
local function ValidateKey(key)
	local Success, Response = pcall(function()
		return (
			game:HttpGet(ValidateKeyUrl .. HttpService:UrlEncode(key))
		)
	end)
	if Success then
		local Data = HttpService:JSONDecode(Response)
		if Data.valid then
			return true
		end
	else
		return false
	end
end

-- Key System
local KeySystem = Window:CreateTab({
	Name = "Key System",
	Icon = "security",
	ImageSource = "Material",
	ShowTitle = true
})

-- Key Section
local KeySection = KeySystem:CreateSection("If You Cant Copy The Link To ClipBoard Contact Me Via Discord")

-- Get Key Link
local GetKeyLink = KeySystem:CreateButton({
	Name = "Copy Key Link To ClipBoard",
	Description = nil,
	Callback = function()
		if setclipboard then
			setclipboard("https://workink.net/1ZQb/hrvpte1t")

			Luna:Notification({
				Title = "Key Link Copied To ClipBoard",
				Icon = "notifications_active",
				ImageSource = "Material",
				Content = ""
			})
		else
			Luna:Notification({
				Title = "Unable To Copy Key Link To ClipBoard",
				Icon = "notifications_active",
				ImageSource = "Material",
				Content = "Your Executor Does Not Support This Feature Contact Me Via Discord",
			})
		end	
	end
})

-- Key Input
local KeyInput = KeySystem:CreateInput({
	Name = "Input Key Link Here",
	Description = nil,
	PlaceholderText = "",
	CurrentValue = "", 
	Numeric = false,
	MaxCharacters = nil,
	Enter = true,
    	Callback = function(Text)
			local Key = Text

			Luna:Notification({
				Title = "Validating Key Please Wait ...",
				Icon = "notifications_active",
				ImageSource = "Material",
				Content = ""
			})

			if ValidateKey(Key) then
				Luna:Notification({
					Title = "Key Valid",
					Icon = "check_circle",
					ImageSource = "Material",
					Content = "Loading Exploits",
				})
				IsKeyValid = true

				SaveKey(Key)
			else
				Luna:Notification({
					Title ="Key Invalid",
					Icon = "dangerous",
					ImageSource = "Material",
					Content = "Please Check That Your Key Is Valid",
				})
				IsKeyValid = false
			end
    	end
}, "KeyInput")

local DiscordLink = KeySystem:CreateSection("Discord Link - https://discord.gg/VS7QcNmmp6")

local SavedKey = LoadSavedKey()
if SavedKey and ValidateKey(SavedKey) then
	Luna:Notification({
		Title = "Saved Key Loaded",
		Icon = "check_circle",
		ImageSource = "Material",
		Content = ""
	})
	IsKeyValid = true
end

repeat
	task.wait()
until IsKeyValid
-----------------------------------------------------------------------------------------------
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local camera = workspace.CurrentCamera

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Uis = game:GetService("UserInputService")

local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "dashboard",
    ImageSource = "Material",
    ShowTitle = true
})

local MainTabLocalPlayerSection = MainTab:CreateSection("Local Player")

local FasterWalkState = false
local FasterWalkConnection
local FasterWalkConnection1
local FasterWalkState = MainTab:CreateToggle({
    Name = "Faster Walk",
    Description = nil,
    CurrentValue = false,
    Callback = function(state)
        FasterWalkState = state

        if FasterWalkConnection then
            FasterWalkConnection:Disconnect()
            FasterWalkConnection = nil
        end
        if FasterWalkConnection1 then
            FasterWalkConnection1:Disconnect()
            FasterWalkConnection1 = nil
        end

        local Char = Player.Character or Player.CharacterAdded:Wait()
        local Hum = Char:WaitForChild("Humanoid")

        local function ApplySpeed(Humanoid)
            if FasterWalkConnection then
                FasterWalkConnection:Disconnect()
                FasterWalkConnection = nil
            end

            Humanoid.WalkSpeed = 25
            FasterWalkConnection = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if Humanoid.WalkSpeed ~= 25 then
                    Humanoid.WalkSpeed = 25
                end
            end)
        end

        if FasterWalkState then
            ApplySpeed(Hum)
            FasterWalkConnection1 = Player.CharacterAdded:Connect(function(NewChar)
                local Humanoid = NewChar:WaitForChild("Humanoid")
                ApplySpeed(Humanoid)
            end)
        else
            if FasterWalkConnection then
                FasterWalkConnection:Disconnect()
                FasterWalkConnection = nil
            end
            if FasterWalkConnection1 then
                FasterWalkConnection1:Disconnect()
                FasterWalkConnection1 = nil
            end
            Hum.WalkSpeed = 25
        end
    end
})

local EnableJumpState = false
local JumpConnection
local EnableJump = MainTab:CreateToggle({
    Name = "Enable Jump",
    Description = "Allows you to jump",
    CurrentValue = false,
    Callback = function(state)
        EnableJumpState = state

        local Char = Player.Character or Player.CharacterAdded:Wait()
        local Hum = Char:WaitForChild("Humanoid")

        local function ApplyJump(Humanoid)
            Humanoid.JumpPower = 50
        end

        if EnableJumpState then
            ApplyJump(Hum)
            JumpConnection = Player.CharacterAdded:Connect(function(NewChar)
                local Humanoid = NewChar:WaitForChild("Humanoid")
                ApplyJump(Humanoid)
            end)
        else
            if JumpConnection then
                JumpConnection:Disconnect()
                JumpConnection = nil
            end
            Hum.JumpPower = 0
        end
    end
})

local InfStaminaState = false
local StaminaConnection
local StaminaConnection1
local InfStamina = MainTab:CreateToggle({
	Name = "Inf Stamina",
	Description = nil,
	CurrentValue = false,
	Callback = function(state)
		InfStaminaState = state

		if StaminaConnection then
			StaminaConnection:Disconnect()
			StaminaConnection = nil
		end

		if StaminaConnection1 then
			StaminaConnection1:Disconnect()
			StaminaConnection1 = nil
		end

		local Char = Player.Character or Player.CharacterAdded:Wait()

		local function FreezeStam(Character)
			if StaminaConnection then
				StaminaConnection:Disconnect()
				StaminaConnection = nil
			end

			Character:SetAttribute("Stamina", 100)

			if Character:GetAttribute("Stamina") then
				Character:SetAttribute("Stamina", 100)
				StaminaConnection = Character:GetAttributeChangedSignal("Stamina"):Connect(function()
					Character:SetAttribute("Stamina", 100)
				end)
			end
		end

		if InfStaminaState then
			FreezeStam(Char)
			StaminaConnection1 = Player.CharacterAdded:Connect(function(NewChar)
				NewChar:WaitForChild("Humanoid")
				FreezeStam(NewChar)
			end)
		else
			if StaminaConnection then
				StaminaConnection:Disconnect()
				StaminaConnection = nil
			end
			if StaminaConnection1 then
				StaminaConnection1:Disconnect()
				StaminaConnection1 = nil
			end
		end
	end
})

local MainTabDisableSection = MainTab:CreateSection("Player Settings")

local PromptTimerConnection
local DisablePromptTimer = MainTab:CreateButton({
	Name = "Disable E Prompt Time",
	Description = "Removes the hold timer for ProximityPrompts (NPCs, doors, etc.)",
	Callback = function()
		if PromptTimerConnection then
			PromptTimerConnection:Disconnect()
			PromptTimerConnection = nil
		end

		for _, child in pairs(workspace:GetDescendants()) do
			if child:IsA("ProximityPrompt") then
				child.HoldDuration = 0
			end
		end


		PromptTimerConnection = workspace.DescendantAdded:Connect(function(descendant)
			if descendant:IsA("ProximityPrompt") then
				descendant.HoldDuration = 0
			end
		end)
	end
})

local CompleteTutorial = MainTab:CreateButton({
	Name = "Complete Tutorial",
	Description = "Auto Completes Tutorial",
	CurrentValue = false,
	Callback = function()
		game.ReplicatedStorage.Remotes.Notify:FireServer("You Completed The Tutorial!", 5)
		game.ReplicatedStorage.Remotes.ControllerRemote:FireServer("CompletedTutorial")
	end
})

local RemoveCriticalState = MainTab:CreateButton({
	Name = "Remove Critical State",
	Description = "Completly Deletes The Critical State",
	Callback = function()
		local Critical = Player:FindFirstChild("PlayerScripts"):FindFirstChild("CriticalHandler")
		if Critical then
			Critical:Destroy()
		end
	end
})

local RagdollConnection
local RemoveRagdollState = MainTab:CreateButton({
	Name = "Remove Ragdoll State",
	Description = "Completly Deletes The Ragdoll State",
	Callback = function()
		if RagdollConnection then
			RagdollConnection:Disconnect()
			RagdollConnection = nil
		end

		local Char = Player.Character or Player.CharacterAdded:Wait()
		
		local function Destroy(Char)
			local Ragdoll = Char:FindFirstChild("Ragdoll")
			if Ragdoll then
				Ragdoll:Destroy()
			end
		end

		Destroy(Char)
		RagdollConnection = Player.CharacterAdded:Connect(function(NewChar)
			NewChar:WaitForChild("Ragdoll")
			Destroy(NewChar)
		end)
	end
})

local GunBuyEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GunBuy")
local GunShop = Window:CreateTab({
	Name = "Gun Shop",
	Icon = "shopping_cart",
	ImageSource = "Material",
	ShowTitle = true
})

local GunShopSection1 = GunShop:CreateSection("Light Weapons")

local Ruger = GunShop:CreateButton({
	Name = "Ruger | Price 800",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("Ruger", 800)
	end
})

local Makarov = GunShop:CreateButton({
	Name = "Makarov | Price 1000",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("Makarov", 1000)
	end
})

local Glock17 = GunShop:CreateButton({
	Name = "Glock17 | Price 1200",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("Glock17", 1200)
	end
})

local Mac = GunShop:CreateButton({
	Name = "Mac | Price 3000",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("Mac", 3000)
	end
})

local Tec9 = GunShop:CreateButton({
	Name = "Tec-9 | Price 3500",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("Tec-9", 3500)
	end
})

local UMP = GunShop:CreateButton({
	Name = "UMP | Price 4800",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("UMP", 4800)
	end
})

local GunShopSection2 = GunShop:CreateSection("Medium Weapons")

local Shotgun = GunShop:CreateButton({
	Name = "Shotgun | Price 5000",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("Shotgun", 5000)
	end
})

local Glock19X = GunShop:CreateButton({
	Name = "Glock19X | Price 5000",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("Glock19X", 5000)
	end
})

local AUG = GunShop:CreateButton({
	Name = "AUG | Price 5000",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("AUG", 5000)
	end
})

local Draco = GunShop:CreateButton({
	Name = "Draco | Price 5200",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("Draco", 5200)
	end
})

local GlockSwitch = GunShop:CreateButton({
	Name = "GlockSwitch | Price 5400",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("GlockSwitch", 5400)
	end
})

local GunShopSection3 = GunShop:CreateSection("Heavy Weapons")

local ARPistol = GunShop:CreateButton({
	Name = "ARPistol | Price 5000",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("ARPistol", 5000)
	end
})

local HoneyBadger = GunShop:CreateButton({
	Name = "HoneyBadger | Price 5500",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("HoneyBadger", 5500)
	end
})

local AK47 = GunShop:CreateButton({
	Name = "AK-47 | Price 6500",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("AK-47", 6500)
	end
})

local Vector = GunShop:CreateButton({
	Name = "Vector | Price 7000",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("Vector", 7000)
	end
})

local MP5 = GunShop:CreateButton({
	Name = "MP5 | Price 7500",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("MP5", 7500)
	end
})

local TSR15 = GunShop:CreateButton({
	Name = "TSR-15 | Price 8000",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("TSR-15", 8000)
	end
})

local BinaryG17 = GunShop:CreateButton({
	Name = "BinaryG17 | Price 7000",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("BinaryG17", 7000)
	end
})

local AmmoShop = Window:CreateTab({
	Name = "Ammo Shop",
	Icon = "shopping_cart",
	ImageSource = "Material",
	ShowTitle = true
})

local PistolAmmo = AmmoShop:CreateButton({
	Name = "Pistol Ammo | Price 50",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("Pistol Ammo", 50)
	end
})

local RifleAmmo = AmmoShop:CreateButton({
	Name = "Rifle Ammo | Price 100",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("Rifle Ammo", 100)
	end
})

local SmgAmmo = AmmoShop:CreateButton({
	Name = "SMG Ammo | Price 100",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("SMG Ammo", 100)
	end
})

local ShotGunAmmo = AmmoShop:CreateButton({
	Name = "ShotGun Ammo | Price 100",
	Description = nil,
	Callback = function()
		GunBuyEvent:FireServer("Shotgun Ammo", 100)
	end
})

local CombatTab = Window:CreateTab({
	Name = "Combat",
	Icon = "gps_fixed",
	ImageSource = "Material",
	ShowTitle = true
})

local EspState
local EspConnection
local EspCharacterConnections = {}
local Esp = CombatTab:CreateToggle({
	Name = "Esp",
	Description = "Highlights All The Enemies",
	CurrentValue = false,
	Callback = function(state)
		EspState = state
		
		local PoliceTeam = game:GetService("Teams"):FindFirstChild("Police")

		local function CreateEnemyEsp(Character)
			if Character and not Character:FindFirstChild("PlayerHighlight") then
				local Highlight = Instance.new("Highlight")
				Highlight.Name = "PlayerHighlight"
				Highlight.FillColor = Color3.fromRGB(255, 255, 153)
				Highlight.OutlineColor = Color3.fromRGB(255, 255, 153)
				Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				Highlight.Parent = Character

				Highlight.AncestryChanged:Connect(function(_, Parent)
					if not Parent then
						Highlight:Destroy()
					end
				end)
			end
		end

		local function RemoveEsp(Character)
			if not Character then return end
			for _, object in pairs(Character:GetChildren()) do
				if object:IsA("Highlight") and object.Name == "PlayerHighlight" then
					object:Destroy()
				end
			end
		end

		local function HandleEnemies(OtherPlayer)
			local function Apply()
				if OtherPlayer.Character then
					CreateEnemyEsp(OtherPlayer.Character)
				end
			end
			Apply()
			EspCharacterConnections[OtherPlayer] = OtherPlayer.CharacterAdded:Connect(Apply)
		end

		local function ScanForPlayers()
			for _, OtherPlayer in pairs(Players:GetPlayers()) do
				if OtherPlayer ~= Player then
					HandleEnemies(OtherPlayer)
				end
			end

			EspConnection = Players.PlayerAdded:Connect(function(NewPlayer)
				if NewPlayer ~= Player then
					HandleEnemies(NewPlayer)
				end
			end)
		end

		local function ClearAllEsp()
			for _, OtherPlayer in pairs(Players:GetPlayers()) do
				if OtherPlayer ~= Player and OtherPlayer.Character then
					RemoveEsp(OtherPlayer.Character)
				end
			end

			if EspConnection then
				EspConnection:Disconnect()
				EspConnection = nil
			end

			for OtherPlayer, conn in pairs(EspCharacterConnections) do
				if conn then
					conn:Disconnect()
				end
			end
			table.clear(EspCharacterConnections)
			EspCharacterConnections = {}
		end

		if EspState then
			ScanForPlayers()
		else
			ClearAllEsp()
		end
	end
})

local CombatTabSection = CombatTab:CreateSection("Aimbot Fov")

local FOV_RADIUS = 100
local FOV_COLOR = Color3.fromRGB(255, 255, 255)
local FOV_VISIBLE = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = FOV_RADIUS
FOVCircle.Color = FOV_COLOR
FOVCircle.Thickness = 2
FOVCircle.Transparency = 1
FOVCircle.Filled = false
FOVCircle.Visible = FOV_VISIBLE

local FOVConnection

local function updatePosition()
    local viewportSize = camera.ViewportSize
    if viewportSize.X > 0 and viewportSize.Y > 0 then
        FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    end
end

local function toggleFOVCircle(state)
    FOVCircle.Visible = state

    if FOVConnection then
        FOVConnection:Disconnect()
        FOVConnection = nil
    end

    if state then
        updatePosition() -- set initial position
        FOVConnection = RunService.RenderStepped:Connect(updatePosition)
    end
end

local FovCircleToggle = CombatTab:CreateToggle({
    Name = "Fov Circle",
    CurrentValue = false,
    Callback = function(state)
        toggleFOVCircle(state)
    end
})

local AimbotState = false
local AimbotConnection
local Aimbot = CombatTab:CreateToggle({
	Name = "Aimbot",
	Description = "Use Fov Circle For Custom Lock On Range",
	CurrentValue = false,
	Callback = function(state)
		AimbotState = state

		if AimbotConnection then
			AimbotConnection:Disconnect()
			AimbotConnection = nil
		end

		local holding = false

		Uis.InputBegan:Connect(function(input, gpe)
			if not gpe and input.UserInputType == Enum.UserInputType.MouseButton2 then
				holding = true
			end
		end)

		Uis.InputEnded:Connect(function(input, gpe)
			if not gpe and input.UserInputType == Enum.UserInputType.MouseButton2 then
				holding = false
			end
		end)

		if AimbotState then
			local Char = Player.Character or Player.CharacterAdded:Wait()
			local Root = Char:WaitForChild("HumanoidRootPart")

			AimbotConnection = RunService.RenderStepped:Connect(function()
				if not holding then return end

				local mouseCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
				local Target = nil
				local MaxDistance = math.huge
				local MaxPartDistance = math.huge

				for _, child in pairs(Players:GetPlayers()) do
					if child ~= Player and child.Character and child.Character:FindFirstChild("Head") then
						local HeadPart = child.Character:FindFirstChild("Head")
						local screenPos, onScreen = camera:WorldToViewportPoint(HeadPart.Position)
						if onScreen then
							local Pos = Vector2.new(screenPos.X, screenPos.Y)
							local Distance = (Pos - mouseCenter).Magnitude
							if Distance <= FOVCircle.Radius and Distance < MaxDistance then
								local PartDistance = (Root.Position - HeadPart.Position).Magnitude
								if PartDistance < MaxPartDistance then
									MaxDistance = Distance
									MaxPartDistance = PartDistance
									Target = child
								end
							end
						end
					end
				end

				if Target and Target.Character and Target.Character:FindFirstChild("Head") then
					local HeadPos = Target.Character:FindFirstChild("Head").Position
					camera.CFrame = CFrame.new(camera.CFrame.Position, HeadPos)
				end
			end)
		end
	end
})

local FOVSlider = CombatTab:CreateSlider({
	Name = "Aimbot Fov",
	Range = {0, 300},
	Increment = 1,
	CurrentValue = 100,
	Callback = function(value)
		FOV_RADIUS = value
		FOVCircle.Radius = value
	end
})

CombatTab:CreateSection("Silent Aim Fov")

local FOV_RADIUS1 = 100
local FOV_COLOR1 = Color3.fromRGB(255, 255, 255)
local FOV_VISIBLE1 = false

local FOVCircle1 = Drawing.new("Circle")
FOVCircle1.Radius = FOV_RADIUS1
FOVCircle1.Color = FOV_COLOR1
FOVCircle1.Thickness = 2
FOVCircle1.Transparency = 1
FOVCircle1.Filled = false
FOVCircle1.Visible = FOV_VISIBLE1

local SilentAimState = false
local SilentAimConnection
local SilentAimConnection1
local SilentAim = CombatTab:CreateToggle({
	Name = "Silent Aim",
	Description = "Hits All Targets Within Fov (Does Not Lock Onto Target)",
	CurrentValue = false,
	Callback = function(state)
		SilentAimState = state

		if SilentAimConnection then
			SilentAimConnection:Disconnect()
			SilentAimConnection = nil
		end
		if SilentAimConnection1 then
			SilentAimConnection1:Disconnect()
			SilentAimConnection1 = nil
		end

		local HitEvent = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GunFramework"):WaitForChild("Remotes"):WaitForChild("Position")

		local function FindTarget()
			local MaxDistance = math.huge
			local Target = nil
			local MousePos = Uis:GetMouseLocation()
			for _, child in pairs(Players:GetPlayers()) do
				if child ~= Player and child.Character and child.Character:FindFirstChild("HumanoidRootPart") then
					local RootPos, OnScreen = camera:WorldToViewportPoint(child.Character:FindFirstChild("HumanoidRootPart").Position)
					if OnScreen then
						local ScreenPos = Vector2.new(RootPos.X, RootPos.Y)
						local Distance = (ScreenPos - MousePos).Magnitude
						if Distance <= FOV_RADIUS1 and 	Distance < MaxDistance then
							MaxDistance = Distance
							Target = child
						end
					end
				end	
			end
			return Target
		end

		local function HitTarget(Target)
			local TargetHead = Target.Character:FindFirstChild("Head")
			local Tool = Player.Character:FindFirstChildOfClass("Tool")
			local ToolId = Tool:GetAttribute("Id")
			if ToolId and HitEvent then
				HitEvent:FireServer(ServerId, ToolId, TargetHead)
			end
		end	

		if SilentAimState then
			FOVCircle1.Visible = true
			SilentAimConnection = RunService.RenderStepped:Connect(function()
				local MousePos = Uis:GetMouseLocation()
				FOVCircle1.Position = Vector2.new(MousePos.X, MousePos.Y)
			end)
			SilentAimConnection1 = Uis.InputBegan:Connect(function(Input, Gpe)
				if Gpe then return end
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					local Target = FindTarget()
					if Target then
						HitTarget(Target)
					end
				end
			end)
		else
			FOVCircle1.Visible = false
		end
	end
})

local FOVSlider1 = CombatTab:CreateSlider({
	Name = "Slient Aim Fov",
	Range = {0, 300},
	Increment = 1,
	CurrentValue = 100,
	Callback = function(value)
		FOV_RADIUS1 = value
		FOVCircle1.Radius = value
	end
})

CombatTab:CreateSection("To use kill aura you must have a gun inside your backpack and you must of shot your gun atleast once to activate")

local KillAuraState = false
local KillAuraDistance = 50
local KillAuraConnection
local KillAura = CombatTab:CreateToggle({
	Name = "Kill Aura",
	Description = "Kills all enemies within distance",
	CurrentValue = false,
	Callback = function(state)
		KillAuraState = state

		if KillAuraConnection then
			KillAuraConnection:Disconnect()
			KillAuraConnection = nil
		end

		local Char = Player.Character or Player.CharacterAdded:Wait()
		local Root = Char:WaitForChild("HumanoidRootPart")
		local HitEvent = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GunFramework"):WaitForChild("Remotes"):WaitForChild("Position")

		local function FindTarget()
			local MaxDistance = math.huge
			local Target = nil
			for _, child in pairs(Players:GetPlayers()) do
				if child ~= Player and child.Character and child.Character:FindFirstChild("HumanoidRootPart") and not child.Character:FindFirstChild("SafeHighlight") then
					local OtherRoot = child.Character:FindFirstChild("HumanoidRootPart")
					local Distance = (Root.Position - OtherRoot.Position).Magnitude
					if Distance < KillAuraDistance and Distance < MaxDistance then
						MaxDistance = Distance
						Target = child
					end
				end
			end
			return Target
		end

		local function FindToolId()
			local Target = nil
			for _, object in pairs(Player.Backpack:GetChildren()) do
				for _, child in pairs(object:GetChildren()) do
					if child.Name == "Settings" then
						if object:GetAttribute("Id") then
							Target = object:GetAttribute("Id")
						end
						break
					end
				end
			end
			return Target
		end

		if KillAuraState then
			KillAuraConnection = RunService.Heartbeat:Connect(function()
				local Target = FindTarget()
				local ToolId = FindToolId()
				if Target and ToolId then
					local TargetHead = Target.Character:FindFirstChild("Head")
					if TargetHead then
						HitEvent:FireServer(ServerId, ToolId, TargetHead)
					end
				end
			end)
		end	
	end
})

local KillAuraSlider = CombatTab:CreateSlider({
	Name = "Kill Aura Range",
	Range = {10, 1000},
	Increment = 1,
	CurrentValue = 50,
	Callback = function(value)
		KillAuraDistance = value
	end
})

local CombatTabSection1 = CombatTab:CreateSection("Fist PvP")

local FistGodmode = false
local FistGodmodeToggle = CombatTab:CreateToggle({
	Name = "Fist Godmode",
	Description = "Blocks All Punches",
	CurrentValue = false,
	Callback = function(state)
		FistGodmode = state

		local args1 = {
			"Block"
		}

		if FistGodmode then
			task.spawn(function()
				while FistGodmode do
					game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Combat"):FireServer(unpack(args1))
					task.wait(0.3)
				end
			end)
		end
	end
})

local FistKillAuraState = false
local FistKillAura = CombatTab:CreateToggle({
	Name = "Fist Kill Aura",
	Description = "Auto Hits Nearby Enemies When Fists Are Equipped",
	CurrentValue = false,
	Callback = function(state)
		FistKillAuraState = state

		local Char = Player.Character or Player.CharacterAdded:Wait()
		local Root = Char:WaitForChild("HumanoidRootPart")

		local AttackEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Combat")

		local function FindTarget()
			local MaxDistance = 50
			local Target = nil
			local Target1 = nil

			for _, child in pairs(Players:GetPlayers()) do
				if child ~= Player and child.Character and child.Character.Humanoid then
					local Humanoid = child.Character:FindFirstChild("Humanoid")
					local UpperTorso = child.Character:FindFirstChild("UpperTorso")
					local OtherRoot = child.Character:FindFirstChild("HumanoidRootPart")
					if OtherRoot and UpperTorso and Humanoid and Humanoid.Health > 0 then
						local Distance = (Root.Position - OtherRoot.Position).Magnitude
						if Distance < MaxDistance then
							MaxDistance = Distance
							Target = Humanoid
							Target1 = UpperTorso
						end
					end
				end
			end
			return Target, Target1
		end

		local function HitTarget()
			local TargetHum, TargetTorso = FindTarget()

			if TargetHum and TargetTorso then
				AttackEvent:FireServer("Hit", TargetHum, TargetTorso)
			end
		end

		if FistKillAuraState then
			task.spawn(function()
				while FistKillAuraState do
					HitTarget()
					task.wait(0.3)
				end
			end)
		end
	end
})

local StompState = false
local StompConnection
local AutoStomp = CombatTab:CreateToggle({
	Name = "Auto Stomp",
	Description = "Stomps All Nearby Downed Players",
	CurrentValue = false,
	Callback = function(state)
		StompState = state

		local Char = Player.Character or Player.CharacterAdded:Wait()
		local Root = Char:WaitForChild("HumanoidRootPart")
		local StompEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Combat")

		local function FindTarget()
			local MaxDistance = 100
			local Target = nil

			for _, child in pairs(Players:GetPlayers()) do
				if child and child.Character and child.Character:FindFirstChild("CriticalBoard") then
					local OtherRoot = child.Character:FindFirstChild("HumanoidRootPart")
					local Distance = (Root.Position - OtherRoot.Position).Magnitude
					if Distance < MaxDistance then
						MaxDistance = Distance
						Target = child
					end	
				end
			end
			return Target
		end

		local function HitTarget()
			local Target = FindTarget()
			if Target and Target.Character then
				local TargetHum = Target.Character:FindFirstChild("Humanoid")
				local TargetLowerTorso = Target.Character:FindFirstChild("LowerTorso")
				if TargetHum and TargetLowerTorso then
					local Success, Error = pcall(function()
						StompEvent:FireServer("Stomp", TargetHum, TargetLowerTorso)
					end)
					if not Success then 
						warn("Failed To Stomp Target")
					end
				end
			end
		end

		if StompState then
			StompConnection = RunService.RenderStepped:Connect(function()
				HitTarget()
				task.wait(0.2)
			end)
		else
			if StompConnection then
				StompConnection:Disconnect()
				StompConnection = nil
			end
		end
	end
})

local CombatTabSection2 = CombatTab:CreateSection("HitBox Expander")

local HitBoxState = false
local HitBoxValue = 1
local HitBoxExpanderSlider = CombatTab:CreateSlider({
	Name = "HitBox Value",
	Range = {1, 30},
	Increment = 1,
	CurrentValue = 1,
	Callback = function(value)
		HitBoxValue = value

		if HitBoxState then
			for _, child in pairs(Players:GetPlayers()) do
				if child ~= Player and child.Character and child.Character:FindFirstChild("HumanoidRootPart") then
					local OtherRoot = child.Character:FindFirstChild("HumanoidRootPart")
					if OtherRoot then
						OtherRoot.Size = Vector3.new(HitBoxValue, HitBoxValue, HitBoxValue)
					end
				end
			end
		end
	end
})

local HitBoxExpanderToggle = CombatTab:CreateToggle({
	Name = "HitBox Expander",
	Description = "Increases Players HitBox By Your Values Choice",
	CurrentValue = false,
	Callback = function(state)
		HitBoxState = state

		local function HitBoxEnabled()
			for _, child in pairs(Players:GetPlayers()) do
				if child ~= Player and child.Character and child.Character:FindFirstChild("HumanoidRootPart") then
					local OtherRoot = child.Character:FindFirstChild("HumanoidRootPart")
					if OtherRoot then
						OtherRoot.Size = Vector3.new(HitBoxValue, HitBoxValue, HitBoxValue)
						OtherRoot.Color = Color3.fromRGB(45, 0, 165)
						OtherRoot.Transparency = 0.5
					end
				end
			end
		end

		local function HitBoxDisabled()
			for _, child in pairs(Players:GetPlayers()) do
				if child ~= Player and child.Character and child.Character:FindFirstChild("HumanoidRootPart") then
					local OtherRoot = child.Character:FindFirstChild("HumanoidRootPart")
					if OtherRoot then
						OtherRoot.Size = Vector3.new(2, 2, 1)
						OtherRoot.Transparency = 1
					end
				end
			end
		end

		if HitBoxState then
			HitBoxEnabled()
		else
			HitBoxDisabled()
		end
	end
})

local MiscTab = Window:CreateTab({
	Name = "Misc",
	Icon = "more_horiz",
	ImageSource = "Material",
	ShowTitle = true
})

MiscTab:CreateSection("Open Uis")

local Atm = MiscTab:CreateButton({
	Name = "Atm",
	Description = nil,
	Callback = function()
		local Atm
		local Success, Error = pcall(function()
			Atm = workspace.Map.ATMs:GetChildren()[9]["ATM Build"].Func.ATM
		end)
		if not Atm then
			warn("Not Found Atm")
		end
		if Atm then
			fireproximityprompt(Atm)
		end
	end
})

local MerchantDealer = MiscTab:CreateButton({
	Name = "Merchant",
	Description = nil,
	Callback = function()
		local Merchant
		local Success, Error = pcall(function()
			Merchant = workspace.Map.FlipsyPrompts.Merchant.UpperTorso.Handler
		end)
		if not Success then
			warn("Not Found Merchant")
		end
		if Merchant then
			fireproximityprompt(Merchant)
		end
	end
})

local ClothesStore = MiscTab:CreateButton({
	Name = "Clothes Store",
	Description = nil,
	Callback = function()
		local Clothes
		local Success, Error = pcall(function()
			Clothes = workspace.Map.FlipsyPrompts.Clothing.UpperTorso.Handler
		end)
		if not Success then
			warn("Not Found Clothes Store")
		end
		if Clothes then
			fireproximityprompt(Clothes)
		end
	end
})

local SpinTheWheel = MiscTab:CreateButton({
	Name = "Spin The Wheel",
	Description = nil,
	Callback = function()
		local Wheel
		local Success, Error = pcall(function()
			Wheel = workspace.Map.FlipsyPrompts.Wheel.UpperTorso.Handler
		end)
		if not Success then
			warn("Not Found The Wheel Sp")
		end
		if Wheel then
			fireproximityprompt(Wheel)
		end
	end
})
