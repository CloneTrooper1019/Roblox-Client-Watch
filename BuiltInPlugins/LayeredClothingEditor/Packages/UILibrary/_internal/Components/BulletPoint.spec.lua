return function()
		local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local BulletPoint = require(script.Parent.BulletPoint)

	local function createTestBulletPoint(container)
		return Roact.createElement(MockWrapper, {
            Container = container,
        }, {
            BulletPoint = Roact.createElement(BulletPoint, {
                Text = "test",
                TextSize = 20,
            }),
		})
	end

    it("should create and destroy without errors", function()
        local element = createTestBulletPoint()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestBulletPoint(container), container)
		local bulletPoint = container:FindFirstChildOfClass("Frame")

		expect(bulletPoint.Text).to.be.ok()
		expect(bulletPoint.Dot).to.be.ok()

		Roact.unmount(instance)
	end)
end