--[[
	Generic component that manages flow of provided screens. Each screen is given callbacks to control
	the flow.

	Required Props:
		table Screens: list of Roact components that are rendered in the flow (order in list is order in flow)
		callback GetNextIndex: calculates index for the next screen, takes in current index and must return a number
		callback GetPreviousIndex: calculates index for the previous screen, takes in current index and must return a number

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
		self.GoTo(self.props.GetNextIndex(self.state.currentScreenIndex))
	end

	self.GoToPrevious = function()
		self.GoTo(self.props.GetPreviousIndex(self.state.currentScreenIndex))
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