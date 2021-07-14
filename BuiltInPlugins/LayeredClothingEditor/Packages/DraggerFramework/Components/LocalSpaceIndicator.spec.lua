return function()
	local Selection = game:GetService("Selection")

	local DraggerFramework = script.Parent.Parent
	local Library = DraggerFramework.Parent.Parent
	local Roact = require(Library.Packages.Roact)

	local LocalSpaceIndicator = require(DraggerFramework.Components.LocalSpaceIndicator)
	local DraggerContext_FixtureImpl = require(DraggerFramework.Implementation.DraggerContext_FixtureImpl)

	local function createTestLocalSpaceIndicator(onScreen)
		local context = DraggerContext_FixtureImpl.new(nil, Selection)

		local cameraCFrame = context:getCameraCFrame()
		local distanceOffset
		if onScreen then
			distanceOffset = 10
		else
			distanceOffset = -10
		end

		local position = cameraCFrame.Position + cameraCFrame.LookVector * distanceOffset

		return Roact.createElement(LocalSpaceIndicator, {
			CFrame = CFrame.new(position),
			Size = Vector3.new(1, 1, 1),
			DraggerContext = context,
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestLocalSpaceIndicator()

		expect(function()
			local handle = Roact.mount(element)
			Roact.unmount(handle)
		end).to.never.throw()
	end)

	it("should render correctly", function()
		local container = Instance.new("Folder")
		local element = createTestLocalSpaceIndicator(true)
		local handle = Roact.mount(element, container)

		local gui = container:FindFirstChildOfClass("ScreenGui")
		expect(gui).to.be.ok()
		local textLabel = gui:FindFirstChildOfClass("TextLabel")
		expect(textLabel).to.be.ok()

		Roact.unmount(handle)
	end)

	it("should not render if position is offscreen", function()
		local container = Instance.new("Folder")
		local element = createTestLocalSpaceIndicator(false)
		local handle = Roact.mount(element, container)

		expect(#container:GetChildren()).to.equal(0)

		Roact.unmount(handle)
	end)
end
