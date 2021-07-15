--[[
	The InstancePicker allows a user to hover over UI instances and choose one to be inspected in the
	DeveloperInspector plugin.
]]
local Source = script.Parent.Parent.Parent
local Packages = Source.Parent

local RunService = game:GetService("RunService")

local Dash = require(Packages.Dash)
local class = Dash.class
local format = Dash.format
local reduce = Dash.reduce

local ZERO_UDIM2 = UDim2.fromScale(0, 0)
local PICK_DELAY = 0.2

-- Arbitrary number larger than DevFramework FOCUSED_ZINDEX
local PICKER_ZINDEX = 1100000

local function tweenUDim2(prevValue, nextValue, progress)
	local scaleX = (prevValue.X.Scale * (1 - progress) + nextValue.X.Scale * progress)
	local offsetX = (prevValue.X.Offset * (1 - progress) + nextValue.X.Offset * progress)
	local scaleY = (prevValue.Y.Scale * (1 - progress) + nextValue.Y.Scale * progress)
	local offsetY = (prevValue.Y.Offset * (1 - progress) + nextValue.Y.Offset * progress)
	return UDim2.new(scaleX, offsetX, scaleY, offsetY)
end

local function createPickerArea()
	local pickerArea = Instance.new("ImageButton")
	pickerArea.Name = "InspectorHover"
	pickerArea.Active = true
	pickerArea.AutoButtonColor = false
	pickerArea.BorderSizePixel = 1
	pickerArea.BorderColor3 = Color3.fromRGB(0, 0, 0)
	pickerArea.BackgroundColor3 = Color3.fromRGB(220, 230, 255)
	pickerArea.BackgroundTransparency = 0.2
	pickerArea.ZIndex = PICKER_ZINDEX
	return pickerArea
end

local function createHighlightArea()
	local highlightArea = Instance.new("Frame")
	highlightArea.Name = "InspectorHover"
	highlightArea.BorderSizePixel = 1
	highlightArea.BorderColor3 = Color3.fromRGB(0, 0, 0)
	highlightArea.BackgroundColor3 = Color3.fromRGB(220, 230, 255)
	highlightArea.BackgroundTransparency = 0.2
	highlightArea.ZIndex = PICKER_ZINDEX

	local dimensions = Instance.new("TextLabel")
	dimensions.Name = "Dimensions"
	dimensions.Size = UDim2.new(0, 60, 0, 24)
	dimensions.Parent = highlightArea
	dimensions.BorderColor3 = Color3.fromRGB(0, 0, 0)
	dimensions.BorderSizePixel = 1
	dimensions.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	dimensions.BackgroundTransparency = 0.2
	dimensions.ZIndex = PICKER_ZINDEX + 1

	return highlightArea
end

local InstancePicker = class("InstancePicker", function(debugInterface, onSelect)
	return {
		debugInterface = debugInterface,
		onSelect = onSelect,
		active = false,
		connection = nil,
		selectedObject = nil,
		pickerArea = createPickerArea(),
		highlightArea = createHighlightArea(),
		selectedTime = os.clock(),
		nextPosition = ZERO_UDIM2,
		nextSize = ZERO_UDIM2,
		prevPosition = ZERO_UDIM2,
		prevSize = ZERO_UDIM2,
	}
end)

function InstancePicker:getRoot()
	return self.debugInterface.rootInstance
end

function InstancePicker:getPickerParent()
	return self.debugInterface.pickerParent or self:getRoot()
end

function InstancePicker:getRelativeMousePosition()
	local root = self:getRoot()
	if not root then
		return nil
	end
	if root:IsA("PluginGui") then
		return root:GetRelativeMousePosition()
	else
		local mouse = game:GetService("Players").LocalPlayer:GetMouse()
		return Vector2.new(mouse.X, mouse.Y)
	end
end

function InstancePicker:_init()
	self.pickerArea.Activated:Connect(function()
		self.onSelect(self.selectedObject)
	end)
