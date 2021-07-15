--[[
	Wraps a component such that the documentation at the top of the file is used
	for strict typing validation of the component's props.

	NOTE: This typechecking will only be run when the Roact global config has {propValidation = true}!
	This is helpful during development for making sure components are being used correctly,
	but should not be used in production code because it will impact performance.
	For more info, see: https://roblox.github.io/roact/api-reference/#propvalidation

	Typecheck.wrap
		Using Typecheck.wrap, components can be wrapped with strict typechecking.
		The typechecking is based on the block comment at the top of the Component file.
		Params:
			Component component: The Roact component itself.
			Script script: The Component script itself, where the docs are located.

	Example:
		local MyComponent = Roact.PureComponent:extend("MyComponent")
		Typecheck.wrap(MyComponent, script)

	Typecheck uses interfaces from Osyris's "t" library.
	For more info, see: https://github.com/osyrisrblx/t
]]
local Util = script.Parent.Parent
local THEME_REFACTOR = require(Util.RefactorFlags).THEME_REFACTOR
local DocParser = require(script.Parent.DocParser)

local FFlagShipBuiltinPluginAsByteCode = settings():GetFFlag("ShipBuiltinPluginAsByteCode")

local propsTraceback = [[%s
	Found in the props table of the Component %q.]]

local styleTraceback = [[%s
	Found in the StyleTable of the Component %q.]]

-- Helper function for wrap.
-- Given a t interface for the Component's props and style, validates before rendering the Component.
local function validate(component, propsInterface, styleInterface)
	component.validateProps = function()
		-- validateProps is called before init and before every render, but we want this
		-- to only be called once, so that it just sets up the renderAfterValidation wrapper.
		-- We know it's already ran if the wrapper already exists.
		if component.__renderAfterValidation then
			return true
		end

		-- Define a wrapper to validate props before every render.
		-- We aren't using validateProps directly because we also want to be able to
		-- validate a component's StyleTable if it is a component that uses Style.
		if component.__renderWithContext then
			-- If this component uses mapToProps to inject context values into props,
			-- we need to validate after context is injected. We can then also check Style.
			component.__renderAfterValidation = component.__renderWithContext
			function component:__renderWithContext()
				local success, errorMessage = propsInterface(self.props)
				if success then
					if styleInterface then
						local style
						if THEME_REFACTOR then
							style = self.props.Stylizer
						else
							style = self.props.Theme:getStyle("Framework", self)
						end
						success, errorMessage = styleInterface(style)
						if not success then
							errorMessage = styleTraceback:format(errorMessage, tostring(component))
						end
					end
				else
					errorMessage = propsTraceback:format(errorMessage, tostring(component))
				end
				assert(success, errorMessage)
				return self:__renderAfterValidation()
			end
		else
			component.__renderAfterValidation = component.render
			function component:render()
				local success, errorMessage = propsInterface(self.props)
				if not success then
					errorMessage = propsTraceback:format(errorMessage, tostring(component))
				end
				assert(success, errorMessage)
				return self:__renderAfterValidation()
			end
		end

		return true
	end
end

local function wrap(component, script)
	local isSourceAvailable = true
	if FFlagShipBuiltinPluginAsByteCode then
		-- script.Source is a Plugin-security API, and needs to be gated
		-- by pcall as DeveloperFramework also runs embedded in a place
		isSourceAvailable = false
		pcall(function()
			isSourceAvailable = script.Source ~= ""
		end)
	end
	if isSourceAvailable then
		local docParser = DocParser.new(component, script)
		local docs = docParser:parse()
		local propsInterface, styleInterface = DocParser.toInterface(docs)
		validate(component, propsInterface, styleInterface)
	end
end

return wrap
