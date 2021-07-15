return function()
	local CoreGui = game:GetService("CoreGui")
	local CorePackages = game:GetService("CorePackages")
	local RobloxReplicatedStorage = game:GetService("RobloxReplicatedStorage")

	local Roact = require(CorePackages.Roact)
	local RoactRodux = require(CorePackages.RoactRodux)
	local Rodux = require(CorePackages.Rodux)
	local UIBlox = require(CorePackages.UIBlox)

	local PlayerList = script.Parent.Parent.Parent
	local Reducers = PlayerList.Reducers
	local Reducer = require(Reducers.Reducer)

	local Connection = PlayerList.Components.Connection
	local LayoutValues = require(Connection.LayoutValues)
	local LayoutValuesProvider = LayoutValues.Provider

	local CreateLayoutValues = require(PlayerList.CreateLayoutValues)

	local Actions = PlayerList.Actions
	local SetTenFootInterface = require(Actions.SetTenFootInterface)

	--Create dummy events in RobloxReplicatedStorage:
	local NewPlayerGroupDetails = Instance.new("RemoteEvent")
	NewPlayerGroupDetails.Name = "NewPlayerGroupDetails"
	NewPlayerGroupDetails.Parent = RobloxReplicatedStorage

	local RobloxGui = CoreGui:WaitForChild("RobloxGui")
	local SendNotificationInfo = Instance.new("BindableEvent")
	SendNotificationInfo.Name = "SendNotificationInfo"
	SendNotificationInfo.Parent = RobloxGui

	local PlayerListApp = require(script.Parent.PlayerListApp)

	local AppDarkTheme = require(CorePackages.AppTempCommon.LuaApp.Style.Themes.DarkTheme)
	local AppFont = require(CorePackages.AppTempCommon.LuaApp.Style.Fonts.Gotham)

	local appStyle = {
		Theme = AppDarkTheme,
		Font = AppFont,
	}

	it("should create and destroy without errors", function()
		local element = Roact.createElement(RoactRodux.StoreProvider, {
			store = Rodux.Store.new(Reducer, nil, {
				Rodux.thunkMiddleware,
			})
		}, {
			LayoutValuesProvider = Roact.createElement(LayoutValuesProvider, {
				layoutValues = CreateLayoutValues(false)
			}, {
				ThemeProvider = Roact.createElement(UIBlox.Style.Provider, {
					style = appStyle,
				}, {
					PlayerListApp = Roact.createElement(PlayerListApp),
				})
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors tenfoot", function()
		local store = Rodux.Store.new(Reducer, nil, {
			Rodux.thunkMiddleware,
		})
		store:dispatch(SetTenFootInterface(true))

		local element = Roact.createElement(RoactRodux.StoreProvider, {
			store = store
		}, {
			LayoutValuesProvider = Roact.createElement(LayoutValuesProvider, {
				layoutValues = CreateLayoutValues(true)
			}, {
				ThemeProvider = Roact.createElement(UIBlox.Style.Provider, {
					style = appStyle,
				}, {
					PlayerListApp = Roact.createElement(PlayerListApp),
				})
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
