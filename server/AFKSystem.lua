---------------
--By Hallkezz--
---------------

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

    if cmd_args[1] == "/pause" or cmd_args[1] == "/afk" then

		Network:Send( args.player, "AFKSystem", false)
	
        return false
    end

    return true
end

local AFKSystem = AFKSystem()