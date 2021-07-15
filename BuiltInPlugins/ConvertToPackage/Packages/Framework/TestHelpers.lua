local strict = require(script.Parent.Util.strict)

return strict({
	Instances = require(script.Instances),

	makeSettableValue = require(script.makeSettableValue),
	provideMockContext = require(script.provideMockContext),
	runFrameworkTests = require(script.runFrameworkTests),
	setEquals = require(script.setEquals),
	testImmutability = require(script.testImmutability),
})
