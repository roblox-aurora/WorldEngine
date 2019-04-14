local import = require(game:GetService("ReplicatedStorage"):WaitForChild("WorldEngine"):WaitForChild("Import"))

local t = import "t"
local table = import "table"
local Entity = import "../Entity"

local unsignedFloat = t.numberMin(0)
local CharacterEntityConstructorArgs = t.tuple(t.optional(unsignedFloat))

local CharacterEntity = Entity:Extend("CharacterEntity", {abstract = true})
function CharacterEntity:constructor(health)
	assert(CharacterEntityConstructorArgs(health))
	Entity:super(self)

	self._health = health or 100
	self._maxHealth = health or 100
	self._stats = {}
end

function CharacterEntity:GetHealth()
	return self._health
end

function CharacterEntity:SetStat(name, value)
	assert(t.tuple(t.string, t.numberMin(0))(name, value))
	self._stats[name] = value
end

function CharacterEntity:GetStats()
	return table.copy(self._stats)
end

function CharacterEntity:SetStats(stats)
	assert(t.map(t.string, t.numberPositive)(stats))

	for stat, value in next, stats do
		assert(t.numberPositive(value))
		assert(t.string(stat))
		self._stats[stat] = value
	end
end

function CharacterEntity:GetStat(name)
	return self._stats[name] or 0
end

function CharacterEntity:SetHealth(health)
	assert(unsignedFloat(health))
	self._health = health
end

function CharacterEntity:TakeDamage(amount)
	assert(unsignedFloat(amount))

	if amount > self._health then
		self._health = 0
	else
		self._health = self._health - amount
	end
end

function CharacterEntity:Heal(amount)
	assert(unsignedFloat(amount))

	if self._health + amount > self._maxHealth then
		self._health = self._maxHealth
	else
		self._health = self._health + amount
	end
end

function CharacterEntity:IsAlive()
	return self._health > 0
end

return CharacterEntity
