-- Bypassed By yours truly maxcomuk :)
-- Dont delete my credits he he your choice

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local RepStorage = game:GetService("ReplicatedStorage")
local SwingTool = RepStorage:WaitForChild("Events"):WaitForChild("SwingTool")

local resourcesFolder = workspace:WaitForChild("Map"):WaitForChild("Resources")
if not resourcesFolder then return end

local function findNearestTarget()
    local nearestTarget = nil
    local nearestDistance = math.huge

    for _, folder in ipairs(resourcesFolder:GetChildren()) do
        for _, model in ipairs(folder:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("Health") then
                local part = model:FindFirstChildWhichIsA("BasePart")
                if part then
                    local dist = (hrp.Position - part.Position).Magnitude
                    if dist < nearestDistance then
                        nearestDistance = dist
                        nearestTarget = model
                    end
                end
            end
        end
    end

    return nearestTarget
end

local function hitNearestTarget()
    local target = findNearestTarget()
    if not target then
        print("NOT FOUND Target - vortex hub lol")
        return
    end

    SwingTool:FireServer({target}, nil, nil, nil)
end

local crittersFolder = workspace:WaitForChild("Important"):WaitForChild("Critters")
local function findNearestCritter()
    local nearestTarget = nil
    local nearestDistance = math.huge

    for _, model in ipairs(crittersFolder:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("Health") then
            local part = model:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = (hrp.Position - part.Position).Magnitude
                if dist < nearestDistance then
                    nearestDistance = dist
                    nearestTarget = model
                end
            end
        end
    end

    return nearestTarget
end

-- TOGGLE IT ON / OFF HERE
getgenv().AutoBreakEnabled = true

if getgenv().AutoBreakEnabled then
    while getgenv().AutoBreakEnabled do
        local target = findNearestCritter()
        if target then
            SwingTool:FireServer({target}, nil, nil, nil)
        end
        task.wait(0.5)
    end     
end
