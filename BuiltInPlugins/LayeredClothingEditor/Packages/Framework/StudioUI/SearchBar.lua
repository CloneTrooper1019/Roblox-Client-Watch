--[[
	A search bar component with a single line TextInput and button to request a search.

	Optional Props:
		number Width: how wide the search bar is in pixels.
		number ButtonWidth: how wide the search button is in pixels.
		number LayoutOrder: The layout order of this component in a list.
		callback OnSearchRequested: callback for when the user presses the enter key
			or clicks the search button. This will also be called with an empty string
			when the user clicks "Clear". - OnSearchRequested(searchTerm: string)
		callback OnTextChanged: callback for when the text was changed - OnTextChanged(text: string)
		string PlaceholderText: Placeholder text to show when there is no search term entered.
		string SearchTerm: Search term to populate the text input with.
		boolean ShowSearchButton: Whether to show the search button at the right of the bar (default true).
		boolean ShowSearchIcon: Whether to show an in-line search icon at the left of the Search text (default false).
		Style Style: The style with which to render this component.
		StyleModifier StyleModifier: The StyleModifier index into Style.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.

	Style Values:
		Style BackgroundStyle: The style with which to render the background.
		Enum.Font Font: The font used to render the text in this link.
		Color3 PlaceholderTextColor: The color of the placeholder text.
		number TextSize: The font size of the text in this link.
		Color3 TextColor: The color of the search term text.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local isInputMainPress = Util.isInputMainPress
local Typecheck = Util.Typecheck
local StyleModifier = Util.StyleModifier

local UI = require(Framework.UI)
local Button = UI.Button
local Separator = UI.Separator
local TextInput = UI.TextInput
local Pane = UI.Pane

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local SearchBar = Roact.PureComponent:extend("SearchBar")
Typecheck.wrap(SearchBar, script)

SearchBar.defaultProps = {
	Width = 200,
	ButtonWidth = 24,
	LayoutOrder = 0,
	PlaceholderText = "Search",
	ShowSearchButton = true,
	ShowSearchIcon = false,
} or {}

function SearchBar:init()
	self.state = {
		text = "",
		lastSearchTermAsProp = "",
		isFocused = false,
		isHovered = false,
		shouldFocus = false
	}

	self.mouseEnter = function()
		self:setStateAndStyleModifier({
			isHovered = true
		})
	end

	self.mouseLeave = function()
		self:setStateAndStyleModifier({
			isHovered = false
		})
	end

	self.requestSearch = function()
		if self.props.OnSearchRequested then
			self.props.OnSearchRequested(self.state.text)
		end
	end

	-- Handle clicking in the small gaps between the TextBox and the buttons or the left edge of the SearchBar
	self.onBackgroundInputBegan = function(rbx, input)
		local isMainPress = isInputMainPress(input)
		if isMainPress then
			self:setState({
				shouldFocus = true
			})
		end
	end

	self.onBackgroundFocusLost = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.Focus then
			self:onFocusLost(false)
		end
	end

	self.onTextChanged = function(text)
		self:setState(function(state)
			if state.text == text then
				return
			end

			return {
				text = text
			}
		end)
	end

	self.onTextBoxFocusGained = function(rbx)
		self:setStateAndStyleModifier({
			isFocused = true,
		})
	end

	self.onTextBoxFocusLost = function(enterPressed)
		self:onFocusLost(enterPressed)
	end

	self.onClearButtonClicked = function()
		self:setStateAndStyleModifier({
			text = "",
			isFocused = true,
		})
		self:setState({
			shouldFocus = true
		})

		self.requestSearch()
	end
end

function SearchBar:didUpdate(prevProps, prevState)
	if self.props.OnTextChanged and prevState.text ~= self.state.text then
		self.props.OnTextChanged(self.state.text)
	end
end

--[[
	Set StyleModifier (for Theme.getStyle) based on hover and focus state.

	If the SearchBar is still focused when hover ends, keep the StyleModifier as Hover
]]
function SearchBar:setStateAndStyleModifier(newState)
	self:setState(function(state)
		local isNowFocused = newState.isFocused
		if isNowFocused == nil then
			isNowFocused = state.isFocused
		end

		local isNowHovered = newState.isHovered
		if isNowHovered == nil then
			isNowHovered = state.isHovered
		end

		if isNowFocused or isNowHovered then
			newState.StyleModifier = StyleModifier.Hover
		else
			newState.StyleModifier = Roact.None
		end

		return newState
	end)
end

function SearchBar.getDerivedStateFromProps(nextProps, lastState)
	-- Check if the search term passed in as a prop is different to the last
	-- one passed in. If it is, then that perhaps means the user searched for
	-- something externally (e.g. clicking on a suggestion) or the search
	-- was cleared because the category changed.
	--
	-- In these cases, we should
	-- override our own text value with what was passed in. This check is so
	-- that it only happens once, rather than every time the search bar is
	-- rerendered.
	local searchTerm = nextProps.SearchTerm
	local lastSearchTermAsProp = lastState.lastSearchTermAsProp or ""

	if (searchTerm ~= lastSearchTermAsProp) then
		return {
			text = searchTerm,
			lastSearchTermAsProp = searchTerm
		}
	end

	return {}
end

function SearchBar:onFocusLost(enterPressed)
	self:setStateAndStyleModifier({
		isFocused = false,
		shouldFocus = false
	})

	if enterPressed then
		self.requestSearch()
	end
end

function SearchBar:render()
	local props = self.props
	local state = self.state

	local containerWidth,buttonWidth, layoutOrder, placeholderText, showSearchButton, showSearchIcon
	containerWidth = props.Width
	buttonWidth = props.ButtonWidth
	layoutOrder = props.LayoutOrder
	placeholderText = props.PlaceholderText
	showSearchButton = props.ShowSearchButton
	showSearchIcon = props.ShowSearchIcon

	local shouldFocus = state.shouldFocus
	local text = state.text
	local showClearButton = #text > 0

	local isFocused = state.isFocused
	local isHovered = state.isHovered

	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = props.theme:getStyle("Framework", self)
	end

	local padding = style.Padding
	local borderColor = (isFocused or isHovered) and style.Hover.BorderColor or nil
	local iconWidth = style.IconWidth
	local iconColor = style.IconColor
	local iconOffset = style.IconOffset

	local leftPadding = type(padding) == "table" and padding.Left or padding
	local topPadding = type(padding) == "table" and padding.Top or padding
	local separatorWidth = 1
	local buttonsWidth = (showClearButton and buttonWidth or 0) + (showSearchButton and buttonWidth or 0) + separatorWidth
	local buttonSize = UDim2.new(0, buttonWidth, 1, 0)

	local children = {
		Input = Roact.createElement(Pane, {
			Layout = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			Spacing = iconOffset,
			Padding = iconOffset,
		}, {
			SearchIcon = showSearchIcon and Roact.createElement(Pane, {
				Size = UDim2.fromOffset(iconWidth, iconWidth),
				ScaleType = Enum.ScaleType.Fit,
				LayoutOrder = 1,
				Style = {
					Image = style.SearchIcon,
					Background = iconColor,
				}
			}),

			TextInput = Roact.createElement(TextInput, {
				Position = UDim2.new(0, leftPadding, 0.5, 0),
				Size = UDim2.new(1, -(buttonsWidth + (leftPadding * 2)), 1, -2*topPadding),
				AnchorPoint = Vector2.new(0, 0.5),
				LayoutOrder = 2,
				PlaceholderText = placeholderText,
				Text = text,
				OnTextChanged = self.onTextChanged,
				OnFocusGained = self.onTextBoxFocusGained,
				OnFocusLost = self.onTextBoxFocusLost,
				ShouldFocus = shouldFocus
			}),
		}),

		Buttons = Roact.createElement(Pane, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, buttonsWidth, 1, 0),
			Layout = Enum.FillDirection.Horizontal,
		}, {
			ClearButton = showClearButton and Roact.createElement(Button, {
				Size = buttonSize,
				LayoutOrder = 1,
				OnClick = self.onClearButtonClicked,
				Style = style.Buttons.Clear
			}),

			-- Thin dividing line between the text box and the search button
			Separator = showSearchButton and Roact.createElement(Separator, {
				DominantAxis = Enum.DominantAxis.Height,
				LayoutOrder = 2,
				Position = UDim2.new(0, buttonWidth, 0.5, 0)
			}),

			SearchButton = showSearchButton and Roact.createElement(Button, {
				Size = buttonSize,
				LayoutOrder = 3,
				OnClick = self.requestSearch,
				Style = style.Buttons.Search
			}),
		})
	}

	return Roact.createElement(Pane, {
		Size = UDim2.new(0, containerWidth, 1, 0),
		ClipsDescendants = true,
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		BorderColor = borderColor,
		Style = "BorderBox",
		[Roact.Event.MouseEnter] = self.mouseEnter,
		[Roact.Event.MouseLeave] = self.mouseLeave,
		[Roact.Event.InputBegan] = self.onBackgroundInputBegan,
		[Roact.Event.InputEnded] = self.onBackgroundFocusLost,
	}, children)
end

ContextServices.mapToProps(SearchBar, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return SearchBar
