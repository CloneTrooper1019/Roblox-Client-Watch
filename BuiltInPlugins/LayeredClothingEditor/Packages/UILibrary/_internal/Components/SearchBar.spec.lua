return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local SearchBar = require(script.Parent.SearchBar)

	it("should create and destroy without errors", function()
		local element = Roact.createElement(MockWrapper, {}, {
			SearchBar = Roact.createElement(SearchBar, {
				Size = UDim2.new(0, 100, 0, 20),
				OnSearchRequested = function() end,
			}),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	describe("the textbox", function()
		it("should move as text is typed", function()
			local width = 200
			local element = Roact.createElement(MockWrapper, {}, {
				SearchBar = Roact.createElement(SearchBar, {
					Size = UDim2.new(0, width, 0, 20),
					Enabled = true,
					OnSearchRequested = function() end,
				}),
			})
			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container, "SearchBar")
			local searchBar = container.SearchBar
			local textBox = searchBar.TextBox

			local str = ("abcdefghijklmnopqrstuvwxyz"):rep(2)

			textBox.Text = str:sub(1, 1)
			local previousWidth = textBox.AbsoluteSize.x

			for i = 1, #str, 1 do
				local text = str:sub(1, i)
				textBox.Text = text

				local width = textBox.AbsoluteSize.x
				expect(width >= previousWidth).to.equal(true)
				previousWidth = width
			end

			Roact.unmount(instance)
		end)
	end)
end