end

function InstancePicker:setActive(active: boolean)
	self.active = active
	local root = self:getRoot()
	if not root then
		return
	end
	if active then
		self.pickerArea.Parent = self:getPickerParent()
		local onCalculate
		onCalculate = function()
			if not self.active then
				return
			end
			self:calculateFramePosition()
			delay(PICK_DELAY, onCalculate)
		end
		onCalculate()
		self.connection = RunService.RenderStepped:Connect(function()
			self:updateFrame()
		end)
	elseif self.connection then
		self.connection:Disconnect()
		self.connection = nil
		self.pickerArea.Parent = nil
	end
end

function InstancePicker:updateFrame()
	local progress = math.min(1, (os.clock() - self.selectedTime) / 0.1)
	self.pickerArea.Position = tweenUDim2(self.prevPosition, self.nextPosition, progress)
	self.pickerArea.Size = tweenUDim2(self.prevSize, self.nextSize, progress)
end

function InstancePicker:intersectMouse(root: Instance, mousePosition: Vector2)
	local descendants = root:GetDescendants()
	local result = reduce(descendants, function(current, instance: Instance)
		if instance == self.pickerArea then
			return current
		end
		local intersects = false
		if instance:IsA("GuiBase2d") then
			local mousePosition = mousePosition - instance.AbsolutePosition
			intersects =  mousePosition.X >= 0
				and mousePosition.X <= instance.AbsoluteSize.X
				and mousePosition.Y >= 0
				and mousePosition.Y <= instance.AbsoluteSize.Y
		end
		if instance:IsA("GuiObject") and not instance.Visible then
			intersects = false
		end
		if intersects then
			local area = instance.AbsoluteSize.X * instance.AbsoluteSize.Y
			if current.minArea > area then
				current.minArea = area
				current.instance = instance
			end
		end
		return current
	end, {
		minArea = math.huge
	})
	return result.instance
end

function InstancePicker:calculateFramePosition()
	local root = self:getRoot()
	local mousePosition = self:getRelativeMousePosition()
	if not root or not mousePosition then
		return
	end
	if mousePosition ~= self.mousePosition then
		self.mousePosition = mousePosition
		local foundObject = self:intersectMouse(root, mousePosition)
		if foundObject then
			if foundObject ~= self.selectedObject then
				self.selectedObject = foundObject
				self.prevPosition = UDim2.fromOffset(self.pickerArea.AbsolutePosition.X, self.pickerArea.AbsolutePosition.Y)
				self.prevSize = UDim2.fromOffset(self.pickerArea.AbsoluteSize.X, self.pickerArea.AbsoluteSize.Y)
				self.nextPosition = UDim2.fromOffset(foundObject.AbsolutePosition.X, foundObject.AbsolutePosition.Y)
				self.nextSize = UDim2.fromOffset(foundObject.AbsoluteSize.X, foundObject.AbsoluteSize.Y)
				self.selectedTime = os.clock()
			end
		else
			self.selectedObject = nil
		end
	end
end

function InstancePicker:highlight(instance: Instance)
	-- Some instances may not have sizes so guard for error
	pcall(function()
		self.highlightArea.Parent = self:getPickerParent()
		self.highlightArea.Position = UDim2.fromOffset(instance.AbsolutePosition.X, instance.AbsolutePosition.Y)
		self.highlightArea.Size = UDim2.fromOffset(instance.AbsoluteSize.X, instance.AbsoluteSize.Y)
		local dimensions = self.highlightArea:FindFirstChild("Dimensions")
		dimensions.Text = format("{X}x{Y}", instance.AbsoluteSize)
	end)
end

function InstancePicker:dehighlight()
	self.highlightArea.Parent = nil
end

function InstancePicker:destroy()
	if self.connection then
		self.connection:Disconnect()
	end
	self.pickerArea:Destroy()
end

return InstancePicker