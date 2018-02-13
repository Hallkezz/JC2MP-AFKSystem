---------------
--By Hallkezz--
---------------

-----------------------------------------------------------------------------------
--Settings
local Debug = false -- ON/OFF Debug.
local Active = false -- ON/OFF AFKSystem window.
-----------------------------------------------------------------------------------
local ButtonName = "Continue" -- "Continue" button name.
local WinSize = 0.1 -- Window size.
local Content = "You are AFK" -- Text in the window.
local Title = "AFK" -- Title text.
---------------------
local TColor = Color.Yellow -- Message text color.
local Pause = "AFK mode enabled." -- "Pause" Text.
local Unpause = "Welcome back" -- "Continue" Text.
local Warning = "You cannot enter the AFC here!" --  Warning when the player is in another world.
---------------------
local TagOffset = 30
local TagSize = 16
local TagText  = "AFK"
local TagColor = Color(0, 200, 255, 250)
-----------------------------------------------------------------------------------


-----------------------------------------------------------------------------------
--Script
class 'AFKSystem'

function AFKSystem:__init()
	self.active = Active
	
	if Debug then
		print("AFKSystem loaded.") -- Debug info in console.
	end	
	
--Window
	self.window = Window.Create()
    self.window:SetSizeRel( Vector2( WinSize, WinSize ) )
    self.window:SetPositionRel( Vector2( 0.5, 0.5 ) - self.window:GetSizeRel()/2 )
    self.window:SetVisible( self.active )
    self.window:SetTitle( Title )
    self.window:Subscribe( "WindowClosed", self, self.Close )
	
	local base1 = BaseWindow.Create( self.window )
    base1:SetDock( GwenPosition.Fill )
    base1:SetSize( Vector2( self.window:GetSize().x, self.window:GetSize().y ) )
	
--Button
	self.buy_button = Button.Create( base1 )
    self.buy_button:SetSize( Vector2( self.window:GetSize().x, 22 ) )
    self.buy_button:SetText( ButtonName )
    self.buy_button:SetDock( GwenPosition.Bottom )
    self.buy_button:Subscribe( "Press", self, self.Close )
	
	self.contents = Label.Create( base1 )
	self.contents:SetSize( Vector2( self.window:GetSize().x, 32 ) )
	self.contents:SetAlignment( GwenPosition.Center )
	
	self.contents2 = Label.Create( base1 )
	self.contents2:SetSize( Vector2( self.window:GetSize().x, 32 ) )
	self.contents2:SetText( Content )
	self.contents2:SetTextSize(14)
	self.contents2:SetDock( GwenPosition.Left )
	
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "KeyUp", self, self.KeyUp )
	Events:Subscribe("ModulesLoad", ModulesLoad)
    Events:Subscribe("ModuleUnload", ModuleUnload)
	Network:Subscribe( "AFKSystem", self, self.Display )
end

function AFKSystem:Display( onjoin )
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
	Chat:Print(Pause, TColor ) -- "Pause" Text.
	
	if Debug then
		print("AFK enabled.") -- Debug info in console.
	end	
end

function AFKSystem:LocalPlayerInput( args )
    if self.active and Game:GetState() == GUIState.Game then
        return false
    end
end

function AFKSystem:SetActive( active )
    if self.active ~= active then
        if active == true and LocalPlayer:GetWorld() ~= DefaultWorld then
            Chat:Print( Warning, Color.Red )
            return
        end

		if not active then
		    Game:FireEvent("ply.vulnerable") -- The script disables immortality.
			Game:FireEvent("ply.unpause") -- Defrost of the player.
			Game:FireEvent("bm.savecheckpoint.go") -- The script displays the "Saving"
			Chat:Print(Unpause .. " " .. LocalPlayer:GetName() .. "!", TColor) -- "Resume" Text.
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
	
	for player in Client:GetStreamedPlayers() do
		if self.active then
			local tagpos    = player:GetBonePosition("ragdoll_Head") + Vector3(0, 0.4, 0)
			local distance  = tagpos:Distance(LocalPlayer:GetPosition())
			local pos, onsc = Render:WorldToScreen(tagpos)

			if onsc then
				local scale   = math.clamp(1 - distance / 1000, 0.75, 1)
				local size    = Render:GetTextSize(TagText, TagSize, scale)
				pos           = pos - Vector2(size.x / 2, size.y + TagOffset * scale)
				local sColor  = Color(0, 0, 0, 180 * scale ^ 2)
				local color   = Copy(TagColor)
				color.a       = 255 * scale

				Render:DrawText(pos + Vector2.One, TagText, sColor, TagSize, scale)
				Render:DrawText(pos, TagText, color, TagSize, scale)
			end
		end
	end	

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
	
	if Debug then
		print("AFK disabled.") -- Debug info in console.
	end		
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

AFKSystem = AFKSystem()

--v1.0--
--02.13.18--