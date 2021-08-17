-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local Tasks = {}
local TasksCreated = 0

-- Modules
local Signal = require(ReplicatedStorage.Modules.Shared.Event.Signal)

-- Mirror
local Maid = {}
local Task = {}

----

local TaskThread = coroutine.create(function()
	while true do
		local PassedFunction = coroutine.yield()
		PassedFunction()
	end
end)
coroutine.resume(TaskThread)

----

Maid.ClassName = "Maid"

function Maid:AssignTask(Value: Instance | RBXScriptConnection, Link): Task
	TasksCreated += 1
	
	local FinishBinds = {}
	local OnFinished = Signal.new()
	local Finished = false
	
	local _Task = {}
	_Task.ClassName = "Task"
	_Task.Id = TasksCreated
	_Task.Values = typeof(Value) == "table" and Value or {Value} -- Internal
	_Task.Link = Link -- Internal
	
	setmetatable(_Task, {
		__index = function(t, i)
			if i == "Finished" then
				return Finished
			elseif i == "OnFinished" then
				return OnFinished
			elseif i == "FinishBinds" then -- Internal
				return FinishBinds
			end
			
			return Task[i]
		end,
		__newindex = function(t, i, v)
			if t == FinishBinds then
				FinishBinds[i] = v
			end
		end,
	})
	
	if Link then
		coroutine.resume(TaskThread, function()
			if not Finished then
				local Connection = Link.AncestryChanged:Connect(function(Ancestor, NewParent)
					if NewParent == nil then
						_Task:Finish()
					end
				end)
				
				OnFinished:Connect(function()
					if Connection and not Connection.Connected then
						Connection:Disconnect()
					end
				end)
			end
		end)
	end
	
	Tasks[_Task.Id] = _Task
	
	return _Task
end

function Task:Finish()
	if not self.Finished then
		self.Finished = true
		
		-- Disconnect link listeners
		self.OnFinished:Fire()
		self.OnFinished:Destroy()
		
		-- Binded functions
		for _, func in pairs(self.FinishBinds) do
			func()
		end
		self.FinishBinds = {}
		
		-- Disconnect/Destroy value
		for Index, Value in pairs(self.Values) do
			if typeof(Value) == "RBXScriptConnection" then
				self.Values[Index]:Disconnect()
			elseif typeof(Value) == "Instance" then
				self.Values[Index]:Destroy()
			end
		end
	end
end

function Task:BindToFinish(func: any)
	if not self.Finished and typeof(func) == "function" then
		self.FinishBinds[#self.FinishBinds+1] = func
	end
end

export type Task = {ClassName: string, Id: number, Finished: boolean, OnFinished: Signal}

return setmetatable(Maid, {
	__index = function(t, i)
		if i == "Tasks" then
			return Tasks
		end
	end,
})
