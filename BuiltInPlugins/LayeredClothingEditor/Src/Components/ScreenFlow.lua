--[[
	Generic component that manages flow of provided screens. Each screen is given callbacks to control
	the flow.

	Required Props:
		table Screens: list of Roact components that are rendered in the flow (order in list is order in flow)

	Optional Props:
		callback OnScreenChanged: fired whenever a the flow has changed screens.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local Util = Framework.Util

local ScreenFlow = Roact.PureComponent:extend("ScreenFlow")

local Typecheck = Util.Typecheck
Typecheck.wrap(ScreenFlow, script)

function ScreenFlow:init(initialProps)
	self.state = {
		currentScreenIndex = 1
	}

	self.GoToNext = function()
		local props = self.props
		local state = self.state

		local screens = props.Screens

		-- cycling behavior
		local newIndex = (state.currentScreenIndex + 1) % #screens
		newIndex = newIndex == 0 and #screens or newIndex
		self.GoTo(newIndex)
	end

	self.GoToPrevious = function()
		local state = self.state
		local newIndex = state.currentScreenIndex - 1
		self.GoTo(newIndex)
	end

	self.GoTo = function(index)
		local props = self.props

		local screens = props.Screens
		index = math.clamp(index, 1, #screens)
		self:setState({
			currentScreenIndex = index,
		})

		if self.props.OnScreenChanged then
			self.props.OnScreenChanged(index)
		end
	end
end

function ScreenFlow:render()
	local props = self.props
	local state = self.state

	local screens = props.Screens
	local currentScreenIndex = state.currentScreenIndex
	local currentScreen = screens[currentScreenIndex]

	return Roact.createElement(currentScreen, {
		GoToNext = self.GoToNext,
		GoToPrevious = self.GoToPrevious,
	})
end

return ScreenFlow