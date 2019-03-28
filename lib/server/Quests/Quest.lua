local Libraries = game:GetService("ReplicatedStorage"):WaitForChild("Libraries")
local Object = require(Libraries:WaitForChild("Object"))
local QuestObjective = require(script.Parent.QuestObjective)
local t = require(Libraries:WaitForChild("t"))
local qt = require(script.Parent.validator)
local registry = {}

local questConstructorValidator = t.tuple(t.intersection(qt.id, qt.uniqueKey(registry)), t.string)
local isQuestObjective = Object.typeIs(QuestObjective)

local Quest = Object:Extend("Quest")
function Quest:constructor(uniqueQuestId, name)
	assert(questConstructorValidator(uniqueQuestId, name))
	self.Id = uniqueQuestId
	self.Name = name
	self.Objectives = {}

	registry[uniqueQuestId] = self
end

function Quest:AddObjective(objective)
	assert(isQuestObjective(objective))
	table.insert(self.Objectives, objective)
end

function Quest:GetObjectives()
	return self.Objectives
end

return Quest
