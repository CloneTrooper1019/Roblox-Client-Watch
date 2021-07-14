--[[
	A component that wraps all external elements needed for the UILibrary.
	Entries in the wrapper are optional, but if you do not provide an
	element that is needed by the components you are using, you will get
	an error upon trying to mount those components.

	Props:
		Theme theme = A theme object to be used by a ThemeProvider.
		PluginGui focusGui = The top-level gui to be used by a FocusProvider.
		Plugin plugin = A Plugin object which can be used to construct guis.
]]

local Library = script.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local ThemeProvider = Theming.Provider

local Focus = require(Library.Focus)
local FocusProvider = Focus.Provider

local Plugin = require(Library.Plugin)
local PluginProvider = Plugin.Provider

local Camera = require(Library.Camera)
local CameraProvider = Camera.Provider

local UILibraryWrapper = Roact.PureComponent:extend("UILibraryWrapper")

function UILibraryWrapper:addProvider(root, provider, props)
	return Roact.createElement(provider, props, {root})
end

function UILibraryWrapper:render()
	local props = self.props
	local children = props[Roact.Children]
	local root = Roact.oneChild(children)

	-- ThemeProvider
	local theme = props.theme
	if theme then
		root = self:addProvider(root, ThemeProvider, {
			theme = theme,
		})
	end

	-- FocusProvider
	local focusGui = props.focusGui
	if focusGui then
		root = self:addProvider(root, FocusProvider, {
			pluginGui = focusGui,
		})
	end

	-- PluginProvider
	local plugin = props.plugin
	if plugin then
		root = self:addProvider(root, PluginProvider, {
			plugin = plugin,
		})
	end

	-- CameraProvider
	root = self:addProvider(root, CameraProvider, nil)

	return root
end

return UILibraryWrapper