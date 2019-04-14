local import = require(script.Parent.Import)
return function()
	local import_relative = import.relative
	local import_server = import.lemur(true)
	import = import.lemur()

	it(
		"should handle regular imports (similar to require)",
		function()
			local test = import(script.Parent.Object)
			expect(test).to.equal(require(script.Parent.Object))
		end
	)

	it(
		"should handle explicit relativeTo args",
		function()
			local _, test = import("WorldEngine/Object", "ReplicatedStorage")
			expect(test).to.equal("ReplicatedStorage.WorldEngine.Object")
		end
	)

	it(
		"should be able to import from ReplicatedStorage",
		function()
			local result = import("~/WorldEngine/Import")
			expect(result).to.equal(script.Parent.Import)

			local _, result2 = import_server("~/WorldEngine/Quests/Quest")
			expect(result2).to.equal("ServerScriptService.WorldEngine.Quests.Quest")
		end
	)
	it(
		"should import libraries by default",
		function()
			local result = import "Logger"
			expect(result).to.equal(script.Parent.Logger)
		end
	)
	it(
		"should be able to import relative",
		function()
			local result = import("../Logger")
			expect(result).to.equal(script.Parent.Logger)
		end
	)
	it(
		"should be able to import via variables",
		function()
			local _, path = import("@core/Quests/Quest")
			expect(path).to.equal("ServerScriptService.WorldEngine.Quests.Quest")

			local _, path2 = import("@corelib/Object")
			expect(path2).to.equal("ReplicatedStorage.WorldEngine.Object")
		end
	)
	it(
		"should be able to import via root",
		function()
			local _, test = import("/ServerScriptService/WorldEngine/Quests/Quest")
			expect(test).to.equal("ServerScriptService.WorldEngine.Quests.Quest")
		end
	)
	it(
		"should handle prototype.relative",
		function()
			expect(
				function()
					import_relative("Logger") -- should error because Logger isn't a member of script
				end
			).to.throw()
		end
	)

	it(
		"should handle defaults",
		function()
			local Promisify = import_relative "../Promisify"
			expect(Promisify).to.equal(require(script.Parent.Promisify).default)

			local Promisify2 = import_relative(script.Parent.Promisify)
			expect(Promisify2).to.equal(require(script.Parent.Promisify).default)
		end
	)

	it(
		"should not import non-modulescripts",
		function()
			expect(
				function()
					import_relative "/ReplicatedStorage"
				end
			).to.throw()
		end
	)

	describe(
		"Multi Imports",
		function()
			it(
				"should handle multiple imports",
				function()
					local Logger, Object = import_relative {"Logger", "Object"}:from "~/WorldEngine"
					expect(Logger).to.equal(require(script.Parent.Logger))
					expect(Object).to.equal(require(script.Parent.Object))
				end
			)

			it(
				"should error on invalid import names",
				function()
					expect(
						function()
							import_relative {"."}:from "~/WorldEngine"
						end
					).to.throw()
				end
			)
		end
	)
end
