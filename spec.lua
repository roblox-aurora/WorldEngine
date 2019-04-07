--[[
	Loads our library and all of its dependencies, then runs tests using TestEZ.
]]
-- If you add any dependencies, add them to this table so they'll be loaded!
local LOAD_MODULES = {
	{"lib/shared", "WorldEngine", "ReplicatedStorage"},
	{"lib/server", "WorldEngine", "ServerScriptService"},
	{"modules/testez/lib", "TestEZ"}
}

-- This makes sure we can load Lemur and other libraries that depend on init.lua
package.path = package.path .. ";?/init.lua"

-- If this fails, make sure you've cloned all Git submodules of this repo!
local lemur = require("modules.lemur")

-- Create a virtual Roblox tree
local habitat = lemur.Habitat.new()
local game = habitat.game
local replicated = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- We'll put all of our library code and dependencies here
local Root = lemur.Instance.new("Folder")
Root.Name = "Root"

-- Load all of the modules specified above
for _, module in ipairs(LOAD_MODULES) do
	local container = habitat:loadFromFs(module[1])
	container.Name = module[2]

	local parent = module[3]
	if (parent) then
		container.Parent = game:GetService(parent)
	else
		container.Parent = Root
	end
end

-- Load TestEZ and run our tests
local TestEZ = habitat:require(Root.TestEZ)

local results = TestEZ.TestBootstrap:run({replicated.WorldEngine, ServerScriptService.WorldEngine}, TestEZ.Reporters.TextReporter)

-- Did something go wrong?
if results.failureCount > 0 then
	os.exit(1)
end
