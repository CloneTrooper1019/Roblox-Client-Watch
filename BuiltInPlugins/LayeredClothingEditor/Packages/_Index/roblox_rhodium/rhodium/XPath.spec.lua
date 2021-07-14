return function()
	local XPath = require(script.Parent.XPath)

	local function makeInstance(className, props, children)
		local instance = Instance.new(className)
		if children then
			for _, child in ipairs(children) do
				child.Parent = instance
			end
		end
		if props then
			for k, v in pairs(props) do
				instance[k] = v
			end
		end
		return instance
	end

	local specialChars = [[special chars !"#$%&'()*+,-./:;<=>?@[]\^_`{|}~]]
	local convertedSpecialChars = [[special chars !"#$%&'()*+\,-\./:;<\=>?@\[\]\\^_`{|}~]]

	local root = makeInstance("Folder",
			{
				Name = "root",
				Parent = workspace
			}, {
				makeInstance("Frame", {Name = "Frame"}, {
					makeInstance("TextButton", {
						Text = "Button1"
					}),
					makeInstance("TextLabel", {
						Text = "Label1"
					}),
					makeInstance("ImageButton", {

					})
				}),
				makeInstance("Frame", {Name = "Frame"}, {
					makeInstance("TextButton", {
						Text = "Button2"
					}),
					makeInstance("TextLabel", {
						Text = "Label2"
					})
				}),
				makeInstance("Frame", {Name = "Frame"}, {
					makeInstance("TextLabel", {Text = "Label3"}),
					makeInstance("Frame", {Name = specialChars}, {
						makeInstance("TextButton", {Name = "TextButton3"})
					}),
					makeInstance("TextLabel", {Name = "SpecialCharLabel", Text = specialChars})
				})
		})

	describe("basic tests", function()
		it("getFirstInstance should work", function()
			local path = XPath.new("game.Workspace.root.Frame[.TextButton.Text = Button2, .ClassName = Frame].TextLabel")
			local instance = path:getFirstInstance()
			expect(instance.Text).to.equal("Label2")
			expect(XPath.new(instance):toString()).to.equal("game.Workspace.root.Frame.TextLabel")
		end)
		it("wildcard should work", function()
			local path = XPath.new("game.Workspace.root.*[.TextButton.Text = Button2].TextLabel")
			local instance = path:getFirstInstance()
			expect(instance.Text).to.equal("Label2")
		end)
		it("wildcard on property should work", function()
			local path = XPath.new("game.Workspace.root.*[.ImageButton.Name = *].TextLabel")
			local instance = path:getFirstInstance()
			expect(instance.Text).to.equal("Label1")
		end)
	end)
	describe("should work with special chars", function()
		it("should work with special chars in path", function()
			local pathStr = "game.Workspace.root.Frame."..convertedSpecialChars..".TextButton3"
			local path = XPath.new(pathStr)
			expect(path:toString()).to.equal(pathStr)
			local instance = path:getFirstInstance()
			expect(instance.Name).to.equal("TextButton3")
		end)
		it("should work with special chars in filter keys", function()
			local pathStr = "game.Workspace.root.Frame[."..convertedSpecialChars..".TextButton3.Name = TextButton3].TextLabel"
			local path = XPath.new(pathStr)
			expect(path:toString()).to.equal(pathStr)
			local instance = path:getFirstInstance()
			expect(instance.Text).to.equal("Label3")
		end)
		it("should work with special chars in filter values", function()
			local pathStr = "game.Workspace.root.Frame[.SpecialCharLabel.Text = "..convertedSpecialChars.."].TextLabel"
			local path = XPath.new(pathStr)
			expect(path:toString()).to.equal(pathStr)
			local instance = path:getFirstInstance()
			expect(instance.Text).to.equal("Label3")
		end)
	end)
end
