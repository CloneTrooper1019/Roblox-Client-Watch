local root = script.Parent
local Packages = root.Parent

local Cryo = require(Packages.Cryo)
local Roact = require(Packages.Roact)

local Rect = require(root.Rect)

local FitFrameOnAxis = Roact.PureComponent:extend("FitFrameOnAxis")
FitFrameOnAxis.Axis = {
	Horizontal = {},
	Vertical = {},
	Both = {},
}

FitFrameOnAxis.defaultProps = {
	axis = FitFrameOnAxis.Axis.Vertical,
	minimumSize = UDim2.new(UDim.new(0, 0), UDim.new(0, 0)),
	margin = Rect.square(0),

	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	ImageSet = {},
	VerticalAlignment = Enum.VerticalAlignment.Top,
	contentPadding = UDim.new(0, 0),
}

function FitFrameOnAxis:init()
	self.layoutRef = Roact.createRef()
	self.frameRef = self.props[Roact.Ref] or Roact.createRef()

	self.onResize = function()
		local currentLayout = self.layoutRef.current
		local currentFrame = self.frameRef.current
		if not currentFrame or not currentLayout then
			return
		end

		currentFrame.Size = self:__getSize(currentLayout)
	end
end

function FitFrameOnAxis:render()
	assert(self.props.Size == nil, "Size is not a valid property of FitFrameOnAxis. Did you mean `minimumSize`?")
	local children = self.props[Roact.Children] or {}
	local filteredProps = self:__getFilteredProps()

	return Roact.createElement("ImageLabel", filteredProps,
		Cryo.Dictionary.join(children, {
			["$layout"] = Roact.createElement("UIListLayout", {
				FillDirection = self.props.FillDirection,
				HorizontalAlignment = self.props.HorizontalAlignment,
				Padding = self.props.contentPadding,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = self.props.VerticalAlignment,

				[Roact.Change.AbsoluteContentSize] = self.onResize,
				[Roact.Ref] = self.layoutRef,
			}),
			["$margin"] = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, self.props.margin.left),
				PaddingRight = UDim.new(0, self.props.margin.right),
				PaddingTop = UDim.new(0, self.props.margin.top),
				PaddingBottom = UDim.new(0, self.props.margin.bottom),
			}),
		})
	)
end

function FitFrameOnAxis:didMount()
	self.onResize()
end

function FitFrameOnAxis:didUpdate()
	self.onResize()
end

function FitFrameOnAxis:__getFilteredProps()
	-- Will return a new prop map after removing
	-- Roact.Children and any defaultProps in an effort
	-- to only return safe Roblox Instance "ImageLabel"
	-- properties that may be present.
	local filteredProps = Cryo.Dictionary.join(self.props.ImageSet, {
		[Roact.Ref] = self.frameRef,
	})

	for property, _ in pairs(FitFrameOnAxis.defaultProps) do
		filteredProps[property] = Cryo.None
	end

	return Cryo.Dictionary.join(self.props, filteredProps, {
		[Roact.Children] = Cryo.None,
	})
end

function FitFrameOnAxis:__getSize(currentLayout)
	if self.props.axis == FitFrameOnAxis.Axis.Both then
		return self:__getBothAxisSize(currentLayout)
	else
		-- Arrangement of UDims are flip-flopped based
		-- on which axis is our primary axis
		local axisUDim = self:__getAxisUDim(currentLayout.AbsoluteContentSize)
		local otherUDim = self:__getOtherUDim()

		if self.props.axis == FitFrameOnAxis.Axis.Vertical then
			return UDim2.new(otherUDim, axisUDim)
		elseif self.props.axis == FitFrameOnAxis.Axis.Horizontal then
			return UDim2.new(axisUDim, otherUDim)
		end
	end
end

function FitFrameOnAxis:__getBothAxisSize(currentLayout)
	local minimumSize = self.props.minimumSize
	local absoluteContentSize = currentLayout.AbsoluteContentSize

	local xAxis = UDim.new(minimumSize.X.Scale, absoluteContentSize.X + self:__getHorizontalMargin())
	local yAxis = UDim.new(minimumSize.Y.Scale, absoluteContentSize.Y + self:__getVerticalMargin())

	return UDim2.new(xAxis, yAxis)
end

function FitFrameOnAxis:__getAxisUDim(vector2)
	-- Merges minimumSize with given Vector2
	-- to create UDim for primary axis
	local minimumSize = self.props.minimumSize

	local targetUDim
	local lengthOfChildren
	if self.props.axis == FitFrameOnAxis.Axis.Vertical then
		targetUDim = minimumSize.Y
		lengthOfChildren = vector2.Y + self:__getVerticalMargin()
	elseif self.props.axis == FitFrameOnAxis.Axis.Horizontal then
		targetUDim = minimumSize.X
		lengthOfChildren = vector2.X + self:__getHorizontalMargin()
	end

	return UDim.new(targetUDim.Scale, math.max(lengthOfChildren, targetUDim.Offset))
end

function FitFrameOnAxis:__getVerticalMargin()
	return self.props.margin.top + self.props.margin.bottom
end

function FitFrameOnAxis:__getHorizontalMargin()
	return self.props.margin.left + self.props.margin.right
end

function FitFrameOnAxis:__getOtherUDim()
	-- Since there is no primary axis to merge with,
	-- this UDim is entirely represented by minimumSize
	local minimumSize = self.props.minimumSize

	if self.props.axis == FitFrameOnAxis.Axis.Vertical then
		return minimumSize.X
	elseif self.props.axis == FitFrameOnAxis.Axis.Horizontal then
		return minimumSize.Y
	end
end

return FitFrameOnAxis