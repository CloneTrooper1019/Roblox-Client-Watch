--[[
	This component displays information about a collaborator (user/group/roleset).
	Thumbnail, name (of the user/group/roleset), and permissions are part of the information that is displayed.

	Necessary Properties:
	CollaboratorName = string, name of collaborator. displayed in primary label
	CollaboratorId = num, for external scripts to check whose permission changed when we fire events
	CollaboratorIcon = string, path to icon to display for item (e.g. user headshot, group logo, etc)
	Action = string, permission level the collaborator has (Own | Edit | UseView | No Access (rolesets only))
	
	Optional Properties:
	HideLastSeparator = bool, default to false. If true the last separator will be hidden so that separators don't overlap.
	LayoutOrder = num, default to 0.
	Removable = bool, if true then the delete button is visible and can be clicked.
	Removed = function, callback function for when the delete button is clicked.
	RolePermissionChanged = function, callback function for when a user who has had this package shared with them, has their
		permissions changed.
]]
local FFlagToolboxReplaceUILibraryComponentsPt3 = game:GetFastFlag("ToolboxReplaceUILibraryComponentsPt3")

local ITEM_HEIGHT = 60
local PADDING_Y = 10
local PADDING_X = 6
local CONTENT_HEIGHT = ITEM_HEIGHT - PADDING_Y
local LIST_PADDING = 30
local DROPDOWN_WIDTH = 120
local DROPDOWN_ICON_SIZE = 20
local CLOSE_ICON_SIZE = 16
local DROPDOWN_ITEM_WIDTH = 300

local Plugin = script.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local UILibrary = require(Libs.UILibrary)

local Button
local DropdownMenu
local IconButton
local DetailedDropdown
local DetailedDropdownItem
local LoadingIndicator
if FFlagToolboxReplaceUILibraryComponentsPt3 then
	local Framework = require(Libs.Framework)
	DropdownMenu = Framework.UI.DropdownMenu
	DetailedDropdownItem = require(Plugin.Core.Components.AssetConfiguration.Permissions.DetailedDropdownItem)
	IconButton = Framework.UI.IconButton
else
	DetailedDropdown = UILibrary.Component.DetailedDropdown
	LoadingIndicator = UILibrary.Component.LoadingIndicator
	Button = UILibrary.Component.Button
end

local Util = Plugin.Core.Util
local Images = require(Util.Images)
local Constants = require(Util.Constants)
local ContextHelper = require(Util.ContextHelper)
local withTheme = ContextHelper.withTheme

local PermissionsDirectory = Plugin.Core.Components.AssetConfiguration.Permissions
local CollaboratorThumbnail = require(PermissionsDirectory.CollaboratorThumbnail)

local ContentProvider = game:GetService("ContentProvider")

local CollaboratorItem = Roact.PureComponent:extend("CollaboratorItem")

local function DeleteButton(props)
	if not FFlagToolboxReplaceUILibraryComponentsPt3 then
		return withTheme(function(theme)
			return Roact.createElement(Button, {
				Size = UDim2.new(0, CONTENT_HEIGHT, 0, CONTENT_HEIGHT),
				Position = UDim2.new(1, 0, 0, 0),
				AnchorPoint = Vector2.new(1, 0),

				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				RenderContents = function(buttonTheme, hovered)
					return {
						Icon = Roact.createElement("ImageLabel", {
							Size = UDim2.new(0, CLOSE_ICON_SIZE, 0, CLOSE_ICON_SIZE),
							Position = UDim2.new(0.5, 0, 0.5, 0),
							AnchorPoint = Vector2.new(0.5, 0.5),

							Image = Images.CLOSE_ICON,
							ImageColor3 = theme.assetConfig.packagePermissions.collaboratorItem.deleteButton,
							ImageTransparency = hovered and 0 or 0.4,

							BackgroundTransparency = 1,
							BorderSizePixel = 0,
						})
					}
				end,

				OnClick = function()
					if props.Enabled and props.OnClicked then
						props.OnClicked()
					end
				end,
			})
		end)
	end
