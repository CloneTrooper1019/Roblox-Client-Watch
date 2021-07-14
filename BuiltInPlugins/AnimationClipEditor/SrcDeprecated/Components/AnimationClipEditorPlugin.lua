--[[
	The main Animation Editor plugin window.

	Contains logic for the main toolbar button and dock widget.
	Also creates the external services which are provided to context.
]]

local Selection = game:GetService("Selection")
local RunService = game:GetService("RunService")

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Rodux = require(Plugin.Rodux)
local UILibrary = require(Plugin.UILibrary)
local isEmpty = require(Plugin.SrcDeprecated.Util.isEmpty)

local AnimationClipEditor = require(Plugin.SrcDeprecated.Components.AnimationClipEditor)
local DockWidget = require(Plugin.SrcDeprecated.Components.PluginWidget.DockWidget)
local ErrorDialogContents = require(Plugin.SrcDeprecated.Components.BlockingDialog.ErrorDialogContents)

local MainProvider = require(Plugin.SrcDeprecated.Context.MainProvider)
local Theme = require(Plugin.SrcDeprecated.Util.Theme)
local MainReducer = require(Plugin.SrcDeprecated.Reducers.MainReducer)
local Localization = UILibrary.Studio.Localization
local DevelopmentReferenceTable = Plugin.SrcDeprecated.Resources.DevelopmentReferenceTable
local TranslationReferenceTable = Plugin.SrcDeprecated.Resources.TranslationReferenceTable

local Constants = require(Plugin.SrcDeprecated.Util.Constants)
local DebugFlags = require(Plugin.SrcDeprecated.Util.DebugFlags)
local MakePluginActions = require(Plugin.SrcDeprecated.Util.MakePluginActions)
local showBlockingDialog = require(Plugin.SrcDeprecated.Util.showBlockingDialog)

local ReleaseEditor = require(Plugin.SrcDeprecated.Thunks.ReleaseEditor)
local SetSnapToKeys = require(Plugin.SrcDeprecated.Actions.SetSnapToKeys)
local SetShowAsSeconds = require(Plugin.SrcDeprecated.Actions.SetShowAsSeconds)
local SetTool = require(Plugin.SrcDeprecated.Actions.SetTool)

local AnimationClipEditorPlugin = Roact.PureComponent:extend("AnimationClipEditorPlugin")

function AnimationClipEditorPlugin:createPluginButton(plugin, localization)
	self.toolbar = plugin:CreateToolbar(localization:getText("Plugin", "Toolbar"))
	self.mainButton = self.toolbar:CreateButton(localization:getText("Plugin", "Button"),
		localization:getText("Plugin", "Description"), Constants.PLUGIN_BUTTON_IMAGE)
end

