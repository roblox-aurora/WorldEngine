local import = require(script.Parent.Import)
return function()
	local import_relative = import.relative
	local import_server = import.lemur(true)
	import = import.lemur()

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
			local _, path = import("@engine/Quests/Quest")
			expect(path).to.equal("ServerScriptService.WorldEngine.Quests.Quest")

			local _, path2 = import("@lib/Object")
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
		"should handle multiple imports",
		function()
			local Logger, Object = import_relative {"Logger", "Object"} :from "~/WorldEngine"
			expect(Logger).to.equal(require(script.Parent.Logger))
			expect(Object).to.equal(require(script.Parent.Object))
		end
	)
end
