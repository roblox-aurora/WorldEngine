local t = require(script.Parent.t)
local tattachment = t.instance("Attachment")

local Welds = {}

function Welds:WeldAttachments(attach1, attach2)
	assert(t.tuple(tattachment, tattachment)(attach1, attach2))

	local weld = Instance.new("Weld")
	weld.Part0 = attach1.Parent
	weld.Part1 = attach2.Parent
	weld.C0 = attach1.CFrame
	weld.C1 = attach2.CFrame
	weld.Parent = attach1.Parent
	return weld
end

local ARGT_FindFirstMatchingAttachment = t.tuple(t.instance("Model"), t.string)
function Welds:FindFirstMatchingAttachment(model, name)
	assert(ARGT_FindFirstMatchingAttachment(model, name))
	for _, child in pairs(model:GetDescendants()) do
		if child:IsA("Attachment") and child.Name == name then
			return child
		end
	end
end

local ARGT_WeldAccoutrement = t.tuple(t.instance("Model"), t.instanceIsA("Accoutrement"), t.optional(t.string))
function Welds:WeldAccoutrement(character, accessory, handleName)
	assert(ARGT_WeldAccoutrement(character, accessory, handleName))
	handleName = handleName or "Handle"

	local handle = accessory:FindFirstChild(handleName)
	if handle then
		local accoutrementAttachment = handle.FindFirstChildOfClass("Attachment")
		if accoutrementAttachment then
			local characterAttachment = self:FindFirstMatchingAttachment(character, accoutrementAttachment.Name)
			if characterAttachment then
				self:WeldAttachments(accoutrementAttachment, characterAttachment)
				accessory.Parent = character
			else
				error("Could not find matching `" .. tostring(accoutrementAttachment.Name) .. "` attachment in character!")
			end
		else
			error("Could not find Attachment in handle `" .. tostring(handle) .. "`")
		end
	else
		error("No handle detected!")
	end
end
Welds.WeldAccessory = Welds.WeldAccoutrement

return Welds
