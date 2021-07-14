return function()
	local Style = script.Parent
	local Core = Style.Parent
	local UIBlox = Core.Parent

	--Note: remove along with styleRefactorConfig
	local UIBloxConfig = require(UIBlox.UIBloxConfig)
	local styleRefactorConfig = UIBloxConfig.styleRefactorConfig

	local itSkipIfConfigDisabled = it
	if not styleRefactorConfig then
		itSkipIfConfigDisabled = itSKIP
	end
	---

	local Packages = UIBlox.Parent
	local Roact = require(Packages.Roact)
	local StyleProvider = require(script.Parent.StyleProvider)
	local withStyle = require(script.Parent.withStyle)

	itSkipIfConfigDisabled("should pass style through multiple components", function()
		local styleTestValue = nil
		local function UseStyle(props)
			return withStyle(function(style)
				styleTestValue = style.testValue
				return nil
			end)
		end

		local function StyleTree(props)
			return Roact.createElement(StyleProvider, {
				style = {
					testValue = props.styleValue,
				}
			}, {
				Intermediate = Roact.createElement("Frame", {}, {
					StyledChild = Roact.createElement(UseStyle)
				})
			})
		end

		expect(styleTestValue).never.to.be.ok()
		local instance = Roact.mount(Roact.createElement(StyleTree, {
			styleValue = 10,
		}))
		expect(styleTestValue).to.equal(10)

		Roact.unmount(instance)
	end)

	itSkipIfConfigDisabled("should update when changed", function()
		local styleTestValue = nil
		local function UseStyle(props)
			return withStyle(function(style)
				styleTestValue = style.testValue
				return nil
			end)
		end

		local function StyleTree(props)
			return Roact.createElement(StyleProvider, {
				style = {
					testValue = props.styleValue,
				}
			}, {
				Intermediate = Roact.createElement("Frame", {}, {
					StyledChild = Roact.createElement(UseStyle)
				})
			})
		end

		expect(styleTestValue).never.to.be.ok()
		local instance = Roact.mount(Roact.createElement(StyleTree, {
			styleValue = 10,
		}))
		expect(styleTestValue).to.equal(10)
		instance = Roact.update(instance, Roact.createElement(StyleTree, {
			styleValue = 99,
		}))
		expect(styleTestValue).to.equal(99)

		Roact.unmount(instance)
	end)
end

