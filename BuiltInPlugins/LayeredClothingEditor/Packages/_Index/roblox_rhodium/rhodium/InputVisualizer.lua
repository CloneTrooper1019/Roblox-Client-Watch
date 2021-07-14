local InputVisualizer = {}
InputVisualizer.__index = InputVisualizer

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")

function InputVisualizer.new()
	local self = {}
	local state, guiRoot = pcall(function() return game.CoreGui.Parent.CoreGui end)
	if state == false then
		local LocalPlayer = game.Players.LocalPlayer
		while LocalPlayer == nil do
			LocalPlayer = game.Players.LocalPlayer
			wait()
		end
		guiRoot = LocalPlayer.PlayerGui
	end

	local GuiName = "InputVisualizer"
	if guiRoot:FindFirstChild(GuiName) == nil then
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = GuiName
		screenGui.DisplayOrder = 1000000
		screenGui.Parent = guiRoot
	end
	guiRoot = guiRoot[GuiName]
	self.guiRoot = guiRoot

	setmetatable(self, InputVisualizer)
	return self
end

function InputVisualizer:onInputBegan(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		self:click(Vector2.new(input.Position.X, input.Position.Y))
	elseif input.UserInputType == Enum.UserInputType.Touch then
		self:click(Vector2.new(input.Position.X, input.Position.Y))
	end
end

function InputVisualizer:click(vec2, pluginGui)
	local delay = 0.5
	local image = nil
	if image == nil then
		image = Instance.new("ImageLabel")
		image.Image = "rbxassetid://1549893588"
		image.BackgroundTransparency = 1
		image.Parent = pluginGui or self.guiRoot
		image.Size = UDim2.new(0, 20, 0, 20)
		image.Name = "MouseClick"
		image.ZIndex = 10
	end

	image.Visible = true
	image.Position = UDim2.new(0, vec2.X-image.Size.X.Offset/2, 0, vec2.Y-image.Size.Y.Offset/2)
	image.ImageTransparency = 0
	local goal = {ImageTransparency = 1}
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false)
	local tween = TweenService:Create(image, tweenInfo, goal)
	tween:Play()
	Debris:AddItem(image, delay)
end

function InputVisualizer:enable()
	self.handler = UserInputService.InputBegan:connect(
		function(input, gameProcessed)
			self:onInputBegan(input, gameProcessed)
		end)
end

function InputVisualizer:disable()
	if self.handler then
		self.handler:Disconnect()
	end
	self.handler = nil
end

return InputVisualizer