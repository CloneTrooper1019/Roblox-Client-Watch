return function()
	local Framework = script.Parent.Parent.Parent
	local StyleModifier = require(Framework.Util.StyleModifier)
	local FrameworkTypes = require(script.Parent.FrameworkTypes)
	local Symbol = require(Framework.Util.Symbol)
	local Signal = require(Framework.Util.Signal)
	local Flags = require(Framework.Util.Flags)
	local FlagsList = Flags.new({
		FFlagRefactorDevFrameworkContextItems = {"RefactorDevFrameworkContextItems"},
	})

	it("should typecheck Components", function()
		expect(FrameworkTypes.Component({})).to.equal(false)
		expect(FrameworkTypes.Component({
			render = {},
		})).to.equal(false)
		expect(FrameworkTypes.Component({
			render = function()
			end,
		})).to.equal(true)
	end)

	it("should typecheck ContextItems", function()
		expect(FrameworkTypes.ContextItem({})).to.equal(false)
		expect(FrameworkTypes.ContextItem({
			createProvider = {},
		})).to.equal(false)
		expect(FrameworkTypes.ContextItem({
			createProvider = function()
			end,
		})).to.equal(true)
	end)

	it("should typecheck Themes", function()
		expect(FrameworkTypes.Theme({})).to.equal(false)
		expect(FrameworkTypes.Theme({
			getStyle = {},
		})).to.equal(false)
		expect(FrameworkTypes.Theme({
			getStyle = function()
			end,
		})).to.equal(true)
	end)

	it("should typecheck Plugins", function()
		expect(FrameworkTypes.Plugin({})).to.equal(false)
		expect(FrameworkTypes.Plugin({
			get = {},
		})).to.equal(false)
		expect(FrameworkTypes.Plugin({
			get = function()
			end,
		})).to.equal(true)
	end)

	it("should typecheck Mice", function()
		expect(FrameworkTypes.Mouse({})).to.equal(false)
		expect(FrameworkTypes.Mouse({
			get = {},
		})).to.equal(false)
		expect(FrameworkTypes.Mouse({
			get = function()
			end,
		})).to.equal(true)
	end)

	it("should typecheck Focuses", function()
		if FlagsList:get("FFlagRefactorDevFrameworkContextItems") then
			expect(FrameworkTypes.Focus({})).to.equal(false)
			expect(FrameworkTypes.Focus({
				get = {},
			})).to.equal(false)
			expect(FrameworkTypes.Focus({
				get = function()
				end,
			})).to.equal(true)
		else
			expect(FrameworkTypes.Focus({})).to.equal(false)
			expect(FrameworkTypes.Focus({
				getTarget = {},
			})).to.equal(false)
			expect(FrameworkTypes.Focus({
				getTarget = function()
				end,
			})).to.equal(true)
		end
	end)

	it("should typecheck Symbols", function()
		expect(FrameworkTypes.Symbol(Symbol.named("Test"))).to.equal(true)
		expect(FrameworkTypes.Symbol(0)).to.equal(false)
	end)

	it("should typecheck Signals", function()
		expect(FrameworkTypes.Signal({})).to.equal(false)
		expect(FrameworkTypes.Signal(0)).to.equal(false)
		expect(FrameworkTypes.Signal(Signal.new())).to.equal(true)
	end)

	it("should typecheck StyleModifiers", function()
		expect(FrameworkTypes.StyleModifier("Hover")).to.equal(false)
		expect(FrameworkTypes.StyleModifier(StyleModifier.Hover)).to.equal(true)
	end)

	it("should typecheck Styles", function()
		expect(FrameworkTypes.Style("String")).to.equal(true)
		expect(FrameworkTypes.Style({})).to.equal(true)
		expect(FrameworkTypes.Style(0)).to.equal(false)
	end)

	it("should typecheck Instances", function()
		expect(FrameworkTypes.Instance(Instance.new("Folder"))).to.equal(true)
		expect(FrameworkTypes.Instance({})).to.equal(true)
	end)
end
