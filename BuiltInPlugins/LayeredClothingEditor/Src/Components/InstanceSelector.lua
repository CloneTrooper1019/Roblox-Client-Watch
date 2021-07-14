--[[
	To select instance from workspace viewport or explorer
	Required Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Mouse Mouse: A Mouse ContextItem, which is provided via mapToProps.
		table Localization: A Localization ContextItem, which is provided via mapToProps.
		Plugin Plugin: A Plugin ContextItem, which is provided via mapToProps.
		callback IsSelectedInstanceValid: function to decide if the selected instance is valid
		callback OnValidSelection: function to do when select a valid instance
	Optional Props:
		callback OnInvalidSelection: function to do when select a invalid instance
		string InvalidSelectionWarningText: if exist, show a popup dialog with this text when select a invalid instance
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local ConfirmDialog = require(Plugin.Src.Components.ConfirmDialog)
local ShowDialog = require(Plugin.Src.Util.ShowDialog)

-- Connects to Run and Selection services in order to detect
-- when a user has selected an instance in either the Workspace
-- Viewport or the Explorer.
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Selection = game:GetService("Selection")
local InstanceSelector = Roact.PureComponent:extend("InstanceSelector")

local Util = Framework.Util
local Typecheck = Util.Typecheck
Typecheck.wrap(InstanceSelector, script)

function InstanceSelector:setSelectedInstance()
	if #Selection:Get() > 0 then
		local willSelectItem = Selection:Get()[1]
		if self.selectedItem ~= willSelectItem then
			self.selectedItem = willSelectItem
		end
	end
end

function InstanceSelector:getSelectedInstance()
	local previousSelectedItem = self.selectedItem
	self:setSelectedInstance()
	local selectedInstance = self.selectedItem
	if selectedInstance == previousSelectedItem then
		return nil
	end
	return selectedInstance
end

function InstanceSelector:getMouseTarget()
	return self.props.Mouse:get().Target
end

function InstanceSelector:selectValidInstance(validFunc, invalidFunc)
	local target = self:getMouseTarget()
	local isSelectedInstanceValid = self.props.IsSelectedInstanceValid
	if target ~= nil then
		if isSelectedInstanceValid(target) then
			validFunc(target)
		else
			invalidFunc(target)
		end
	end
end

function InstanceSelector:init()
	self.state = {
		hoverPart = nil
	}

	self.selectedItem = nil

	self.selectInstance = function(instance)
		Selection:Set({instance})
	end

	self.deselect = function()
		Selection:Set({})
	end

	self.highlightInstance = function(instance)
		self:setState({
			hoverPart = instance,
		})
	end

	self.removeHighlight = function()
		self:setState({
			hoverPart = Roact.None,
		})
	end
end

function InstanceSelector:didMount()
	local props = self.props
	local isSelectedInstanceValid = props.IsSelectedInstanceValid
	local onValidSelection = props.OnValidSelection
	local onInvalidSelection = props.OnInvalidSelection
	local invalidSelectionWarningText = props.InvalidSelectionWarningText
	self.SelectionChangedHandle = Selection.SelectionChanged:Connect(function()
		local selectedInstance = self:getSelectedInstance()
		if not selectedInstance then
			return
		end
		if isSelectedInstanceValid(selectedInstance) then
			onValidSelection(selectedInstance)
		else
			if onInvalidSelection then
				onInvalidSelection(selectedInstance)
			end
			if invalidSelectionWarningText then
				ShowDialog(props.Plugin, props.Localization, ConfirmDialog,{
					Text = invalidSelectionWarningText,
				})
			end
		end
	end)

	local mouse = self.props.Mouse:get()
	if mouse and mouse.Button1Down then
		self.MouseButtonDown = mouse.Button1Down:Connect(function()
			self:selectValidInstance(self.selectInstance, self.deselect)
		end)
	end

	self.Heartbeat = RunService.Heartbeat:Connect(function(step)
		self:selectValidInstance(self.highlightInstance, self.removeHighlight)
	end)
end

function InstanceSelector:render()
	local state = self.state
	local props = self.props

	local hoverPart = state.hoverPart
	local container = props.Container or CoreGui
	local theme = props.Stylizer

	return Roact.createElement(Roact.Portal, {
		target = container,
	}, {
		HoverBox = hoverPart and Roact.createElement("SelectionBox", {
			Archivable = false,
			Adornee = hoverPart,
			LineThickness = theme.HoverLineThickness,
		}),
	})
end

function InstanceSelector:willUnmount()
	if self.Heartbeat then
		self.Heartbeat:Disconnect()
	end

	if self.SelectionChangedHandle then
		self.SelectionChangedHandle:Disconnect()
	end

	if self.MouseButtonDown then
		self.MouseButtonDown:Disconnect()
	end
end

ContextServices.mapToProps(InstanceSelector,{
	Stylizer = ContextServices.Stylizer,
	Localization = ContextServices.Localization,
	Mouse = ContextServices.Mouse,
	Plugin = ContextServices.Plugin,
})

return InstanceSelector