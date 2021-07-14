--[[
	The main plugin component.
	Consists of the PluginWidget, Toolbar, Button, and Roact tree.

	New Plugin Setup: When creating a plugin, commit this template
		first with /packages in a secondary pull request.

		A common workaround for the large diffs from Packages/_Index is to put
		the Packages/_Index changes into a separate PR like this:
			master <- PR <- Packages PR
		Get people to review *PR*, then after approvals, merge *Packages PR*
		into *PR*, and then *PR* into master.


	New Plugin Setup: Search for other TODOs to see other tasks to modify this template for
	your needs. All setup TODOs are tagged as New Plugin Setup:
]]

local main = script.Parent.Parent
-- local _Types = require(main.Src.Types) -- uncomment to enable
local Roact = require(main.Packages.Roact)
local Rodux = require(main.Packages.Rodux)

local Framework = require(main.Packages.Framework)

local StudioUI = Framework.StudioUI

local PluginToolbar = StudioUI.PluginToolbar
local PluginButton = StudioUI.PluginButton

local ContextServices = Framework.ContextServices
local Plugin = ContextServices.Plugin
local Mouse = ContextServices.Mouse
local Store = ContextServices.Store

local MainReducer = require(main.Src.Reducers.MainReducer)
local MakeTheme = require(main.Src.Resources.MakeTheme)

local TranslationDevelopmentTable = main.Src.Resources.Localization.TranslationDevelopmentTable
local TranslationReferenceTable = main.Src.Resources.Localization.TranslationReferenceTable

local Components = main.Src.Components
local EditDebugpointDialog = require(Components.Breakpoints.EditDebugpointDialog)
local CallstackWindow = require(Components.Callstack.CallstackWindow)
local CallstackComponent = require(Components.Callstack.CallstackComponent)

local FFlagDebuggerPluginEditBreakpoint = game:GetFastFlag("DebuggerPluginEditBreakpoint_alpha")
local FFlagLuaUIDebuggerCallstack = game:GetFastFlag("LuaUIDebuggerCallstack")

local MainPlugin = Roact.PureComponent:extend("MainPlugin")

local CALLSTACK_META_NAME = "Callstack"
local BREAKPOINTS_META_NAME = "Breakpoints"
local WATCH_META_NAME = "Watch"
local TOOLBAR_NAME = "Debugger"

function MainPlugin:init(props)
	self.state = {
		editBreakpoint = {
			Enabled = false,
		},
		callstackWindow = {
			Enabled = false,
		},
		breakpointsWindow = {
			Enabled = false,
		},
		watchWindow = {
			Enabled = false,
		},
	}

	self.toggleWidgetEnabled = function(targetWidget)
		self:setState(function(state)
			return {
				[targetWidget] = {
					Enabled =  not state[targetWidget].Enabled,
				}
			}
		end)
	end

	self.onWidgetClose = function(targetWidget)
		self:setState({
			[targetWidget] = {
				Enabled = false,
			}
		})
	end

	self.onWidgetEnabledChanged = function(targetWidget)
		self:setState({
			[targetWidget] = {
				Enabled = false,
			},
		})
	end

	self.store = Rodux.Store.new(MainReducer, nil, {
		Rodux.thunkMiddleware,
	})

	self.localization = ContextServices.Localization.new({
		stringResourceTable = TranslationDevelopmentTable,
		translationResourceTable = TranslationReferenceTable,
		pluginName = "Debugger",
	})
	--[[
		New Plugin Setup: Each plugin is expected to provide a createEventHandlers function to the constructor
			which should return a table mapping event -> eventHandler.

			To enable localization, add the plugin to
			Client/RobloxStudio/Translation/builtin_plugin_config.py
	--]]
	self.analytics = ContextServices.Analytics.new(function()
		return {}
	end, {})
end

function MainPlugin:renderButtons(toolbar)
	return {
		ToggleCallstack = FFlagLuaUIDebuggerCallstack and Roact.createElement(PluginButton, {
			Name = "callStackDockWidgetActionV2",
			Toolbar = toolbar,
			Active = true,
			Title = CALLSTACK_META_NAME,
			Tooltip = "",
			Icon = "rbxasset://textures/Debugger/callStack.png",
			OnClick = function()
				self.toggleWidgetEnabled("callstackWindow")
			end,
			ClickableWhenViewportHidden = true,
		}),
		ToggleBreakpointsWindow = FFlagLuaUIDebuggerCallstack and Roact.createElement(PluginButton, {
			Name = "breakpointsDockWidgetActionV2",
			Toolbar = toolbar,
			Active = true,
			Title = BREAKPOINTS_META_NAME,
			Tooltip = "",
			Icon = "rbxasset://textures/Debugger/Breakpoint.png",
			OnClick = function()
				self.toggleWidgetEnabled("breakpointsWindow")
			end,
			ClickableWhenViewportHidden = true,
		}),
		ToggleWatchWindow = FFlagLuaUIDebuggerCallstack and Roact.createElement(PluginButton, {
			Name = "watchDockWidgetActionV2",
			Toolbar = toolbar,
			Active = true,
			Title = WATCH_META_NAME,
			Tooltip = "",
			Icon = "rbxasset://textures/Debugger/Watch-Window.png",
			OnClick = function()
				self.toggleWidgetEnabled("watchWindow")
			end,
			ClickableWhenViewportHidden = true,
		}),
	}
end

function MainPlugin:renderButtonsTemporary(toolbar)
	return {
		ToggleEditBreakpoint = FFlagDebuggerPluginEditBreakpoint and Roact.createElement(PluginButton, {
			Toolbar = toolbar,
			Active = true,
			Title = self.localization:getText("EditBreakpoint", "DialogName"),
			Tooltip = "Temporary Edit Breakpoint button for development purpose ",
			Icon = "rbxasset://textures/GameSettings/Error.png", -- Located under Client/content/textures
			OnClick = function()
				self.toggleWidgetEnabled("editBreakpoint")
			end,
			ClickableWhenViewportHidden = true,
		}),
	}
end

function MainPlugin:render()
	local props = self.props
	local state = self.state
	local plugin = props.Plugin
	local editBreakpointEnabled = state.editBreakpoint and state.editBreakpoint.Enabled
	local callstackWindowEnabled = state.callstackWindow and state.callstackWindow.Enabled

	return ContextServices.provide({
		Plugin.new(plugin),
		Store.new(self.store),
		Mouse.new(plugin:getMouse()),
		MakeTheme(),
		self.localization,
		self.analytics,
	}, {
		Toolbar = Roact.createElement(PluginToolbar, {
			Title = TOOLBAR_NAME,
			RenderButtons = function(toolbar)
				return self:renderButtons(toolbar)
			end,
		}),
		TemporaryToolbar = Roact.createElement(PluginToolbar, {
			Title = "Temporary",
			RenderButtons = function(toolbar)
				return self:renderButtonsTemporary(toolbar)
			end,
		}),
		EditDebugpointDialog = FFlagDebuggerPluginEditBreakpoint and editBreakpointEnabled and Roact.createElement(EditDebugpointDialog, {
			Enabled = editBreakpointEnabled,
			OnClose = function()
				self.onWidgetClose("editBreakpoint")
			end,
		}) or nil, 
		CallstackWindow = (FFlagLuaUIDebuggerCallstack and callstackWindowEnabled) and Roact.createElement(CallstackWindow, {
			Enabled = callstackWindowEnabled,
			OnClose = function()
				self.onWidgetClose("callstackWindow")
			end,
		}, {
			Callstack = Roact.createElement(CallstackComponent),
		}) or nil,
	})
end

return MainPlugin
