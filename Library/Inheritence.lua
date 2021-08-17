--> Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--> Modules
local Signal = require(ReplicatedStorage.Modules.Shared.Event.Signal)

--> Mirror
local Inheritence = {}

---- EXPOSED API -------------------------------------------------------------------------------------------------------

-- Anonymously create a new instance.
function Inheritence.new(ClassName: string, Name: string, Parent: Instance, Properties)
	local Instance = Instance.new(ClassName)
	Instance.Name = Name or Instance.Name
	
	if Properties then
		for Property, Value in pairs(Properties) do
			Instance[Property] = Value
		end
	end
	
	Instance.Parent = Parent
	
	return Instance
end

-- Pull an array with all the ancestors of the given instance.
function Inheritence:GetAncestors(Instance: Instance)
	local Ancestors = {}
	local CurrentAncestor = Instance.Parent
	
	while CurrentAncestor do
		table.insert(Ancestors, CurrentAncestor)
		CurrentAncestor = CurrentAncestor.Parent
	end
	
	return Ancestors
end

-- Iterates over the children and any folder found within the Instance.
-- Returns an array with all the instances that passed the conditional.
function Inheritence:GetNestedInstances(Instance: Instance, Conditional: any)
	local Instances = {}
	
	local function Iterate(Instance)
		for _, Child in pairs(Instance:GetChildren()) do
			if Child:IsA("Folder") then
				Iterate(Child)
			elseif (Conditional and Conditional(Child)) or true then
				table.insert(Instances, Child)
			end
		end
	end
	
	Iterate(Instance)
	
	return Instances
end

-- Yield until a CollectionService tag exists under the Instance.
function Inheritence:WaitForTag(Instance: Instance, TagName: string, Timeout: number)
	local ev = Signal.new()
	local HasTag = false
	
	local Instance = CollectionService:GetInstanceAddedSignal(TagName):Connect(function(i)
		if i == Instance then
			HasTag = true
			ev:Fire()
		end
	end)
	
	task.spawn(function()
		if not Timeout then
			task.spawn(function()
				task.wait(5)
				if not HasTag then
					warn("Infinite yield possible on Inheritence.WaitForTag")
					wait(Instance, TagName)
				end
			end)
		end
		task.wait(Timeout or math.huge)
		
		ev:Fire()
	end)
	
	ev:Wait()
	
	return HasTag
end

-- Instance destroyed event
function Inheritence.Destroyed(Instance: Instance)
	local Signal = Signal.new()
	
	local Connection
	Connection = Instance.Parent.ChildRemoved:Connect(function(Child)
		if Child == Instance then
			Signal:Fire()
			Signal:Destroy()
		end
	end)
	
	return Signal
end

----

return Inheritence
