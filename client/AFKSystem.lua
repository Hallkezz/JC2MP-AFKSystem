---------------
--By Hallkezz--
---------------

class 'AFKSystem'
function AFKSystem:__init()

--Settings
	self.buttonname = "Continue" -- "Continue" button name.
	self.winsize = 0.1 -- Window size.
	self.motdcontent =  "You're AFK" -- Text in the window.	
	self.title =  "AFK" -- Title text.
	self.warning = "You cannot enter the AFC here!" --  Warning when the player is in another world.
	self.pause = "You're AFK!" -- "Pause" Text.
	self.unpause = "Welcome back" -- "Continue" Text.
	self.TColor = Color.Yellow -- Message text color.

	self.active = false
	
--Debug
    print("AFKSystem loaded.")	
	
--Window
	self.window = Window.Create()
    self.window:SetSizeRel( Vector2( self.winsize, self.winsize ) )
    self.window:SetPositionRel( Vector2( 0.5, 0.5 ) - self.window:GetSizeRel()/2 )
    self.window:SetVisible( self.active )
    self.window:SetTitle( self.title )
    self.window:Subscribe( "WindowClosed", self, self.Close )
	
	local base1 = BaseWindow.Create( self.window )
    base1:SetDock( GwenPosition.Fill )
    base1:SetSize( Vector2( self.window:GetSize().x, self.window:GetSize().y ) )
	
--Button	
	self.buy_button = Button.Create( base1 )
    self.buy_button:SetSize( Vector2( self.window:GetSize().x, 22 ) )
    self.buy_button:SetText( self.buttonname )
    self.buy_button:SetDock( GwenPosition.Bottom )
    self.buy_button:Subscribe( "Press", self, self.Close )
	
	self.contents = Label.Create( base1 )
	self.contents:SetSize( Vector2( self.window:GetSize().x, 32 ) )
	self.contents:SetAlignment( GwenPosition.Center )
	
	self.contents2 = Label.Create( base1 )
	self.contents2:SetSize( Vector2( self.window:GetSize().x, 32 ) )
	self.contents2:SetText( self.motdcontent )
	self.contents2:SetTextSize(13)
	self.contents2:SetDock( GwenPosition.Left )
	
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "KeyUp", self, self.KeyUp )
	Events:Subscribe("ModulesLoad", ModulesLoad)
    Events:Subscribe("ModuleUnload", ModuleUnload)
	Network:Subscribe( "AFKSystem", self, self.Display )
end

function AFKSystem:Display( onjoin )
	print(onjoin)
	if onjoin and self.pauseplayer then
	    Game:FireEvent("ply.invulnerable") -- The script includes immortality.
		Game:FireEvent("ply.pause") -- It freezes the player.
	end
	self:Open()
end

function AFKSystem:KeyUp( args )
if self.button then
    if args.key == self.button_key then
        self:SetActive( not self:GetActive() )
    end
end
end

function AFKSystem:GetActive()
    return self.active
end

function AFKSystem:Open( args )
	self:SetActive( true )
	Chat:Print(self.pause, self.TColor ) -- "Pause" Text.
end

function AFKSystem:LocalPlayerInput( args )
if self.freezeplayer then
    if self.active and Game:GetState() == GUIState.Game then
        return false
    end
end
end

function AFKSystem:SetActive( active )
    if self.active ~= active then
        if active == true and LocalPlayer:GetWorld() ~= DefaultWorld then
            Chat:Print( self.warning, Color.Red )
            return
        end

		if not active then
		    Game:FireEvent("ply.vulnerable") -- The script disables immortality.
			Game:FireEvent("ply.unpause") -- Defrost of the player.
			Game:FireEvent("bm.savecheckpoint.go") -- The script displays the "Saving"
			Chat:Print(self.unpause .. ", " .. LocalPlayer:GetName() .. "!", self.TColor) -- "Resume" Text.
            local sound = ClientSound.Create(AssetLocation.Game, {
			    bank_id = 13,
			    sound_id = 3,
			    position = LocalPlayer:GetPosition(),
			    angle = Angle()
           })

           sound:SetParameter(0,0.75)
		end
        self.active = active
        Mouse:SetVisible( self.active )
    end
end

function AFKSystem:Render()
    local is_visible = self.active and (Game:GetState() == GUIState.Game)

    if self.window:GetVisible() ~= is_visible then
        self.window:SetVisible( is_visible )
    end

    if self.active then
        Mouse:SetVisible( true )
		Game:FireEvent("ply.pause")
    end
end

function AFKSystem:Close( args )
    self:SetActive( false )
end

--Helps
function ModulesLoad()
	Events:Fire( "HelpAddItem",
        {
            name = "AFK",
            text = 
                "Type /afk or /pause to get in AFK mode.\n" ..
                "\n::By Hallkezz!"
        } )
end

function ModuleUnload()
    Events:Fire( "HelpRemoveItem",
        {
            name = "AFK"
        } )
end

local AFKSystem = AFKSystem()

--v0.2--