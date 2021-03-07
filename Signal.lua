-- Variables
local Signals = {}

-- Mirror
local Signal = {}

---- EXPOSED API ----------------------------------------

function Signal.new(Index)
	Index = Index or #Signals
	
	-- Signal already exists under a different name? Return it.
	-- It's not recommended to make the Index a numerical value.
	if Signals[Index] then
		return Signals[Index]
	end
	
	local BindableEvent = Instance.new("BindableEvent")
	local AliveConnections = {}
	local SignalAlive = true
	
	local _Signal = {}
	
	function _Signal:Fire(...)
		if not SignalAlive then
			return
		end
		
		BindableEvent:Fire(...)
	end
	
	function _Signal:Connect(func)
		if not SignalAlive then
			return
		end
		
		assert(func, "Signal.Connect: Argument 1 missing or nil.")
		
		----
		
		local Connection = BindableEvent.Event:Connect(func)
		local RBXScriptConnection = {}
		
		function RBXScriptConnection:Disconnect()
			AliveConnections[Connection] = nil
			Connection:Disconnect()
			Connection = nil
		end
		
		AliveConnections[Connection] = RBXScriptConnection
		
		return RBXScriptConnection
	end
	
	function _Signal:Wait(Timeout)
		if not SignalAlive then
			return
		end
		
		----
		
		if Timeout then
			local SignalYield = Signal.new()
			
			local Connection = _Signal:Connect(function(...)
				SignalYield:Fire(table.pack(...))
			end)
			
			local Thread = coroutine.resume(coroutine.create(function()
				wait(Timeout)
				SignalYield:Fire()
			end))
			
			local Tuple = table.pack(SignalYield:Wait())
			SignalYield:Destroy()
			
			return Tuple
		else
			return BindableEvent.Event:Wait()
		end
	end
	
	function _Signal:Destroy()
		if not SignalAlive then
			return
		end
		SignalAlive = false
		
		-- Disconnect and remove all alive connections that are connected to this signal.
		for Connection, _ in pairs(AliveConnections) do
			AliveConnections[Connection]:Disconnect()
		end
		
		BindableEvent:Destroy()
	end
	
	Signals[Index] = _Signal
	
	return _Signal
end

----

return Signal
