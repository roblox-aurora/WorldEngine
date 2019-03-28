local Libraries = game:GetService("ReplicatedStorage"):WaitForChild("Libraries")
local Object = require(Libraries:WaitForChild("Object"))
local t = require(Libraries:WaitForChild("t"))
local qt = require(script.Parent.validator)
local registry = {}

local questConstructorValidator = t.tuple(t.intersection(qt.id, qt.uniqueKey(registry)), t.string)

local Quest = Object:Extend("Quest")
function Quest:constructor(uniqueQuestId, name)
	assert(questConstructorValidator(uniqueQuestId, name))
	self.Id = uniqueQuestId
	self.Name = name

	registry[uniqueQuestId] = self
end

return Quest
