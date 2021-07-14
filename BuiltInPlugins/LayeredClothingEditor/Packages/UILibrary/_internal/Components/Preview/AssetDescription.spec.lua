return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local AssetDescription = require(Library.Components.Preview.AssetDescription)

	local function createTestAsset(container, name)
		local element = Roact.createElement(MockWrapper,{},{
			AssetDescription = 	Roact.createElement(AssetDescription, {
				Position = UDim2.new(1, 0, 1, 0),
				Size = UDim2.new(1, 0, 1, 0),
				LeftContent = "",
				RightContent = "",

				UseBoldLine = false,
			})
		})

		return Roact.mount(element, container or nil, name or "")
	end

	it("should create and destroy without errors", function()
		local instance = createTestAsset()
		Roact.unmount(instance)
	end)
end
