local Logger = require(script.Parent.Logger)

return function()
	describe(
		"Variable parser",
		function()
			it(
				"should handle parsing variables",
				function()
					local logger = Logger.new()
					local helloWorld = logger:_parseVariable("Hello {0}", 0, "World")
					expect(helloWorld).to.be.ok()
					expect(helloWorld).to.equal("Hello World")

					local hello20 = logger:_parseVariable("Hello {0}", 0, 20)
					expect(hello20).to.be.ok()
					expect(hello20).to.equal("Hello 20")
				end
			)

			it(
				"should handle the json formatter",
				function()
					local logger = Logger.new()
					local helloWorld = logger:_parseVariable("{0:j}", 0, {hello = "world"})
					expect(helloWorld).to.be.ok()
					expect(helloWorld).to.equal('{"hello":"world"}')
				end
			)

			it(
				"should handle the quote formatter",
				function()
					local logger = Logger.new()
					local helloWorld = logger:_parseVariable("Hello {0:q}", 0, "World")
					expect(helloWorld).to.be.ok()
					expect(helloWorld).to.equal('Hello "World"')

					local hello20 = logger:_parseVariable("Hello {WORLDVAR:q}", "WORLDVAR", 20)
					expect(hello20).to.be.ok()
					expect(hello20).to.equal('Hello "20"')
				end
			)

			it(
				"should handle the hex formatter",
				function()
					local logger = Logger.new()
					local helloWorld = logger:_parseVariable("{0:x}", 0, 2)
					expect(helloWorld).to.be.ok()
					expect(helloWorld).to.equal("2")

					local hello20 = logger:_parseVariable("{HEX2:2x}", "HEX2", 15)
					expect(hello20).to.be.ok()
					expect(hello20).to.equal("0f")
				end
			)

			it(
				"should handle the floating point formatter",
				function()
					local logger = Logger.new()
					local helloWorld = logger:_parseVariable("{0:f}", 0, 2)
					expect(helloWorld).to.be.ok()
					expect(helloWorld).to.equal("2.0")

					local hello20 = logger:_parseVariable("{FLOAT2:2f}", "FLOAT2", 15)
					expect(hello20).to.be.ok()
					expect(hello20).to.equal("15.00")
				end
			)

			it(
				"should handle the integer formatter",
				function()
					local logger = Logger.new()
					local helloWorld = logger:_parseVariable("{0:i}", 0, 2.456)
					expect(helloWorld).to.be.ok()
					expect(helloWorld).to.equal("2")

					local hello20 = logger:_parseVariable("{INT2:i}", "INT2", 15.543)
					expect(hello20).to.be.ok()
					expect(hello20).to.equal("15")
				end
			)

			it(
				"should handle the decimal formatter",
				function()
					local logger = Logger.new()
					local helloWorld = logger:_parseVariable("{0:d}", 0, 2.456)
					expect(helloWorld).to.be.ok()
					expect(helloWorld).to.equal("2")

					local hello20 = logger:_parseVariable("{INT5:5d}", "INT5", 15.543)
					expect(hello20).to.be.ok()
					expect(hello20).to.equal("00015")
				end
			)

			it(
				"should handle the rounding integer formatter",
				function()
					local logger = Logger.new()
					local helloWorld = logger:_parseVariable("{0:1i}", 0, 2.556) -- will round up
					expect(helloWorld).to.be.ok()
					expect(helloWorld).to.equal("3")

					local helloWorld2 = logger:_parseVariable("{0:-1i}", 0, 2.356) -- will round down
					expect(helloWorld2).to.be.ok()
					expect(helloWorld2).to.equal("2")
				end
			)

			it(
				"should error on invalid formatters",
				function()
					local logger = Logger.new()

					expect(
						function()
							logger:_parseVariable("{0:kek}", 0, "hi")
						end
					).to.throw()
				end
			)
		end
	)

	describe(
		"String Formatter",
		function()
			it(
				"should format regular one-based indexes",
				function()
					local logger = Logger.new()
					local testStr = logger:Format("{1}, {2}!", "Hello", "World")
					expect(testStr).to.equal("Hello, World!")
				end
			)

			it(
				"should format dictionary based values",
				function()
					local logger = Logger.new()
					local testStr = logger:FormatTable("{Hello}, {World}!", {Hello = "Hello", World = "World"})
					expect(testStr).to.equal("Hello, World!")
				end
			)

			it(
				"should error on invalid indexes",
				function()
					local logger = Logger.new()

					expect(
						function()
							logger:Format("{1}", nil, "Hi there")
						end
					).to.throw()

					expect(
						function()
							logger:Format("{0}", "hi there") -- idx zero doesn't exist, should be 1 or use zeroBasedIndexing!
						end
					).to.throw()

					expect(
						function()
							logger:FormatTable("{0}", {value = "hi"})
						end
					).to.throw()
				end
			)
		end
	)

	it(
		"should support the default logger",
		function()
			local default = Logger:Is(getmetatable(Logger).__index)
			expect(default).to.equal(true)
		end
	)

	it(
		"should only allow adding loggers to the table",
		function()
			expect(
				function()
					Logger.MyLogger = Logger.new()
				end
			).to.never.throw()

			expect(
				function()
					Logger.FailValue = 10
				end
			).to.throw()
		end
	)

	describe(
		"Prefixes",
		function()
			it(
				"should work with full script names",
				function()
					local logger = Logger.new({prefix = Logger.Prefix.ScriptFullName, verbosity = Logger.Verbosity.Verbose})
					expect(logger:Info("Test"):match("^%[(.-)%]")).to.equal("ReplicatedStorage.WorldEngine.Logger.spec")
				end
			)
			it(
				"should work with script names",
				function()
					local logger = Logger.new({prefix = Logger.Prefix.ScriptName, verbosity = Logger.Verbosity.Verbose})
					expect(logger:Info("Test"):match("^%[(.-)%]")).to.equal("Logger.spec")
				end
			)
			it(
				"should work with custom prefixes",
				function()
					local logger = Logger.new({prefix = "MyLogger", verbosity = Logger.Verbosity.Verbose})
					expect(logger:Info("Test"):match("^%[(.-)%]")).to.equal("MyLogger")
				end
			)
			it(
				"should work with no prefix",
				function()
					local logger = Logger.new({prefix = Logger.Prefix.None, verbosity = Logger.Verbosity.Verbose})
					expect(logger:Info("Test"):match("^%[(.-)%]")).never.to.be.ok()
				end
			)
		end
	)

	describe(
		"Constructor",
		function()
			it(
				"should allow disabling of the formatter",
				function()
					local logger = Logger.new({formatterEnabled = false})
					expect(logger.formatterEnabled).to.equal(false)
				end
			)
		end
	)
end
