local Quest = require(script.Parent.Quest)

return function()
	it(
		"Should allow creating quests",
		function()
			local testQuest = Quest.new("quest-name", "Quest Name")
			expect(testQuest).to.be.ok()
			expect(testQuest.Id).to.equal("quest-name")
			expect(testQuest.Name).to.equal("Quest Name")
		end
	)

	it(
		"should not allow id duplicates",
		function()
			expect(
				function()
					Quest.new("quest-name", "Quest Name 2")
				end
			).to.throw()
		end
	)

	it(
		"should not allow invalid ids",
		function()
			expect(
				function()
					Quest.new("cool quest", "Quest Name 3")
				end
			).to.throw()

			expect(
				function()
					Quest.new("c%ool", "Quest Name 3")
				end
			).to.throw()

			expect(
				function()
					Quest.new("coolQuest", "Quest Name 3")
				end
			).to.throw()
		end
	)
end
