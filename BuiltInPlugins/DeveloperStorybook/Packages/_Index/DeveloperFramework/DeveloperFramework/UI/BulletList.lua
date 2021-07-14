--[[
	An array of strings and/or elements displayed as a bulleted list.

	Required Props:
		array[any] Items: The item to display after each bullet point. Should be an array of strings and/or elements.
			Strings will be measured to determine the item size. Elements must specify their own size.

	Optional Props:
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		number LayoutOrder: Order in which the element is placed.
		StyleModifier StyleModifier: The StyleModifier index into Style.
		boolean TextWrapped: Sets text wrapped.
		Enum.TextTruncate TextTruncate: Sets text truncated.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.

	Style Values:
		Enum.Font Font: The font used to render the text.
		number ItemOffset: The distance between the marker's right edge and the list item, in pixels.
		string MarkerImage: The Marker Image. The image will be colorised with the TextColor.
		number MarkerSize: The size of the Marker - assumes a 1:1 aspect ratio.
		number Padding: The padding value to apply between each item.
		Color3 TextColor: The color of the text.
		number TextSize: The size of the text.
]]
local TextService = game:GetService("TextService")

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local Cryo = require(Framework.Parent.Cryo)
local ContextServices = require(Framework.ContextServices)
local Util = require(Framework.Util)
local t = require(Framework.Util.Typecheck.t)
local Typecheck = Util.Typecheck

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local BulletList = Roact.PureComponent:extend("BulletList")
Typecheck.wrap(BulletList, script)

function BulletList:init()
	self.itemRefs = {}
	self.frameRef = Roact.createRef()
	self.listSizeConnection = nil

	self.updateListItemsAndFrameSize = function()
		local props = self.props

		local frame = self.frameRef.current
		local sizeX = frame.AbsoluteSize.x

		local items = props.Items
		local theme = props.Theme
		local style
		if THEME_REFACTOR then
			style = props.Stylizer
		else
			style = theme:getStyle("Framework", self)
		end

		local textSize = style.TextSize
		local font = style.Font
		local padding = style.Padding

		assert(t.enum(Enum.Font)(font), "Font must be a member of Enum.Font")
		assert(t.numberMin(0)(padding), "Padding style must be a number >= 0")
		assert(t.numberMin(0)(textSize), "TextSize style must be a number >= 0")

		local totalSize = 0
		for i, item in ipairs(items) do
			local itemRef = self.itemRefs[i]
			if itemRef.current then
				local itemHeight

				if type(item) == "string" then
					local textSize = TextService:GetTextSize(
						item,
						textSize,
						font,
						Vector2.new(sizeX - self:calculateItemOffset(), math.huge)
					)
					itemHeight = textSize.y
				else
					local content = itemRef.current:FindFirstChild("Content"):FindFirstChild("ContentElement")

					if content then
						itemHeight = content.AbsoluteSize.Y
					end
				end

				if itemHeight then
					itemRef.current.Size = UDim2.new(1, 0, 0, itemHeight)
					totalSize = totalSize + itemHeight
				end
			end
		end
		frame.Size = UDim2.new(1, 0, 0, totalSize + padding * (#items - 1))
	end
end

function BulletList:didMount()
	self.updateListItemsAndFrameSize()
end

function BulletList:didUpdate()
	self.updateListItemsAndFrameSize()
end

function BulletList:calculateItemOffset()
	local style
	if THEME_REFACTOR then
		style = self.props.Stylizer
	else
		style = self.props.Theme:getStyle("Framework", self)
	end
	local itemOffset = style.ItemOffset
	local markerSize = style.MarkerSize

	assert(t.numberMin(0)(markerSize), "MarkerSize style must be a number >= 0")
	assert(t.number(itemOffset), "ItemOffset style must be a number")

	return markerSize + itemOffset
end

function BulletList:render()
	local props = self.props
	local textWrapped = props.TextWrapped
	local textTruncate = props.TextTruncate

	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end
	local font = style.Font
	local markerImage = style.MarkerImage
	local markerSize = style.MarkerSize
	local textColor = style.TextColor
	local textSize = style.TextSize
	local padding = style.Padding

	assert(t.numberMin(0)(markerSize), "MarkerSize style must be a number >= 0")
	assert(t.numberMin(0)(textSize), "TextSize style must be a number >= 0")

	local itemOffset = self:calculateItemOffset()

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder or 1,
		Size = UDim2.new(1, 0, 0, 0),

		[Roact.Ref] = self.frameRef,
		[Roact.Change.AbsoluteSize] = self.updateListItemsAndFrameSize
	},
		Cryo.Dictionary.join(
			{
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, padding),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
			},
			table.unpack(Cryo.List.map(
				props.Items,
				function(item, i)
					if self.itemRefs[i] == nil then
						self.itemRefs[i] = Roact.createRef()
					end

					local itemContentPosition = UDim2.new(0, itemOffset, 0, -1)
					local itemContentSize = UDim2.new(1, -itemOffset, 1, 0)

					local itemElement

					if type(item) == "string" then
						itemElement = Roact.createElement("TextLabel", {
							BackgroundTransparency = 1,
							Position = itemContentPosition,
							Size = itemContentSize,
							Text = item,
							Font = font,
							TextColor3 = textColor,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
							TextWrapped = textWrapped,
							TextSize = textSize,
							TextTruncate = textTruncate,
						})
					else
						itemElement = Roact.createElement("Frame", {
							BackgroundTransparency = 1,
							Position = itemContentPosition,
							Size = itemContentSize,
						}, {
							ContentElement = item
						})
					end

					local element = Roact.createElement("Frame", {
						BackgroundTransparency = 1,
						LayoutOrder = i,
						Size = UDim2.new(1, 0, 0, 0),

						[Roact.Ref] = self.itemRefs[i],
					}, {
						Content = itemElement,

						Marker = Roact.createElement("ImageLabel", {
							BorderSizePixel = 0,
							BackgroundTransparency = 1,
							Image = markerImage,
							ImageColor3 = textColor,
							Position = UDim2.new(0, 0, 0, (textSize / 2) - (markerSize / 2)),
							Size = UDim2.new(0, markerSize, 0, markerSize)
						}),
					})

					return {
						["item_" .. i] = element
					}
				end
			))
		)
	)
end

ContextServices.mapToProps(BulletList, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return BulletList
