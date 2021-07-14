return function()
    local Library = script.Parent.Parent.Parent
    local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local SearchLinkText = require(Library.Components.Preview.SearchLinkText)

	it("should expect an OnClick function", function()
		local element = Roact.createElement(MockWrapper, {}, {
			LinkText = Roact.createElement(SearchLinkText, {
				Text = "Test",
			}),
		})
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should create and destroy without errors", function()
		local element = Roact.createElement(MockWrapper, {}, {
			LinkText = Roact.createElement(SearchLinkText, {
				Text = "Test",
				OnClick = function()
				end,
			}),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local element = Roact.createElement(MockWrapper, {}, {
			LinkText = Roact.createElement(SearchLinkText, {
				Text = "Test",
				OnClick = function()
				end,
			}),
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container)

		local main = container:FindFirstChildOfClass("TextButton")
		expect(main.Text).to.be.ok()
		expect(main.SearchIcon).to.be.ok()

		Roact.unmount(instance)
	end)
end
