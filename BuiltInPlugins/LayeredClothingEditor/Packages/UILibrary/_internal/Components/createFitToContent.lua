--[[
	This component generates a list of elements and resizes the container so that it fits the size of the list.

	Call the function createFitToContent and pass in the container, the layout of the elements, and any properties
]]
local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local join = require(Library.join)

local function createFitToContent(containerComponent, layoutComponent, layoutProps)
	local name = ("FitComponent(%s, %s)"):format(containerComponent, layoutComponent)
	local FitComponent = Roact.Component:extend(name)

	function FitComponent:init()
		self.layoutRef = Roact.createRef()
		self.containerRef = Roact.createRef()

		self.layoutProps = join(layoutProps, {
			[Roact.Ref] = self.layoutRef,
			[Roact.Change.AbsoluteContentSize] = function()
				if self.layoutRef.current ~= nil and self.containerRef.current ~= nil then
					self:resizeContainer()
				end
			end,
		})
	end

	function FitComponent:render()
		assert(self.props.Size == nil, "Size must not be specified!")

		local children = join({
			["Layout"] = Roact.createElement(layoutComponent, self.layoutProps),
		}, self.props[Roact.Children])

		local props = join(self.props, {
			[Roact.Children] = children,
			[Roact.Ref] = self.containerRef,
		})

		return Roact.createElement(containerComponent, props)
	end

	function FitComponent:didMount()
		self:resizeContainer()
	end

	function FitComponent:didUpdate()
		self:resizeContainer()
	end

	function FitComponent:resizeContainer()
		local layout = self.layoutRef.current
		if layout then
			local layoutSize = layout.AbsoluteContentSize
			self.containerRef.current.Size = UDim2.new(1, 0, 0, layoutSize.Y)
		end
	end

	return FitComponent
end

return createFitToContent