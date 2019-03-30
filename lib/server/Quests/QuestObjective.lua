local Libraries = game:GetService("ReplicatedStorage"):WaitForChild("WorldEngine")
local Object = require(Libraries:WaitForChild("Object"))
local t = require(Libraries:WaitForChild("t"))
-- local qt = require(script.Parent.validator)

local questObjectiveConstructorValidator = t.tuple(t.integer, t.string)

local QuestObjective = Object:Extend("QuestObjective", {abstract = true})
function QuestObjective:constructor(stage, description)
	assert(questObjectiveConstructorValidator(stage, description))
	self.Stage = stage
	self.Description = description
end

function QuestObjective:GetDescription()
	return self.Description
end

return QuestObjective
