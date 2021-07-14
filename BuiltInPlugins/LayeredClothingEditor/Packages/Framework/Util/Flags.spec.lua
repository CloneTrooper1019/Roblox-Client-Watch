return function()
	local Flags = require(script.Parent.Flags)

	describe("new", function()
		it("should return a table", function()
			local flags = Flags.new()
			expect(flags).to.be.a("table")

			-- CANNOT TEST Flags.new(featureMap) AS IT TOUCHES REAL FASTFLAGS AND GLOBAL STATE
		end)

		describe("configurations", function()
			it("shouldAssertOnMissingFlag", function()
				expect(function()
					local flags = Flags.new(nil, {
						shouldAssertOnMissingFlag = true,
					})
					flags:get("someUndefinedFlag")
				end).to.throw()

				local flags = Flags.new(nil, {
					shouldAssertOnMissingFlag = false,
				})
				local value = flags:get("someUndefinedFlag")
				expect(value).to.be.ok()
			end)

			--[[it("shouldFetchLiveValues", function()
				-- CANNOT TEST THIS CONFIGURATION WHEN TRUE
			end)]]

			it("defaultValueIfMissing", function()
				local flags = Flags.new(nil, {
					shouldAssertOnMissingFlag = false,
					defaultValueIfMissing = true,
				})
				local isEnabled = flags:get("someUndefinedFlag")
				expect(isEnabled).to.equal(true)
			end)
		end)
	end)

	describe("mock", function()
		it("should return a table", function()
			local flags = Flags.mock()
			expect(flags).to.be.a("table")
		end)

		it("should allow a value to be the default for flags that aren't defined", function()
			local flags = Flags.mock(true)
			local isEnabled = flags:get("someUndefinedKey")
			expect(isEnabled).to.equal(true)

			flags = Flags.mock(false)
			isEnabled = flags:get("someOtherKey")
			expect(isEnabled).to.equal(false)

			-- by default, set to false
			flags = Flags.mock()
			isEnabled = flags:get("someFinalKey")
			expect(isEnabled).to.equal(false)
		end)

		it("should allow specific flags to be enabled/disabled in tests", function()
			local flags = Flags.mock(false)
			local isEnabled = flags:get("someFlags")
			expect(isEnabled).to.equal(false)

			flags:setLocalOverride("someFlags", true)
			isEnabled = flags:get("someFlags")
			expect(isEnabled).to.equal(true)
		end)
	end)

	describe("setLocalOverride", function()
		it("should throw if the feature does not exist", function()
			local flags = Flags.new({
				Feature = "Flag",
			}, {
				shouldFetchLiveValues = false,
			})
			expect(function()
				flags:setLocalOverride("NoFeatureHere", true)
			end).to.throw()
		end)

		it("should override the value", function()
			local flags = Flags.new({
				Feature = "Flag",
			}, {
				shouldFetchLiveValues = false,
			})
			expect(flags:get("Feature")).to.equal(false)
			flags:setLocalOverride("Feature", true)
			expect(flags:get("Feature")).to.equal(true)
			flags:setLocalOverride("Feature", false)
			expect(flags:get("Feature")).to.equal(false)
		end)
	end)

	describe("setAllLocalOverrides", function()
		it("should set the local override for every feature", function()
			local flags = Flags.new({
				Feature = "Flag",
				OtherFeature = "OtherFlag",
			}, {
				shouldFetchLiveValues = false,
			})
			expect(flags:get("Feature")).to.equal(false)
			expect(flags:get("OtherFeature")).to.equal(false)
			flags:setAllLocalOverrides(true)
			expect(flags:get("Feature")).to.equal(true)
			expect(flags:get("OtherFeature")).to.equal(true)
			flags:setAllLocalOverrides(false)
			expect(flags:get("Feature")).to.equal(false)
			expect(flags:get("OtherFeature")).to.equal(false)
		end)
	end)

	describe("clearLocalOverride", function()
		it("should clear the override", function()
			local flags = Flags.new({
				Feature = "Flag",
			}, {
				shouldFetchLiveValues = false,
			})
			flags:setLocalOverride("Feature", true)
			expect(flags:get("Feature")).to.equal(true)
			flags:clearLocalOverride("Feature")
			expect(flags:get("Feature")).to.equal(false)
		end)

		it("should throw if the override was never set", function()
			local flags = Flags.new({
				Feature = "Flag",
			}, {
				shouldFetchLiveValues = false,
			})
			expect(function()
				flags:clearLocalOverride("NoFeatureHere", true)
			end).to.throw()
		end)
	end)

	describe("clearAllLocalOverrides", function()
		it("should clear the local override for every feature", function()
			local flags = Flags.new({
				Feature = "Flag",
				OtherFeature = "OtherFlag",
			}, {
				shouldFetchLiveValues = false,
			})
			expect(flags:get("Feature")).to.equal(false)
			expect(flags:get("OtherFeature")).to.equal(false)
			flags:setAllLocalOverrides(true)
			expect(flags:get("Feature")).to.equal(true)
			expect(flags:get("OtherFeature")).to.equal(true)
			flags:clearAllLocalOverrides()
			expect(flags:get("Feature")).to.equal(false)
			expect(flags:get("OtherFeature")).to.equal(false)
		end)
	end)
end
