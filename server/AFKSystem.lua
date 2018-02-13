---------------
--By Hallkezz--
---------------

-----------------------------------------------------------------------------------
--Settings
local Active = "/pause" -- AFK Activate command.
local Active2 = "/afk" -- AFK Activate command 2.
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

    if cmd_args[1] == Active or cmd_args[1] == Active2 then

		Network:Send( args.player, "AFKSystem", false)
	
        return false
    end

    return true
end

AFKSystem = AFKSystem()

--v1.0--
--02.13.18--