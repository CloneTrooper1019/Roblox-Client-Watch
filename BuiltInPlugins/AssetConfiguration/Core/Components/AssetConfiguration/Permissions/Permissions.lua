--[[
    This component is top most parent for managing Package Permissions for User and Group Owned Packages.
    This component should only be renendered if the current user is the Owner of a Package or the Owner of group,
    if this is a group package.

    Necessary Properties:
        Size = UDim2, determines the size of the Permissions page.
        LayoutOrder = num, determines the layout order of this Permissions page in its parent.
    Optional Properties:

]]
local FFlagToolboxReplaceUILibraryComponentsPt1 = game:GetFastFlag("ToolboxReplaceUILibraryComponentsPt1")
local FFlagToolboxReplaceUILibraryComponentsPt3 = game:GetFastFlag("ToolboxReplaceUILibraryComponentsPt3")

local Plugin = script.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)

local UILibrary = require(Libs.UILibrary)
local Framework = require(Libs.Framework)
local ContextServices = Framework.ContextServices

local LayoutOrderIterator
local StyledScrollingFrame
local ScrollingFrame
if FFlagToolboxReplaceUILibraryComponentsPt3 then
    LayoutOrderIterator = Framework.Util.LayoutOrderIterator
    ScrollingFrame = Framework.UI.ScrollingFrame
else
    StyledScrollingFrame = UILibrary.Component.StyledScrollingFrame
    LayoutOrderIterator = UILibrary.Util.LayoutOrderIterator
end

local Separator
if FFlagToolboxReplaceUILibraryComponentsPt1 then
	Separator = require(Libs.Framework).UI.Separator
else
	local UILibrary = require(Libs.UILibrary)
	Separator = UILibrary.Component.Separator
end

local PermissionsDirectory = Plugin.Core.Components.AssetConfiguration.Permissions
local PackageOwnerWidget = require(PermissionsDirectory.PackageOwnerWidget)
local CollaboratorSearchWidget = require(PermissionsDirectory.CollaboratorSearchWidget)
local CollaboratorsWidget = require(PermissionsDirectory.CollaboratorsWidget)
local PermissionsConstants = require(PermissionsDirectory.PermissionsConstants)

local Util = Plugin.Core.Util
local Constants = require(Util.Constants)
local ContextHelper = require(Util.ContextHelper)
local withLocalization = ContextHelper.withLocalization
local withTheme = ContextHelper.withTheme

local SearchCollaborators = require(Plugin.Core.Thunks.SearchCollaborators)

local SetCollaborators = require(Plugin.Core.Actions.SetCollaborators)
local SetGroupMetadata = require(Plugin.Core.Actions.SetGroupMetadata)
local AddChange = require(Plugin.Core.Actions.AddChange)

local Permissions = Roact.PureComponent:extend("Permissions")

function Permissions:init()
    self.state = {
        OwnerType = Enum.CreatorType[self.props.Owner.type]
    }
end

--Uses props to display current settings values
function Permissions:render()
    if FFlagToolboxReplaceUILibraryComponentsPt1 then
        return withLocalization(function(localization, localized)
            return self:renderContent(nil, localization, localized)
        end)
    else
        return withTheme(function(theme)
            return withLocalization(function(localization, localized)
                return self:renderContent(theme, localization, localized)
            end)
        end)
    end
end

