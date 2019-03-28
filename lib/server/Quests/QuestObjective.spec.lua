local Quest = require(script.Parent.Quest)
local QuestObjective = require(script.Parent.QuestObjective)

local TestObjective = QuestObjective:Extend("TestObjective")
function TestObjective:constructor(stageId)
	QuestObjective:super(self, stageId, "Test Objective")
end

return function()
	it(
		"should handle adding quest objectives",
		function()
			local myQuest = Quest.new("quest-obj-one", "Quest Objectives 1");
			myQuest:AddObjective(TestObjective.new(1, "Test Objective"))

			local objs = myQuest:GetObjectives()
			local firstObj = objs[1]
			expect(firstObj).to.be.ok()
			expect(firstObj.Stage).to.equal(1)
			expect(firstObj.Description).to.equal("Test Objective")
		end
	)
end
