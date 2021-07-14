local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local AssetPreview = require(script.Parent)

local Util = require(Framework.Util)
local Cryo = Util.Cryo

local UI = require(Framework.UI)
local Container = UI.Container

return function()
	local model = Instance.new("Model")
	local part = Instance.new("Part")
	part.Parent = model

	local props = {
		AssetData = {
			Asset = {
				TypeId = 10,
				Updated = "6/14/2016 6:43:37 PM",
				Id = 1234,
				AssetGenres = {},
				Description = "Cause heck, why not? \r\n\r\nA pine tree is cool, right? And here is some very long text that I have added specificially to test wrapping.",
				Name = "Pine Tree with a very long name",
				IsEndorsed = true,
				Created = "10/21/2014 8:59:44 PM"
			},
			Creator = {
				Name = "Someone",
				Type = 1,
				Id = 5678
			},
			Thumbnail = {
				EndpointType = "Avatar",
				Url = "rbxasset://textures/face.png",
				Final = true,
				UserId = 0
			}
		},
		AssetInstance = model,
		ActionText = "Insert",
		OnClickAction = function() end,
		OnClickCreator = function() end,
		OnClickContext = function() end,
		Favorites = {
			Count = 10500,
			IsFavorited = false,
			OnClick = function() end
		},
		Voting = {
			UpVotes = 5,
			DownVotes = 4,
		},
		OnVoteUp = function() end,
		OnVoteDown = function() end,
	}

	return {
		Basic = Roact.createElement(Container, {
			Size = UDim2.new(0, 368, 0, 700)
		}, {
			Roact.createElement(AssetPreview, Cryo.Dictionary.join(props, {
				Size = UDim2.new(0, 368, 1, 0),
			}))
		}),

		BasicNoDescription = Roact.createElement(Container, {
			Size = UDim2.new(0, 368, 0, 700)
		}, {
			Roact.createElement(AssetPreview, Cryo.Dictionary.join(props, {
				Size = UDim2.new(0, 368, 1, 0),
				AssetData = Cryo.Dictionary.join(props.AssetData, {
					Asset = Cryo.Dictionary.join(props.AssetData.Asset, {
						Description = Cryo.None,
					})
				}),
			}))
		}),

		BasicVideo = Roact.createElement(Container, {
			Size = UDim2.new(0, 368, 0, 700)
		}, {
			Roact.createElement(AssetPreview, Cryo.Dictionary.join(props, {
				Size = UDim2.new(0, 368, 1, 0),
				AssetData = Cryo.Dictionary.join(props.AssetData, {
					Asset = Cryo.Dictionary.join(props.AssetData.Asset, {
						Id = 5608250999,
						TypeId = Enum.AssetType.Video.Value,
					})
				}),
			}))
		}),

		BasicWithISODates = Roact.createElement(Container, {
			Size = UDim2.new(0, 368, 0, 700)
		}, {
			Roact.createElement(AssetPreview, Cryo.Dictionary.join(props, {
				Size = UDim2.new(0, 368, 1, 0),
				AssetData = Cryo.Dictionary.join(props.AssetData, {
					Asset = Cryo.Dictionary.join(props.AssetData.Asset, {
						Created = "2014-10-21T08:59:44Z",
						Updated = "2016-06-14T18:43:37Z",
					})
				}),
			}))
		}),

		BasicWithRawDates = Roact.createElement(Container, {
			Size = UDim2.new(0, 368, 0, 700)
		}, {
			Roact.createElement(AssetPreview, Cryo.Dictionary.join(props, {
				Size = UDim2.new(0, 368, 1, 0),
				AssetData = Cryo.Dictionary.join(props.AssetData, {
					Asset = Cryo.Dictionary.join(props.AssetData.Asset, {
						CreatedRaw = "/Date(1413925184257)/",
						UpdatedRaw = "/Date(1413925184257)/",
					})
				}),
			}))
		}),

		NoVoting = Roact.createElement(Container, {
			Size = UDim2.new(0, 368, 0, 700)
		}, {
			Roact.createElement(AssetPreview, Cryo.Dictionary.join(props, {
				Size = UDim2.new(0, 368, 1, 0),
				Voting = Cryo.None,
			}))
		}),

		Scrolling = Roact.createElement(Container, {
			Size = UDim2.new(0, 368, 0, 500)
		}, {
			Roact.createElement(AssetPreview, Cryo.Dictionary.join(props, {
				Size = UDim2.new(0, 368, 1, 0),
			}))
		}),

		Narrow = Roact.createElement(Container, {
			Size = UDim2.new(0, 207, 0, 750)
		}, {
			Roact.createElement(AssetPreview, Cryo.Dictionary.join(props, {
				Size = UDim2.new(0, 207, 1, 0),
			}))
		}),
	}
end