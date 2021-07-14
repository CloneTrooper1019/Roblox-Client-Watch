--[[
	Component that shows a Badge Icon. This is not the same as
	createElement("ImageLabel", {
		Image = "rbxthumb://..."
	})
	as it displays the badge icon with Design's intended look & feel for badge icons (e.g. in a circle and
	specialized loading/load failed indicators), as well as automatically changing the size we request from
	the backend based on the element's size

	Props:
		Id - Badge's iconImageId that will be displayed

	Optional Props:
		Size
		Position
		AnchorPoint
		LayoutOrder
		ZIndex
]]
local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local ContextServices = require(Plugin.Framework.ContextServices)

local AutoThumbnail = require(Plugin.Src.Components.AutoThumbnails.AutoThumbnail)

local BadgeIconThumbnail = Roact.Component:extend(script.Name)

function BadgeIconThumbnail:getThumbnail(contentId, status)
    local props = self.props
    local theme = props.Theme:get("Plugin")

    if status == Enum.AssetFetchStatus.Success then
        return contentId
    elseif status == Enum.AssetFetchStatus.Failure then
        return theme.badgeIconThumbnail.loadFailureImage
    else
        return theme.badgeIconThumbnail.loadingImage
    end
end

function BadgeIconThumbnail:render()
    local props = self.props
    local id = props.Id

    assert(type(id) == "number")

    local size = props.Size and props.Size or UDim2.fromScale(1, 1)
    local position = props.Position
    local anchorPoint = props.AnchorPoint
    local layoutOrder = props.LayoutOrder
    local zIndex = props.ZIndex

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Size = size,
        Position = position,
        AnchorPoint = anchorPoint,
        LayoutOrder = layoutOrder,
        ZIndex = zIndex,
    }, {
        AutoThumbnail = Roact.createElement(AutoThumbnail, {
            Id = id,
            ThumbnailType = "BadgeIcon",
            UseAssetThumbnailUrl = true,
            RenderContents = function(contentId, status)
                local thumbnail = self:getThumbnail(contentId, status)
                
                return Roact.createElement("ImageLabel", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Image = thumbnail,
                })
            end,
        })
    })
end

ContextServices.mapToProps(BadgeIconThumbnail, {
    Theme = ContextServices.Theme,
})

return BadgeIconThumbnail
