local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local UI = require(Framework.UI)
local TextLabel = UI.Decoration.TextLabel

local Util = require(Framework.Util)
local Cryo = Util.Cryo
local Immutable = Util.Immutable
local LayoutOrderIterator = Util.LayoutOrderIterator
local FitFrame = Util.FitFrame
local FitFrameVertical = FitFrame.FitFrameVertical

--[[
	generateStories should be a callback that returns a dictionary of name -> Roact element
]]
return function(generateStories, options)
	options = Immutable.JoinDictionaries({
		frameProps = {},
		storyRenderer = function(story, props)
			return Roact.createElement(FitFrameVertical, Immutable.JoinDictionaries({
				width = UDim.new(1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, props), {
				Story = story
			})
		end,
	}, options or {})

	local layoutOrderIterator = LayoutOrderIterator.new()
	local elements = {}

	local stories = generateStories()

	local storyNames = Cryo.Dictionary.keys(stories)
	table.sort(storyNames)

	for _, name in ipairs(storyNames) do
		local story = stories[name]

		if story == nil then
			-- Story values might be nil if disabled using a FFlag, for example
			continue
		end

		elements["Title_" .. name] = Roact.createElement(TextLabel, {
			LayoutOrder = layoutOrderIterator:getNextOrder(),
			Style = "Bold",
			Text = name,
			FitWidth = true
		})

		elements["Story_" .. name] = options.storyRenderer(story, {
			LayoutOrder = layoutOrderIterator:getNextOrder(),
		})
	end

	return Roact.createElement(FitFrameVertical, Immutable.JoinDictionaries({
		contentPadding = UDim.new(0, 10),
		width = UDim.new(1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, options.frameProps), elements)
end
