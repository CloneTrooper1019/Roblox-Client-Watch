return function()
    local Library = script.Parent.Parent.Parent
    local Roact = require(Library.Parent.Parent.Roact)

    local MockWrapper = require(Library.MockWrapper)

	local AssetPreview = require(Library.Components.Preview.AssetPreview)

	local function createTestAsset(container, name)
		local testModel = Instance.new("Model")

		local assetData = {
			Asset = {
				Id = 123456,
				Description = "This is a test asset",
				Created = "",
				Updated = "",
				AssetGenres = {},
			},

			Creator = {
				Name = "Roblox Studio",
			},
		}

		local element = Roact.createElement(MockWrapper, {}, {
			AssetPreview = Roact.createElement(AssetPreview, {
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				AssetData = assetData,
				CurrentPreview = testModel,

				ShowInstallationBar = true,
				InstallDisabled = false,
				ShowRobuxIcon = true,
				LoadingBarText = "Installing",

				FavoriteCounts = 1000,
				Favorited = true,
				OnFavoritedActivated = function() end,

				OnTreeItemClicked = function() end,
				TryCreateContextMenu = function() end,
				SearchByCreator = function() end,

				Voting = {},
				OnVoteUp = function() end,
				OnVoteDown = function() end,

				ActionBarText = "Insert",
				CanInsertAsset = true,
				TryInsert = function() end,

				MaxPreviewWidth = 250,
				MaxPreviewHeight = 400,

				ZIndex = 0,

				PurchaseFlow = Roact.createElement("Frame"),
				SuccessDialog = Roact.createElement("Frame"),
			})
		})

		return Roact.mount(element, container or nil, name or "")
	end

	it("should create and destroy without errors", function()
		local instance = createTestAsset()
		Roact.unmount(instance)
	end)
end