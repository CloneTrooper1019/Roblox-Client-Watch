--[[
	Wraps theme styles and update logic into a ContextItem.

	Theme.new(createStyles):
		Constructs a new Theme.

		Params:
			function createStyles(theme, getColor):
				A function that returns a mapping of component names to style tables.
				The getColor function is used to get a Color from the Palette at the given
				name, based on what the current Studio theme is.
				Theme is also passed so that it can be used to index into any StyleValues
				that may have been defined by the user or other external sources.

	Theme:getStyle(namespace, element):
		Gets the style table for the current element.
		The table will be indexed into based on the element's Style prop
		and StyleModifier prop or state. If neither of these are provided,
		it will get the Default style in the table.

		Params:
			string namespace = The namespace to acquire the style table at.
			Element element = The Roact element instance to acquire the style
				table at. If an element is calling this, it will pass 'self'.

	Theme:get(namespace):
		Gets the set of style tables at the given namespace.

		Params:
			string namespace = The namespace to acquire the tables at.

	Example usage:
		-- makeTheme
		local Theme = ContextHelpers.Theme
		local function makeTheme()
			local pluginTheme = {
				TextBox = {
					Default = {
						TextColor = Color3.new(),
						Font = Enum.Font.SourceSans,
					},
				},
			}

			return Theme.new(function(theme, getColor)
				return {
					Framework = StudioFrameworkStyles.new(theme, getColor),
					Plugin = pluginTheme,
				}
			end)
		end
		return makeTheme

		--TextBox
		local TextBox = Roact.PureComponent:extend("TextBox")

		function TextBox:render()
			local props = self.props
			local theme = props.Theme
			local style = theme:getStyle("Plugin", self)

			return Roact.createElement("TextBox", {
				TextColor3 = style.TextColor,
				Font = style.Font,
			})
		end

		ContextServices.mapToProps(TextBox, {
			Theme = ContextServices.Theme,
		})

		return TextBox
]]

local noValuesError = [[
No StyleTable was defined for component '%s'.
You need to define a StyleTable for the component in the theme.]]

local noDefaultsError = [[
No default Style was defined for component '%s'.
You need to create a 'style.lua' file in the component's folder.]]

local noFallbackError = [[
No '%s' Style was defined for component '%s', and there were no defaults to fall back to.
You need to create a 'style.lua' file in the component's folder.]]

local noStyleWarning = [[
No '%s' Style was defined for component '%s', so it fell back to the Default Style.
Check to see if there is a typo in the style name, or a missing entry in the StyleTable.]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextItem = require(Framework.ContextServices.ContextItem)
local Provider = require(Framework.ContextServices.Provider)
local Util = require(Framework.Util)
local Signal = Util.Signal
local Immutable = Util.Immutable
local Palette = Util.Palette

local Theme = ContextItem:extend("Theme")

function Theme.new(createStyles)
	assert(type(createStyles) == "function", "Theme.new expects a 'createStyles' function.")

	local self = {
		getTheme = function()
			return settings().Studio.Theme
		end,

		createStyles = function(...)
			return createStyles(...)
		end,

		valuesChanged = Signal.new(),
		values = {},
		themeChangedConnection = nil,
	}
	setmetatable(self, Theme)

	self:__recalculateTheme()

	local signal = settings().Studio.ThemeChanged
	self.themeChangedConnection = signal:Connect(function()
		self:__recalculateTheme()
	end)

	return self
end

function Theme:createProvider(root)
	return Roact.createElement(Provider, {
		ContextItem = self,
		UpdateSignal = self.valuesChanged,
	}, {root})
end

function Theme:get(namespace)
	if self.values[namespace] then
		return self.values[namespace]
	else
		error(string.format("Invalid Theme namespace: %s", namespace))
	end
end

function Theme:getStyle(namespace, component)
	local values = self:get(namespace)
	local name = component.__componentName
	local style = component.props.Style
	local modifier = component.props.StyleModifier or component.state.StyleModifier

	assert(values[name], string.format(noValuesError, name))

	-- Get the values at the current style
	local styledValues
	if style then
		if type(style) == "table" then
			styledValues = style
		elseif type(style) == "string" then
			styledValues = values[name][style] or values[name].Default
			assert(styledValues, string.format(noFallbackError, style, name))

			if values[name][style] == nil then
				warn(string.format(noStyleWarning, style, name))
			end
		end
	else
		assert(values[name].Default, string.format(noDefaultsError, name))
		styledValues = values[name].Default
	end

	-- If values were found at a StyleModifier, apply fallbacks
	if modifier and styledValues[modifier] then
		local modified = styledValues[modifier]
		setmetatable(modified, {
			__index = styledValues,
		})

		for k, v in pairs(modified) do
			if type(v) == "table" and styledValues[k] then
				setmetatable(v, {
					__index = styledValues[k],
				})
			end
		end

		styledValues = modified
	end

	return styledValues
end

function Theme:__update(changedValues)
	self.values = Immutable.JoinDictionaries(self.values, changedValues)

	if self.valuesChanged then
		self.valuesChanged:Fire(self)
	end
end

function Theme:__recalculateTheme()
	local theme = self.getTheme()

	local function getColor(colorName)
		return Palette[colorName]:get(theme.Name)
	end

	local newValues = self.createStyles(theme, getColor)

	self:__update(newValues)
end

function Theme:destroy()
	if self.themeChangedConnection then
		self.themeChangedConnection:Disconnect()
	end
end

-- Creates a new mock theme.
-- createStyles: A function used to construct a table of theme values.
-- getTheme: A function used to get the current theme.
-- themeChanged: A Signal used to fire a theme change.
function Theme.mock(createStyles, getTheme, themeChanged)
	assert(type(createStyles) == "function", "Theme.mock expects a 'createStyles' function.")
	assert(type(getTheme) == "function", "Theme.mock expects a 'getTheme' function.")

	local self = {
		getTheme = function()
			return getTheme()
		end,

		createStyles = function(...)
			return createStyles(...)
		end,

		valuesChanged = Signal.new(),
		values = {},
		themeChangedConnection = nil,
	}

	setmetatable(self, Theme)

	if themeChanged then
		self.themeChangedConnection = themeChanged:Connect(function()
			self:__recalculateTheme()
		end)
	end

	self:__recalculateTheme()

	return self
end

return Theme
