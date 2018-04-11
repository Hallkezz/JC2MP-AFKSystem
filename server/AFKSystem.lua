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
end

function AFKSystem:PlayerJoin( args )
	if self.onjoin then
		Network:Send( args.player, "AFKSystem", true)
	end
end

function AFKSystem:PlayerChat( args )
    local cmd_args = args.text:split( " " )

    if cmd_args[1] == active or cmd_args[1] == activeTwo then
		Network:Send( args.player, "AFKSystem", false)
        return false
    end
    return true
end

afksystem = AFKSystem()

--v1.1--
--04.11.18--