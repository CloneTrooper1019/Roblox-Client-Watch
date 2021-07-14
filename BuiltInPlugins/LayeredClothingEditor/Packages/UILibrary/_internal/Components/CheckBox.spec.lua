return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local CheckBox = require(script.Parent.CheckBox)

	local function createTestCheckBox(enabled, selected)
		return Roact.createElement(MockWrapper, {}, {
			checkBox = Roact.createElement(CheckBox, {
				Title = "Title",
				TextSize = 24,
				Enabled = enabled,
				Selected = selected,
				OnClicked = function()
				end,
			})
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestCheckBox(true, false)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestCheckBox(true, false), container)
		local frame = container:FindFirstChildOfClass("Frame")

		expect(frame.Background).to.be.ok()
		expect(frame.Background.Selection).to.be.ok()
		expect(frame.Background.TitleLabel).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should change color when highlighted", function ()
		local container = Instance.new("Folder")

		-- selected
		local instance = Roact.mount(createTestCheckBox(true, true), container)
		local frame = container:FindFirstChildOfClass("Frame")
		expect(frame.Background.Selection.Visible).to.equal(true)

		-- unselected
		instance = Roact.update(instance, createTestCheckBox(true, false))
		expect(frame.Background.Selection.Visible).to.equal(false)
		Roact.unmount(instance)
	end)

	it("should gray out when disabled", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestCheckBox(false, true), container)
		local frame = container:FindFirstChildOfClass("Frame")

		expect(frame.Background.Selection.Visible).to.equal(false)
		expect(frame.Background.TitleLabel.TextTransparency).never.to.equal(0)

		Roact.unmount(instance)
	end)
end