local import = require(script.Parent.Import).Test()
local import_server = require(script.Parent.Import).Test(true)
return function()
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
		"should be able to import relative",
		function()
			local result = import("../Logger")
			expect(result).to.equal(script.Parent.Logger)
		end
	)
	it(
		"should be able to import via variables",
		function()
			local _, path = import("$engine/Quests/Quest")
			expect(path).to.equal("ServerScriptService.WorldEngine.Quests.Quest")

			local _, path2 = import("$lib/Object")
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
end
