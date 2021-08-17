-- Variables
local LastId = 0

-- Mirror
local Signal = {}

---- EXPOSED API -------------------------------------------------------------------------------------------------------

-- Creates a new Signal class
function Signal.new(): Signal
	local Class = {}
	
	-- Constants
	Class.BindableEvent = Instance.new("BindableEvent")
	
	-- Variables
	local Connections = {}
	local Alive = true
	
	setmetatable(Class, {
		__index = function(t, i)
			if i == "Connections" then
				return Connections
			elseif i == "Alive" then
				return Alive
			end
			
			if Alive then
				-- Signal is alive, meaning we can use its functions.
				return Signal[i]
			end
		end,
		__newindex = function(t, i, v)
			if t == Connections then
				Connections[i] = v
			elseif i == "Alive" then
				Alive = v
			end
		end,
	})
	
	LastId += 1
	
	return Class
end

-- Fires the signal
function Signal:Fire(...)
	self.BindableEvent:Fire(...)
end

-- Connects a function to run when the Signal is fired
function Signal:Connect(func: any)
	assert(func, "Signal.Connect: Argument 1 missing or nil.")
	
	local Connection = self.BindableEvent.Event:Connect(func)
	local RBXScriptConnection = {}
	
	local Self = self -- Define self so we get the [Signal] class, not the [RBXScriptConnection] class inside of Disconnect.
	function RBXScriptConnection:Disconnect()
		Self.Connections[Connection] = nil
		Connection:Disconnect()
		Connection = nil
	end
	
	self.Connections[Connection] = RBXScriptConnection
	
	return RBXScriptConnection
end

-- Yields until the next time the Signal fires, with the optional given timeout value.
function Signal:Wait(Timeout: number)
	if Timeout then
		local SignalYield = Signal.new()
		
		local Connection = Signal:Connect(function(...)
			SignalYield:Fire(table.pack(...))
		end)
		
		local Thread = coroutine.resume(coroutine.create(function()
			task.wait(Timeout)
			SignalYield:Fire()
		end))
		
		local Tuple = table.pack(SignalYield:Wait())
		SignalYield:Destroy()
		
		return Tuple
	else
		return self.BindableEvent.Event:Wait()
	end
end

-- Destroys the Signal class
function Signal:Destroy()
	-- Disconnect and remove all alive connections that are connected to this signal.
	for Connection, _ in pairs(self.Connections) do
		self.Connections[Connection]:Disconnect()
	end
	
	self.BindableEvent:Destroy()
	self.Alive = false
end

----

type Fire = (...any) -> nil
type Connect = (...any) -> RBXScriptConnection
type Wait = (Timeout: number) -> any
type Destroy = (nil) -> nil

export type Signal = {Alive: boolean, Fire: Fire, Connect: Connect, Wait: Wait, Destroy: Destroy}

return Signal
