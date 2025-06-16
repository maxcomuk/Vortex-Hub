local Window = {}
Window.__index = Window

function Window.new()
	local self = setmetatable({}, Window)
	
	local VortexHub = Instance.new("ScreenGui")
	VortexHub.Name = "VortexHub"
	
	if syn and syn.protect then
		syn.protect_gui(VortexHub)
	end
	
	VortexHub.Parent = game:GetService("CoreGui")
	VortexHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.root = VortexHub
	
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Parent = VortexHub
	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Main.BorderSizePixel = 0
	Main.Position = UDim2.new(0, 640, 0, 273)
	Main.Size = UDim2.new(0.4, 0.5)
	

	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Parent = Main
	Title.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
	Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Title.BorderSizePixel = 0
	Title.Position = UDim2.new(0, 9, 0, 9)
	Title.Size = UDim2.new(0, 494, 0, 18)
	Title.Font = Enum.Font.FredokaOne
	Title.Text = "Street life remasterd V1.0"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextSize = 20.000
	Title.TextWrapped = true
	Title.TextXAlignment = Enum.TextXAlignment.Left
	
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = Title
	
	local UICorner_2 = Instance.new("UICorner")
	UICorner_2.Parent = Main
	
	local Tabs = Instance.new("ScrollingFrame")
	Tabs.Name = "Tabs"
	Tabs.Parent = Main
	Tabs.Active = true
	Tabs.AnchorPoint = Vector2.new(0.5, 0.5)
	Tabs.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
	Tabs.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Tabs.BorderSizePixel = 0
	Tabs.Position = UDim2.new(0, 53, 0, 177)
	Tabs.Size = UDim2.new(0, 88, 0, 277)
	Tabs.CanvasSize = UDim2.new(0, 0, 0, 0)
	Tabs.ScrollBarThickness = 0
	
	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = Tabs
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 5)
	
	local UICorner_3 = Instance.new("UICorner")
	UICorner_3.CornerRadius = UDim.new(0, 5)
	UICorner_3.Parent = Tabs
	
	return self
end

function Window:CreateTab(Name)
	local TextButton = Instance.new("TextButton")
	TextButton.Name = Name
	TextButton.Parent = self.root.Main.Tabs
	TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
	TextButton.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
	TextButton.BackgroundTransparency = 1.000
	TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.BorderSizePixel = 0
	TextButton.Position = UDim2.new(0, 44, 0, 25)
	TextButton.Size = UDim2.new(0, 88, 0, 50)
	TextButton.Font = Enum.Font.FredokaOne
	TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextButton.TextSize = 15.000
	TextButton.TextWrapped = true
	
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint.Parent = TextButton
	UIAspectRatioConstraint.AspectRatio = 2.700
end

return Window
