--[[
	Lib Sfx
	Sound Effect library for WorldEngine

	namespace SoundEffects
		PlayEffect( effectId: string | number, volume?: number )
		PlayEffectAtPosition( effectId: string | number, position: Vector3, volume?: number )


]]
local SoundService = game:GetService("SoundService")

local t = require(script.Parent.t)
local Promise = require(script.Parent.Promise)
local SoundEffects = {}
local masterVolume = 1

local EffectSoundGroup = Instance.new("SoundGroup", SoundService)
EffectSoundGroup.Name = "Effects"

local t_identifier = t.union(t.string, t.number)

local function new(soundId, volume, vec3)
	assert(t.string(soundId))
	assert(t.optional(t.number)(volume))
	assert(t.optional(t.Vector3)(vec3))

	volume = volume or 1
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume * masterVolume
	return sound
end

local function getId(value)
	if type(value) == "string" then
		if value:match("^rbxassetid://") or value:match("^rbxasset://sounds/") then
			return value
		else
			error("Invalid id: " .. tostring(value))
		end
	elseif type(value) == "number" then
		return "rbxassetid://" .. value
	else
		error(tostring(value) .. "is not a valid id")
	end
end

local function asyncWrap(f)
	return function(self, ...)
		local args = {...}
		return Promise.new(
			function(resolve, reject)
				Promise.spawn(
					function()
						local success, result = pcall(f, self, unpack(args))
						if success then
							resolve(result)
						else
							reject(result)
						end
					end
				)
			end
		)
	end
end

local soundPool = {}
local function getSoundObject(assetUri)
	assert(t.string(assetUri))
	assert(assetUri:match("^rbxassetid://") or assetUri:match("^rbxasset://sounds/"))
	for _, sound in next, soundPool do
		if sound.SoundId == assetUri and not sound.IsPlaying then
			return sound
		end
	end

	local sound = new(assetUri)
	sound.Name = "Sound" .. tostring(#soundPool + 1)
	table.insert(soundPool, sound)
	return sound
end

local PlayEffect_ArgTypes = t.tuple(t_identifier, t.optional(t.number))
function SoundEffects:PlayEffect(effectId, volume)
	assert(PlayEffect_ArgTypes(effectId, volume))

	local effect = getSoundObject(getId(effectId))
	effect.SoundGroup = EffectSoundGroup
	effect.Name = effectId
	effect.Parent = SoundService

	effect:Play()
	effect.Ended:Wait()
end
SoundEffects.PlayEffectAsync = asyncWrap(SoundEffects.PlayEffect)

local PlayEffectAtPosition_ArgTypes = t.tuple(t_identifier, t.Vector3, t.optional(t.number))
function SoundEffects:PlayEffectAtPosition(effectId, position, volume)
	assert(PlayEffectAtPosition_ArgTypes(effectId, position, volume))

	local part = Instance.new("Part")
	part.Name = "Sfx3dPlayer"
	part.Transparency = 1
	part.Anchored = true
	part.CFrame = CFrame.new(position)

	local effect = new(getId(effectId), volume, position)
	effect.Parent = part
	effect:Play()
	effect.Ended:Wait()
	effect:Destroy()
	part:Destroy()
end
SoundEffects.PlayEffectAtPositionAsync = asyncWrap(SoundEffects.PlayEffectAtPosition)

return SoundEffects
