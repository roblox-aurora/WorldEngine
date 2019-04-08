local Object = require(script.Parent.Object)
local t = require(script.Parent.t)
local Maid = Object:Extend("Maid", {mutators = true})

local function t_task(value)
	local _type = typeof(value)
	local isValid = _type == "RBXScriptConnection" or _type == "function" or (_type == "table" and value.Destroy)

	return isValid, "Expected function, RBXScriptConnection or table with Destroy"
end

function Maid:constructor()
	self._tasks = {}
end

local isAddId = t.tuple(t.string, t_task)
function Maid:Add(...)
	if (isAddId(...)) then
		local id, task = ...
		self._tasks[id] = task
	else
		local task = ...
		assert(t_task(task))
		table.insert(self._tasks, task)
	end
end

function Maid:get(index)
	return self._tasks[index]
end

function Maid:set(index, value)
	self:Add(index, value)
end

function Maid:Clean()
	local tasks = self._tasks

	-- Disconnect all events first as we know this is safe
	-- luacov: disable
	-- because Lemur doesn't do RBXScriptConnections properly.
	for index, task in pairs(tasks) do
		if typeof(task) == "RBXScriptConnection" then
			tasks[index] = nil
			task:Disconnect()
		end
	end
	-- luacov: enable

	local index, task = next(tasks)
	while task ~= nil do
		tasks[index] = nil
		if type(task) == "function" then
			task()
	-- luacov: disable
	-- because Lemur doesn't do RBXScriptConnections properly.
		elseif typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
	-- luacov: enable
		elseif task.Destroy then
			task:Destroy()
		end
		index, task = next(tasks)
	end
end

return Maid
