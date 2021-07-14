--[[
	Component that automatically handles the asynchronous loading of thumbnails and requesting the appropriate
	size thumbnail from the backend based on the size of the element.

	Props:
		Id - Id of the subject whose thumbnail we are fetching
		ThumbnailType - Type of thumbnail we are fetching (see https://developer.roblox.com/en-us/articles/Content#rbxthumb)
		RenderContents function(string contentId, Enum.AssetFetchStatus status) - Callback used to create the
			thumbnail element. This callback should return a single element whose size is UDim2.new(1, 0, 1, 0)
]]
local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Roact)

local ContentProvider = game:GetService("ContentProvider")

-- TODO (awarwick) 5/17/2020 We should probably expose this from the engine rather than hardcoding it
local VALID_SIZES = {
	GroupIcon = {
		Vector2.new(150, 150),
		Vector2.new(420, 420),
	},
	AvatarHeadShot = {
		Vector2.new(48, 48),
		Vector2.new(60, 60),
		Vector2.new(150, 150),
	},
    Avatar = {
		Vector2.new(100, 100),
		Vector2.new(352, 352),
		Vector2.new(720, 720),
	},
	GameIcon = {
		Vector2.new(50, 50),
		Vector2.new(128, 128),
		Vector2.new(150, 150),
		Vector2.new(256, 256),
		Vector2.new(512, 512),
	},
	BadgeIcon = {
		Vector2.new(150, 150),
	},
	GamePass = {
		Vector2.new(150, 150),
	},
	Asset = {
		Vector2.new(150, 150),
		Vector2.new(420, 420),
	},
	BundleThumbnail = {
		Vector2.new(150, 150),
		Vector2.new(420, 420),
	},
	Outfit = {
		Vector2.new(150, 150),
		Vector2.new(420, 420),
	},
}

local function getRbxthumbSize(thumbnailType, elementAbsoluteSize)
	local validSizes = VALID_SIZES[thumbnailType]
	local closestSize = validSizes[1]

	for i=2, #validSizes do
		local thisSize = validSizes[i]
		local closestDistance = math.abs(elementAbsoluteSize.Magnitude - closestSize.Magnitude)
		local thisDistance = math.abs(elementAbsoluteSize.Magnitude - thisSize.Magnitude)
		if thisDistance < closestDistance then
			closestSize = thisSize
		end
	end

	return closestSize
end

local function getRbxthumbUrl(thumbnailType, id, size)
	return "rbxthumb://type="..thumbnailType.."&id="..id.."&w="..size.X.."&h="..size.Y
end

local function getAssetThumbnailUrl(id, size)    
    return "https://www.roblox.com/asset-thumbnail/image?width="..size.X.."&height="..size.Y.."&format=png&assetId="..id
end

local AutoThumbnail = Roact.Component:extend(script.Name)

function AutoThumbnail:init()
	self.state = {
		fetchStatus = nil,
		contentId = nil,
	}

	self.ref = Roact.createRef()
	self.fetchingContentId = nil
	self.currentId = nil
	self.currentThumbnailType = nil

	self.updateThumbnail = function()
		local props = self.props
		local thumbnailType = props.ThumbnailType
		local id = props.Id
		local useAssetThumbnailUrl = props.UseAssetThumbnailUrl

		local ref = self.ref

		if not ref:getValue() then return end

		local absoluteSize = ref:getValue().AbsoluteSize
		local thumbnailSize = getRbxthumbSize(thumbnailType, absoluteSize)
		local contentId

		if useAssetThumbnailUrl then
			contentId = getAssetThumbnailUrl(id, thumbnailSize)
		else
			contentId = getRbxthumbUrl(thumbnailType, id, thumbnailSize)
		end

		if id ~= self.currentId or thumbnailType ~= self.currentThumbnailType then
			self.currentId = id
			self.currentThumbnailType = thumbnailType
			self:setState({
				fetchStatus = Roact.None,
				contentId = contentId,
			})
		end

		if contentId ~= self.state.contentId then
			self.loadThumbnail(contentId)
		end
	end

	self.loadThumbnail = function(contentId)
		if contentId == self.fetchingContentId then return end

		self.fetchingContentId = contentId

		coroutine.wrap(function()
			ContentProvider:PreloadAsync({ contentId }, function(contentId, status)
				local isMounted = self.ref:getValue() ~= nil
				if self.fetchingContentId == contentId and isMounted then
					self.fetchingContentId = nil
					self:setState({
						fetchStatus = status,
						contentId = contentId,
					})
				end
			end)
		end)()
	end
end

function AutoThumbnail:didUpdate(previousProps, previousState)
	local props = self.props

	local oldId = previousProps.Id
	local newId = props.Id
	local oldThumbnailType = previousProps.ThumbnailType
	local newThumbnailType = props.ThumbnailType
	if oldId ~= newId or oldThumbnailType ~= newThumbnailType then
		self.updateThumbnail()
	end
end

function AutoThumbnail:didMount()
	self.updateThumbnail()
end

function AutoThumbnail:render()
	local props = self.props
	local state = self.state

	local renderContents = props.RenderContents

	local contentId = state.contentId
	local fetchStatus = state.fetchStatus

	-- This Frame doesn't serve any visual purpose. It exists only to get the absolute size of the thumbnail
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),

		[Roact.Ref] = self.ref,
		[Roact.Change.AbsoluteSize] = self.updateThumbnail,
	}, {
		Thumbnail = renderContents(contentId, fetchStatus)
	})
end

return AutoThumbnail
