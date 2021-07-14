return function()
	local DraggerFramework = script.Parent.Parent
	local Library = DraggerFramework.Parent.Parent

	local Roact = require(Library.Packages.Roact)

	local StandaloneSelectionBox = require(DraggerFramework.Components.StandaloneSelectionBox)

	local function createTestStandaloneSelectionBox(container, cframe, size)
		return Roact.createElement(StandaloneSelectionBox, {
			Container = container,
			CFrame = cframe,
			Size = size,
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestStandaloneSelectionBox()

		expect(function()
			local handle = Roact.mount(element)
			Roact.unmount(handle)
		end).to.never.throw()
	end)

	it("should render correctly", function()
		local container = Instance.new("Folder")
		local element = createTestStandaloneSelectionBox(container)
		local handle = Roact.mount(element, container)

		local dummyPart = container:FindFirstChildOfClass("Part")
		local selectionBox = container:FindFirstChildOfClass("SelectionBox")
		expect(dummyPart).to.be.ok()
		expect(selectionBox).to.be.ok()

		Roact.unmount(handle)
	end)
end
