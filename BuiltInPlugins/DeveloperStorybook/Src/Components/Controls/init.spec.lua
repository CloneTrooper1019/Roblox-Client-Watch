return function()
	local FFlagDevFrameworkCheckbox = game:GetFastFlag("DevFrameworkCheckbox")

	local Main = script.Parent.Parent.Parent.Parent
	local Roact = require(Main.Packages.Roact)
	local Controls = require(script.Parent)
	local MockWrap = require(Main.Src.Resources.MockWrap)

	it("should create and destroy without errors", function()
		local element = MockWrap(Roact.createElement(Controls, {
			LayoutOrder = 1,
			Controls = {
				simpleToggle = true
			},
			ControlState = {},
			SetControls = function()
			end
		}))
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("Folder")
		local element = MockWrap(Roact.createElement(Controls, {
			LayoutOrder = 1,
			Controls = {
				simpleToggle = true
			},
			ControlState = {
				simpleToggle = true
			},
			SetControls = function()
			end
		}))
		local instance = Roact.mount(element, container)
		if FFlagDevFrameworkCheckbox then
			expect(container.Element.Contents.Content.Pane.simpleToggle).to.be.ok()
		else
			expect(container.Element.Contents.Content.Pane.simpleToggle.Button).to.be.ok()
			expect(container.Element.Contents.Content.Pane.simpleToggle.Label).to.be.ok()
		end
		Roact.unmount(instance)
	end)
end
