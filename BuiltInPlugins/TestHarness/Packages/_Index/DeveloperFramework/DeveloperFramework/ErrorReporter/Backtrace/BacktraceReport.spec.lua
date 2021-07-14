return function()
	local BacktraceReport = require(script.Parent.BacktraceReport)
	local Framework = script.Parent.Parent.Parent
	local tutils = require(Framework.Util.Typecheck.tutils)
	local deepEqual = require(Framework.Util.deepEqual)

	describe("new()", function()
		it("should return a valid report", function()
			local report = BacktraceReport.new()
			local isValid = report:validate()

			expect(isValid).to.equal(true)
		end)
	end)

	describe("validate()", function()
		it("should return false if the report has registers but no arch information, true otherwise", function()
			local report = BacktraceReport.new()

			report.threads = {
				default = {
					stack = {
						[1] = {
							registers = {
								rax = "16045690984833335023",
							},
						}
					},
				},
			}

			expect(report:validate()).to.equal(false)

			-- invalid arch
			report.arch = {
				name = "x64",
				regsiters = nil,
			}

			expect(report:validate()).to.equal(false)

			-- correct arch
			report.arch = {
				name = "x64",
				registers = {
					rax = "u64",
				},
			}

			expect(report:validate()).to.equal(true)
		end)
	end)

	describe("IAnnotations", function()
		local IAnnotations = BacktraceReport.IAnnotations

		it("should return false if not a table", function()
			local result = IAnnotations("string")
			expect(result).to.equal(false)
		end)

		it("should return false if a non-table value is not string, number, or boolean", function()
			local result = IAnnotations({
				Value = function() end,
			})
			expect(result).to.equal(false)

			result = IAnnotations({
				Value = "a",
				Value2 = 1,
				Value3 = false,
				Recursive = {
					Value11 = "ab",
					MoreRecursive = {
						Value12 = "abc",
						Value22 = function() end,
					},
				},
			})
			expect(result).to.equal(false)
		end)

		it("should return true for an empty table", function()
			expect(IAnnotations({})).to.equal(true)
		end)

		it("should return true if a non-table value is either string, number, or boolean", function()
			local result = IAnnotations({
				Value = "a",
				Value2 = 1,
				Value3 = false,
				Recursive = {
					Value11 = "ab",
					Value21 = 2,
					Array = {
						[1] = "abc",
						[2] = 3,
						[3] = true,
					},
				},
			})
			expect(result).to.equal(true)
		end)
	end)

	describe("addAttributes()", function()
		it("should correctly add attributes", function()
			local report = BacktraceReport.new()
			report:addAttributes({
				att1 = 1,
			})
			expect(tutils.fieldCount(report.attributes)).to.equal(1)
			expect(report.attributes.att1).to.equal(1)
			report:addAttributes({
				att1 = 2,
				att2 = false,
				att3 = "test",
			})
			expect(tutils.fieldCount(report.attributes)).to.equal(3)
			expect(report.attributes.att1).to.equal(2)
			expect(report.attributes.att2).to.equal(false)
			expect(report.attributes.att3).to.equal("test")
		end)
	end)

	describe("addAnnotations()", function()
		it("should correctly add annotations", function()
			local environmentVariables = {
				ENV_VAR_EXAMPLE = "example",
			}
			local dependencies = {
				Roact = {
					version = "0.2.0",
				},
				Otter = {
					version = "0.1.0",
				},
			}

			local report = BacktraceReport.new()

			report:addAnnotations({
				EnvironmentVariables = environmentVariables,
			})
			expect(tutils.fieldCount(report.annotations)).to.equal(1)
			expect(deepEqual(report.annotations.EnvironmentVariables, environmentVariables)).to.equal(true)

			report:addAnnotations({
				SomeProperty = true,
				Dependencies = dependencies,
			})
			expect(tutils.fieldCount(report.annotations)).to.equal(3)
			expect(deepEqual(report.annotations.EnvironmentVariables, environmentVariables)).to.equal(true)
			expect(report.annotations.SomeProperty).to.equal(true)
			expect(deepEqual(report.annotations.Dependencies, dependencies)).to.equal(true)
		end)
	end)

	describe("addStackToThread()", function()
		it("should correctly add stack to the thread with the name provided", function()
			local stack1 = {
				[1] = {
					line = "100",
					funcName = "field testError",
					sourceCode = "1",
				}
			}
			local stack2 = {
				[1] = {
					line = "110",
					funcName = "field ?",
					sourceCode = "2",
				}
			}

			local report = BacktraceReport.new()

			report:addStackToThread(stack1, "main")
			expect(tutils.fieldCount(report.threads)).to.equal(1)
			expect(deepEqual(report.threads.main.stack, stack1)).to.equal(true)

			report:addStackToThread(stack2, "1")
			expect(tutils.fieldCount(report.threads)).to.equal(2)
			expect(deepEqual(report.threads.main.stack, stack1)).to.equal(true)
			expect(deepEqual(report.threads["1"].stack, stack2)).to.equal(true)
		end)
	end)

	describe("fromMessageAndStack()", function()
		it("should return a valid report", function()
			local report = BacktraceReport.fromMessageAndStack("index nil", "Script 'Workspace.Script', Line 3")
			local isValid = report:validate()

			expect(isValid).to.equal(true)
		end)
	end)
end