function AnimationClipEditorPlugin:init(initialProps)
	assert(initialProps.plugin ~= nil, "AnimationClipEditorPlugin requires a Plugin.")

	local middlewares = {Rodux.thunkMiddleware}
	if DebugFlags.LogRoduxEvents() then
		table.insert(middlewares, Rodux.loggerMiddleware)
	end
	self.store = Rodux.Store.new(MainReducer, nil, middlewares)

	self.localization = Localization.new({
		pluginName = Constants.PLUGIN_NAME,
		stringResourceTable = DevelopmentReferenceTable,
		translationResourceTable = TranslationReferenceTable,
	})

	self.actions = MakePluginActions(initialProps.plugin, self.localization)

	self.state = {
		enabled = true,
		pluginGui = nil,
	}

	self.onDockWidgetLoaded = function(dockWidget)
		self.dockWidget = dockWidget
	end

	self:createPluginButton(initialProps.plugin, self.localization)

	self.mainButton:SetActive(self.state.enabled)

	self.mainButton.Click:connect(function()
		if RunService:IsRunning() then
			showBlockingDialog(initialProps.plugin, Roact.createElement(ErrorDialogContents, {
				ErrorType = Constants.EDITOR_ERRORS.OpenedWhileRunning,
				ErrorKey = Constants.EDITOR_ERRORS_KEY,
				ErrorHeader = Constants.EDITOR_ERRORS_HEADER_KEY,
			}))
		else
			self:setState(function(state)
				return {
					enabled = not state.enabled,
				}
			end)
		end
	end)

	self.onDockWidgetEnabledChanged = function(enabled)
		if self.state.enabled == enabled then
			return
		end

		self:setState({
			enabled = enabled,
		})
	end

	-- If we deactivated because the user selected a ribbon tool,
	-- it is likely they were trying to use move/rotate in the editor.
	-- Use it to switch the current tool.
	self.onToolSelected = function(tool)
		local plugin = initialProps.plugin
		if tool == Enum.RibbonTool.Select
			or tool == Enum.RibbonTool.Rotate
			or tool == Enum.RibbonTool.Move
			or tool == Enum.RibbonTool.Scale then

			if self.state.enabled then
				local heartbeat
				heartbeat = RunService.Heartbeat:Connect(function()
					heartbeat:Disconnect()
					self.mainButton:SetActive(true)
					plugin:Activate(true)
				end)

				tool = (tool == Enum.RibbonTool.Scale and Enum.RibbonTool.Select) or tool
				self.store:dispatch(SetTool(tool))
				self.store:getState().Analytics:onToolChanged(tool.Name)
				return true
			end
		end
	end

	self.deactivationListener = self.props.plugin.Deactivation:Connect(function()
		local plugin = initialProps.plugin
		local tool = plugin:GetSelectedRibbonTool()
		if tool ~= Enum.RibbonTool.None and isEmpty(Selection:Get()) then
			if self.onToolSelected(tool) then
				return
			end
		end
		if self.state.enabled then
			self.store:dispatch(ReleaseEditor())
		end
	end)
end

function AnimationClipEditorPlugin:getPluginSettings()
	local plugin = self.props.plugin
	local snapToKeys = plugin:GetSetting("SnapToKeys")
	local showAsSeconds = plugin:GetSetting("ShowAsSeconds")
	if snapToKeys ~= nil and showAsSeconds ~= nil then
		self.store:dispatch(SetShowAsSeconds(showAsSeconds))
		self.store:dispatch(SetSnapToKeys(snapToKeys))
	end
end

function AnimationClipEditorPlugin:setPluginSettings()
	local plugin = self.props.plugin
	local status = self.store:getState().Status
	plugin:SetSetting("SnapToKeys", status.SnapToKeys)
	plugin:SetSetting("ShowAsSeconds", status.ShowAsSeconds)
end

function AnimationClipEditorPlugin:didMount()
	self:setState({
		pluginGui = self.dockWidget,
		enabled = self.dockWidget.Enabled,
	})
	self:getPluginSettings()
end

function AnimationClipEditorPlugin:willUnmount()
	if self.deactivationListener then
		self.deactivationListener:Disconnect()
	end
	self:setPluginSettings()
end

function AnimationClipEditorPlugin:render()
	local props = self.props

	local store = self.store
	local localization = self.localization
	local plugin = props.plugin
	local actions = self.actions

	local pluginGui = self.state.pluginGui
	local pluginGuiLoaded = pluginGui ~= nil

	local enabled = self.state.enabled
	self.mainButton:SetActive(enabled)

	return Roact.createElement(DockWidget, {
		Plugin = plugin,
		Title = localization:getText("Plugin", "Name"),
		Name = "AnimationClipEditor",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

		InitialDockState = Enum.InitialDockState.Bottom,
		InitialEnabled = false,
		InitialEnabledShouldOverrideRestore = true,
		Size = Constants.MAIN_FLOATING_SIZE,
		MinSize = Constants.MAIN_MINIMUM_SIZE,

		Enabled = enabled,

		[Roact.Ref] = self.onDockWidgetLoaded,
		[Roact.Change.Enabled] = self.onDockWidgetEnabledChanged,
	}, {
		MainProvider = pluginGuiLoaded and enabled and Roact.createElement(MainProvider, {
			theme = Theme.new(),
			focusGui = pluginGui,
			store = store,
			plugin = plugin,
			localization = localization,
			pluginActions = actions,
			mouse = plugin:GetMouse(),
		}, {
			AnimationClipEditor = Roact.createElement(AnimationClipEditor),
		})
	})
end

return AnimationClipEditorPlugin
