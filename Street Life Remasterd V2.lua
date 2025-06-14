-- this script was rushed please allow my trash organisation and no object oriented programming involed i know there are so much better ways to create this but i had not time
-- if you want to skip key system simple make IsKeyValid variable to true like this (IsKeyValid = true) or simple delete the repeat task.wait()

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

local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()

local Window = Luna:CreateWindow({
	Name = "Street Life Remasterd - Vortex Hub V2.0",
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

local EnableNoClipConnection
local IsNoClipOn = false
local function EnableNoclip()
	if IsNoClipOn then return end
	IsNoClipOn = true

	if EnableNoClipConnection then
		EnableNoClipConnection:Disconnect()
		EnableNoClipConnection = nil
	end

	local Char = Player.Character or Player.CharacterAdded:Wait()
	local function NoClipStart()
		for _, child in pairs(Char:GetChildren()) do
			if child:IsA("BasePart") then
				child.CanCollide = false
			end
		end
	end

	EnableNoClipConnection = RunService.Heartbeat:Connect(function()
		NoClipStart()
	end)
end

local function RemoveNoClip()
	if not IsNoClipOn then return end
	IsNoClipOn = false

	if EnableNoClipConnection then
		EnableNoClipConnection:Disconnect()
		EnableNoClipConnection = nil
	end

	local Char = Player.Character or Player.CharacterAdded:Wait()
	for _, child in pairs(Char:GetChildren()) do
		if child:IsA("BasePart") then
			child.CanCollide = true
		end
	end
end

local IsMoving = false
local function GoToPosition(TargetPos, Speed)
	if IsMoving then return end
	IsMoving = true

	local Char = Player.Character or Player.CharacterAdded:Wait()
	local Root = Char:WaitForChild("HumanoidRootPart")
	if Root and Root:FindFirstChild("TeleportingVelocity") then
		Root.TeleportingVelocity:Destroy()
	end
	
	local SpeedEvaluated = Speed - 15
	local Direction = (TargetPos - Root.Position).Unit
	local Distance = (TargetPos - Root.Position).Magnitude
	local TravelTime = Distance / SpeedEvaluated

    local Info = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
    local safeY = math.max(Root.Position.Y - 30, 5)
    local GoUnderGoal = {CFrame = CFrame.new(Root.Position.X, safeY, Root.Position.Z)}

    local GoAboveGoal = {CFrame = CFrame.new(TargetPos)}
    local TweenDown = TweenService:Create(Root, Info, GoUnderGoal)
    local TweenUp = TweenService:Create(Root, Info, GoAboveGoal)

	TweenDown:Play()
	TweenDown.Completed:Wait()

	EnableNoclip()
	TweenDown:Play()
	TweenDown.Completed:Wait()

    local bv = Instance.new("BodyVelocity")
    bv.Name = "AutoFarmVelocity"
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Direction * SpeedEvaluated
    bv.P = 10000
    bv.Parent = Root

	task.wait(TravelTime)
	if bv and bv.Parent then
		bv:Destroy()
	end
	
	TweenUp:Play()
	TweenUp.Completed:Wait()
	RemoveNoClip()
	IsMoving = false
end

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

-- Fly Toggle
local FlyState = false
local IsFlying = false
local FlyConnection
local FlyInputConnection
local FlyEndedConnection
local FlyKeyConnection
local bodygyro
local bodyvelocity
local FlyToggle = MainTab:CreateToggle({
	Name = "Fly",
	Description = "Press E to toggle",
	CurrentValue = false,
	Callback = function(value)
		FlyState = value

		local Char = Player.Character or Player.CharacterAdded:Wait()
		local Root = Char:WaitForChild("HumanoidRootPart")
		local Uis = game:GetService("UserInputService")
		local RunService = game:GetService("RunService")

		local FlyKeybind = Enum.KeyCode.E
		local Speed = 30

		local direction = {
			Forward = false,
			BackWard = false,
			Right = false,
			Left = false
		}

		local function StartFlying()
			if bodygyro then bodygyro:Destroy() end
			if bodyvelocity then bodyvelocity:Destroy() end

			bodygyro = Instance.new("BodyGyro")
			bodygyro.P = 9e4
			bodygyro.Parent = Root
			bodygyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)

			bodyvelocity = Instance.new("BodyVelocity")
			bodyvelocity.Velocity = Vector3.new(0, 0, 0)
			bodyvelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
			bodyvelocity.Parent = Root

			IsFlying = true

			FlyConnection = RunService.RenderStepped:Connect(function()
				if FlyState then
					local cam = workspace.CurrentCamera
					local movedirection = Vector3.new()

					if direction.Forward then movedirection = movedirection + cam.CFrame.LookVector end
					if direction.BackWard then movedirection = movedirection - cam.CFrame.LookVector end
					if direction.Right then movedirection = movedirection + cam.CFrame.RightVector end
					if direction.Left then movedirection = movedirection - cam.CFrame.RightVector end

					if movedirection.Magnitude > 0 then
						bodyvelocity.Velocity = movedirection.Unit * Speed
					else
						bodyvelocity.Velocity = Vector3.zero
					end
					bodygyro.CFrame = cam.CFrame
				end
			end)

			FlyInputConnection = Uis.InputBegan:Connect(function(Input, gameProcessed)
				if gameProcessed then return end
				if Input.KeyCode == Enum.KeyCode.W then direction.Forward = true end
				if Input.KeyCode == Enum.KeyCode.S then direction.BackWard = true end
				if Input.KeyCode == Enum.KeyCode.D then direction.Right = true end
				if Input.KeyCode == Enum.KeyCode.A then direction.Left = true end
			end)

			FlyEndedConnection = Uis.InputEnded:Connect(function(Input)
				if Input.KeyCode == Enum.KeyCode.W then direction.Forward = false end
				if Input.KeyCode == Enum.KeyCode.S then direction.BackWard = false end
				if Input.KeyCode == Enum.KeyCode.D then direction.Right = false end
				if Input.KeyCode == Enum.KeyCode.A then direction.Left = false end
			end)
		end

		local function StopFlying()
			if bodygyro then bodygyro:Destroy() end
			if bodyvelocity then bodyvelocity:Destroy() end
			if FlyConnection then FlyConnection:Disconnect() end
			if FlyInputConnection then FlyInputConnection:Disconnect() end
			if FlyEndedConnection then FlyEndedConnection:Disconnect() end

			IsFlying = false
		end

		if FlyState then
			if not FlyKeyConnection then
				FlyKeyConnection = Uis.InputBegan:Connect(function(Input, gameProcessed)
					if gameProcessed then return end
					if Input.KeyCode == Enum.KeyCode.E then
						if IsFlying then
							StopFlying()
						else
							StartFlying()
						end
					end
				end)
			end
		else
			if FlyKeyConnection then
				FlyKeyConnection:Disconnect()
				FlyKeyConnection = nil
			end
			StopFlying()
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

local NoClipState = false
local NoClipConnection
local NoClipConnection1
local Noclip = MainTab:CreateToggle({
	Name = "Noclip [Detected]",
	Description = nil,
	CurrentValue = false,
	Callback = function(state)
		NoClipState = state

		if NoClipConnection then
			NoClipConnection:Disconnect()
			NoClipConnection = nil
		end

		if NoClipConnection1 then
			NoClipConnection1:Disconnect()
			NoClipConnection1 = nil
		end

		local Char = Player.Character or Player.CharacterAdded:Wait()

		local function ApplyNoclip(Character)
			for _, child in pairs(Character:GetChildren()) do 
				if child:IsA("BasePart") then
					child.CanCollide = false
				end
			end	
		end

		local function DisableNoclip(Character)
			for _, child in pairs(Character:GetChildren()) do
				if child:IsA("BasePart") then
					child.CanCollide = true
				end
			end
		end

		local function StartNoClip(Character)
			NoClipConnection = RunService.RenderStepped:Connect(function()
				if NoClipState then
					ApplyNoclip(Character)
				end
			end)
		end

		if NoClipState then
			StartNoClip(Char)

			NoClipConnection1 = Player.CharacterAdded:Connect(function(NewChar)
				if NoClipConnection then
					NoClipConnection:Disconnect()
					NoClipConnection = nil
				end
				StartNoClip(NewChar)
			end)
		else
			DisableNoclip(Char)
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

local TeleportsTab = Window:CreateTab({
	Name = "Teleports",
	Icon = "location_on",
	ImageSource = "Material",
	ShowTitle = true
})

local TeleportsTabStoreSection = TeleportsTab:CreateSection("Stores")

local GunShop = TeleportsTab:CreateButton({
	Name = "Gun Store",
	Description = nil,
	Callback = function()
		local Pos = Vector3.new(634.2763671875, 52.366783142089844, -403.2176208496094)
		GoToPosition(Pos, 33)
	end
})

local CarDealer = TeleportsTab:CreateButton({
	Name = "Car Dealer",
	Description = nil,
	Callback = function()
		local Pos = Vector3.new(557.56689453125, 52.356101989746094, 33.54143142700195)
		GoToPosition(Pos, 33)
	end
})

local JewrlyStore = TeleportsTab:CreateButton({
	Name = "Jewrly Store",
	Description = nil,
	Callback = function()
		local Pos = Vector3.new(-5.1605000495910645, 52.64374542236328, -249.66421508789062)
		GoToPosition(Pos, 33)
	end
})

local Bank = TeleportsTab:CreateButton({
	Name = "Bank",
	Description = nil,
	Callback = function()
		local Pos = Vector3.new(429.170166015625, -46.44035339355469, 117.79572296142578)
		GoToPosition(Pos, 33)
	end
})

local DripStore = TeleportsTab:CreateButton({
	Name = "Drip Store",
	Description = nil,
	Callback = function()
		local Pos = Vector3.new(303.62884521484375, 52.44342803955078, -73.7807388305664)
		GoToPosition(Pos, 33)
	end
})

local TeleportsTabNpcSection = TeleportsTab:CreateSection("Npc's")

local IllegalMerchant = TeleportsTab:CreateButton({
	Name = "Illegal Merchant",
	Description = nil,
	Callback = function()
		local Pos = Vector3.new(861.2636108398438, 52.364532470703125, -714.8855590820312)
		GoToPosition(Pos, 33)
	end
})

local LootBuyer = TeleportsTab:CreateButton({
	Name = "Loot Buyer",
	Description = nil,
	Callback = function()
		local Pos = Vector3.new(268.40435791015625, 52.391456604003906, 300.7331848144531)
		GoToPosition(Pos, 33)
	end
})

local SpinTheWheel = TeleportsTab:CreateButton({
	Name = "Spin The Wheel",
	Description = nil,
	Callback = function()
		local Pos = Vector3.new(561.1537475585938, 52.39051055908203, -433.9858093261719)
		GoToPosition(Pos, 33)
	end
})

local MaskNpc = TeleportsTab:CreateButton({
	Name = "Mask Dealer",
	Description = nil,
	Callback = function()
		local Pos = Vector3.new(178.57949829101562, 52.26061248779297, -53.214664459228516)
		GoToPosition(Pos, 33)
	end
})

TeleportsTab:CreateSection("Misc")

local Apartment = TeleportsTab:CreateButton({
	Name = "Apartment",
	Description = "Must Own An Apartment",
	CurrentValue = false,
	Callback = function()
		local function FindApartment()
			local Target = nil
			local Folder
			local Success, Error = pcall(function()
				Folder = workspace.Map.Doors.Buy
			end)
			if not Success then
				warn("Could Not Find Apartment Folder")
			end
			if Folder then
				for _, object in pairs(Folder:GetChildren()) do
					for _, child in pairs(object:GetChildren()) do
						if child.Name == "HomeOwner" then
							for i, v in pairs(child:GetChildren()) do
								if v.Name == "SurfaceGui" then
									for _, Owner in pairs(v:GetChildren()) do
										if Owner.Name == "Owner" then
											local PlayerTxt = "OWNER: " .. tostring(Player)
											local Txt = Owner.Text
											if PlayerTxt and Txt and PlayerTxt == Txt then
												Target = object:FindFirstChild("Safe")
												break
											end
										end
									end
								end
							end
						end
					end
				end
				return Target
			end
		end

		local Target = FindApartment()
		if Target then
			GoToPosition(Target:GetPivot().Position + Vector3.new(0, 5, 0), 33)
		else
			Luna:Notification({ 
				Title = "Apartment not found",
				Icon = "notifications_active",
				ImageSource = "Material",
				Content = "Buy an apartment from the apartment locations"
			})
		end
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

local AutoFarmTab = Window:CreateTab({
	Name = "Auto Rob/Farm",
	Icon = "grass",
	ImageSource = "Material",
	ShowTitle = true
})

AutoFarmTab:CreateSection("AutoFarm")

local BoxJobState = false
local BoxJob = AutoFarmTab:CreateToggle({
	Name = "Box Job",
	Description = nil,
	CurrentValue = nil,
	Callback = function(state)
		BoxJobState = state

		local Char = Player.Character or Player.CharacterAdded:Wait()
		local Root = Char:WaitForChild("HumanoidRootPart")
		local TargetPos = Vector3.new(202.8831329345703, 52.358360290527344, 340.18231201171875)
		local MidWayPoint = Vector3.new(157.2467041015625, 53.00542449951172, 253.40872192382812)
		local SellPoint = Vector3.new(157.9254150390625, 66.95494079589844, 253.3249969482422)

		local function SellBox()
			local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
			local Goal = {CFrame = CFrame.new(SellPoint)}
			local Tween = TweenService:Create(Root, Info, Goal)

			Tween:Play()
			Tween.Completed:Wait()
			local SellPrompt = workspace.Map.Jobs.BoxJob.Deliver.Deliver.Interact
			if SellPrompt then
				fireproximityprompt(SellPrompt)
			end
		end

		local function DelivaryInProgress()
			local Info = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
			local Goal = {CFrame = CFrame.new(MidWayPoint)}
			local Tween = TweenService:Create(Root, Info, Goal)
			
			Tween:Play()
			Tween.Completed:Wait()
			SellBox()
		end

		local function DelivarBox()
			local Info = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
			local Goal = {CFrame = CFrame.new(TargetPos)}
			local Tween = TweenService:Create(Root, Info, Goal)
			Tween:Play()
			Tween.Completed:Wait()

			task.wait(0.5)
			local BoxPrompt = workspace.Map.Jobs.BoxJob.Take.Take.Interact
			if BoxPrompt then
				fireproximityprompt(BoxPrompt)
				DelivaryInProgress()
			end
		end

		if BoxJobState then
			GoToPosition(TargetPos, 33)
			task.spawn(function()
				while BoxJobState do
					DelivarBox()
					task.wait(0.5)
				end
			end)
		end
	end
})

AutoFarmTab:CreateSection("AutoRob (Use Kill Aura For Best Results)")

local TrashCarState = false
local IsRobbingTrashCar = false
local TrashCarFarm = AutoFarmTab:CreateToggle({
	Name = "Car + Trash",
	Description = "Robs All Cars and Searches All Trash",
	CurrentValue = false,
	Callback = function(state)
		TrashCarState = state

		local Char = Player.Character or Player.CharacterAdded:Wait()
		local Root = Char:WaitForChild("HumanoidRootPart")

		local function FindCar()
			local MaxDistance = math.huge
			local Target = nil
			local Folder
			local Success, Error = pcall(function()
				Folder = workspace.Map.Interactions
			end)
			if not Success then
				warn("Failed To Find Interaction Folder")
			end

			if Folder then
				for _, object in pairs(Folder:GetChildren()) do
					if object.Name == "Car Rob" then
						for _, child in pairs(object:GetChildren()) do
							if child.Name == "Window" then
								for _, part in pairs(child:GetChildren()) do
									if part.Name == "H" then
										for _, entitiy in pairs(part:GetChildren()) do
											if entitiy:IsA("ProximityPrompt") and entitiy.Enabled == true then
												local Distance = (Root.Position - part.Position).Magnitude
												if Distance < MaxDistance then
													MaxDistance = Distance
													Target = part
												end
											end
										end
									end
								end
							end
						end
					end
				end
				return Target
			end
		end

		local function FindTrash()
			local MaxDistance = math.huge
			local Target = nil
			local Folder
			local Success, Error = pcall(function()
				Folder = workspace.Map.Interactions
			end)
			if not Success then
				warn("Failed To Find Interaction Folder")
			end

			if Folder then
				for _, object in pairs(Folder:GetChildren()) do
					if object.Name == "Search Trash" then
						for _, child in pairs(object:GetChildren()) do
							if child:IsA("ProximityPrompt") and child.Name == "Handler" and child.Enabled then
								local Distance = (Root.Position - object.Position).Magnitude
								if Distance < MaxDistance then
									MaxDistance = Distance
									Target = object
								end
							end
						end
					end
				end
				return Target
			end
		end

		local function FindClosestRobbery()
			local TargetFound = nil
			local Car = FindCar()
			local Trash = FindTrash()
			if Car and Trash then
				local CarDis = (Root.Position - Car.Position).Magnitude
				local TrashDis = (Root.Position - Trash.Position).Magnitude
				if CarDis < TrashDis then
					Target = Car
				else
					Target = Trash
				end
				return Target
			end
			if Car then
				Target = Car
			end
			if Trash then
				Target = Trash
			end

			return Target
		end

		local function StartRobbery()
			if IsRobbingTrashCar then return end
			IsRobbingTrashCar = true

			local Target = FindClosestRobbery()
			if Target then
				if Target.Name == "H" then
					GoToPosition(Target:GetPivot().Position, 33)
					task.wait(0.5)
					local Prompt = Target:FindFirstChild("ProximityPrompt")
					if Prompt then
						fireproximityprompt(Prompt)
						task.wait(3.5)
						fireproximityprompt(Prompt)
					else
						warn("Failed To Find Prompt")
					end
				elseif Target.Name == "Search Trash" then
					GoToPosition(Target:GetPivot().Position, 33)
					task.wait(0.5)
					local Prompt = Target:FindFirstChild("Handler")
					if Prompt then
						fireproximityprompt(Prompt)
					else
						warn("Failed To Find Prompt")
					end
				end
			else
				warn("Not Found Target")
			end

			IsRobbingTrashCar = false
		end

		if TrashCarState then
			task.spawn(function()
				while TrashCarState do
					if not IsRobbingTrashCar then
						StartRobbery()
					end
					task.wait(0.1)
				end
			end)
		end
	end
})

local BuyEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Buy")
local AtmEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ATM")
local BankState = false
local IsRobbingBank = false
local AutoRobBank = AutoFarmTab:CreateToggle({
	Name = "Bank",
	Description = "Robs Bank Even On Lowest Servers",
	CurrentValue = false,
	Callback = function(state)
		BankState = state

		local BankPos = Vector3.new(405.4408874511719, -49.003597259521484, 102.99531555175781)
		local SafeBankPos = Vector3.new(362.1388244628906, -48.99908447265625, 102.36225128173828)
		local SellPoint = Vector3.new(268.3104553222656, 52.391456604003906, 299.25762939453125)
		local SafeZonePos = Vector3.new(556.25732421875, 52.34392547607422, -78.40464782714844)

		local BankFolder = workspace.Bank
		local function BankStatus()
			local Timer = BankFolder:GetAttribute("BankCooldown")
			local Timer2 = BankFolder:GetAttribute("BankTimeLeft")
			if Timer and Timer == 0 and Timer2 == 0 then
				return true
			else
				return false
			end
			return false
		end

		local function GetC4()
			local Data = game:GetService("Players").LocalPlayer.Data
			if Data then
				if Data.Money.Value >= 2000 then
					BuyEvent:FireServer("C4", 2000)
					return true
				else
					if Data.Bank.Value >= 2000 then
						AtmEvent:FireServer("Withdraw", 2000)
						task.wait(0.5)
						BuyEvent:FireServer("C4", 2000)
						return true
					else
						Luna:Notification({
							Title = "You Cant Afford C4",
							Icon = "notifications_active",
							ImageSource = "Material",
							Content = "Earn Some Cash Sigma",
						})
						return false
					end
				end
			else
				warn("Not Found Data")
			end
			return false
		end

		local function GetTools()
			local Tool
			local Success, Error = pcall(function()
				Tool = Player.Backpack:FindFirstChild("C4") or Player.Character:FindFirstChild("C4")
			end)
			if Tool == nil then
				local GotC4 = GetC4()
				if GotC4 then
					return true
				else
					return false
				end
			end
			if Tool then
				return true
			end
			return false
		end

		local function C4Task()
			local Char = Player.Character or Player.CharacterAdded:Wait()
			local C4Event = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("C4")
			
			local FirstArg = Char:FindFirstChild("C4") or Player.Backpack:FindFirstChild("C4")
			local SecondArg = workspace:WaitForChild("Bank"):WaitForChild("Vault"):WaitForChild("Plant")
			C4Event:FireServer(FirstArg, "COMPLETED", SecondArg)
		end

		local function TakeCover()
			local Char = Player.Character or Player.CharacterAdded:Wait()
			local Root = Char:WaitForChild("HumanoidRootPart")

			local Info = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
			local Goal = {CFrame = CFrame.new(SafeBankPos)}
			local Tween = TweenService:Create(Root, Info, Goal)
			
			Tween:Play()
			Tween.Completed:Wait()
		end

		local function PickUpGold()
			local Char = Player.Character or Player.CharacterAdded:Wait()
			local Root = Char:WaitForChild("HumanoidRootPart")
			
			local MaxDistance = 50
			local Target = nil

			local GoldFolder = workspace.Bank.Vault.BankInteractions
			for _, object in pairs(GoldFolder:GetChildren()) do
				local Distance = (Root.Position - object.Position).Magnitude
				if Distance < MaxDistance then
					MaxDistance = Distance
					Target = object
				end
			end

			local GoldPrompt = Target:FindFirstChild("ProximityPrompt")
			if GoldPrompt then
				local Info = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
				local Goal = {CFrame = CFrame.new(GoldPrompt.Parent.Position)}
				local Tween = TweenService:Create(Root, Info, Goal)
				EnableNoclip()
				Tween:Play()
				Tween.Completed:Wait()
				task.wait(4)
				for i = 1, 10 do
					fireproximityprompt(GoldPrompt)
					task.wait(0.1)
				end
				RemoveNoClip()
			end
		end

		local function StartRobbery()
			if IsRobbingBank then return end
			IsRobbingBank = true

			local IsBankOpen = BankStatus()
			if IsBankOpen then
				local HasTools = GetTools()
				if HasTools then
					GoToPosition(BankPos, 30)
					task.wait(0.5)
					local Char = Player.Character or Player.CharacterAdded:Wait()
					local Hum = Char:WaitForChild("Humanoid")
					task.wait(0.5)
					if not Char:FindFirstChild("C4") then
						Hum:EquipTool(Player.Backpack:FindFirstChild("C4"))
					end
					task.wait(0.5)
					local C4Prompt = workspace.Bank.Vault.Plant.ProximityPrompt
					fireproximityprompt(C4Prompt)
					task.wait(0.2)
					C4Task()
					task.wait(0.1)
					TakeCover()
					PickUpGold()
					GoToPosition(SellPoint, 33)

					local SellPrompt = workspace.Map.Misc.LootBuyer.UpperTorso.Handler
					if SellPrompt then
						fireproximityprompt(SellPrompt)
						task.wait(0.2)
						GoToPosition(SafeZonePos, 33)
					end
				end
			else
				Luna:Notification({
					Title = "Bank Closed",
					Icon = "notifications_active",
					ImageSource = "Material",
					Content = tostring(BankFolder:GetAttribute("BankCooldown")) .. " Seconds Left"
				})
			end
			IsRobbingBank = false
		end

		if BankState then
			task.spawn(function()
				while BankState do
					if not IsRobbingBank then
						StartRobbery()
					end
					task.wait(5)
				end
			end)
		end
	end
})

local JewrlyStoreState = false
local IsRobbingJewrlyStore = false
local JewrlyStoreAutoRob = AutoFarmTab:CreateToggle({
	Name = "Jewrly Store",
	Description = "Can Rob Jewrly Store Twice (It Depends) (BUGGY)",
	CurrentValue = false,
	Callback = function(state)
		JewrlyStoreState = state

		local JewrlyPos = Vector3.new(-10.976996421813965, 52.61960220336914, -258.7524719238281)
		local SellPoint = Vector3.new(268.3104553222656, 52.391456604003906, 299.25762939453125)
		local SafeZonePos = Vector3.new(556.25732421875, 52.34392547607422, -78.40464782714844)

		local JewrlyFolder = workspace.Jewel
		local function JewrlyStatus()
			if JewrlyFolder then
				local CanRob = JewrlyFolder:GetAttribute("CanRob")
				local isRobbing = JewrlyFolder:GetAttribute("Robbing")
				if CanRob or isRobbing then
					return true
				else
					Luna:Notification({
						Title = "Jewrly Store Closed",
						Icon = "notifications_active",
						ImageSource = "Material",
						Content = tostring(JewrlyFolder:GetAttribute("Timer")) .. " Seconds Left"
					})
					return false
				end
			else
				warn("Not Found Jewrly Folder")
			end
			return false
		end

		local function FindGun()
			local Backpack = Player.Backpack
			if Backpack then
				for _, object in pairs(Backpack:GetChildren()) do
					if object ~= "Fist" and object ~= "Phone" then
						for _, child in pairs(object:GetChildren()) do
							if child.Name == "Settings" and child:FindFirstChild("ShootRun") then
								return true
							end
						end	
					end
				end
			end

			local Char = Player.Character or Player.CharacterAdded:Wait()
			if Char then
				for _, object in pairs(Char:GetChildren()) do
					if object:IsA("Tool") and object:FindFirstChild("Settings") and object:FindFirstChild("Settings"):FindFirstChild("ShootRun") then 
						return true
					end
				end
			end

			return false
		end

		local function BuyTool()
			local Data = game:GetService("Players").LocalPlayer.Data
			if Data then
				local Money = Data.Money.Value
				if Money >= 800 then
					GunBuyEvent:FireServer("Ruger", 800)
					return true
				end
				local BankMoney = Data.Bank.Value
				if BankMoney >= 800 then
					AtmEvent:FireServer("Withdraw", 800)
					task.wait(0.5)
					GunBuyEvent:FireServer("Ruger", 800)
					return true
				end
			end

			Luna:Notification({
				Title = "You Cant Afford A Gun Yet",
				Icon = "notifications_active",
				ImageSource = "Material",
				Content = "Go Make Some Money Sigma"
			})
			return false
		end

		local function FindBag()
			for _, child in pairs(Player.Backpack:GetChildren()) do
				if child.Name == "DuffleBag" then
					return true
				end
			end
			local Char = Player.Character or Player.CharacterAdded:Wait()
			if Char then
				for _, object in pairs(Char:GetChildren()) do
					if object.Name == "DuffleBag" then
						return true
					end
				end
			end

			return false
		end

		local function BuyBag()
			local Data = game:GetService("Players").LocalPlayer.Data
			if Data then
				local Money = Data.Money.Value
				if Money >= 500 then
					BuyEvent:FireServer("DuffleBag", 500)
					return true
				end
				local BankMoney = Data.Bank.Value
				if BankMoney >= 500 then
					AtmEvent:FireServer("Withdraw", 500)
					task.wait(0.5)
					BuyEvent:FireServer("DuffleBag", 500)
					return true
				end
			end
			
			Luna:Notification({
				Title = "You Cant Afford To Buy Bag",
				Icon = "notifications_active",
				ImageSource = "Material",
				Content = "Go Make Some Money You Sigma"
			})
			return false
		end

		local function GetTools()
			local GunTool = nil
			local BagTool = nil
			local Char = Player.Character or Player.CharacterAdded:Wait()
			if Char then
				local Tool = FindGun()
				if Tool then
					GunTool = true
				else
					local BoughtTools = BuyTool()
					if BoughtTools then
						GunTool = true
					else
						warn("Failed To Buy Tool")
					end
				end
				local Bag = FindBag()
				if Bag then
					BagTool = true
				else
					local BoughtBag = BuyBag()
					if BoughtBag then
						BagTool = true
					else
						warn("Failed To Buy Bag")
					end
				end
			end

			if GunTool == true and BagTool == true then
				return true
			else
				return false
			end
		end

		local function EquipTool()
			local Tool = nil
			local Char = Player.Character or Player.CharacterAdded:Wait()
			local Hum = Char:WaitForChild("Humanoid")
			for i, v in pairs(Player.Backpack:GetChildren()) do
				if v.Name ~= "Fist" and v.Name ~= "Phone" then
					for _, object in pairs(v:GetChildren()) do
						if object:FindFirstChild("Settings") then
							if Hum then
								Hum:EquipTool(v)
							end
						end
					end
				end
			end
		end

        local function FindJewls()
            local Target = nil
            local Jewls = workspace.Jewel.holders
            if Jewls then
                for _, child in pairs(Jewls:GetChildren()) do
                    for _, object in pairs(child:GetChildren()) do
                        for _, watch in pairs(object:GetChildren()) do
                            if watch.Name == "GrabJewel" and watch:IsA("ProximityPrompt") then
                                Target = watch
                                break
                            end
                        end
					end
                end
            else
                warn("Jewls Not Found")
            end
            return Target
        end

		local function StartRobbery()
			if IsRobbingJewrlyStore then return end
			IsRobbingJewrlyStore = true

			local Char = Player.Character or Player.CharacterAdded:Wait()
			local Hum = Char:WaitForChild("Humanoid")

			local IsOpen = JewrlyStatus()
			if IsOpen then
				local HasTools = GetTools()
				if HasTools then
					GoToPosition(JewrlyPos, 30)
					task.wait(0.5)
					EquipTool()
					task.wait(0.5)
					
					local Jewls = nil
					repeat
						Jewls = FindJewls()
						task.wait(0.1)
					until Jewls ~= nil
					GoToPosition(Jewls.Parent.Position + Vector3.new(0, 5, 0), 30)
					task.wait(0.5)
					Jewls.HoldDuration = 0
					for i = 1, 5 do
						fireproximityprompt(Jewls)
						task.wait(0.1)
					end

					local Jewls2 = nil
					repeat
						Jewls2 = FindJewls()
						task.wait(0.1)
					until Jewls2 ~= nil
					GoToPosition(Jewls2.Parent.Position + Vector3.new(0, 5, 0), 30)
					task.wait(0.5)
					Jewls2.HoldDuration = 0
					for i = 1, 5 do
						fireproximityprompt(Jewls2)
						task.wait(0.1)
					end

					GoToPosition(SellPoint, 30)
					local NpcPrompt
					local Success, Error = pcall(function()
						NpcPrompt = workspace.Map.Misc.LootBuyer.UpperTorso:FindFirstChildOfClass("ProximityPrompt")
					end)
					if Success then
						for _, child in pairs(Player.Backpack:GetChildren()) do
							if child:IsA("Tool") then
								Hum:EquipTool(child)
								task.wait(0.5)
								fireproximityprompt(NpcPrompt)
								task.wait(0.1)
							end
						end
					end
					GoToPosition(SafeZonePos, 33)
				end
			end
			IsRobbingJewrlyStore = false
		end

		if JewrlyStoreState then
			task.spawn(function()
				while JewrlyStoreState do
					if not IsRobbingJewrlyStore then
						StartRobbery()
					end
					task.wait(5)
				end
			end)
		end
	end	
})

local JewrlyState = false
local RobberyFound = nil
local AutoRobNoclipConnection
local AutoRob = AutoFarmTab:CreateToggle({
    Name = "Auto Rob Jewrly Store + Bank",
    Description = "Old autorob i reccoment use this one for jewrly store but not for bank",
    CurrentValue = false,
    Callback = function(state)
        JewrlyState = state

        if AutoRobNoclipConnection then
            AutoRobNoclipConnection:Disconnect()
            AutoRobNoclipConnection = nil
        end
            
        local Player = game:GetService("Players").LocalPlayer
        local Char = Player.Character or Player.CharacterAdded:Wait()
        local Root = Char:WaitForChild("HumanoidRootPart")

        local JewrlyStorePos = Vector3.new(-5.580535888671875, 52.64366149902344, -250.14796447753906)
        local BankPos = Vector3.new(405.5276184082031, -48.74203109741211, 103.22148132324219)
        local LootBuyerPos = Vector3.new(268.2671813964844, 52.220767974853516, 296.6185607910156)
        local SafeZonePos = Vector3.new(556.25732421875, 52.34392547607422, -78.40464782714844)
        
        local ToolBuyEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Buy")
        local AtmEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ATM")
        local JewrlyPath = workspace.Jewel
        local BankPath = workspace.Bank

        local function EnableNoclip()
            for i, v in pairs(Char:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end

        local function DisableNoClip()
            for i, v in pairs(Char:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end

        local function GoToPosViaCFrame(TargetPos, Speed)
            local Info = TweenInfo.new(Speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
            local Goal = {CFrame = TargetPos}
            local Tween = TweenService:Create(Root, Info, Goal)
            Tween:Play()
            Tween.Completed:Wait()
        end

        local function FindRobbery()
            local RobberyFound = nil

            if JewrlyPath:GetAttribute("CanRob") and #game.Players:GetPlayers() >= 10 then
                RobberyFound = "Jewrly Store"
            elseif JewrlyPath:GetAttribute("Robbing") then
                RobberyFound = "Jewrly Store"
            elseif BankPath:GetAttribute("BankTimeLeft") == 0 and BankPath:GetAttribute("BankCooldown") <= 10 then
                RobberyFound = "Bank"
            end
                
            return RobberyFound
        end

        local function BuyGun()
            if Player:FindFirstChild("Data"):FindFirstChild("Money").Value < 800 then
                local PlayersCurrentMoney = Player.Data.Money.Value
                local MoneyRequired = 800 - PlayersCurrentMoney
                AtmEvent:FireServer("Withdraw", MoneyRequired)
                task.wait(0.5)
                GunBuyEvent:FireServer("Ruger", 800)

            	if Player:FindFirstChild("Data"):FindFirstChild("Money").Value > 800 then
                	GunBuyEvent:FireServer("Ruger", 800)
                	return true
				end
            end
            return false
        end

        local function BuyDuffelBag()
            if Player:FindFirstChild("Data"):FindFirstChild("Money").Value < 500 then
                local PlayersCurrentMoney = Player.Data.Money.Value
                local MoneyRequired = 500 - PlayersCurrentMoney
                AtmEvent:FireServer("Withdraw", MoneyRequired)
                task.wait(0.5)
                ToolBuyEvent:FireServer("DuffleBag", 500)
                return true
            end

            if Player:FindFirstChild("Data"):FindFirstChild("Money").Value > 500 then
                ToolBuyEvent:FireServer("DuffleBag", 500)
                return true
            end
            return false
        end

        local function JewrlyTools()
            local GunFound = false
            local DuffelBagFound = false

            for _, gun in pairs(Player.Backpack:GetChildren()) do
                if gun:IsA("Tool") and gun:FindFirstChild("ShootRun", true) then
                    GunFound = true
                end
            end
            if not GunFound then
                for _, gun in pairs(Char:GetChildren()) do
                    if gun:IsA("Tool") and gun:FindFirstChild("ShootRun", true) then
                        GunFound = true
                    end
                end
            end
            if not GunFound then
                GunFound = BuyGun()
                if not GunFound then
                    return false
                end
            end

            for _, bag in pairs(Player.Backpack:GetChildren()) do
                if bag:FindFirstChild("SpecialMesh", true) then
                    DuffelBagFound = true
                end
            end

            if not DuffelBagFound then
                for _, bag in pairs(Char:GetChildren()) do
                    if bag:FindFirstChild("SpecialMesh", true) then
                        DuffelBagFound = true
                    end
                end
            end

            if not DuffelBagFound then
                DuffelBagFound = BuyDuffelBag()
                if not DuffelBagFound then
                    return false
                end
            end


            if GunFound and DuffelBagFound then
                return true
            end
        end

        local function FindJewls()
            local Target = nil
            local Jewls = workspace.Jewel.holders
            if Jewls then
                for _, child in pairs(Jewls:GetChildren()) do
                    for _, object in pairs(child:GetChildren()) do
                        for _, watch in pairs(object:GetChildren()) do
                            if watch.Name == "GrabJewel" and watch:IsA("ProximityPrompt") then
                                Target = watch
                                break
                            end
                        end
                    end
                end
            else
                warn("Jewls Not Found")
            end
            return Target
        end

        local function JewrlyStoreRobbery()
            local Success = JewrlyTools()
            if Success then
                AutoRobNoclipConnection = RunService.Heartbeat:Connect(function()
                    EnableNoclip()
                end)
                GoToPosition(JewrlyStorePos, 33)

                local Gun
                if not Char:FindFirstChild("ShootRun", true) then
                    for i, v in pairs(Player.Backpack:GetChildren()) do
                        if v:IsA("Tool") and v:FindFirstChild("ShootRun", true) then
                            Gun = v
                        end
                    end
                end

                if Char:FindFirstChild("ShootRun", true) then
                    for i, v in pairs(Char:GetChildren()) do
                        if v:IsA("Tool") and v:FindFirstChild("ShootRun", true) then
                            Gun = v
                        end
                    end
                end

                if Gun then
                    local Humanoid = Char:WaitForChild("Humanoid")
                    Humanoid:EquipTool(Gun)
                    task.wait(1)
                    GoToPosViaCFrame(CFrame.new(JewrlyStorePos - Vector3.new(0, 10, 0)), 1)
                    local JewlsSpawned
                    local RETRYCOUNTER = 0
                    local LIMITCOUNTER = 30
                    repeat
                        task.wait(1)
                        RETRYCOUNTER += 1
                        JewlsSpawned = FindJewls()
                    until JewlsSpawned or RETRYCOUNTER >= LIMITCOUNTER

                    local Target = FindJewls()
                    if Target then
                        GoToPosition(Target.Parent.Position + Vector3.new(0, 5, 0), 33)
                        Target.HoldDuration = 0
                        for i = 1, 10 do
                            fireproximityprompt(Target)
                            task.wait(0.5)
                        end
                    end

                    task.wait(0.5)

                    local Target2 = FindJewls()
                    if Target2 then
                        GoToPosition(Target2.Parent.Position + Vector3.new(0, 5, 0), 33)
                        Target2.HoldDuration = 0
                        for i = 1, 10 do
                            fireproximityprompt(Target2)
                            task.wait(0.5)
                        end
                    end

                    task.wait(2)

                    GoToPosition(LootBuyerPos, 33)
                    local NpcPrompt
                    local Success, Error = pcall(function()
                        NpcPrompt = workspace.Map.Misc.LootBuyer.UpperTorso:FindFirstChildOfClass("ProximityPrompt")
                    end)
                    if not NpcPrompt then
                        DisableNoClip()
                        return
                    end
                    for _, object in pairs(Player.Backpack:GetChildren()) do
                        if object:IsA("Tool") then
                            Humanoid:EquipTool(object)
                            fireproximityprompt(NpcPrompt)
                            task.wait(0.3)
                        end
                    end
                    GoToPosition(SafeZonePos, 33)

                    if AutoRobNoclipConnection then
                        AutoRobNoclipConnection:Disconnect()
                        AutoRobNoclipConnection = nil
                    end
                    DisableNoClip()
                else
                    warn("Gun Not Found")
                end
            end
        end

        local function FindC4()
            if Player.Backpack:FindFirstChild("C4") or Char:FindFirstChild("C4") then
                return true
			else
                if Player.Data.Money.Value >= 2000 then
                    ToolBuyEvent:FireServer("C4", 2000)
                    return true
                elseif Player.Data.Bank.Value >= 2000 then
                    local MoneyRequired = 2000 - Player.Data.Money.Value
                    AtmEvent:FireServer("Withdraw", MoneyRequired)
                    task.wait(0.5)
                    ToolBuyEvent:FireServer("C4", 2000)
                    return true
				else
                    return false
                end
            end
            return false
        end

        local function FindGoldBar()
            local GoldBarsFolder = workspace.Bank.Vault.BankInteractions
            local Target
            local ClosestDistance = math.huge
            if GoldBarsFolder then
                for _, gold in pairs(GoldBarsFolder:GetChildren()) do
                    if gold.Name == "Gold Bar" then
                        local Distance = (Root.Position - gold.Position).Magnitude
                        if Distance < ClosestDistance then
                            ClosestDistance = Distance
                            Target = gold
                        end
                    end
                end
                return Target
            end
        end

        local function TakeCover()
            local Info = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
            local Goal = {CFrame = CFrame.new(Vector3.new(362.3018798828125, -48.99903869628906, 102.81547546386719))}
            local Tween = TweenService:Create(Root, Info, Goal)
            Tween:Play()
            Tween.Completed:Wait()
        end

        local function PickUpGold()
            local Counter = 0
            repeat
                Counter += 1
                local GoldBar = FindGoldBar()
                local BagSize = game:GetService("Players").LocalPlayer.PlayerGui.BankRobbery.Main.Filler.TextLabel.Text
                if GoldBar then
                    local Info = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
                    local Goal = {CFrame = CFrame.new(GoldBar.Position)}
                    local Tween = TweenService:Create(Root, Info, Goal)
                    Tween:Play()
                    Tween.Completed:Wait()
                    local PickUpGoldPrompt = GoldBar:FindFirstChild("ProximityPrompt") or GoldBar:FindFirstChildOfClass("ProximityPrompt")
                    for i = 1, 5 do
                        task.wait(0.1)
                        fireproximityprompt(PickUpGoldPrompt)
                    end
                end
            until Counter == 5
        end

        local function BankRobbery()
            local HasC4 = FindC4()
            if HasC4 then
                AutoRobNoclipConnection = RunService.Heartbeat:Connect(function()
                    EnableNoclip()
                end)
                GoToPosition(BankPos, 33)
                local Humanoid = Char:WaitForChild("Humanoid")
                if not Char:FindFirstChild("C4") then
                    Humanoid:EquipTool(Player.Backpack:FindFirstChild("C4"))
                end
                local PlantC4Prompt = workspace.Bank.Vault.Plant.ProximityPrompt
                for i = 1, 5 do
                    task.wait(0.5)
                    fireproximityprompt(PlantC4Prompt)
                end
                local FirstArg = Char:FindFirstChild("C4") or Player.Backpack:FindFirstChild("C4")
                local CompleteC4Task = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("C4")
                local SecondArg = workspace:WaitForChild("Bank"):WaitForChild("Vault"):WaitForChild("Plant")
                CompleteC4Task:FireServer(FirstArg, "COMPLETED", SecondArg)
                TakeCover()
                PickUpGold()
                GoToPosition(LootBuyerPos, 33)
                local NpcPrompt
                local Success, Error = pcall(function()
                    NpcPrompt = workspace.Map.Misc.LootBuyer.UpperTorso:FindFirstChildOfClass("ProximityPrompt")
                end)
                if NpcPrompt then
                    for i = 1, 5 do
                        task.wait(0.1)
                        fireproximityprompt(NpcPrompt)
                    end
                end
                GoToPosition(SafeZonePos, 33)
            end 
        end

        local function StartRobbery()
            if RobberyFound == nil then
            	local Robbery = FindRobbery()
            	if not Robbery then return end
               	RobberyFound = Robbery
            end

            if #game.Players:GetPlayers() >= 10 and RobberyFound == "Jewrly Store" then
                task.wait(2)
                JewrlyStoreRobbery()
                task.wait(0.5)
                RobberyFound = nil
            elseif RobberyFound == "Bank" then
                task.wait(2)
                BankRobbery()
                task.wait(0.5)
                RobberyFound = nil
            end
        end

        if JewrlyState then
            task.spawn(function()
                while JewrlyState do
                    StartRobbery()
                    Luna:Notification({
                        Title = "Waiting For Robberies To Open",
                        Icon = "notifications_active",
						ImageSource = "Material",
						Content = ""
                    })
                    task.wait(1.4)
                    if JewrlyPath:GetAttribute("Timer") then    
                        Luna:Notification({
                            Title = "Jewrly Store " .. tostring(JewrlyPath:GetAttribute("Timer")) .. " Seconds Left",
                            Icon = "notifications_active",
                            ImageSource = "Material",
							Content = ""
                        })
                    end
                    task.wait(1.4)
                    if BankPath:GetAttribute("BankCooldown") then
                        Luna:Notification({
                            Title = "Bank " .. tostring(BankPath:GetAttribute("BankCooldown")) .. " Seconds Left",
                            Icon = "notifications_active",
                            ImageSource = "Material",
							Content = ""
                        })
                    end
                end
            end)
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
