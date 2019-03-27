return function()
	local Object = require(script.Parent.Object)

	local TestClass = Object:Extend("TestClass")
	function TestClass:constructor()
	end

	describe(
		"Classes",
		function()
			it(
				"should be able to create a class",
				function()
					local instance = TestClass.new()
					expect(instance).to.be.ok()
					expect(TestClass:Is(instance)).to.equal(true)
					expect(instance:IsType("TestClass")).to.equal(true)
				end
			)

			it(
				"should be able to handle object inheritance",
				function()
					local TestClass2 = TestClass:Extend("TestClass2")
					function TestClass2:constructor()
						TestClass:super(self)
					end

					local instance = TestClass2.new()
					expect(instance).to.be.ok()
					expect(TestClass:Is(instance)).to.equal(true)
					expect(instance:IsType("TestClass2")).to.equal(true)
					expect(instance:IsType("TestClass")).to.equal(true)
				end
			)

			it(
				"should pass arguments from new to constructor",
				function()
					local TestClass3 = Object:Extend("TestClass3")
					function TestClass3:constructor(value)
						self.value = value
					end

					local instance = TestClass3.new("Hello, World")

					expect(instance.value).to.equal("Hello, World")
				end
			)

			it("should pass arguments to base constructors through super", function()
				local TestClass4 = Object:Extend("TestClass4")
				function TestClass4:constructor(value)
					self.a = value
				end

				local TestClass5 = TestClass4:Extend("TestClass5")
				function TestClass5:constructor(a, b)
					TestClass4:super(self, a)
					self.b = b
				end

				local instance = TestClass5.new("Hello", "World")
				expect(instance.a).to.equal("Hello")
				expect(instance.b).to.equal("World")
			end)
		end
	)

	describe(
		"Enums",
		function()
			it(
				"should handle enum creation",
				function()
					local TestEnum = Object:Enum("TestEnum", {"TestValueA", "TestValueB"})
					expect(TestEnum).to.be.ok()

					expect(TestEnum:Is(TestEnum.TestValueA)).to.equal(true)
					expect(TestEnum:Is(TestEnum.TestValueB)).to.equal(true)

					expect(TestEnum.TestValueA.Value).to.equal(1)
					expect(TestEnum.TestValueB.Value).to.equal(2)

					expect(TestEnum.TestValueA.Name).to.equal("TestValueA")
					expect(TestEnum.TestValueB.Name).to.equal("TestValueB")
				end
			)
		end
	)
end
