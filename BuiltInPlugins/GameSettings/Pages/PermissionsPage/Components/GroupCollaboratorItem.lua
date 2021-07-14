local Page = script.Parent.Parent
local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local Cryo = require(Plugin.Cryo)

local ContextServices = require(Plugin.Framework.ContextServices)

local UILibrary = require(Plugin.UILibrary)
local createFitToContent = UILibrary.Component.createFitToContent
local ExpandableList = UILibrary.Component.ExpandableList
local Spritesheet = UILibrary.Util.Spritesheet

local PermissionsConstants = require(Page.Util.PermissionsConstants)
local CollaboratorItem = require(Page.Components.CollaboratorItem)
local RolesetCollaboratorItem = require(Page.Components.RolesetCollaboratorItem)
local Separator = require(Plugin.Framework).UI.Separator
local GroupIconThumbnail = require(Plugin.Src.Components.AutoThumbnails.GroupIconThumbnail)

local IsGroupOwner = require(Page.Selectors.IsGroupOwner)
local GetGroupRolesets = require(Page.Selectors.GetGroupRolesets)
local GetGroupPermission = require(Page.Selectors.GetGroupPermission)
local GetGroupName = require(Page.Selectors.GetGroupName)
local RemoveGroupCollaborator = require(Page.Thunks.RemoveGroupCollaborator)
local SetGroupPermission = require(Page.Thunks.SetGroupPermission)

local DEFAULT_ROLESET_VALUE = PermissionsConstants.NoAccessKey
local PERMISSIONS = "Permissions"

local FitToContent = createFitToContent("Frame", "UIListLayout", {
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 0),
})

local arrowSize = 12
local arrowPadding = 4 -- padding between arrow and GroupCollaboratorItem icon

local arrowSpritesheet = Spritesheet("rbxasset://textures/StudioSharedUI/arrowSpritesheet.png", {
	SpriteSize = arrowSize,
	NumSprites = 4,
})

local rightArrowProps = arrowSpritesheet[2]
local downArrowProps = arrowSpritesheet[3]

local GroupCollaboratorItem = Roact.PureComponent:extend("GroupCollaboratorItem")

function GroupCollaboratorItem:init()
	self.state = {
		expanded = false,
	}
end

function GroupCollaboratorItem:getCurrentPermission()
	local props = self.props

	local isOwner = props.IsOwner

	local currentPermission = props.CurrentPermission

	if isOwner then
		return PermissionsConstants.MultipleKey
	else
		return currentPermission
	end
end

function GroupCollaboratorItem:getAvailablePermissions()
	local props = self.props

	local isOwner = props.IsOwner

	local localization = props.Localization

	if isOwner then
		return {}
	else
		return {
			{
				Key = PermissionsConstants.NoAccessKey,
				Display = localization:getText(PERMISSIONS, "NoAccessLabel"),
				Description = localization:getText(PERMISSIONS, "NoAccessDescription"),
			},
			{
				Key = PermissionsConstants.PlayKey,
				Display = localization:getText(PERMISSIONS, "PlayLabel"),
				Description = localization:getText(PERMISSIONS, "PlayDescription"),
			}
		}
	end
end

function GroupCollaboratorItem:render()
	local props = self.props

	local layoutOrder = props.LayoutOrder
	local writable = props.Writable
	local id = props.Id

	local theme = props.Theme:get("Plugin")

	local isOwner = props.IsOwner
	local groupRolesets = props.GroupRolesets
	local groupName = props.GroupName

	local setGroupPermission = props.SetGroupPermission
	local removeGroupCollaborator = props.RemoveGroupCollaborator

	local isLoading = #groupRolesets == 0

	local arrowImageProps = self.state.expanded and downArrowProps or rightArrowProps
	local collaboratorItemOffset = arrowSize + arrowPadding

	local children = {}
	for i, rolesetId in ipairs(groupRolesets) do
		children["Separator"..i] = Roact.createElement(Separator, {
			LayoutOrder = i*2 - 1,
			Size = UDim2.new(1, 0, 0, 1),
		})

		children["RolesetCollaborator"..rolesetId] = Roact.createElement(RolesetCollaboratorItem, {
			LayoutOrder = i*2,
			Id = rolesetId,
			Writable = writable,
			CurrentPermission = DEFAULT_ROLESET_VALUE,
			IsGroupOwner = isOwner,
		})
	end

	children.Padding = Roact.createElement("UIPadding", {
		PaddingLeft = UDim.new(0, 90 - arrowPadding),
	})

	local groupCollaboratorItem = Roact.createElement(CollaboratorItem, {
		Name = groupName,
		Icon = Roact.createElement(GroupIconThumbnail, {
			Id = id,
			Size = UDim2.fromScale(1, 1),
		}),

		Writable = writable and not isOwner,
		Loading = isLoading,

		Removable = not isOwner,
		OnRemoved = function()
			removeGroupCollaborator(id)
		end,

		CurrentPermission = self:getCurrentPermission(),
		AvailablePermissions = self:getAvailablePermissions(),
		OnPermissionChanged = function(newPermission)
			setGroupPermission(id, newPermission)
		end,
	})

	return Roact.createElement(ExpandableList, {
		LayoutOrder = layoutOrder,

		TopLevelItem = {
			Frame = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 0,
				-- TODO (awarwick) 5/29/2019. We're using hardcoded sizes now because this design is a WIP
				-- and we don't want to spend the engineering resources on somethat that could drastically change
				Size = UDim2.new(1, 0, 0, 60),
			}, {
				CollapseArrow = Roact.createElement("ImageLabel", Cryo.Dictionary.join(arrowImageProps, {
					Size = UDim2.new(0, arrowSize, 0, arrowSize),
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 0, 0.5, 0),
					BackgroundTransparency = 1,
					ImageColor3 = theme.collaboratorItem.collapseStateArrow,
				})),

				Frame = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -collaboratorItemOffset, 1, 0),
					Position = UDim2.new(0, collaboratorItemOffset, 0, 0),
				}, {
					GroupCollaborator = groupCollaboratorItem,
				}),
			}),
		},

		Content = {
			RoleCollaborators = Roact.createElement(FitToContent, {
				LayoutOrder = 1,
				BackgroundTransparency = 1,
			}, children)
		},

		IsExpanded = self.state.expanded and not isLoading,
		OnExpandedStateChanged = function()
			if isLoading then return end
			self:setState({
				expanded = not self.state.expanded,
			})
		end,
	})
end

ContextServices.mapToProps(GroupCollaboratorItem, {
	Theme = ContextServices.Theme,
	Localization = ContextServices.Localization,
})

GroupCollaboratorItem = RoactRodux.connect(
	function(state, props)
		return {
			IsOwner = IsGroupOwner(state, props.Id),
			GroupRolesets = GetGroupRolesets(state, props.Id),
			GroupName = GetGroupName(state, props.Id),
			CurrentPermission = GetGroupPermission(state, props.Id),
		}
	end,
	function(dispatch)
		return {
			SetGroupPermission = function(...)
				dispatch(SetGroupPermission(...))
			end,
			RemoveGroupCollaborator = function(...)
				dispatch(RemoveGroupCollaborator(...))
			end,
		}
	end
)(GroupCollaboratorItem)


return GroupCollaboratorItem