function Permissions:renderContent(theme, localization, localized)
    if FFlagToolboxReplaceUILibraryComponentsPt1 then
        theme = self.props.Stylizer
    end

    local orderIterator = LayoutOrderIterator.new()

    local canViewCollaborators = self.props.CurrentUserPackagePermission == PermissionsConstants.OwnKey or self.props.CurrentUserPackagePermission == PermissionsConstants.EditKey
    local canManagePermissions = self.props.CurrentUserPackagePermission == PermissionsConstants.OwnKey
    local isUserOwnedPackage = self.state.OwnerType == Enum.CreatorType.User

    -- Text Label should only have 2 lines max
    local textLabelYSize = Constants.FONT_SIZE_MEDIUM * 2

    local scrollingFrameProps
    if FFlagToolboxReplaceUILibraryComponentsPt3 then
        scrollingFrameProps = {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            EnableScrollBarBackground = true,
            LayoutOrder = self.props.LayoutOrder,
            Size = self.props.Size,
        }
    else
        scrollingFrameProps = {
            Size = self.props.Size,

            BackgroundTransparency = 1,
            LayoutOrder = self.props.LayoutOrder,
            BackgroundColor3 = theme.assetConfig.packagePermissions.backgroundColor,

            [Roact.Ref] = self.baseFrameRefs,
        }
    end

    return Roact.createElement(ScrollingFrame or StyledScrollingFrame, scrollingFrameProps, {
        Padding = Roact.createElement("UIPadding", {
            PaddingTop = UDim.new(0, Constants.PERMISSIONS_UI_EDGE_PADDING),
            PaddingBottom = UDim.new(0, Constants.PERMISSIONS_UI_EDGE_PADDING),
            PaddingLeft = UDim.new(0, Constants.PERMISSIONS_UI_EDGE_PADDING),
            PaddingRight = UDim.new(0, Constants.PERMISSIONS_UI_EDGE_PADDING),
        }),

        UIListLayout = Roact.createElement("UIListLayout", {
            Padding = UDim.new(0, Constants.PERMISSIONS_TAB_LIST_PADDING),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),

        OwnerWidget = Roact.createElement(PackageOwnerWidget, {
            LayoutOrder = orderIterator:getNextOrder(),

            Enabled = true,
            OwnerName = self.props.Owner.username,
            OwnerId = self.props.Owner.targetId,
            OwnerType = self.state.OwnerType,

            CanManage = canManagePermissions,

            GroupMetadata = self.props.GroupMetadata,
            Permissions = self.props.Permissions,
            PermissionsChanged = self.props.PermissionsChanged,
        }),

        Separator = Roact.createElement(Separator, {
            LayoutOrder = orderIterator:getNextOrder(),
            Size = (not FFlagToolboxReplaceUILibraryComponentsPt1) and UDim2.new(1, 0, 0, 0) or nil,
        }),

        SearchbarWidget = canManagePermissions and isUserOwnedPackage and Roact.createElement(CollaboratorSearchWidget, {
            LayoutOrder = orderIterator:getNextOrder(),
            Enabled = true,

            GroupMetadata = self.props.GroupMetadata,
            SearchRequested = self.props.SearchRequested,
            SearchData = self.props.SearchData,
            Permissions = self.props.Permissions,

            PermissionsChanged = self.props.PermissionsChanged,
        }),

        RevokedWarningMessage = Roact.createElement("TextLabel", {
            LayoutOrder = orderIterator:getNextOrder(),
            Size = UDim2.new(1, 0, 0, textLabelYSize),

            Text = isUserOwnedPackage and localized.PackagePermissions.Warning.UserOwned or localized.PackagePermissions.Warning.GroupOwned,
            TextXAlignment = Enum.TextXAlignment.Left,

            Font = Constants.FONT,
            TextSize = Constants.FONT_SIZE_MEDIUM,
            TextColor3 = theme.assetConfig.packagePermissions.subTextColor,
            TextWrapped = true,

            BackgroundTransparency = 1,
        }),

        CollaboratorListWidget = canViewCollaborators and isUserOwnedPackage and Roact.createElement(CollaboratorsWidget, {
            LayoutOrder = orderIterator:getNextOrder(),
            Enabled = true,

            OwnerId = self.props.Owner.targetId,
            OwnerType = self.state.OwnerType,

            CanManage = canManagePermissions,

            GroupMetadata = self.props.GroupMetadata,
            Permissions = self.props.Permissions,
            PermissionsChanged = self.props.PermissionsChanged,
            GroupMetadataChanged = self.props.GroupMetadataChanged,
        }),
    })
end

local function mapStateToProps(state, props)
    local groupMetadata = {}
    local permissions = state.collaborators or {}
    local currentUserPackagePermission = PermissionsConstants.NoAccessKey

    if state[props.Owner.targetId] then
        if Enum.CreatorType[props.Owner.type] == Enum.CreatorType.Group then
            groupMetadata = state[props.Owner.targetId].groupMetadata
        end
    end

    if props.AssetId ~= nil then
        if state.packagePermissions and state.packagePermissions[props.AssetId] then
            currentUserPackagePermission = state.packagePermissions[props.AssetId]
        end
    end

    local owner = state.assetConfigData and state.assetConfigData.Creator or props.Owner

    return {
        Owner = owner,
        GroupMetadata = groupMetadata,
        Permissions = permissions,
        CurrentUserPackagePermission = currentUserPackagePermission,
    }
end

local function mapDispatchToProps(dispatch)
    return {
        SearchRequested = function(...)
            dispatch(SearchCollaborators(...))
        end,
        PermissionsChanged = function(newPermissions)
            dispatch(SetCollaborators(newPermissions))
            dispatch(AddChange("permissions", newPermissions))
        end,
        GroupMetadataChanged = function(groupMetadata)
            dispatch(SetGroupMetadata(groupMetadata))
            dispatch(AddChange("groupMetadata", groupMetadata))
        end,
    }
end

if FFlagToolboxReplaceUILibraryComponentsPt3 then
    ContextServices.mapToProps(Permissions, {
        Stylizer = ContextServices.Stylizer,
    })
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(Permissions)
