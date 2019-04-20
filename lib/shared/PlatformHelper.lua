local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

local PlatformHelper = {}

local function getViewportSize()
	return Workspace.CurrentCamera.ViewportSize
end

function PlatformHelper:GetSizeType()
	local size = getViewportSize()
	if size.Y >= 2160 then
		return "4k"
	elseif size.Y >= 1440 then
		return "1440p"
	elseif size.Y >= 720 then
		return "720p"
	elseif size.Y >= 480 then
		return "480p"
	else
		return "other"
	end
end

function PlatformHelper:GetType()
	if UserInputService.GamepadEnabled and GuiService:IsTenFootInterface() then
		return "console"
	elseif UserInputService.TouchEnabled then
		local size = getViewportSize()
		if size.X >= 1023 and size.Y >= 767 then
			return "tablet"
		else
			return "mobile"
		end
	elseif UserInputService.KeyboardEnabled then
		return "computer"
	else
		return "unknown"
	end
end

return PlatformHelper
