--[[
	Split a line of text with zero or more {link} placeholders into a Frame containing TextLabels and LinkButtons.
]]

local TextService = game:GetService("TextService")

local Framework = script.Parent.Parent

local Roact = require(Framework.Parent.Roact)
local Cryo = require(Framework.Parent.Cryo)

local ContextServices = require(Framework.ContextServices)

local LinkText = require(Framework.UI.LinkText)
local Pane = require(Framework.UI.Pane)

local t = require(Framework.Util.Typecheck.t)
local LayoutOrderIterator = require(Framework.Util.LayoutOrderIterator)
local THEME_REFACTOR = require(Framework.Util).RefactorFlags.THEME_REFACTOR

local TextWithInlineLink = Roact.PureComponent:extend("TextWithInlineLink")

local FFlagLuobuDevPublishLua = game:GetFastFlag("LuobuDevPublishLua")
local FFlagGameSettingsEnableVoiceChat = game:GetFastFlag("GameSettingsEnableVoiceChat")

function TextWithInlineLink:init()
	local props = self.props

	assert(t.interface({
		Text = t.string,
		OnLinkClicked = t.callback,
		LinkText = t.string,
		LinkPlaceholder = t.string,
		TextProps = t.interface({
			TextSize = t.integer,
			Font = t.enum(Enum.Font),
		})
	})(props))
end

function TextWithInlineLink:render()
	local props = self.props
	local theme = props.Theme

	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local textProps = props.TextProps
	local text = props.Text
	local linkText = props.LinkText
	local maxWidth = props.MaxWidth
	local textSize = textProps.TextSize
	local layoutOrder = (FFlagLuobuDevPublishLua or FFlagGameSettingsEnableVoiceChat) and props.LayoutOrder or nil

	local lines = {}
	local lineOrder
	local previousLineWrapped

	local frameHeight = 0

	local function measureAndBreakLineIfNeeded(text)
		local size = TextService:GetTextSize(text, textProps.TextSize, textProps.Font, Vector2.new(maxWidth, math.huge))

		-- Whether this text alone would need to wrap
		local textWraps = size.Y > textSize

		local lineWidth = 0
		if #lines > 0 then
			lineWidth = lines[#lines].width
		end

		-- Whether this text appended to the current line would cause overflow
		local textWouldOverflow = lineWidth + size.X > maxWidth

		if previousLineWrapped or #lines == 0 or textWraps or textWouldOverflow then
			local lineHeight = textWraps and size.Y or textSize

			table.insert(lines, {
				width = size.X,
				height = lineHeight,
				items = {}
			})
			lineOrder = LayoutOrderIterator.new()
			frameHeight = frameHeight + lineHeight
		else
			lines[#lines].width = lineWidth + size.X
		end

		previousLineWrapped = textWraps

		return size
	end

	local function appendToLine(val)
		local line = lines[#lines]
		table.insert(line.items, val)
	end

	local function appendTextLabel(text, xOffset)
		if #text == 0 then
			return
		end

		local size = measureAndBreakLineIfNeeded(text)

		appendToLine(Roact.createElement("TextLabel", Cryo.Dictionary.join({
			Text = text,
			Size = UDim2.new(0, size.X, 0, size.Y),
			LayoutOrder = lineOrder:getNextOrder(),
			TextWrapped = true,
		}, textProps)))
	end

	local function appendLink()
		local size = measureAndBreakLineIfNeeded(linkText)

		appendToLine(Roact.createElement(LinkText, {
			-- This component does not support wrapping, so truncate if the text is too long
			Size = UDim2.new(0, size.X, 0, textSize),
			TextTruncate = Enum.TextTruncate.AtEnd,
			LayoutOrder = lineOrder:getNextOrder(),
			OnClick = props.OnLinkClicked,
			Text = linkText,
			Style = {
				TextColor = style.TextColor,
				TextSize = textProps.TextSize,
				Font = textProps.Font,
			},
		}))
	end

	local i = 1
	while true do
		local startPos
		local endPos

		startPos, endPos = string.find(text, props.LinkPlaceholder, i, true)

		-- No (more) link placeholders found
		if startPos == nil then
			break
		end

		-- Add any unconsumed text up to this link
		appendTextLabel(string.sub(text, i, startPos - 1))

		appendLink()

		-- Continue searching for more link placeholders after this one
		i = endPos + 1
	end

	-- Append any remaining text
	appendTextLabel(string.sub(text, i, #text))

	local lineElements = {}

	for i, line in ipairs(lines) do
		lineElements["line_" .. i] = Roact.createElement(Pane, {
			Layout = Enum.FillDirection.Horizontal,
			AutomaticSize = Enum.AutomaticSize.Y,
		}, line.items)
	end

	return Roact.createElement(Pane, {
		Layout = Enum.FillDirection.Vertical,
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = layoutOrder,
	}, lineElements)
end

ContextServices.mapToProps(TextWithInlineLink, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return TextWithInlineLink
