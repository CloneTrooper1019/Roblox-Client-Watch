local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local AssetRender = require(script.Parent)

return function()
	-- Asset IDs used in examples are Roblox-owned

	local testVideoId = 5608250999
	local testSoundId = 1838601237

	local model = Instance.new("Model")
	local part = Instance.new("Part")
	part.Parent = model
	local otherPart = Instance.new("Part")
	otherPart.Name = "otherPart"
	otherPart.Parent = model

	local decal = Instance.new("Decal")
	decal.Texture = "http://www.roblox.com/asset/?id=23156312"

	local modelWithSound = Instance.new("Model")
	local part2 = Instance.new("Part")
	part2.Parent = modelWithSound
	local sound = Instance.new("Sound")
	sound.Parent = modelWithSound
	sound.SoundId = "rbxassetid://1837461008"

	local modelWithScript = Instance.new("Model")
	local part3 = Instance.new("Part")
	part3.Parent = modelWithScript
	local grandchild = Instance.new("Part")
	grandchild.Name = "Grandchild"
	grandchild.Parent = part3
	local myScript = Instance.new("Script")
	myScript.Name = "MyScript"
	myScript.Source = [[
		error("Hello world from AssetRender")
	]]
	myScript.Parent = modelWithScript

	local dummyAssetData = {
		Asset = {}
	}

	local width = 360

	return {
		Loading = Roact.createElement(AssetRender, {
			Width = width,
			AssetData = dummyAssetData,
		}),
		Model = Roact.createElement(AssetRender, {
			Width = width,
			AssetInstance = model,
			AssetData = dummyAssetData,
		}),
		Plugin = Roact.createElement(AssetRender, {
			Width = width,
			AssetData = {
				Asset = {
					Id = 2525227847,
					TypeId = Enum.AssetType.Plugin.Value
				}
			},
		}),
		Thumbnail = Roact.createElement(AssetRender, {
			Width = width,
			AssetInstance = myScript,
			AssetData = dummyAssetData,
		}),
		Image = Roact.createElement(AssetRender, {
			Width = width,
			AssetInstance = decal,
			AssetData = dummyAssetData,
		}),
		Sound = Roact.createElement(AssetRender, {
			Width = width,
			AssetInstance = Instance.new("Sound"),
			AssetData = {
				Asset = {
					Id = testSoundId
				}
			}
		}),
		Video = Roact.createElement(AssetRender, {
			Width = width,
			AssetInstance = Instance.new("VideoFrame"),
			AssetData = {
				Asset = {
					Id = testVideoId
				}
			}
		}),
		SoundDisableTreeView = Roact.createElement(AssetRender, {
			Width = width,
			AssetInstance = Instance.new("Sound"),
			DisableTreeView = true,
			AssetData = {
				Asset = {
					Id = testSoundId
				}
			}
		}),
		VideoDisableTreeView = Roact.createElement(AssetRender, {
			Width = width,
			AssetInstance = Instance.new("VideoFrame"),
			DisableTreeView = true,
			AssetData = {
				Asset = {
					Id = testVideoId
				}
			}
		}),
		SoundInModel = Roact.createElement(AssetRender, {
			Width = width,
			AssetInstance = modelWithSound,
			AssetData = dummyAssetData,
		}),
		ScriptInModel = Roact.createElement(AssetRender, {
			Width = width,
			AssetInstance = modelWithScript,
			AssetData = dummyAssetData,
		})
	}
end