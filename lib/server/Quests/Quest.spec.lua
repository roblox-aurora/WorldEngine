local Quest = require(script.Parent.Quest)

return function()
	it(
		"Should allow creating quests",
		function()
			local testQuest = Quest.new("quest-name", "Quest Name")
			expect(testQuest).to.be.ok()
			expect(testQuest.Id).to.equal("quest-name")
			expect(testQuest.Name).to.equal("Quest Name")

			local testQuest2 = Quest.new("quest-name", "Quest Name 2");
		end
	)
end
