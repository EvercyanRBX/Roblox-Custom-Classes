-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local Tasks = {}
local TasksCreated = 0

-- Modules
local Signal = require(PathToSignalClass)

-- Mirror
local Maid = {}

----

local TaskThread = coroutine.create(function()
	while true do
		local PassedFunction = coroutine.yield()
		PassedFunction() -- Runs the function that was given when running TaskThread.
	end
end)
coroutine.resume(TaskThread)

---- EXPOSED API ----------------------------------------

function Maid:GetTaskCount()
	return #Tasks
end

function Maid:GetTasks()
	return Tasks
end

function Maid:AssignTask(Value, Link)
	assert(Value, "A task value is required to create a new task.")
	assert(Link, "A link (usually the script which required it) is required to create a new task.")
	
	local DisconnectLinksEvent = Signal.new()
	
	local Links = (typeof(Link) == "table" and Link) or {Link}
	local Values = (typeof(Value) == "table" and Value) or {Value}
	
	local Task = {}
	local TaskNumber = TasksCreated + 1
	TasksCreated = TaskNumber
	
	Task.Id = TaskNumber
	Task.Value = Values
	Task.Finished = false
	
	function Task:Finish()
		if not Task.Finished then
			Task.Finished = true
			
			-- Disconnect link listeners
			DisconnectLinksEvent:Fire()
			DisconnectLinksEvent:Destroy()
			
			-- Disconnect/Destroy values
			for Index, Value in pairs(Values) do
				if typeof(Value) == "RBXScriptConnection" then
					Values[Index]:Disconnect()
				elseif typeof(Value) == "Instance" then
					Values[Index]:Destroy()
				end
			end
		end
	end
	
	-- Automatically finish the task when the link(s) get deleted to prevent them hanging in memory forever.
	coroutine.resume(TaskThread, function()
		local LinkConnections = {}
		
		local function DisconnectLinks()
			for Index, _ in pairs(LinkConnections) do
				if LinkConnections[Index] and LinkConnections[Index].Connected then
					LinkConnections[Index]:Disconnect()
				end
			end
		end
		
		DisconnectLinksEvent:Connect(DisconnectLinks)
		
		for _, Link in pairs(Links) do
			if not Task.Finished then
				table.insert(LinkConnections, Link.AncestryChanged:Connect(function(Ancestor, NewParent)
					if NewParent == nil then
						Task:Finish()
					end
				end))
			end
		end
	end)
	
	Tasks[Task.Id] = Task
	
	return Task
end

function Maid:FinishTask(Id)
	if Tasks[Id] then
		Tasks[Id]:Finish()
	end
end

return Maid
