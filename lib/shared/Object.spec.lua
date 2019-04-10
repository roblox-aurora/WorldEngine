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
				"should not allow creating an object from another object",
				function()
					expect(
						function()
							local instance = TestClass.new()
							instance.new()
						end
					).to.throw()
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

			it(
				"should pass arguments to base constructors through super",
				function()
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
				end
			)

			it(
				"should not allow creation of abstract objects",
				function()
					local TestClass6 = Object:Extend("AbstractClass", {abstract = true})
					expect(
						function()
							TestClass6.new()
						end
					).to.throw()
				end
			)

			it(
				"should not allow duplicate class names",
				function()
					Object:Extend("DuplicateClass")
					expect(
						function()
							Object:Extend("DuplicateClass")
						end
					).to.throw()
				end
			)

			it(
				"should not allow extension of sealed classes",
				function()
					local SealedClass = Object:Extend("SealedClass", {sealed = true})
					expect(
						function()
							SealedClass:Extend("SubSealedClass")
						end
					).to.throw()
				end
			)

			describe(
				"Methods",
				function()
					it(
						"should not allow calling IsType on classes",
						function()
							expect(
								function()
									TestClass:IsType(TestClass)
								end
							).to.throw()
						end
					)

					it(
						"should return false on non-matching isType classNames",
						function()
							local instance = TestClass.new()
							expect(instance:IsType("Nope")).to.equal(false)
						end
					)

					it(
						"should not allow calling Is on instances",
						function()
							expect(
								function()
									local instance = TestClass.new()
									instance:Is("TestClass")
								end
							).to.throw()
						end
					)
				end
			)
		end
	)

	describe(
		"ObjectFactory",
		function()
			it(
				"should not allow assigning a value to ObjectFactory",
				function()
					expect(
						function()
							Object.test = 10
						end
					).to.throw()
				end
			)
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

					expect(tostring(TestEnum.TestValueA)).to.equal("Enum[TestEnum@TestValueA]")
				end
			)
		end
	)

	it(
		"should be able to get classes with Get()",
		function()
			local get = Object:Get("TestClass")
			expect(get).to.be.ok()
		end
	)

	it(
		"should error on invalid classes in Get()",
		function()
			expect(
				function()
					Object:Get("Invalid")
				end
			).to.throw()
		end
	)
end
