--[[

	Component for setting the details of the place we are publishing.
	Allows the user to switch to overwriting an existing place

	Props:
		function OnClose - closure to run to close the QWidget dialog
]]

local StudioService = game:GetService("StudioService")

local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local SettingsImpl = require(Plugin.Src.Network.Requests.SettingsImpl)

local Theming = require(Plugin.Src.ContextServices.Theming)
local Constants = require(Plugin.Src.Resources.Constants)
local UILibrary = require(Plugin.Packages.UILibrary)
local Separator = UILibrary.Component.Separator

local MenuBar = require(Plugin.Src.Components.Menu.MenuBar)
local Footer = require(Plugin.Src.Components.Footer)
local BasicInfo = require(Plugin.Src.Components.BasicInfo)

local SetScreen = require(Plugin.Src.Actions.SetScreen)
local SetPublishInfo = require(Plugin.Src.Actions.SetPublishInfo)

local MENU_ENTRIES = {
	"BasicInfo",
}

local ScreenCreateNewGame = Roact.PureComponent:extend("ScreenCreateNewGame")

function ScreenCreateNewGame:init()
	self.state = {
		selected = 1,
	}

	self.changeSelection = function(index)
		self:setState({
			selected = index,
		})
	end
end

function ScreenCreateNewGame:render(props)
	return Theming.withTheme(function(theme)
		local props = self.props

		local onClose = props.OnClose
		local readyToSave = props.ReadyToSave
		local changed = props.Changed

		local selected = self.state.selected

		local openPublishSuccessfulPage = props.OpenPublishSuccessfulPage

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = theme.backgroundColor,
		}, {
			MenuBar = Roact.createElement(MenuBar, {
				Entries = MENU_ENTRIES,
				Selected = selected,
				SelectionChanged = self.changeSelection,
			}),

			Separator = Roact.createElement(Separator, {
				Weight = 3,
				Position = UDim2.new(0, Constants.MENU_BAR_WIDTH, 0.5, 0),
				DominantAxis = Enum.DominantAxis.Height,
			}),

			Page = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, Constants.MENU_BAR_WIDTH, 0, 0),
				Size = UDim2.new(1, -Constants.MENU_BAR_WIDTH, 1, -Constants.FOOTER_HEIGHT)
			}, {
				Roact.createElement(BasicInfo),
			}),

			Footer = Roact.createElement(Footer, {
				MainButton = {
					Name = "Create",
					Active = readyToSave,
					OnActivated = function()
						SettingsImpl.saveAll(changed)
						StudioService.PlacePublishedToRoblox:wait()
						openPublishSuccessfulPage(game, changed)
					end,
				},
				OnClose = onClose,
				NextScreen = Constants.SCREENS.CHOOSE_GAME,
				NextScreenText = "UpdateExistingGame"
			}),
		})
	end)
end

local function mapStateToProps(state, props)
	local settings = state.NewGameSettings
	return {
		Changed = settings.changed,
		ReadyToSave = next(settings.errors) == nil,
	}
end


local function useDispatchForProps(dispatch)
	return {
		OpenPublishSuccessfulPage = function(place, game)
			dispatch(SetPublishInfo({ id = place.GameId, name = place.Name, parentGameName = game.name, }))
			dispatch(SetScreen(Constants.SCREENS.PUBLISH_SUCCESSFUL))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, useDispatchForProps)(ScreenCreateNewGame)
