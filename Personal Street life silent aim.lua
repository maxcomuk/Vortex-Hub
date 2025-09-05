local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Uis = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local ID = nil
local HitEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Modules"):FindFirstChild("GunFramework"):FindFirstChild("Remotes"):FindFirstChild("Position")

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

local Fov_Settings = {Enabled = true, Fov = 150, ShowFov = true}

local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1.5
FovCircle.NumSides = 64
FovCircle.Filled = false
FovCircle.Color = Color3.fromRGB(255, 255, 255)

local function FindEnemyWithinFov()
    local Camera = workspace.CurrentCamera
    local Closest, ClosestDist = nil, Fov_Settings.Fov
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local Root = plr.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(Root.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - (Camera.ViewportSize / 2)).Magnitude
                if dist < ClosestDist then
                    ClosestDist = dist
                    Closest = Root
                end
            end
        end
    end
    return Closest
end

local function FindToolId()
    local Target = nil
    local Char = Player.Character or Player.CharacterAdded:Wait()
    for _, object in pairs(Player.Backpack:GetChildren()) do
        if object:GetAttribute("Id") then
            Target = object:GetAttribute("Id")
        end
    end
    if not Target then
        for _, object in pairs(Char:GetChildren()) do
            if object:IsA("Model") and object:GetAttribute("Id") then
                Target = object:GetAttribute("Id")
            end
        end
    end
    return Target
end

RunService.RenderStepped:Connect(function()
    local Camera = workspace.CurrentCamera
    FovCircle.Radius = Fov_Settings.Fov
    FovCircle.Visible = Fov_Settings.ShowFov
    FovCircle.Position = Camera.ViewportSize / 2
end)

Uis.InputBegan:Connect(function(Input, gpe)
    if not gpe and Input.UserInputType == Enum.UserInputType.MouseButton1 then
        local Char = Player.Character or Player.CharacterAdded:Wait()
        local Target = FindEnemyWithinFov()
        local GunId = FindToolId()
        if Char and Target and GunId and ID then
            print(ID, GunId, Target.Position)
            HitEvent:FireServer(ID, GunId, Target.Position)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local PlrRoot = plr:FindFirstChild("HumanoidRootPart")
            if PlrRoot then
				RootPart.Size = Vector3.new(10, 10, 10)
				RootPart.Transparency = 0.5
				RootPart.Color = Color3.fromRGB(68, 81, 165)
				RootPart.CanCollide = false
            end
        end
    end
end)

while task.wait() do
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= Player and plr.Character then
			local PlrRoot = plr.Character:FindFirstChild("HumanoidRootPart")
			if PlrRoot then
				PlrRoot.Size = Vector3.new(10, 10, 10)
				PlrRoot.Transparency = 0.5
				PlrRoot.Color = Color3.fromRGB(68, 81, 165)
				PlrRoot.CanCollide = false
			end	
		end	
	end
end
