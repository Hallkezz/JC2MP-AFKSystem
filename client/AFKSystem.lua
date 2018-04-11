---------------
--By Hallkezz--
---------------

-----------------------------------------------------------------------------------
--Settings
local debug = false -- ON/OFF Debug.
local active = false -- ON/OFF AFKSystem window.
-----------------------------------------------------------------------------------
local cooldown = 15 -- Cooldown time.
local buttonName = "Continue" -- "Continue" button name.
local winSize = 0.1 -- Window size.
local content = "You are AFK" -- Text in the window.
local title = "AFK" -- Title text.
---------------------
local tColor = Color.Yellow -- Message text color.
local pause = "AFK-Mode enabled." -- "Pause" Text.
local unpause = "Welcome back" -- "Continue" Text.
local warning = "You can not use it here!" --  Warning when the player is in another world.
---------------------
local tagOffset = 30
local tagSize = 16
local tagText  = "AFK"
local tagColor = Color(0, 200, 255, 250)
-----------------------------------------------------------------------------------


-----------------------------------------------------------------------------------
--Script
class 'AFKSystem'

function AFKSystem:__init()
	timer = Timer()
	self.cooltime = 0
	
	self.active = active
	
	if debug then
		print("AFKSystem loaded.") -- Debug info in console.
	end	
	
--Window
	self.window = Window.Create()
    self.window:SetSizeRel( Vector2( winSize, winSize ) )
    self.window:SetPositionRel( Vector2( 0.5, 0.5 ) - self.window:GetSizeRel()/2 )
    self.window:SetVisible( self.active )
    self.window:SetTitle( title )
    self.window:Subscribe( "WindowClosed", self, self.Close )
	
	local base1 = BaseWindow.Create( self.window )
    base1:SetDock( GwenPosition.Fill )
    base1:SetSize( Vector2( self.window:GetSize().x, self.window:GetSize().y ) )
	
--Button
	self.button = Button.Create( base1 )
    self.button:SetSize( Vector2( self.window:GetSize().x, 22 ) )
    self.button:SetText( buttonName )
    self.button:SetDock( GwenPosition.Bottom )
    self.button:Subscribe( "Press", self, self.Close )
	
	self.contents = Label.Create( base1 )
	self.contents:SetSize( Vector2( self.window:GetSize().x, 32 ) )
	self.contents:SetText( content )
	self.contents:SetTextSize(14)
	self.contents:SetDock( GwenPosition.Left )
	
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "ModulesLoad", self, self.ModulesLoad)
    Events:Subscribe( "ModuleUnload", self, self.ModuleUnload)
	Network:Subscribe( "AFKSystem", self, self.Display )
end

function AFKSystem:Display( onjoin )
	self:Open()
end

function AFKSystem:GetActive()
    return self.active
end

function AFKSystem:Open( args )
	if LocalPlayer:GetWorld() ~= DefaultWorld then
		Chat:Print(warning, Color.Red)
		return
	end	
	local time = Client:GetElapsedSeconds()
	if time < self.cooltime then
		Chat:Print("Please wait " .. math.ceil(self.cooltime - time) .. " seconds to activate the AFK-Mod.", Color(255, 34, 34))
		if debug then
			print("Cooldown active. Waiting " .. math.ceil(self.cooltime - time) .. " sec") -- Debug info in console.
		end
		return
	end
	
	self:SetActive( true )
	Chat:Print(pause, tColor ) -- "Pause" Text.
	
	if debug then
		print("AFK enabled.") -- Debug info in console.
	end	
	timer:Restart()
	
	self.cooltime = time + cooldown
	return false	
end

function AFKSystem:LocalPlayerInput( args )
    if self.active and Game:GetState() == GUIState.Game then
        return false
    end
end

function AFKSystem:SetActive( active )
    if self.active ~= active then
        if active == true and LocalPlayer:GetWorld() ~= DefaultWorld then
            Chat:Print( warning, Color.Red )
            return
        end

		if not active then
		    Game:FireEvent("ply.vulnerable") -- The script disables immortality.
			Game:FireEvent("ply.unpause") -- Defrost of the player.
			Game:FireEvent("bm.savecheckpoint.go") -- The script displays the "Saving"
			Chat:Print(unpause .. " " .. LocalPlayer:GetName() .. "!", tColor) -- "Resume" Text.
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
				local size    = Render:GetTextSize(tagText, tagSize, scale)
				pos           = pos - Vector2(size.x / 2, size.y + tagOffset * scale)
				local sColor  = Color(0, 0, 0, 180 * scale ^ 2)
				local color   = Copy(tagColor)
				color.a       = 255 * scale

				Render:DrawText(pos + Vector2.One, tagText, sColor, tagSize, scale)
				Render:DrawText(pos, tagText, color, tagSize, scale)
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
	
	if debug then
		print("AFK disabled.") -- Debug info in console.
	end		
end

--Help
function AFKSystem:ModulesLoad()
	Events:Fire( "HelpAddItem",
		{
			name = "AFK",
			text = 
				"Type /afk or /pause to enter in AFK mode.\n" ..
				"\n::By Hallkezz!"
		} )
end

function AFKSystem:ModuleUnload()
	Events:Fire( "HelpRemoveItem",
		{
			name = "AFK"
		} )
end

afksystem = AFKSystem()

--v1.1--
--04.11.18--