end

if (not FFlagToolboxReplaceUILibraryComponentsPt3) then
	local function LoadingDropdown(props)
		return withTheme(function(theme)
			return Roact.createElement(LoadingIndicator, {
				LayoutOrder = props.LayoutOrder or 0,
				Size = props.Size,
				Position = props.Position,
				AnchorPoint = props.AnchorPoint,
			})
		end)
	end
end

local function CollaboratorIcon(props)
	return Roact.createElement(CollaboratorThumbnail, {
		Size = UDim2.new(0, CONTENT_HEIGHT, 0, CONTENT_HEIGHT),
		LayoutOrder = props.LayoutOrder or 0,
		Image = props.IsLoadedThumbnail and props.CollaboratorIcon or props.DefaultIcon,
		UseMask = props.UseMask,
		IsLoadedThumbnail = props.IsLoadedThumbnail,
	})
end

local function CollaboratorLabels(props)
	return withTheme(function(theme)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, -(LIST_PADDING*4 + CONTENT_HEIGHT + DROPDOWN_WIDTH), 0, CONTENT_HEIGHT),
			Position = UDim2.new(0, CONTENT_HEIGHT + LIST_PADDING, 0, 0),
			LayoutOrder = props.LayoutOrder or 0,

			BackgroundTransparency = 1,
		}, {
			PrimaryLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, props.SecondaryText and 0.5 or 1, 0),
				Text = props.CollaboratorName or "",
				TextXAlignment = Enum.TextXAlignment.Left,

				Font = Constants.FONT,
				TextSize = Constants.FONT_SIZE_TITLE,
				TextColor3 = theme.assetConfig.packagePermissions.subTextColor,
				TextTruncate = Enum.TextTruncate.AtEnd,

				BackgroundTransparency = 1,
			}),
		})
	end)
end

function CollaboratorItem:init()
	self.state = {
		assetFetchStatus = nil,
		showDropdown = false,
	}

	self.isMounted = false

	self.onItemActivated = function(item)
		local props = self.props
		if props.Enabled and props.PermissionChanged then
			props.PermissionChanged(item.Key)
		end
		self.toggleDropdown(false)
	end

	self.onDropdownRenderItem = function(item, index)
		return Roact.createElement(DetailedDropdownItem, {
			Key = item.Key,
			Description = item.Description,
			OnActivated = function() self.onItemActivated(item) end,
			Selected = item.Key == self.props.SelectedItem,
			Title = item.Display,
		})
	end

	self.toggleDropdown = function(isShow)
		self:setState({
			showDropdown = isShow,
		})
	end

	self.onDelete = function()
		local props = self.props
		if props.Enabled and props.Removed then
			props.Removed()
		end
	end
end

function CollaboratorItem:didMount()
	self.isMounted = true
	spawn(function()
		local asset = { self.props.CollaboratorIcon }
		local function setStatus(contentId, status)
			if self.isMounted then
				self:setState({
					assetFetchStatus = status
				})
			end
		end
		ContentProvider:PreloadAsync(asset, setStatus)
	end)
end

function CollaboratorItem:willUnmount()
	self.isMounted = false
end

