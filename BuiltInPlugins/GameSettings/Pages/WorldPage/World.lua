--[[
	Settings page for World settings.
		- Jump power
		- or Jump Height
		- Gravity
		- Walk speed
		- Max slope angle

	Settings:
		bool UseJumpPower - whether to use jump power or jump height settings
		float JumpPower
		float JumpHeight
		float Gravity
		float WalkSpeed
		float MaxSlopeAngle - maximum incline angle (in degrees) that the avatar can walk up
]]
local Page = script.Parent
local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local ContextServices = require(Plugin.Framework.ContextServices)

local WorldRootPhysics = require(Page.ContextServices.WorldRootPhysics)
local AddChange = require(Plugin.Src.Actions.AddChange)
local formatNumberForDisplay = require(Page.Util.formatNumberForDisplay)

local SettingsPage = require(Plugin.Src.Components.SettingsPages.SettingsPage)
local PresetsBar = require(Page.Components.PresetsBar)
local JumpSelect = require(Page.Components.JumpSelect)
local NumberInputRow = require(Page.Components.NumberInputRow)

local RoactStudioWidgets = Plugin.RoactStudioWidgets
local StudioWidgetTitledFrame = require(RoactStudioWidgets.TitledFrame)
local Separator = require(Plugin.Framework).UI.Separator
local StudioWidgetText = require(RoactStudioWidgets.Text)

local INPUT_BOX_OFFSET = 160
local METRIC_LABEL_OFFSET = 170
local ROW_HEIGHT = 35

local LOCALIZATION_ID = script.Name

local function loadSettings(store, contextItems)
	local state = store:getState()
	local game = state.Metadata.game
	local worldRootPhysicsController = contextItems.worldRootPhysicsController

	return {
		function(loadedSettings)
			local gravity = worldRootPhysicsController:getGravity(game)

			loadedSettings["workspaceGravity"] = gravity
		end,
		function(loadedSettings)
			local useJumpPower = worldRootPhysicsController:getUseJumpPower(game)

			loadedSettings["workspaceUseJumpPower"] = useJumpPower
		end,
		function(loadedSettings)
			local jumpPower = worldRootPhysicsController:getJumpPower(game)

			loadedSettings["workspaceJumpPower"] = jumpPower
		end,
		function(loadedSettings)
			local jumpHeight = worldRootPhysicsController:getJumpHeight(game)

			loadedSettings["workspaceJumpHeight"] = jumpHeight
		end,
		function(loadedSettings)
			local walkspeed = worldRootPhysicsController:getWalkspeed(game)

			loadedSettings["workspaceWalkSpeed"] = walkspeed
		end,
		function(loadedSettings)
			local maxSlopeAngle = worldRootPhysicsController:getMaxSlopeAngle(game)

			loadedSettings["workspaceMaxSlopeAngle"] = maxSlopeAngle
		end,
	}
end

local function saveSettings(store, contextItems)
	local state = store:getState()
	local game = state.Metadata.game
	local worldRootPhysicsController = contextItems.worldRootPhysicsController

	return {
		function()
			local changedUseJumpPower = state.Settings.Changed.workspaceUseJumpPower
			if changedUseJumpPower ~= nil then
				worldRootPhysicsController:setUseJumpPower(game, changedUseJumpPower)
			end

			-- Setting either jumpPower or jumpHeight will set the other, so if we have save jobs for both
			-- and then in the UI we only set jumpPower to 50, what may happen is jumpHeight gets saved after
			-- jumpPower and it calculates the same jumpPower that we set but with floating a small error (50.002)
			-- Both of these will always be changed by Game Settings, but ignore the non-dominant one so
			-- the user's specified value is not re-calculated. These have to be in the useJumpPower save
			-- job or else they could execute before useJumpPower is saved
			if worldRootPhysicsController:getUseJumpPower(game) then
				local changedJumpPower = state.Settings.Changed.workspaceJumpPower
				if changedJumpPower ~= nil then
					worldRootPhysicsController:setJumpPower(game, changedJumpPower)
				end
			else
				local changedJumpHeight = state.Settings.Changed.workspaceJumpHeight
				if changedJumpHeight ~= nil then
					worldRootPhysicsController:setJumpHeight(game, changedJumpHeight)
				end
			end
		end,
		function()
			local changed = state.Settings.Changed.workspaceGravity

			if changed ~= nil then
				worldRootPhysicsController:setGravity(game, changed)
			end
		end,
		function()
			local changed = state.Settings.Changed.workspaceWalkSpeed

			if changed ~= nil then
				worldRootPhysicsController:setWalkspeed(game, changed)
			end
		end,
		function()
			local changed = state.Settings.Changed.workspaceMaxSlopeAngle

			if changed ~= nil then
				worldRootPhysicsController:setMaxSlopeAngle(game, changed)
			end
		end,
	}
