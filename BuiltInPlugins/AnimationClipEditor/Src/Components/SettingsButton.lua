--[[
	A settings button which displays on the top right of the editor.
	Displays a menu when the user clicks on the button.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local Constants = require(Plugin.Src.Util.Constants)
local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local SettingsMenu = require(Plugin.Src.Components.SettingsMenu)

local SettingsButton = Roact.PureComponent:extend("SettingsButton")

function SettingsButton:init()
	self.state = {
		showMenu = false,
	}

	self.showMenu = function()
		self:setState({
			showMenu = true,
		})
	end

	self.hideMenu = function()
		self:setState({
			showMenu = false,
		})
	end

	self.mouseEnter = function()
		if self.props.Mouse then
			self.props.Mouse:__pushCursor("PointingHand")
		end
	end

	self.mouseLeave = function()
		if self.props.Mouse then
			self.props.Mouse:__popCursor()
		end
	end
end

function SettingsButton:willUnmount()
	self.props.Mouse:__resetCursor()
end


function SettingsButton:render()
		local props = self.props
		local state = self.state
		local theme = props.Theme:get("PluginTheme")

		local onChangeFPS = props.OnChangeFPS

		return Roact.createElement("ImageButton", {
			BackgroundColor3 = theme.backgroundColor,
			BorderColor3 = theme.borderColor,
			Size = UDim2.new(0, Constants.SCROLL_BAR_SIZE, 0, Constants.TIMELINE_HEIGHT),
			Image = theme.settingsButtonTheme.image,
			ScaleType = Enum.ScaleType.Fit,
			ImageColor3 = theme.settingsButtonTheme.imageColor,
			AutoButtonColor = false,

			[Roact.Event.Activated] = self.showMenu,
			[Roact.Event.MouseEnter] = self.mouseEnter,
			[Roact.Event.MouseLeave] = self.mouseLeave,
		}, {
			SettingsMenu = Roact.createElement(SettingsMenu, {
				ShowMenu = state.showMenu,
				OnMenuOpened = self.hideMenu,
				OnChangeFPS = onChangeFPS,
			}),
		})
end

ContextServices.mapToProps(SettingsButton, {
	Mouse = ContextServices.Mouse,
	Theme = ContextServices.Theme,
})


return SettingsButton