return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local ExpandableList = require(script.Parent.ExpandableList)

	local function createTestExpandableList(props, children, container)
		return Roact.createElement(MockWrapper, {
            Container = container,
        }, {
			ExpandableList = Roact.createElement(ExpandableList, props, children)
		})
    end

    it("should create and destroy without errors", function()
		local element = createTestExpandableList({
            TopLevelItem = {},
            Content = {},
        })
		local instance = Roact.mount(element)
		Roact.unmount(instance)
    end)

    it("should require a top level item table", function()
		local element = createTestExpandableList({
            Content = {},
        })
		expect(function()
			Roact.mount(element)
		end).to.throw()
        local element = createTestExpandableList({
            TopLevelItem = true,
            Content = {}
        })
		expect(function()
			Roact.mount(element)
		end).to.throw()
    end)

    it("should require a content table", function()
		local element = createTestExpandableList({
            TopLevelItem = {},
        })
		expect(function()
			Roact.mount(element)
		end).to.throw()
        local element = createTestExpandableList({
            TopLevelItem = {},
            Content = true
        })
		expect(function()
			Roact.mount(element)
		end).to.throw()
	end)
	
	it("should render correctly", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestExpandableList({
			TopLevelItem = {},
            Content = {},
		}, {}, container), container)
		local frame = container:FindFirstChildOfClass("Frame")

		expect(frame.TopLevelItem).to.be.ok()
		expect(frame.ExpandableFrame).to.be.ok()

		Roact.unmount(instance)
	end)

	it("items should be sized to contents", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestExpandableList({
			TopLevelItem = {
				ArrowIcon = Roact.createElement("TextLabel", {
					Size = UDim2.new(0, 100, 0, 100),
				}),
			},
			Content = {
				Label = Roact.createElement("TextLabel", {
					Size = UDim2.new(0, 100, 0, 100),
				}),
			},
		}, {}, container), container)
		local frame = container:FindFirstChildOfClass("Frame")

		expect(frame.TopLevelItem.Size.X.Scale).to.equal(1)
		expect(frame.TopLevelItem.Size.Y.Offset).to.equal(100)

		expect(frame.ExpandableFrame.Size.X.Scale).to.equal(1)
		expect(frame.ExpandableFrame.Size.Y.Offset).to.equal(100)


		Roact.unmount(instance)
	end)

	it("list should only show top item initially", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestExpandableList({
			TopLevelItem = {
				ArrowIcon = Roact.createElement("TextLabel", {
					Size = UDim2.new(0, 100, 0, 100),
				}),
			},
			Content = {
				Label = Roact.createElement("TextLabel", {
					Size = UDim2.new(0, 100, 0, 100),
				}),
			},
			IsExpanded = false,
		}, {}, container), container)
		local frame = container:FindFirstChildOfClass("Frame")

		expect(frame.Size.X.Scale).to.equal(1)
		expect(frame.Size.Y.Offset).to.equal(100)

		Roact.unmount(instance)
	end)

	it("list should only show both items when expanded is true", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestExpandableList({
			TopLevelItem = {
				ArrowIcon = Roact.createElement("TextLabel", {
					Size = UDim2.new(0, 100, 0, 100),
				}),
			},
			Content = {
				Label = Roact.createElement("TextLabel", {
					Size = UDim2.new(0, 100, 0, 100),
				}),
			},
			IsExpanded = true,
		}, {}, container), container)
		local frame = container:FindFirstChildOfClass("Frame")

		expect(frame.Size.X.Scale).to.equal(1)
		expect(frame.Size.Y.Offset).to.equal(200)

		Roact.unmount(instance)
	end)
end