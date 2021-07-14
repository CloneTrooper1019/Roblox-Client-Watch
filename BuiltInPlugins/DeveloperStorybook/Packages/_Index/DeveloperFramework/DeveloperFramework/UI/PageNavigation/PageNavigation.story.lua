local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local PageNavigation = UI.PageNavigation

local ControlledNav = Roact.PureComponent:extend("ControlledNav")

function ControlledNav:init()
	self.state = {
		PageIndex = 1
	}
	self.onPageChange = function(pageIndex: number)
		self:setState({
			PageIndex = pageIndex
		})
	end
end

function ControlledNav:render()
	local state = self.state
	return Roact.createElement(PageNavigation, {
		PageIndex = state.PageIndex,
		PageCount = 5,
		OnPageChange = self.onPageChange
	})
end

return Roact.createElement(ControlledNav)