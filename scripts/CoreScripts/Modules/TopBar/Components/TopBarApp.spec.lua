return function()
	local CorePackages = game:GetService("CorePackages")
	local RobloxReplicatedStorage = game:GetService("RobloxReplicatedStorage")
	local CoreGui = game:GetService("CoreGui")

	local AppDarkTheme = require(CorePackages.AppTempCommon.LuaApp.Style.Themes.DarkTheme)
	local AppFont = require(CorePackages.AppTempCommon.LuaApp.Style.Fonts.Gotham)

	local Roact = require(CorePackages.Roact)
	local Rodux = require(CorePackages.Rodux)
	local RoactRodux = require(CorePackages.RoactRodux)
	local UIBlox = require(CorePackages.UIBlox)

	local Reducer = require(script.Parent.Parent.Reducer)

	local appStyle = {
		Theme = AppDarkTheme,
		Font = AppFont,
	}

	--Create dummy events in RobloxReplicatedStorage:
	local UpdatePlayerBlockList = Instance.new("RemoteEvent")
	UpdatePlayerBlockList.Name = "UpdatePlayerBlockList"
	UpdatePlayerBlockList.Parent = RobloxReplicatedStorage

	local NewPlayerGroupDetails = Instance.new("RemoteEvent")
	NewPlayerGroupDetails.Name = "NewPlayerGroupDetails"
	NewPlayerGroupDetails.Parent = RobloxReplicatedStorage

	local NewPlayerCanManageDetails = Instance.new("RemoteEvent")
	NewPlayerCanManageDetails.Name = "NewPlayerCanManageDetails"
	NewPlayerCanManageDetails.Parent = RobloxReplicatedStorage

	local RobloxGui = CoreGui:WaitForChild("RobloxGui")
	local SendNotificationInfo = Instance.new("BindableEvent")
	SendNotificationInfo.Name = "SendNotificationInfo"
	SendNotificationInfo.Parent = RobloxGui

	local Sounds = Instance.new("Folder")
	Sounds.Name = "Sounds"
	Sounds.Parent = CoreGui.RobloxGui

	describe("TopBarApp", function()
		it("should create and destroy without errors", function()
			local TopBarApp = require(script.Parent.TopBarApp)

			local store = Rodux.Store.new(Reducer, nil, {
				Rodux.thunkMiddleware,
			})

			local element = Roact.createElement(RoactRodux.StoreProvider, {
				store = store,
			}, {
				ThemeProvider = Roact.createElement(UIBlox.Style.Provider, {
					style = appStyle,
				}, {
					TopBarApp = Roact.createElement(TopBarApp)
				})
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)
	end)
end
