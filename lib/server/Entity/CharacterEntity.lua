local WorldEngine = game:GetService("ReplicatedStorage"):WaitForChild("WorldEngine")
local t = require(WorldEngine:WaitForChild("t"))

local Entity = require(script.Parent.Entity)
local CharacterEntityConstructorArgs = t.tuple(t.optional(t.number))

local CharacterEntity = Entity:Extend("CharacterEntity", {abstract = true})
function CharacterEntity:constructor(health)
	assert(CharacterEntityConstructorArgs(health))
	Entity:super(self)

	self._health = health or 100
	self._maxHealth = health or 100
end

function CharacterEntity:GetHealth()
	return self._health
end

function CharacterEntity:SetHealth(health)
	assert(t.number(health))
	self._health = health
end

function CharacterEntity:IsAlive()
	return self._health > 0
end

return CharacterEntity