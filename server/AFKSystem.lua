---------------
--By Hallkezz--
---------------

-----------------------------------------------------------------------------------
--Settings
local active = "/pause" -- AFK Activate command.
local activeTwo = "/afk" -- AFK Activate command 2.
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
--Script
class 'AFKSystem'

function AFKSystem:__init()
	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
	Network:Subscribe( "ToggleAFKTeg", self, self.ToggleAFKTeg )
end

function AFKSystem:PlayerJoin( args )
	args.player:SetNetworkValue( "PlayerAFK", nil )
end

function AFKSystem:PlayerChat( args )
	local cmd_args = args.text:split( " " )

	if cmd_args[1] == active or cmd_args[1] == activeTwo then
		Network:Send( args.player, "AFKSystem" )
		return false
	end
	return true
end

function AFKSystem:ToggleAFKTeg( args, sender )
	if sender:GetValue( "PlayerAFK" ) then
		sender:SetNetworkValue( "PlayerAFK", false )
	else
		sender:SetNetworkValue( "PlayerAFK", true )
	end
end

afksystem = AFKSystem()

--v2--
--28.10.19--