end

--Loads settings values into props by key
local function loadValuesToProps(getValue, state)
	return {
		WorkspaceUseJumpPower = getValue("workspaceUseJumpPower"),
		WorkspaceJumpPower = getValue("workspaceJumpPower"),
		WorkspaceJumpHeight = getValue("workspaceJumpHeight"),
		WorkspaceGravity = getValue("workspaceGravity"),
		WorkspaceWalkSpeed = getValue("workspaceWalkSpeed"),
		WorkspaceMaxSlopeAngle = getValue("workspaceMaxSlopeAngle")
	}
end

--Implements dispatch functions for when the user changes values
local function dispatchChanges(setValue)
	return {
		WorkspaceUseJumpPowerChanged = setValue("workspaceUseJumpPower"),
		WorkspaceJumpPowerChanged = setValue("workspaceJumpPower"),
		WorkspaceJumpHeightChanged = setValue("workspaceJumpHeight"),
		WorkspaceGravityChanged = setValue("workspaceGravity"),
		WorkspaceWalkSpeedChanged = setValue("workspaceWalkSpeed"),
		WorkspaceMaxSlopeAngleChanged = setValue("workspaceMaxSlopeAngle")
	}
end

local World = Roact.PureComponent:extend("World")

function World:render()
	local props = self.props
	local localization = props.Localization

	local function createChildren()
		local props = self.props
		local localization = props.Localization
		local worldRootPhysicsController = props.WorldRootPhysics:get()

		local gravity = props.WorkspaceGravity
		local setGravity = props.WorkspaceGravityChanged
		local useJumpPower = props.WorkspaceUseJumpPower
		local setUseJumpPower = props.WorkspaceUseJumpPowerChanged
		local walkspeed = props.WorkspaceWalkSpeed
		local setWalkspeed = props.WorkspaceWalkSpeedChanged
		local maxSlopeAngle = props.WorkspaceMaxSlopeAngle
		local setMaxSlopeAngle = props.WorkspaceMaxSlopeAngleChanged

		local jumpHeight, jumpPower
		local setJumpPower = props.WorkspaceJumpPowerChanged
		local setJumpHeight = props.WorkspaceJumpHeightChanged
		if useJumpPower then
			jumpPower = props.WorkspaceJumpPower
			jumpHeight = worldRootPhysicsController.calculateJumpHeight(gravity, jumpPower)
		else
			jumpHeight = props.WorkspaceJumpHeight
			jumpPower = worldRootPhysicsController.calculateJumpPower(gravity, jumpHeight)
		end

		return {
			Presets = Roact.createElement(PresetsBar, {
				LayoutOrder = 1,
				ApplyPreset = function(preset)
					local gravity = preset.Gravity or gravity
					local jumpPower = preset.JumpPower or jumpPower
					local walkspeed = preset.Walkspeed or walkspeed
					local maxSlopeAngle = preset.MaxSlopeAngle or maxSlopeAngle

					setGravity(gravity)
					setUseJumpPower(true)
					setJumpPower(jumpPower)
					setJumpHeight(worldRootPhysicsController.calculateJumpHeight(gravity, jumpPower))
					setWalkspeed(walkspeed)
					setMaxSlopeAngle(maxSlopeAngle)
				end,
			}),

			Separator1 = Roact.createElement(Separator, {
				LayoutOrder = 2,
			}),

			Gravity = Roact.createElement(NumberInputRow, {
				LayoutOrder = 3,

				Title = localization:getText("General", "TitleGravity"),
				Label = localization:getText("General", "GravityWorkspaceGravity"),
				Value = gravity,
				MinValue = 0,
				MaxValue = 1000,
				OnUpdate = function(newGravity)
					setGravity(newGravity)
					if useJumpPower then
						setJumpHeight(worldRootPhysicsController.calculateJumpHeight(newGravity, jumpPower))
					else
						setJumpPower(worldRootPhysicsController.calculateJumpPower(newGravity, jumpHeight))
					end
				end,
				UnitsFormatFunction = function(inputNumber)
					return localization:getText("General", "UnitsMetersPerSecondSquared1", {formatNumberForDisplay(inputNumber)})
				end,
			}),

			Separator2 = Roact.createElement(Separator, {
				LayoutOrder = 4,
			}),

			JumpSelect = Roact.createElement(JumpSelect, {
				LayoutOrder = 5,
				UseJumpPower = useJumpPower,
				JumpPower = jumpPower,
				JumpHeight = jumpHeight,
				SetUseJumpPower = setUseJumpPower,
				SetJumpPower = function(newJumpPower)
					setJumpPower(newJumpPower)
					setJumpHeight(worldRootPhysicsController.calculateJumpHeight(gravity, newJumpPower))
				end,
				SetJumpHeight = function(newJumpHeight)
					setJumpHeight(newJumpHeight)
					setJumpPower(worldRootPhysicsController.calculateJumpPower(gravity, newJumpHeight))
				end,
			}),

			WalkSpeed = Roact.createElement(NumberInputRow, {
				LayoutOrder = 6,

				Title = localization:getText("General", "TitleWalk"),
				Label = localization:getText("General", "WalkSpeed"),
				Value = walkspeed,
				MinValue = 0,
				MaxValue = math.huge,
				OnUpdate = setWalkspeed,
				UnitsFormatFunction = function(inputNumber)
					return localization:getText("General", "UnitsMetersPerSecond1", {formatNumberForDisplay(inputNumber)})
				end,
			}),

			JumpDistance = Roact.createElement(StudioWidgetTitledFrame, {
				Title = "",
				MaxHeight = 10,
				LayoutOrder = 7,
				TitleTextYAlignment = Enum.TextYAlignment.Center
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				JumpDistanceLabel = Roact.createElement(StudioWidgetText, {
					LayoutOrder = 1,
					Enabled = true,
					Size = UDim2.new(0, INPUT_BOX_OFFSET, 0, ROW_HEIGHT),
					Text = localization:getText("General", "JumpDistance"),
				}),
				JumpDistanceValue = Roact.createElement(StudioWidgetText, {
					LayoutOrder = 2,
					Enabled = true,
					Size = UDim2.new(0, METRIC_LABEL_OFFSET, 0, ROW_HEIGHT),
					Text = formatNumberForDisplay(worldRootPhysicsController.calculateJumpDistance(gravity, jumpPower, walkspeed)),
				}),
				JumpDistanceMetricValue = Roact.createElement(StudioWidgetText, {
					LayoutOrder = 3,
					Enabled = true,
					Size = UDim2.new(1, -(METRIC_LABEL_OFFSET+INPUT_BOX_OFFSET), 0, ROW_HEIGHT),
					Text = localization:getText("General", "UnitsMeters1", {
						formatNumberForDisplay(worldRootPhysicsController.convertStudsToMeters(
							worldRootPhysicsController.calculateJumpDistance(gravity, jumpPower, walkspeed)))
					}),
				}),
			}),

			MaxSlopeAngle = Roact.createElement(NumberInputRow, {
				LayoutOrder = 8,

				Title = localization:getText("General", "TitleSlope"),
				Label = localization:getText("General", "SlopeAngle"),
				Value = maxSlopeAngle,
				MinValue = 0,
				MaxValue = 89,
				OnUpdate = setMaxSlopeAngle,
				UnitsFormatFunction = nil,
			}),
		}
	end

	return Roact.createElement(SettingsPage, {
		SettingsLoadJobs = loadSettings,
		SettingsSaveJobs = saveSettings,
		Title = localization:getText("General", "Category"..LOCALIZATION_ID),
		PageId = LOCALIZATION_ID,
		CreateChildren = createChildren,
	})
end

ContextServices.mapToProps(World, {
	Localization = ContextServices.Localization,
	WorldRootPhysics = WorldRootPhysics,
})

local settingFromState = require(Plugin.Src.Networking.settingFromState)
World = RoactRodux.connect(
	function(state, props)
		if not state then return end

		local getValue = function(propName)
			return settingFromState(state.Settings, propName)
		end

		return loadValuesToProps(getValue, state)
	end,

	function(dispatch)
		local setValue = function(propName)
			return function(value)
				dispatch(AddChange(propName, value))
			end
		end

		return dispatchChanges(setValue)
	end
)(World)

World.LocalizationId = LOCALIZATION_ID

return World