function CollaboratorItem:render()
	return withTheme(function(theme)
		local props = self.props

		props.Items = props.Items or {}

		local removable = props.Removable and #props.Items > 0 and not props.IsLoading

		local isLoadedThumbnail = self.state.assetFetchStatus == Enum.AssetFetchStatus.Success

		local defaultIcon = nil
		-- only user thumbnail uses mask
		if props.SubjectType == Enum.CreatorType.User then
			defaultIcon = Images.DEFAULT_USER_THUMBNAIL
		else
			defaultIcon = Images.DEFAULT_GROUP_THUMBNAIL
		end

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, ITEM_HEIGHT),
			LayoutOrder = props.LayoutOrder or 0,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Contents = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BackgroundColor3 = theme.assetConfig.packagePermissions.backgroundColor,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, PADDING_X),
					PaddingRight = UDim.new(0, PADDING_X),
					PaddingTop = UDim.new(0, PADDING_Y),
					PaddingBottom = UDim.new(0, PADDING_Y),
				}),
				Icon = props.CollaboratorIcon ~= nil and Roact.createElement(CollaboratorIcon, {
					LayoutOrder = 0,
					Enabled = props.Enabled,

					UseMask = props.UseMask,
					CollaboratorIcon = props.CollaboratorIcon,
					DefaultIcon = defaultIcon,
					IsLoadedThumbnail = isLoadedThumbnail,
				}),
				Labels = Roact.createElement(CollaboratorLabels, {
					LayoutOrder = 1,
					Enabled = props.Enabled,

					CollaboratorName = props.CollaboratorName,
					SecondaryText = props.SecondaryText,
				}),
				DropdownFrame = FFlagToolboxReplaceUILibraryComponentsPt3 and Roact.createElement("Frame",{
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -(CONTENT_HEIGHT+LIST_PADDING), 0, 0),
					Size = UDim2.new(0, DROPDOWN_WIDTH, 0, CONTENT_HEIGHT),
				}, {
					Dropdown = Roact.createElement(DropdownMenu, {
						Hide = (not (props.Enabled and #props.Items > 0)) or (not self.state.showDropdown),
						OnFocusLost = function() self.toggleDropdown(false) end,
						Items = props.Items,
						OnRenderItem = self.onDropdownRenderItem,
						Width = DROPDOWN_ITEM_WIDTH,
					}),
				}),
				Dropdown = FFlagToolboxReplaceUILibraryComponentsPt3 and Roact.createElement(IconButton, {
					Disabled = not (props.Enabled and #props.Items > 0),
					RightIcon = "rbxasset://textures/StudioToolbox/ArrowDownIconWhite.png",
					Text = props.Action,
					OnClick = function() self.toggleDropdown(true) end,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -(CONTENT_HEIGHT+LIST_PADDING), 0, 0),
					Size = UDim2.new(0, DROPDOWN_WIDTH, 0, CONTENT_HEIGHT),
				}, {
					TextPadding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 4),
					}),
				}) or Roact.createElement(DetailedDropdown, {
					LayoutOrder = 2,
					Enabled = props.Enabled and #props.Items > 0,

					ButtonText = props.Action,
					Items = props.Items,
					SelectedItem = props.SelectedItem,

					BackgroundTransparency = 1,

					ItemHeight = ITEM_HEIGHT,
					DescriptionTextSize = Constants.FONT_SIZE_MEDIUM,
					DisplayTextSize = Constants.FONT_SIZE_TITLE,
					IconSize = DROPDOWN_ICON_SIZE,

					Size = UDim2.new(0, DROPDOWN_WIDTH, 0, CONTENT_HEIGHT),
					Position = UDim2.new(1, -(CONTENT_HEIGHT+LIST_PADDING), 0, 0),
					AnchorPoint = Vector2.new(1, 0),

					OnItemClicked = function(item)
						if props.Enabled and props.PermissionChanged then
							props.PermissionChanged(item)
						end
					end,
				}),
				Delete = (FFlagToolboxReplaceUILibraryComponentsPt3 and removable) and Roact.createElement(IconButton, {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundStyle = "RoundBox",
					Position = UDim2.new(1, 0, 0, 0),
					Size = UDim2.new(0, CONTENT_HEIGHT, 0, CONTENT_HEIGHT),
					LeftIcon = Images.CLOSE_ICON,
					OnClick = self.onDelete,
				})
				or ((not FFlagToolboxReplaceUILibraryComponentsPt3) and removable) and Roact.createElement(DeleteButton, {
					LayoutOrder = 3,
					Enabled = props.Enabled,

					OnClicked = props.Removed,
				}),
			}),
		})
	end)
end

return CollaboratorItem
