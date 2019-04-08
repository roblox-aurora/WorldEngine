local Promisify = require(script.Parent.Promisify)
local Promise = require(script.Parent.Promise)
return function()
	local ERR = "Value must be string!"
	local myFunctionAsync =
		Promisify(
		function(value)
			assert(type(value) == "string", ERR)
			return value:rep(3)
		end
	)

	describe(
		"Wrapping functions in a promise",
		function()
			it(
				"should handle wrapping a function in a promise",
				function()
					local callTest = myFunctionAsync("Test")
					expect(Promise.is(callTest)).to.equal(true)

					local success, result = callTest:await() -- use await because can't test with :andThen( )
					expect(success).to.equal(true)
					expect(result).to.equal("TestTestTest")

					local callTest2 = myFunctionAsync(10)
					local success2 = callTest2:await()
					expect(success2).to.equal(false)
				end
			)
		end
	)
end
