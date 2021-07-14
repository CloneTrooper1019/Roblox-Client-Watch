--[[
	Displays an animated SelectionBox adornment on the hovered Workspace object.
]]

-- Services
local RunService = game:GetService("RunService")

local DraggerFramework = script.Parent.Parent
local Library = DraggerFramework.Parent.Parent
local Roact = require(Library.Packages.Roact)

local ANIMATED_HOVER_BOX_UPDATE_BIND_NAME = "AnimatedHoverBoxUpdate"
local MODEL_LINE_THICKNESS_SCALE = 2.5

--[[
	Return a hover color that is a blend between the Studio settings HoverOverColor
	and SelectColor, based on the current time and HoverAnimateSpeed.
]]
local function getHoverColorForTime(color1, color2, animatePeriod, currentTime)
	local alpha = 0.5 + 0.5 * math.sin(currentTime / animatePeriod * math.pi)
	return color2:lerp(color1, alpha)
end

local AnimatedHoverBox = Roact.PureComponent:extend("AnimatedHoverBox")

function AnimatedHoverBox:init(initialProps)
	assert(initialProps.HoverTarget, "Missing required property 'HoverTarget'.")
	assert(initialProps.SelectColor, "Missing required property 'SelectColor'.")
	assert(initialProps.HoverColor, "Missing required property 'HoverColor'.")
	assert(initialProps.LineThickness, "Missing required property 'LineThickness'.")
	assert(initialProps.SelectionBoxComponent, "Missing required property 'SelectionBoxComponent'.")

	self:setState({
		currentColor = getHoverColorForTime(
			self.props.SelectColor, self.props.HoverColor, self.props.AnimatePeriod or math.huge, 0),
	})

	self._isMounted = false
	self._startTime = 0
end

function AnimatedHoverBox:didMount()
	self._isMounted = true
	self._startTime = tick()

	RunService:BindToRenderStep(ANIMATED_HOVER_BOX_UPDATE_BIND_NAME, Enum.RenderPriority.First.Value, function()
		if self._isMounted then
			local deltaT = tick() - self._startTime
			self:setState({
				currentColor = getHoverColorForTime(
					self.props.SelectColor, self.props.HoverColor, self.props.AnimatePeriod or math.huge, deltaT)
			})
		end
	end)
end

function AnimatedHoverBox:willUnmount()
	self._isMounted = false
	RunService:UnbindFromRenderStep(ANIMATED_HOVER_BOX_UPDATE_BIND_NAME)
end

function AnimatedHoverBox:render()
	if not self.props.HoverTarget then
		return nil
	end

	local lineThickness = self.props.LineThickness
	if self.props.HoverTarget:IsA("Model") then
		lineThickness = lineThickness * MODEL_LINE_THICKNESS_SCALE
	end

	return Roact.createElement(self.props.SelectionBoxComponent, {
		Adornee = self.props.HoverTarget,
		Color3 = self.state.currentColor,
		LineThickness = lineThickness,
	})
end

return AnimatedHoverBox
