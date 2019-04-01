local Libraries = game:GetService("ReplicatedStorage"):WaitForChild("WorldEngine")
local Object = require(Libraries:WaitForChild("Object"))
local t = require(Libraries:WaitForChild("t"))
-- local qt = require(script.Parent.validator)

local questObjectiveConstructorValidator = t.tuple(t.integer, t.string)

local QuestObjective = Object:Extend("QuestObjective", {abstract = true})
function QuestObjective:constructor(stage, description)
	assert(questObjectiveConstructorValidator(stage, description))
	self._stage = stage
	self._description = description
end

function QuestObjective:GetDescription()
	return self._description
end

function QuestObjective:GetStage()
	return self._stage
end

return QuestObjective
