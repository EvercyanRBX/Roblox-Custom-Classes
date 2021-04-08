--[[

    SoftShutdown2 is my own implementation of Merely's 'Soft Shutdown Script'.
    The purpose of a soft shutdown script (mine in this case) is to teleport all players in a server to a place in the game when a developer shuts down all servers.
    The players will then wait a mere few seconds to make sure that Roblox prepares a new server to avoid the risk of getting an outdated one, then the server will teleport all the players together back to the original place.
    By default Roblox doesn't offer this, but with our own implementation we can make sure we get most of our players back into the game for the best player and developer experience.
    
    The few tests I have done with another player were successful with both shutting down all servers and migrating to the latest update.
    I haven't tested it, but I made this script with keeping all players in the same server together during the process, so while I can't teleport the players who were originally
    in a VIP server back to the VIP server, I can reserve a server that other players cannot join. If you need any data pertaining to the VIP server, you can send them over through the TeleportOptions:SetTeleportData function.
    
    Compared to Merely's original, this should keep all players in the server together through the transporting process, teleports to a separate place in the game to avoid having
    to load through assets in the original place for better network performance, and uses up-to-date functions including the new teleport API.
    
    I have tested this and after the teleport process has happened, it only took a few seconds to get back into a new server.
    Enjoy!
    
]]

-- Services
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Configuration
local SoftShutdownPlace = 6654385582 -- Replace this with a place in your game (usually empty) where players are temporarily housed until ready for a new server in the original place.

----

if game.PlaceId == SoftShutdownPlace then -- SoftShutdown place in the universe
	local Player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
	local TeleportData = Player:GetJoinData().TeleportData
	local IsSoftShutdown = TeleportData and TeleportData.IsSoftShutdown
	
	if IsSoftShutdown then
		wait(3)
		
		-- Keep the server alive for longer to make sure all players get teleported back.
		game:BindToClose(function()
			wait(15)
		end)
		
		-- Teleport all the players back into a reserved server under the place.
		local ReservedServerId = TeleportService:ReserveServer(TeleportData.ReturnPlaceId)
		
		local TeleportOptions = Instance.new("TeleportOptions")
		TeleportOptions.ReservedServerAccessCode = ReservedServerId
		
		-- Keep attempting to teleport players until there are no more.
		-- We do this multiple times to make sure all of them get teleported in case if any players join late.
		while wait(10/4) do
			local Success, Failure = pcall(function()
				local TeleportResult = TeleportService:TeleportAsync(
					TeleportData.ReturnPlaceId,
					Players:GetPlayers(),
					TeleportOptions
				)
			end)
			if not Success then
				warn(Failure)
			end
		end
	end
else
	game:BindToClose(function()
		if RunService:IsStudio() or #Players:GetChildren() == 0 then
			return
		end
		
		local TeleportOptions = Instance.new("TeleportOptions")
		TeleportOptions.ShouldReserveServer = true
		TeleportOptions:SetTeleportData({
			IsSoftShutdown = true,
			ReturnPlaceId = game.PlaceId
		})
		
		local TeleportResult = TeleportService:TeleportAsync(
			SoftShutdownPlace,
			Players:GetPlayers(),
			TeleportOptions
		)
		
		while #Players:GetPlayers() > 0 do
			wait(1)
		end
	end)
end
