--[[
	USE IN TESTS ONLY
	Provides mocks of all necessary context items for testing.
]]

local Library = script.Parent
local Roact = require(Library.Parent.Parent.Roact)

local UILibraryWrapper = require(Library.UILibraryWrapper)

local createTheme = require(Library.createTheme)
local dummyTheme = createTheme()

local MockWrapper = Roact.PureComponent:extend("MockWrapper")

local function createMockPlugin(container)
	return {
		CreateQWidgetPluginGui = function()
			return Instance.new("BillboardGui", container)
		end
	}
end

function MockWrapper:init(props)
	local container = props.Container

	self.mockGui = Instance.new("ScreenGui", container)
	self.mockGui.Name = "MockGui"
	self.mockPlugin = createMockPlugin(container)
end

function MockWrapper:render()
	return Roact.createElement(UILibraryWrapper, {
		theme = dummyTheme,
		focusGui = self.mockGui,
		plugin = self.mockPlugin,
	}, self.props[Roact.Children])
end

function MockWrapper:willUnmount()
	self.mockGui:Destroy()
end

return MockWrapper