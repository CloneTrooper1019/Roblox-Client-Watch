--[[
	Represents the button and dropdown at the end of the Summary track
	which allows the user to add new tracks.

	Props:
		UDim2 Size = The size of the button.
		UDim2 Position = The position of the button.
		list Tracks = A list of tracks that have not been added yet.
			These tracks are maps that must include the Name and Instance fields.

		function OnTrackSelected(instance, track) = A callback for when the user
			has selected a track to add to the editor.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local Framework = require(Plugin.Packages.Framework)
local Constants = require(Plugin.Src.Util.Constants)
local Cryo = require(Plugin.Packages.Cryo)

local ContextMenu = require(Plugin.Src.Components.ContextMenu)
local Tooltip = require(Plugin.Src.Components.Tooltip)
local ContextServices = Framework.ContextServices

local GetFFlagFacialAnimationSupport = require(Plugin.LuaFlags.GetFFlagFacialAnimationSupport)

local AddTrackButton = Roact.PureComponent:extend("AddTrackButton")

function AddTrackButton:init()
	self.state = {
		showMenu = false,
	}

	self.showMenu = function()
		self:setState({
			showMenu = true,
		})
	end

	self.hideMenu = function()
		self:setState({
			showMenu = false,
		})
	end

	self.mouseEnter = function()
		if self.props.Mouse then
			self.props.Mouse:__pushCursor("PointingHand")
		end
		self:setState({
			hovering = true,
		})
	end

	self.mouseLeave = function()
		if self.props.Mouse then
			self.props.Mouse:__popCursor()
		end
		self:setState({
			hovering = false,
		})
	end
end

function AddTrackButton:willUnmount()
	self.props.Mouse:__resetCursor()
end

function AddTrackButton:makeFacialAnimationControlSubMenu(facsList)
	local items = {}

	for _, facs in ipairs(facsList) do
		table.insert(items, {
			Name = facs.Name,
			ItemSelected = function()
				if self.props.OnTrackSelected then
					self.props.OnTrackSelected(facs.Instance, facs.Name, facs.Type)
				end
			end,
		})
	end

	return items
end

function AddTrackButton:makeFacialAnimationRegionSubMenu(localization)
	local props = self.props
	local items = {}
	local facsTree = {}
	local hasFacsItems = false

	-- Group facs by region
	for _, facs in ipairs(props.Facs) do
		local region = Constants.FacsControlToRegionMap[facs.Name] or Constants.FACS_REGIONS.Other

		if not facsTree[region] then
			facsTree[region] = {}
		end

		table.insert(facsTree[region], facs)
		hasFacsItems = true
	end

	if hasFacsItems then
		-- Add region submenus
		local keys = Cryo.Dictionary.keys(facsTree)
		table.sort(keys)

		for _, region in ipairs(keys) do
			if facsTree[region] then
				table.insert(items, {
					Name = localization:getText("Menu", region),
					Items = self:makeFacialAnimationControlSubMenu(facsTree[region])
				})
			end
		end

		-- "Add all" option
		table.insert(items, Constants.MENU_SEPARATOR)
		table.insert(items, {
			Name = localization:getText("Menu", "AddAllFacs"),
			ItemSelected = function()
				for _, facs in ipairs(props.Facs) do
					self.props.OnTrackSelected(facs.Instance, facs.Name, facs.Type)
				end
			end,
		})
	end

	return items
end

function AddTrackButton:makeTrackActions(localization)
	local props = self.props
	local actions = {}

	for _, track in ipairs(props.Tracks) do
		table.insert(actions, {
			Name = track.Name,
			ItemSelected = function()
				self.props.OnTrackSelected(track.Instance, track.Name, track.Type)
			end,
		})
	end

	if not GetFFlagFacialAnimationSupport() or #props.Tracks > 0 then
		table.insert(actions, Constants.MENU_SEPARATOR)
		table.insert(actions, {
			Name = localization:getText("Menu", "AddAllTracks"),
			ItemSelected = function()
				for _, track in ipairs(props.Tracks) do
					self.props.OnTrackSelected(track.Instance, track.Name, track.Type)
				end
			end,
		})

		if GetFFlagFacialAnimationSupport() then
			table.insert(actions, Constants.MENU_SEPARATOR)
		end
	end

	if GetFFlagFacialAnimationSupport() then
		local facsItems = self:makeFacialAnimationRegionSubMenu(localization)
		for _, item in pairs(facsItems) do
			table.insert(actions, item)
		end
	end

	return actions
end

function AddTrackButton:render()
	local localization = self.props.Localization
	local props = self.props
	local theme = props.Theme:get("PluginTheme")
	local state = self.state

	local showMenu = state.showMenu
	local hovering = state.hovering

	local size = props.Size
	local position = props.Position
	local trackTheme = theme.trackTheme

	return Roact.createElement("ImageButton", {
		Size = size,
		Position = position,
		AnchorPoint = Vector2.new(1, 0.5),
		Image = trackTheme.addButtonBackground,
		ImageColor3 = hovering and trackTheme.hoveredAddButtonColor or trackTheme.addButtonColor,
		BackgroundTransparency = 1,

		[Roact.Event.Activated] = self.showMenu,
		[Roact.Event.MouseEnter] = self.mouseEnter,
		[Roact.Event.MouseLeave] = self.mouseLeave,
	}, {
		PlusIcon = Roact.createElement("ImageLabel", {
			Size = UDim2.new(0, 9, 0, 8),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = trackTheme.plusIcon,
			ImageColor3 = hovering and trackTheme.hoveredPlusIconColor or trackTheme.plusIconColor,
			BackgroundTransparency = 1,
		}),

		TrackMenu = showMenu and Roact.createElement(ContextMenu, {
			Actions = self:makeTrackActions(localization),
			OnMenuOpened = self.hideMenu,
		}),

		Tooltip = Roact.createElement(Tooltip, {
			TextKey = "AddTrackButton",
		}),
	})
end

ContextServices.mapToProps(AddTrackButton, {
	Theme = ContextServices.Theme,
	Localization = ContextServices.Localization,
	Mouse = ContextServices.Mouse,
})

return AddTrackButton