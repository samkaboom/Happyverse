print("Client.lua is indexing")

local MainUI = script.Parent

do --recolor the UI for the client
	local UIBackgroundColor = Color3.fromRGB(30,30,30);
	local UITextColor = Color3.fromRGB(255,255,255);
	local UITextBoxTextColor = Color3.new(1,1,1);
	local UITextBoxBorderTransparency = 1;
	local UITextBoxBorderColor = Color3.new(0,0,0)
	local UITextBorderColor = Color3.fromRGB(0,0,0);
	local UITextBorderTransparency = 0.5;
	local UIButtonColor = Color3.fromRGB(50,50,50);
	local UIFont = Enum.Font.Merriweather

	local function RecolorUIForClient()
		for i, v in pairs(MainUI:GetDescendants()) do
			if v:IsA("Frame") and v.Name == "Slide" then
				v.BackgroundColor3 = UIButtonColor;
			elseif v:IsA("Frame") and v.Name ~= "Slide" then
				if not v:FindFirstAncestor("ColorWindow") and v.Name ~= "bar" then
					v.BackgroundColor3 = UIBackgroundColor;
				end
			elseif v:IsA("TextLabel") then
				v.Font = UIFont
				if not v:FindFirstAncestor("ColorWindow") then
					v.TextColor3 = UITextColor;
					v.TextStrokeTransparency = UITextBorderTransparency;
					v.TextStrokeColor3 = UITextBorderColor;
					v.BackgroundColor3 =  UIBackgroundColor;
				end

			elseif v:IsA("TextButton") then
				v.Font = UIFont
				if not v:FindFirstChild("Slide") then
					if not v:FindFirstAncestor("ColorWindow") and not v:FindFirstAncestor("ColorSelection") then
						v.BackgroundColor3 =  UIBackgroundColor;
					else
						v.BackgroundColor3 = Color3.new(1,1,1)
					end
				else
					v.BackgroundColor3 = Color3.new(1,1,1)				
				end

				v.TextColor3 = UITextColor;
				v.TextStrokeTransparency = UITextBorderTransparency;
				v.TextStrokeColor3 = UITextBorderColor;
			elseif v:IsA("TextBox") then
				if not v:FindFirstAncestor("ColorWindow") then
					v.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
					v.TextColor3 = UITextBoxTextColor
					v.TextStrokeTransparency = UITextBoxBorderTransparency;
					v.TextStrokeColor3 = UITextBoxBorderColor;
				end
				v.Font = UIFont

			end
		end
	end

	RecolorUIForClient()

end

-- Services

TeleportService = game:GetService("TeleportService")
ReplicatedStorage = game:GetService("ReplicatedStorage")
TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Constants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants"))
DraggableObject = require(script:WaitForChild("DraggableObject"))
PropPlacer = require(script:WaitForChild("PropPlacer"))
GroupVerification = require(script:WaitForChild("GroupVerification"))

-- Remote Events and Remote Functions

CustomizationInvoke = ReplicatedStorage:WaitForChild("Customization")
CustomizingEvent = ReplicatedStorage:WaitForChild("CustomizingEvent")
MultiverseInvoke = ReplicatedStorage:WaitForChild("Multiverse")
ServerListUpdate = ReplicatedStorage:WaitForChild("ServerListUpdate")
VisualizerEvent = ReplicatedStorage:WaitForChild("AttackVisualizer")
promptPurchaseInvoke = ReplicatedStorage:WaitForChild("GamepassPurchases")
weaponPackInvoke = ReplicatedStorage:WaitForChild("WeaponPacks")
print("past first stack")

CustomLoadingScreen = ReplicatedStorage:WaitForChild("CustomLoadingScreen")
TeleportService:SetTeleportGui(CustomLoadingScreen)
teleportData = TeleportService:GetLocalPlayerTeleportData()


-- IMPORTANT AF

-- Basics
print("Loading basics...")

CustomizationRoomPlaceId = 88229153869269
MainLobbyPlaceId = 88229153869269

Client = Players.LocalPlayer
GroupId = 17062776

local PlayerGui = Client:WaitForChild("PlayerGui")

-- Avoid toggling Roblox's PlayerList CoreGui during boot; Studio can throw inside CoreGui.Settings.Pages.Players.

-- main/bottom bar

local BottomBar = MainUI.BottomBar
local AnimationsOpen = BottomBar.Animations
local CustomizationOpen = BottomBar.Customization
local ServerBrowserOpen = BottomBar.ServerBrowser
local VisualizerOpen = BottomBar.AttackVisualizer
local SettingsOpen = BottomBar.Settings
local PropOpen = BottomBar.propPlacer
local AllowFollowsButton = MainUI.GeneralSettings.AllowFollows
local ToolsOpen = BottomBar.Tools
local WaitingUI = MainUI.Waiting
local AnimationsUI = MainUI.Animations
local VisualizerUI = MainUI.Visualizer
local PropPlacerUI = MainUI.PropPlacer
local GeneralSettings = MainUI.GeneralSettings

local CurrentForeignVisualization = nil
local CurrentForeignProp = nil
local DeleteVisualizationToggle = false

-- Visualizer

local VisualizerFolder = script.Visualizer

local WorkspaceVisualizedFolder = workspace:FindFirstChild("WorkspaceVisualizedFolder") or Instance.new("Folder")
WorkspaceVisualizedFolder.Name = "WorkspaceVisualizedFolder"
WorkspaceVisualizedFolder.Parent = workspace

WorkspaceVisualizedFolder:ClearAllChildren()

local CurrentVisualizerColor = Color3.new(1,0,0)
local CurrentVisualizerMode = "AOE"
local CurrentVisuzaliserAsset = VisualizerFolder.AOEArea:Clone()

local AccessoryTemplate = script.AccessoryTemplate
local IgnoreIncomingAccessory = false

CurrentUI = nil -- what UI we're on, global
CurrentSlot = nil
ToggleUIBar = false
MainUI_MouseDetectionFrame = MainUI.MouseDetectionFrame



--local Fade = MainUI.Fade

-- Customization

local CustomizationUI = MainUI.Customization
local CustomizationBottomBar = CustomizationUI.CustomizationBottomBar

local AccessoriesBin = CustomizationUI.AccessoriesBox.Bin

local AccessoryColorPane = CustomizationUI.ColorBox
local AccessoryTransformPane = CustomizationUI.TransformBox
local AccessoryBodyPartPane = CustomizationUI.BodyPartBox
local AccessoryParticlePane = CustomizationUI.ParticlesBox
local CharacterInfoPane = CustomizationUI.InfoBox
local CharacterTraitsPane = CustomizationUI.TraitsBox

local CurrentEmpowermentSelectionBoxVisible = nil

local CurrentSkillSelectionBoxes = {false, false, false, false, false}

local lastHandles

local SelectedAccessories = {}

-- some randoms i dont think is used anymore

local CausingAnchor = {}

local InviteInsidePosition = UDim2.new(0.885, 0,0.45, 0)
local InviteOutsidePosition = UDim2.new(1, 0,0.45, 0)
local InviteActive = false

-- VERY IMPORTANT

local MajorDebounce = false
local DSDebounce = false

-- limiters

local MaxHeight = Constants.MaxHeight
local MaxInches = Constants.MaxInches
local MaxSlots = Constants.MaxSaveSlots
local MaxAccessories = Constants.MaxAccessories
local MaxAccessoryDistance = Constants.MaxAccessoryDistance

-- OOC toggle

local OOCToggle = true

-- Multiverse Variables

local TEST_MODE = true

-- XP counter

local CurrentXP = 0



local PlaceId = game.PlaceId
local JobId = game.JobId

local PromptDebounce = false

--local Counter = ReplicatedStorage:WaitForChild("RefreshTimer")

local CurrentPlaceIdInspecting = nil

-- General UIs

local AllowsFollows = true
local AnimationsDeb = false


repeat wait() until Client.Character

local Character = Client.Character

local OwnsAccessoriesAndSlotsGamepass = true
--local OwnsSecondAccessoriesAndSlotsGamepass = false
--local OwnsThirdAccessoriesAndSlotsGamepass = false
local OwnsBetterCustomizationGamepass = true
local OwnsCustomMeshGamepass = true
local OwnsPropPlacer = true

local SlotsBoxSizeWithOutfits = UDim2.new(0.2, 0,0.389, 0)
local SlotBarPositionWithOutfits = UDim2.new(0.79, 0,0.364, 0)



local LeaderboardHidden = false

local Humanoid = Character:WaitForChild("Humanoid")

local Animator = Humanoid:WaitForChild("Animator")

-- Animations

local Animations = script:WaitForChild("Animations")

local AnimationsTable = {

}

-- Prop Placer System
PropPlacer.PropListClone()


do
	for i, v in pairs(script:WaitForChild("Animations"):GetChildren()) do
		AnimationsTable[v.Name] = Animator:LoadAnimation(v)
		local c = script:WaitForChild("AnimationButton"):Clone()
		c.Name = v.Name
		c.Slide.displayText.Text = v.Name
		c.Parent = MainUI.Animations.Frame.Bin
	end

	for index, Track in pairs(AnimationsTable) do
		Track.Priority = Enum.AnimationPriority.Action
	end

end


do -- experimental adjustments
	ReplicatedStorage:WaitForChild("ServerType")
	wait()
	if ReplicatedStorage.ServerType.Value == "Supporter Preview" then
		MainUI.EventSystem.Visible = true
		script.InspectionCard.Join.Visible = true
		script.InspectionCard.Invite.Visible = true
		MainUI.bug.Text = MainUI.bug.Text .. " (Supporter Preview)"
		MainUI.Info.PatchNotes.top.Visible = true
		MainUI.GeneralSettings.Shop.Visible = true
	else
		MainUI.EventSystem.Visible = false
		--MainUI.BottomBar.propPlacer.Visible = false
		--	MainUI.Info.PatchNotes.top.Visible = false
		--MainUI.GeneralSettings.Shop.Visible = false
	end
	if ReplicatedStorage.ServerType.Value == "Freeform" then
		--MainUI.GeneralSettings.servertype.Text = "You are playing on a Freeform server. Nothing is canon. You can do anything. Have fun."
	elseif ReplicatedStorage.ServerType.Value == "Supporter Preview" then
		--MainUI.GeneralSettings.servertype.Text = "You are playing on a Supporter Preview server. Some features are new and might affect the roleplay experience. It is not canon."
	elseif ReplicatedStorage.ServerType.Value == "Canonical" then
		--MainUI.GeneralSettings.servertype.Text = "You are playing on a Canonical server. This is the normal experience. Everything is canon and rules must be followed."
	end
	if game.PlaceId == MainLobbyPlaceId and GroupVerification.CheckRank(Client, "Community") == true then
		--script.MiniBrowser.JoinExperimental.Visible = true
	end

	--[[game.ReplicatedStorage.ServerType.Changed:Connect(function()
		if ReplicatedStorage.ServerType.Value == "Freeform" then
			--MainUI.GeneralSettings.servertype.Text = "You are playing on a Freeform server. Nothing is canon. You can do anything. Have fun."
		elseif ReplicatedStorage.ServerType.Value == "Supporter Preview" then
			--MainUI.GeneralSettings.servertype.Text = "You are playing on a Supporter Preview server. Some features are new and might affect the roleplay experience. It is not canon."
		elseif ReplicatedStorage.ServerType.Value == "Canonical" then
			--MainUI.GeneralSettings.servertype.Text = "You are playing on a Canonical server. This is the normal experience. Everything is canon and rules must be followed."
		end
		
		if ReplicatedStorage.ServerType.Value == "Supporter Preview" then
			MainUI.EventSystem.Visible = true
			script.InspectionCard.Join.Visible = true
			script.InspectionCard.Invite.Visible = true
			MainUI.bug.Text = MainUI.bug.Text .. " (Supporter Preview)"
			MainUI.Info.PatchNotes.top.Visible = true
			MainUI.GeneralSettings.Shop.Visible = true
		else
			MainUI.EventSystem.Visible = false
			--MainUI.BottomBar.propPlacer.Visible = false
			--MainUI.Info.PatchNotes.top.Visible = false
			--MainUI.GeneralSettings.Shop.Visible = false
		end
		if ReplicatedStorage.ServerType.Value == "Freeform" then
			MainUI.GeneralSettings.servertype.Text = "You are playing on a Freeform server. Nothing is canon. You can do anything. Have fun."
		elseif ReplicatedStorage.ServerType.Value == "Supporter Preview" then
			MainUI.GeneralSettings.servertype.Text = "You are playing on a Supporter Preview server. Some features are new and might affect the roleplay experience. It is not canon."
		elseif ReplicatedStorage.ServerType.Value == "Canonical" then
			MainUI.GeneralSettings.servertype.Text = "You are playing on a Canonical server. This is the normal experience. Everything is canon and rules must be followed."
		end
		
	end)]]

	if game:GetService("RunService"):IsStudio() then
		MainUI.EventSystem.Visible = true
		script.InspectionCard.Join.Visible = true
		script.InspectionCard.Invite.Visible = true
		MainUI.bug.Text = MainUI.bug.Text .. " (studio)"
		MainUI.Info.PatchNotes.top.Visible = true
		MainUI.GeneralSettings.Shop.Visible = true
	end
end



local PlaceInformationTable = {

	[16022954380]= {
		["Name"] = "The Shallows";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[76800883465932]= {
		["Name"] = "Harmonic Vault";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[133726169233993]= {
		["Name"] = "Obsidian Shrine";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[70549089948008]= {
		["Name"] = "The Witherholt";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[14450222064]= {
		["Name"] = "Castellan Ward";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[16820101062]= {
		["Name"] = "Blacksmoke";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[16737334026]= {
		["Name"] = "Watcher's Row";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[127880360332494]= {
		["Name"] = "Library of Alabastra";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[120313151037448]= {
		["Name"] = "The Mindwraith";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[123482208262598]= {
		["Name"] = "Core of Creation";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[119803004897276]= {
		["Name"] = "Yellow Abbey";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[112332753872711]= {
		["Name"] = "Sunken Moth";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[84063695355472]= {
		["Name"] = "Fort Dawn";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[90763476777088]= {
		["Name"] = "In-Between";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[96473183100769]= {
		["Name"] = "Ashen Crucible";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[79292773154512]= {
		["Name"] = "Orkney Rising";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[108910128947424]= {
		["Name"] = "New Messina";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[107129351430752]= {
		["Name"] = "Hall of Jubilation";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[104785274421883]= {
		["Name"] = "Stillwater Apartments";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[109702489786758]= {
		["Name"] = "Marbrick Forest";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[133750941421087]= {
		["Name"] = "Blackstone Mineshaft";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[124344702839053]= {
		["Name"] = "Rotstone";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[73687410995256]= {
		["Name"] = "Howling Wolf";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[123996615578683]= {
		["Name"] = "St. Althea's Cathedral";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[132298553099601]= {
		["Name"] = "BSNFLK Bop";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[18698171098]= {
		["Name"] = "The Gala";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[119440617660843]= {
		["Name"] = "The Council Hall";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[117944198445997]= {
		["Name"] = "Dawn";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[16335093772] = {
		["Name"] = "Event Areas";
		["DisplayImage"] = 0;
		["Description"] = ""
	},

	[13501188035] = {
		["Name"] = "Coding Studio 1";
		["DisplayImage"] = 0;
		["Description"] = "A coding studio"
	},
	[12822869744] = {
		["Name"] = "Lobby";
		["DisplayImage"] = 0;
		["Description"] = "Main"
	},
	[13516290197] = {
		["Name"] = "Messina";
		["DisplayImage"] = 14573892892;
		["Description"] = "Main"
	},
	[13516289815] = {
		["Name"] = "Customization Room";
		["DisplayImage"] = 0;
		["Description"] = "Main"
	},
	[95468475320806] = {
		["Name"] = "Lin Jun City";
		["DisplayImage"] = 0;
		["Description"] = "Main"
	},
	[78022774582045] = {
		["Name"] = "Brewed Awakening";
		["DisplayImage"] = 0;
		["Description"] = "Main"
	},
	[87639394171191] = {
		["Name"] = "St. Jian Lian's Cathedral";
		["DisplayImage"] = 0;
		["Description"] = "Main"
	},
	[108983354484264] = {
		["Name"] = "The Sunspire Library";
		["DisplayImage"] = 0;
		["Description"] = "Main"
	},
	[134062149028327] = {
		["Name"] = "Lin Jun Residential";
		["DisplayImage"] = 0;
		["Description"] = "Main"
	},
	[96013919143783] = {
		["Name"] = "Veiled Emporium";
		["DisplayImage"] = 0;
		["Description"] = "Main"
	},
	[131426189085289] = {
		["Name"] = "The Airship";
		["DisplayImage"] = 0;
		["Description"] = "Main"
	},
	[82970261751299] = {
		["Name"] = "The Train";
		["DisplayImage"] = 0;
		["Description"] = "Main"
	},
	[133916187791199] = {
		["Name"] = "Tian Di Palace";
		["DisplayImage"] = 0;
		["Description"] = "Main"
	},
	[15889165808] = {
		["Name"] = "Saint Adram";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[13546912069] = {
		["Name"] = "Vale of Cinder";
		["DisplayImage"] = 0;
		["Description"] = "The Deadlands";
	},
	[14536242217] = {
		["Name"] = "Basinfolk";
		["DisplayImage"] = 0;
		["Description"] = "The Deadlands";
	};
	[14573368083] = { --1
		["Name"] = "Home";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14573425543] = { --2
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Archelm";
	};
	[14573462989] = { --3
		["Name"] = "Home";
		["DisplayImage"] = 14573867906;
		["Description"] = "A home within Archelm";
	};
	[14573490722] = { --4
		["Name"] = "Home";
		["DisplayImage"] = 14573867636;
		["Description"] = "A home within Archelm";
	};
	[14573503670] = { --5
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Archelm";
	};
	[14583861075] = { --6
		["Name"] = "Home";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14583890154] = { --7
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Archelm";
	};
	[14583911927] = { --8
		["Name"] = "Home";
		["DisplayImage"] = 14573867636;
		["Description"] = "A home within Archelm";
	};
	[14583966895] = { --9
		["Name"] = "Home";
		["DisplayImage"] = 14573867906;
		["Description"] = "A home within Archelm";
	};
	[14584009099] = { --10
		["Name"] = "Throne Room";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14584029109] = { --11
		["Name"] = "The Manor";
		["DisplayImage"] = 14573867471;
		["Description"] = "A luxurious home for the nobility";
	};
	[14584076184] = { --12
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Archelm";
	};
	[14584095821] = { --13
		["Name"] = "Station Orion";
		["DisplayImage"] = 14573868105;
		["Description"] = "The Center of Transportation";
	};
	[14584128094] = { --14
		["Name"] = "Home";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14584162291] = { --15
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Archelm";
	};
	[14584196339] = { --16
		["Name"] = "Home";
		["DisplayImage"] = 14573867906;
		["Description"] = "A home within Archelm";
	};
	[14584246178] = { --17
		["Name"] = "Home";
		["DisplayImage"] = 14573867906;
		["Description"] = "A home within Archelm";
	};
	[14584293320] = { --18
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Archelm";
	};
	[14584335800] = { --19
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Archelm";
	};
	[14584367280] = { --20
		["Name"] = "Home";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14584437001] = { --21
		["Name"] = "Home";
		["DisplayImage"] = 14573867636;
		["Description"] = "A home within Archelm";
	};
	[14584470521] = { --22
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Archelm";
	};
	[14584502091] = { --23
		["Name"] = "Home";
		["DisplayImage"] = 14573867906;
		["Description"] = "A home within Archelm";
	};
	[14584533229] = { --24
		["Name"] = "Home";
		["DisplayImage"] = 14573867906;
		["Description"] = "A home within Archelm";
	};
	[14584567998] = { --25
		["Name"] = "Home";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14584653101] = { --26
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Archelm";
	};
	[14584692185] = { --27
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Archelm";
	};
	[14584720219] = { --28
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Archelm";
	};
	[14584756869] = { --29
		["Name"] = "Home";
		["DisplayImage"] = 14573867906;
		["Description"] = "A home within Archelm";
	};
	[14584794863] = { --30
		["Name"] = "Home";
		["DisplayImage"] = 14573867636;
		["Description"] = "A home within Archelm";
	};
	[14585015793] = { --31
		["Name"] = "Home";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14585034285] = { --32
		["Name"] = "Home";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14585058641] = { --33
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Archelm";
	};
	[14585085882] = { --34
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Archelm";
	};
	[14585174588] = { --35
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Archelm";
	};
	-- basinfolk interiors
	[14652247271]  = { --36
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Basinfolk";
	};
	[14652287644] = { --37
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Basinfolk";
	};
	[14652319048] = { --38
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Basinfolk";
	};
	[14621341731] = { -- The Inn
		["Name"] = "The Inn";
		["DisplayImage"] = 14621771536;
		["Description"] = "A tavern within Archelm";
	};
	[15090002937] = { -- the academy
		["Name"] = "The Academy";
		["DisplayImage"] = 0;
		["Description"] = "";
	};
	[14549103090] = { -- the bank
		["Name"] = "The Bank";
		["DisplayImage"] = 0;
		["Description"] = "";
	};
	[15381264997] = { -- The Underhelm
		["Name"] = "The Underhelm";
		["DisplayImage"] = 0;
		["Description"] = "";
	};
	[14649892844] = { -- The Courthouse
		["Name"] = "The Courthouse";
		["DisplayImage"] = 15382255209;
		["Description"] = "";
	};
	[15432964046] = { -- The Courthouse
		["Name"] = "Sunscorched Arena";
		["DisplayImage"] = 0;
		["Description"] = "";
	};
	[94153612486163] = { -- Deep Marbrick
		["Name"] = "Archway Grotto (Marbrick)";
		["DisplayImage"] = 0;
		["Description"] = "";
	};
}
-- 






local GamepassList = {
	["179828905"] = {
		["Owned"] = false,
		["Name"] = "More Accessories",
		["ExecuteCode"] = function(self)
			warn("Owns two times slots")

			MaxAccessories = Constants.MoreAccessoriesGamepassMaxAccessories
			MaxSlots = Constants.MaxSaveSlots
			OwnsAccessoriesAndSlotsGamepass = true
		end,
	},
	["179830466"] = {
		["Owned"] = false,
		["Name"] = "Custom Meshes",
		["ExecuteCode"] = function(self)
			warn("Owns custom meshes")
			OwnsCustomMeshGamepass = true
		end,
	},
	["179829743"] = {
		["Owned"] = false,
		["Name"] = "Customization+",
		["ExecuteCode"] = function(self)
			warn("Owns better Customization")

			MaxHeight = Constants.MaxHeight
			MaxInches = Constants.MaxInchesWithCustomization
			MaxAccessoryDistance = Constants.MaxAccessoryDistanceWithCustomization
			OwnsBetterCustomizationGamepass = true
			AccessoryParticlePane.Paywall.Visible = false
		end,
	},
	--["219852574"] = {
	--	["Owned"] = false,
	--	["Name"] = "Prop placer+",
	--	["ExecuteCode"] = function(self)
	--		warn("Prop placer")

	--		OwnsPropPlacer = true
	--	end,
	--}
	--[[["173226015"]  = {
		["Owned"] = false,
		["Name"] = "Test gamepass",
		["ExecuteCode"] = function(self)
			print("This is a test gamepass. Code would run right now.")
		end,
	}]]
}

local WeaponsPackList = {
}

--CustomizationUI.InfoBox.Bin.Accessories.Bin.UIListLayout.Padding = UDim.new(CustomizationUI.InfoBox.Bin.Accessories.Bin.UIListLayout.Padding.Scale/2,0)
--CustomizationUI.InfoBox.Bin.Accessories.Bin.CanvasSize = UDim2.new(0,0,CustomizationUI.InfoBox.Bin.Accessories.Bin.CanvasSize.Y.Scale*2, 0)

local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local GamepassWhitelist = {[71816461] = true; [31032835] = true}

local function GetGamepassesRecursive()
	local succ, result = pcall(function()
		for i, v in pairs(GamepassList) do
			local id = tonumber(i)
			local UserOwnsPass = MarketplaceService:UserOwnsGamePassAsync(Client.UserId, id)
			if GroupVerification.CheckRank(Client, "Gamemaster") == true then UserOwnsPass = true end
			if GamepassWhitelist[Client.UserId] then UserOwnsPass = true end
			if RunService:IsStudio() then UserOwnsPass = true end
			if UserOwnsPass then
				v:ExecuteCode()
				v.Owned = true
			end
		end
	end)

	if not succ then warn(result) wait(1) GetGamepassesRecursive() end
end

GetGamepassesRecursive()

local specialvipslots = false

local vipwhitelist = {}


CustomizationUI.AccessoriesBox.Bin.SelectionManagement.NeutralSize.Value = 40
CustomizationUI.AccessoriesBox.Bin.SelectionManagement.ExpandedSize.Value = 60

if vipwhitelist[Client.UserId] == true or Client.Name == "Player1" or GroupVerification.CheckRank(Client, "Gamemaster") then
	MaxAccessories = Constants.SpecialMaxAccessories
	specialvipslots = true
	MaxSlots = Constants.SpecialMaxSaveSlots

	warn("IS SPECIAL PLAYER!")

end

local tbOfButtons = {}
wait()

if game.PlaceId == 3073983401 then
	MainUI.Info.Visible = true
end

-- Avatar body parts
print("Loading avatar body parts...")
local BodyHeightScale = Humanoid.BodyHeightScale
local BodyDepthScale = Humanoid.BodyDepthScale
local BodyWidthScale = Humanoid.BodyWidthScale
local HeadScale = Humanoid.HeadScale

local CharacterTable = {
	["ParticleEmitters"] = {},
	["Rigs"] = {},
	["Accessories"] = {},
	["Animations"] = {
		["WalkAnimation"] = Character.Humanoid.HumanoidDescription.WalkAnimation,
		["RunAnimation"] = Character.Humanoid.HumanoidDescription.RunAnimation,
		["IdleAnimation"] = Character.Humanoid.HumanoidDescription.IdleAnimation,
	},
	["CharacterInformation"] = {
		["CharacterName"] = "",
		["CharacterBio"] = "",
		["CharacterImg"] = "",
		["EmpowermentType"] = "",
		["Empowerment"] = "",
		["EmpowermentTitle"] = "",
		["IsCustomEmpowerment"] =false,
		["Skills"] = {
			{}, {}, {}, {}, {}
		}
	},
	["FaceID"] = Character.Head.face.Texture:match("%d+") or "",
	["LimbRemover"] = {},
	["Scale"] = {
		["Height"] = BodyHeightScale.Value,
		["Depth"] = BodyDepthScale.Value,
		["Width"] = BodyWidthScale.Value,
		["Head"] = HeadScale.Value
	},
	["BodyColors"] = {
		["Head"] = {
			["R"] = Character["Body Colors"]["HeadColor3"].R,
			["G"] = Character["Body Colors"]["HeadColor3"].G,
			["B"] = Character["Body Colors"]["HeadColor3"].B
		},
		["RightArm"] = {
			["R"] = Character["Body Colors"]["RightArmColor3"].R,
			["G"] = Character["Body Colors"]["RightArmColor3"].G,
			["B"] = Character["Body Colors"]["RightArmColor3"].B
		},
		["LeftArm"] = {
			["R"] = Character["Body Colors"]["LeftArmColor3"].R,
			["G"] = Character["Body Colors"]["LeftArmColor3"].G,
			["B"] = Character["Body Colors"]["LeftArmColor3"].B
		},
		["LeftLeg"] = {
			["R"] = Character["Body Colors"]["LeftLegColor3"].R,
			["G"] = Character["Body Colors"]["LeftLegColor3"].G,
			["B"] = Character["Body Colors"]["LeftLegColor3"].B
		},
		["RightLeg"] = {
			["R"] = Character["Body Colors"]["RightLegColor3"].R,
			["G"] = Character["Body Colors"]["RightLegColor3"].G,
			["B"] = Character["Body Colors"]["RightLegColor3"].B
		},
		["Torso"] = {
			["R"] = Character["Body Colors"]["TorsoColor3"].R,
			["G"] = Character["Body Colors"]["TorsoColor3"].G,
			["B"] = Character["Body Colors"]["TorsoColor3"].B
		},
	},
}

local Empowerments = {
	["Physiology"] = {
		["Superstrength"] = "Carry and throw motorcycles, dumpsters and other large, heavy objects such as vending machines. Strong enough to lift a small car onto its side, as well as break cement walls and dent metals. -1 to KINETIC DAMAGE TYPE",
		["Speedster"] = "Sprint at speeds that are difficult for the average human to keep up with. Speedsters do not have any added physicality or reflexes, but are capable of performing high agility maneuvers such as wallrunning. ABLE TO BE PERCEIVED BY AU NATUREL / SUPERSENSE",
		["Durability"] = "Absurd toughness, with the ability to take direct hits from superhuman opponents. Able to endure light arms fire to the body in relatively short bursts. -3 to CHOSEN DAMAGE TYPE",
		["Enhanced Physique"] = "Olympic levels of speed, with peak human strength that's greater than any kind of bodybuilder. Generally increased stamina allows one to go on runs comparable to marathons, and carry out other feats for long periods of time that would normally be too intensive on the human body. -1 to KINETIC DAMAGE TYPE",
		["Regeneration"] = "‘Regen’ commonly suffer through wounds that would otherwise need external attention, and recovers all on their own. Regenerators are capable of passively healing deep cuts, bullet wounds up to L2 Damage, as well as bruises sustained from combat. Regenerators can heal in or out of combat, with the former typically requiring more stamina and time to perform."
	},
	["Genetic"] = {
		["Shapeshifting"] = "Shape-shifters are able to shift into most domestic or smaller sized animals such as dogs, cats, or larger rodents for extended periods of time. The larger the creature is, like a direwolf, the more effort is put in and shorter the form lasts for (2min), while smaller forms are capable of being held for longer periods of time (hours+).",
		["Body Control"] = "Basic control over the human body, those with bodily control are able to protrude and sharpen their bones into rough shapes such as spears or claws, and stretch out their flesh several feet long as if it was rubber. Usage demands an increased level of food consumption, and may very well induce fits of mania regarding the ‘malleability’ of the body - otherwise known as bio-supremacy.",
		["Chroma-Grade"] = "‘Chroma-Grades,’ short for Chromatic Gradients, are capable of eliciting the pigments of their skin to change color in an advanced, brilliant way - oils seep through their clothing to make the effect uniform, turning them nigh-invisible to the average eye. Through manipulating mutant chromatophores, ‘Chroma-Grades’ match their environments nigh-perfectly, especially in low-light areas.",
		["Hybrid"] = "Empowered with animalistic traits that drastically alter their cosmetics and human nature, altering appearances to grow abundant amounts of hair, fur, or taking on certain traits such as the beak of a bird. A ‘Hybrid’ is oft ostracized, or caricatured by genetic enhancements, but those born with it enjoy some physiological benefits similar to ENHANCED CONDITIONING.",
		["Acute Senses"] = "Senses become genetically mutated, allowing one to hear, taste, and smell to more sensitive levels - comparable to a household cat or dog. Allows the ability to track others through visual impairments, and be able to perceive the physically enhanced, such as speedsters."
	},
	["Composite"] = {
		["Solid Composite"] = "Woven into an Empowered’s musculoskeletal system, a specific element becomes the dominant chemical in your body’s make-up. This lends to a more durable frame, sometimes to the point of increasing kinetic damage output & absorption, at the cost of making one heavy and cumbersome. CHOOSE ANY ELEMENT WITHIN REASON, -2 DAM",
		["Water Composite"] = "The Empowered’s bodily fluids and veins are replaced with trace amounts of water, liquid nitrogen, and hydrogen. This allows for one to envelop their limbs in water, as if it was an extension of their own arm or lab, stretching them out into shapes such as a lasso. Water composites are also known to have a sleeker physique, allowing them to slip through tighter areas through their unique makeup. Weakened by fire / heat.",
		["Acid Composite"] = "The Empowered’s saliva and blood are replaced with traces of heavily acidic elements, which are able to be utilized either passively or actively. When cut, these Composites will leak acid from their wounds, capable of giving 3rd degree chemical burns to anyone unfortunate enough exposed to their “blood”. Acid composites are also capable of quite literally spitting out acid, travelling several feet outwards, and able to disintegrate past weak and thin metals.",
		["Smoke Composite"] = "The Empowered’s repository system is altered to power on smoke, turning their breaths into thick amounts of smog. Smoke composites are unable to breathe in oxygen, making them immune to suffocation. A smoke composite’s body will typically cause them to have more bounce to their actions, allowing them to leap onto rooftops, and float in the air for several seconds.",
		["Electricity Composite"] = "Highly-excited nerves lend energy composites the ability to have an extremely receptive nervous system. Electricity composites are powered through their nerves, always on edge, causing them to have more explosiveness and quickness to their movements. Composites can also administer shocks through skin-to-skin contact, similar to an electric eel."
	},
	["Tactile"] = {
		["Pyrokinesis"] = "With the ability to launch out fiery projectiles from their body, pyrokinetics are the equivalent of a flamethrower on P.E.D’s, able to burn flesh easily and melt weaker metals with some strain. The projectiles detonate on impact, but require for someone to telegraph their action before shooting one outwards, with repetitive use straining the body.",
		["Cryokinesis"] = "Cryokinetics shoot out projectiles of frost at their behest, inflicting 2nd/3rd degree frostbite on Humanoids, frosting over lighter metals to turn them into brittle as wood, and freeze objects or limbs on contact. Cryokinetics can form basic constructs out of their ice, such as a long staff, but these are relatively easy to shatter and break.",
		["Vitrikinesis"] = "Vitrikinetics are capable of harnessing the minute world of inorganic crystalline danger. Shattering windows within twice-arms reach, and capable of directing shrapnel & clouded glass through the air, they are often one of the more viscera-inclined MANIPs. A basic shield - capable of taking blunt force impacts - can be formed over one’s forearm, but this Empowerment is mostly an aggressive one.",
		["Geokinesis"] = "Geokinetics utilize their earthen environment to their advantage, forming weapons from shards of rock, shielding themselves and allies in earth, and forming a necessary component of many constructive efforts. Constructs made by Geokinetics are only able to be broken by enhanced SUPER STRENGTHs. They are incapable of interfacing rigid, non-earthen projections or crystallines, like glass or metal.",
		["Electrokinesis"] = "Electrokinetics can redirect radiant energy in the form of taser-like lightning, causing burns, heart murmurs, and overloading currents against enemies. The more current they are exposed to, the more freely they are capable of doing so."
	},
	["Psionic"] = {
		["Telekinesis"] = "Two “ghost limbs” interface the world the same exact way a real limb would, with motions such as pushing easier to do than a more precise action. The limbs have a limit of several dozen feet, meaning they need to extend outwards, as well as requiring concentration to use properly. About as strong as ENHANCED CONDITIONING, and they are excessively tiring to use for any extended period of time.",
		["Reader"] = "By touching unconscious Empowered or objects with enough concentration and intent, one can tap into the memories and interactions revolving around them that have occurred in the past twenty four hours, absorbing that information through psychic means. When ‘reading,’ one is subject to scarring displays and emotional conviction out of their control.",
		["Technopathy"] = "By interfacing with the “CYBERSPACE”, Technopaths are able to access an individual’s NIC, allowing them to identify their name, occupation, and empowerment to a basic level. Technopaths are also capable of performing minor “quickhacks”, including turning off street lights, opening locked electronic doors, and disabling security cameras.",
		["Levitation"] = "Capable of suspending themselves in mid-air and, in short bursts, propelling themselves, those blessed with ‘Levitation’ keep themselves upright using the sheer power of their mind, floating through air using a small “bubble” incapable of doing anything more than affecting their movement, or the paths of slow-moving objects within arm’s reach. Agility differs, with some being more capable at the constant application of force - ‘flight’ - and others ‘bursts’ - lending a hand to attack evasion.",
		["Glinting"] = "Mild fluctuations in location, with comparably shifted mentalities, to glint is to transpose one’s location a short distance. Glinters can teleport up to two meters/six feet, with direct eyesight of their location necessary, and a protracted bodily cue - like swaying a hand or pulling on air. Glinters can only teleport a limited amount of times before puking - once every two minutes."
	},
	["Anomaly"] = {
		["Poppet"] = "Items that should not be animated, nor living, brought to life, unable to communicate normally, but mystically resilient and elusive by clever means. Never an object larger than a forearm, these bad omens often drift through bodies. A ‘poppet’ can be killed, but will merely return again after three days - characterizing their persistence and mysticism.",
		["Tanuki"] = "Short life-spans and elusive natures lend the Tanuki mystical experiences. Varying as shorter, monochromatic bipedal felines, the Tanuki are seasoned tricksters, summoning up short (5s) sensory illusions on singular targets with focus. These illusions vary in complexity, but are of simple origin - and disarray often being the only considerations a Tanuki gives to their acts.",
		["Witnesses"] = "Righteous and mystifying, a Witness is an animated creature of light - pure light. Acting in a virtuously fateful way, they communicate in single-worded telepathic conventions of emotion - dancing balls of light, made of four intersecting cubes, never larger than a grapefruit. Some consider them lost souls. All that matters is that they are capable of returning - forever and more, four days after death.",
		["The Marred"] = "Life is a blessing to some, and Marred are damned to still be alive. Missing limbs, replaced body-parts, headless freaks, the Marred sport everyday objects as integral parts of themselves, forming new attachments with symbolic relics of old or items of new. Marred are not capable of returning by any means within their control, living haunted and brief lives.",
		["Sapients"] = "Life is a blessing to some, and Marred are damned to still be alive. Missing limbs, replaced body-parts, headless freaks, the Marred sport everyday objects as integral parts of themselves, forming new attachments with symbolic relics of old or items of new. Marred are not capable of returning by any means within their control, living haunted and brief lives."
	}
}

local Skills = {
	["Lifestyle"] = {
		["Au-naturel"] = "Common sense is not so common, and to maintain a healthy body is hard nowadays. Athletes, healthnuts, and sports med offer an ‘AU NATUREL’ a strong and endured body without the use of cyber or bioware - popular crutches nowadays.",
		["Savior"] = "Familiar with standard Humanoid anatomy, these street-trained medics are not licensed, but their life in the slums have given them chances to care for most basic wounds. Surface-level, and not inclined to fixing mortal problems.",
		["Scraphammer"] = "Scraphammers have spent a long time scouring junk yards & studying old manuals - capable of tinkering with the most basic of gutterware goods & consumer products. Single-use or rudimentary objects - like gas masks - are craftable in time.",
		["Thread-spinner"] = "Young apprentices of seamwinders and even armorers who are proficient at putting together uniforms & outfits - or repairing basic soft-armors at the cost of time & resources. Thread-Spinners are an essential part of social mobility.",
		["Munch Peddler"] = "Not everyone likes protein packs and artificial mush. The ones that master the culinary trade master people’s stomachs, and keep entire groups functioning. A ‘MUNCH PEDDLER’ is a necessary chef in any gang’s food chain.",
		["Drug Familiar"] = "Not a chemist, but a user. Down on their luck, the ‘DRUG FAMILIAR’ garner experience replicating popular recipes at a noticeable loss of quality. They aren’t any Heisenberg, but they can still get you high as a bird."
	},
	["Combat"] = {
		["Bladework"] = "Versed in the physical application of blades in combat, those who study ‘BLADEWORK’ are adeptly proficient in the usage of up to two variants of sword, knife, or bladed polearm. While not excessive in flair, they are effective at least.",
		["Blunt-force"] = "Bashing and smashing comes as second nature for Man, but those with a focus on it find boons wherever their fists or batons may land. Limited in scope to martial arts or anything with an abnormally blunt edge to it, they can be either middle-belts of the arts or nuts with clubs.",
		["Sleight-handed"] = "Unorthodox in approach, the Sleight-Handed pride themselves on utilizing two different items during melee conflict - specializing in what is commonly known as ‘dual-wielding’ through either a supposed agility or ‘great deal of strength,’ dredging up haphazard Hollywood flair.",
		["Limbic Attunement"] = "Limbic Attunement implies an Empowered has become one with their movements, allowing flowing attacks and use of their whole body to fight off a number of close-range strikes. Brute genetics overtake honed precision and arts.",
		["Forecasting"] = "Certain Empowerements allow for the projection of the body - elemental or by various other means. ‘FORECASTING’ denotes experience in throwing one’s-self at a distance, swirling storms and forming crude limbs made to strike at range.",
		["Lead-slinger"] = "Bridging old-school-cool and new-age desperation, a Lead-Slinger specializes in using two specific, singular models of ranged Pac in tandem with each-other. Composing of revolvers, pistols, slow-firing SMGs, or self-loading bows, one has trained since adolescence to gunsling adeptly.",
		["Ballistical"] = "Radical. Ballistical. Cool with the usage of small-arms, from basic pistols, to SMG’s, or the most iconic of rifles, these barely-trained practitioners of ranged conflict maintain guns & arguably semi-accurately fire downrange, with varying levels of final effectivity.",
		["Old-school"] = "Just as a sword’s lifespan extends into the 2030’s, thrown objects have been effective since the days of slingshots. Rudimentary compound bows, throwing knives, and any other assortment archaic tools can be studied & used at range."
	}

}

if Character:WaitForChild("Shirt", 10) then
	CharacterTable["ShirtTemplate"] = Client.Character.Shirt.ShirtTemplate
else
	CharacterTable["ShirtTemplate"] = ""
end

if Character:WaitForChild("Pants", 10) then
	CharacterTable["PantsTemplate"] = Client.Character.Pants.PantsTemplate
else
	CharacterTable["PantsTemplate"] = ""
end

-- Commonly used functions

function round(n) -- rounds
	return math.floor(n * 100) / 100
end

local function deepCopy(original) -- copies tables rather than makes a reference
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

local function TweenButtonClick(button) -- this is needed for all buttons, causes the click down and release animation/yielding

	if button:FindFirstChild("Slide") then
		script.ButtonSoundEffect:Play()
		button.Slide:TweenPosition(UDim2.new(0,0,0,0), "In", "Quad", 0.1, true)
		local tween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {["BackgroundColor3"] = Color3.fromRGB(0, 170, 255)})
		tween:Play()
		local con1
		local con2
		local res = false
		con1 = button.MouseButton1Up:Connect(function()
			con1:Disconnect()
			con2:Disconnect()
			con2 = nil
			con1 = nil
			res = true
		end)
		con2 = button.MouseLeave:Connect(function()
			con1:Disconnect()
			con2:Disconnect()
			con2 = nil
			con1 = nil
			res = false
		end)
		repeat wait() until con1 == nil and con2 == nil
		print(button.Name, "Result!", res)
		button.Slide:TweenPosition(UDim2.new(0,0,-0.1,0), "Out", "Quad", 0.1, true)
		local tween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["BackgroundColor3"] = Color3.fromRGB(255,255,255)})
		tween:Play()
		return  res
	end

end

local function GetPlayerFromUserId(UserId) -- grabs the player from the userid
	print("GET PLAYER FROM USER ID:", UserId)
	for i, v in pairs(Players:GetPlayers()) do
		if v.UserId == UserId then
			return v
		end
	end
end

local CachedPlayerNames = {} -- this is just a specific cache for this function so we dont have to call the APU multiple times

local function GetNameFromUserId(UserId) -- grabs the name from the userid
	if not CachedPlayerNames[UserId] then
		CachedPlayerNames[UserId] = Players:GetNameFromUserIdAsync(UserId)
	end
	return CachedPlayerNames[UserId]
end

function RegularRound(n) -- rounding but not as precise, typical usage
	return math.round(n * 100) / 100
end

function DefaultDelay() -- this a non-conditional resetting of the MajorDebounce to false. we currently dont use it (yet) because situation hasnt arised
	MajorDebounce = true; delay(0.25, function() MajorDebounce = false end)
end

local AccessoryCount = 0

local function RecountAccessories()
	local count = 0
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("Accessory") then
			count = count + 1
		end
	end
	AccessoryCount = count
end

local function CountAccessories() -- counts accessories, is useful from multiple places
	return AccessoryCount
end

local function GetMouseScreenPosition(mouse)
	return UDim2.new(mouse.X / mouse.ViewSizeX, 0, mouse.Y / mouse.ViewSizeY, 0)
end

RecountAccessories()
Character.ChildAdded:Connect(function(child)
	if child:IsA("Accessory") then
		AccessoryCount = AccessoryCount + 1
	end
end)
Character.ChildRemoved:Connect(function(child)
	if child:IsA("Accessory") then
		AccessoryCount = math.max(AccessoryCount - 1, 0)
	end
end)

local function FixRevertScaleForAllAccessories(NewTable) -- sometimes the scale will get messed up due to a roblox issue
	print("attempting to fix revert scale")
	for i, v in pairs(CharacterTable.Accessories) do
		if not v.IsMeshPart then
			for z, x in pairs(NewTable.Accessories) do
				if v.Object == x.Object then
					warn("Found proper accessory to fix revert scale for. Current:", v.RevertScale, "new:", x.RevertScale)
					v.RevertScale = x.RevertScale
					v.Scale = x.Scale
					v.AccessoryWeld.C0 = x.AccessoryWeld.C0
					v.AccessoryWeld.C1 = x.AccessoryWeld.C1
					v.DistanceFromOrigin = x.DistanceFromOrigin
					v.OriginalC0 = x.OriginalC0
					v.OriginalC1 = x.OriginalC1
					v.HandleSize = x.HandleSize
				end
			end
		end
	end
end


--[[
local UIRig = script.UIRig
UIRig.Parent = workspace
local CurrentCamera = workspace.CurrentCamera
local lastpos = nil

game:GetService("RunService").RenderStepped:Connect(function()
	if not lastpos then lastpos = CurrentCamera.CFrame end
	local speed = (lastpos.Position-CurrentCamera.CFrame.Position).magnitude
	local diff = (lastpos.Position-CurrentCamera.CFrame.Position)
	
	if speed ~= 0 then
		local difference = speed/50
	local newPos = CurrentCamera.CFrame + Vector3.new(diff.X*difference, diff.Y*difference, diff.Z*difference)
	
	UIRig:SetPrimaryPartCFrame(newPos)
		
	end
	lastpos = CurrentCamera.CFrame
end)
--]]

-- credits
do
	print("Indexing credits")
	--local Credits = script:FindFirstChild("Credits")
	--local Music = script.MenuMusic
	--local SkipButton = Credits.Credits.Skip
	local startfov = 70
	workspace.CurrentCamera.CameraSubject = Character
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	workspace.CurrentCamera.FieldOfView = startfov

	--[[if false == true then --if game.PlaceId == 11220296665 or game.PlaceId == MainLobbyPlaceId then
		if not  Client:FindFirstChild("CreditsPlayed") then 
			print("PLAYING CREDITS")
			Credits.Parent = script.Parent.Parent
			Credits.Enabled = true
			MainUI.Enabled = false
		script.CreditsScript.Enabled = true
			SkipButton.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(SkipButton)
				if not res then return end
				script.CreditsScript:Destroy()
				Credits:Destroy()
				Music:Destroy()
				MainUI.Enabled = true
				workspace.CurrentCamera.CameraSubject = Character
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				workspace.CurrentCamera.FieldOfView = startfov
				
			end)
		end
	else
		Credits:Destroy()
	end]]
end


MainUI.Info.Close.MouseButton1Down:Connect(function()
	local res = TweenButtonClick(MainUI.Info.Close)
	if not res then return end
	MainUI.Info.Visible = false
end)

-- Bottom Bar

MainUI_MouseDetectionFrame.MouseEnter:Connect(function()
	ToggleUIBar = true
	--if CustomizationUI.Visible == true then return end
	BottomBar:TweenPosition(UDim2.new(0,0,0.96,0), "Out", "Sine", 0.25, true)
end)

MainUI_MouseDetectionFrame.MouseLeave:Connect(function()
	ToggleUIBar = true
	BottomBar:TweenPosition(UDim2.new(0,0,1,0), "Out", "Sine", 0.25, true)
end)

CustomizationBottomBar.Exit.MouseButton1Down:Connect(function()
	local res = TweenButtonClick(CustomizationUI.CustomizationBottomBar.Exit)
	if res == false then return end
	if OOCToggle then return end
	if CurrentUI == "Customization" then CurrentUI = nil; CustomizationUI.Visible = false; 
		BottomBar.Visible = true; 
		--MainUI.GeneralSettings["Toggle Prompts"].Visible = true; 
		MainUI.GeneralSettings["ToggleVisualizations"].Visible = true;
		MainUI.GeneralSettings["AllowFollows"].Visible = true;
		MainUI.GeneralSettings["LeaderboardFilter"].Visible = true;
		MainUI.GeneralSettings["Shop"].Visible = true; 
		MainUI.Leaderboard.Visible = true
		if lastHandles then
			lastHandles.Visible = false
		end
		CustomizingEvent:FireServer(false)
		return end
	CurrentUI  = "Customization"
	CustomizationUI.Visible = true
	CustomizingEvent:FireServer(true)
end)


-- Bottom bar events


do

	ServerBrowserOpen.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(ServerBrowserOpen)
		if res == false then return end
	end)

	AnimationsOpen.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(AnimationsOpen)
		if res == false then return end
		if AnimationsDeb == true then
			AnimationsUI.Visible = false
			AnimationsDeb = false
		else
			AnimationsUI.Visible = true
			AnimationsDeb = true
		end
	end)

	SettingsOpen.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(SettingsOpen)
		if res == false then return end
	end)

	local InfoOpen = BottomBar.Info

	InfoOpen.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(InfoOpen)
		if not res then return end
		if MainUI.Info.Visible == true then MainUI.Info.Visible = false else MainUI.Info.Visible = true end
	end)


	VisualizerOpen.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(VisualizerOpen)
		if res == false then return end
		if CurrentUI ~= "Visualizer" then
			CurrentUI = "Visualizer"
			VisualizerUI.Visible = true
			CustomizationUI.Visible =false
			PropPlacerUI.Visible = false

			CurrentVisuzaliserAsset.Parent = WorkspaceVisualizedFolder
		elseif CurrentUI == "Visualizer" then
			CurrentUI = nil
			MainUI.GeneralSettings["ToggleVisualizations"].Visible = true
			MainUI.GeneralSettings["Shop"].Visible = true
			MainUI.GeneralSettings["LeaderboardFilter"].Visible = true
			MainUI.GeneralSettings["AllowFollows"].Visible = true
			MainUI.Leaderboard.Visible = true
			CurrentUI = nil
			VisualizerUI.Visible = false
			VisualizerUI.Visible = false
			CustomizationUI.Visible =false
			PropPlacerUI.Visible = false
			CurrentVisuzaliserAsset.Parent = nil
		end
	end)

	local OOCToggleButton = BottomBar.OOC
	local OOCDeb = false

	OOCToggleButton.MouseButton1Down:Connect(function()
		print("OOC DEB:", OOCDeb)
		local res = TweenButtonClick(OOCToggleButton)
		if not res then return end
		if OOCDeb == true then return end
		OOCDeb = true
		if OOCToggle == false then
			OOCToggle = true
			CustomizationUI.Visible = false
			CustomizingEvent:FireServer(false)
			CurrentUI = nil
			CustomizationInvoke:InvokeServer("OOC", OOCToggle)
		else
			OOCToggle = false
			CustomizationInvoke:InvokeServer("OOC", OOCToggle)
		end
		wait(1)
		OOCDeb = false
	end)






	local followdeb = false
	local localdeb = false
	AllowFollowsButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(AllowFollowsButton)
		if res == false then return end
		if followdeb == true then
			if localdeb == true then return end
			localdeb = true
			local t = AllowFollowsButton.Slide.displayText.Text
			AllowFollowsButton.Slide.displayText.Text = "On cooldown"
			wait(0.5)
			AllowFollowsButton.Slide.displayText.Text = t
			localdeb = false
			return end

		followdeb = true
		localdeb = false
		if AllowsFollows == true then
			AllowsFollows = false
		else
			AllowsFollows = true
		end

		if AllowsFollows == false then
			AllowFollowsButton.Slide.displayText.Text = "Allow Follows: OFF"
		else
			AllowFollowsButton.Slide.displayText.Text = "Allow Follows: ON"
		end
		local res = MultiverseInvoke:InvokeServer("SetFollowPreference", AllowsFollows)
		wait(10)
		followdeb = false
		localdeb = false
	end)

	ToolsOpen.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(ToolsOpen)
		if res == false then return end
	end)

	CustomizationOpen.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationOpen)
		if res == false then return end
		if OOCToggle then return end
		if CurrentUI == "Customization" then CurrentUI = nil; CustomizationUI.Visible = false; CustomizingEvent:FireServer(false) return end
		BottomBar.Visible = false
		MainUI.GeneralSettings["Toggle Prompts"].Visible = false; --MainUI.GeneralSettings["ToggleVisualizations"].Visible = false
		MainUI.Leaderboard.Visible = false
		CurrentUI  = "Customization"
		CurrentVisuzaliserAsset.Parent = nil
		CustomizationUI.Visible = true
		PropPlacerUI.Visible = false
		VisualizerUI.Visible = false
		CurrentVisuzaliserAsset.Parent = nil
		CustomizingEvent:FireServer(true)
		if lastHandles and #SelectedAccessories > 0 then lastHandles.Visible = true end
	end)

	PropOpen.MouseButton1Down:Connect(function(p)

		local res = TweenButtonClick(PropOpen)

		if res == false then return end
		if OOCToggle then return end
		if OwnsPropPlacer == false then
			PropOpen.Slide.displayText.Text = "Purchase required"
			wait(2)
			PropOpen.Slide.displayText.Text = "Prop Placer"
			return
		end

		if PropPlacerUI.Visible == true then

			PropPlacerUI.Visible = false
			PropPlacer.KillHandles()
			--MainUI.GeneralSettings["Toggle Prompts"].Visible = true
			MainUI.GeneralSettings["ToggleVisualizations"].Visible = true
			MainUI.GeneralSettings["Shop"].Visible = true
			MainUI.GeneralSettings["LeaderboardFilter"].Visible = true
			MainUI.GeneralSettings["AllowFollows"].Visible = true
			MainUI.Leaderboard.Visible = true
			CurrentUI = nil
		else
			MainUI.GeneralSettings["Toggle Prompts"].Visible = false
			MainUI.GeneralSettings["ToggleVisualizations"].Visible = false
			MainUI.GeneralSettings["Shop"].Visible = false
			MainUI.GeneralSettings["LeaderboardFilter"].Visible = false
			MainUI.GeneralSettings["AllowFollows"].Visible = false
			MainUI.Leaderboard.Visible = false
			CustomizationUI.Visible = false
			VisualizerUI.Visible = false
			CurrentVisuzaliserAsset.Parent = nil
			CurrentUI  = "Prop Placer"
			PropPlacerUI.Visible = true	
		end

	end)


	-- Customization Bottom Bar

	CustomizationBottomBar.Color.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationBottomBar.Color)
		if res == false then return end
		if AccessoryColorPane.Visible == true then AccessoryColorPane.Visible = false else AccessoryColorPane.Visible = true end
	end)

	CustomizationBottomBar.WeldPart.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationBottomBar.WeldPart)
		if res == false then return end
		if AccessoryBodyPartPane.Visible == true then AccessoryBodyPartPane.Visible = false else AccessoryBodyPartPane.Visible = true end
	end)

	CustomizationBottomBar.Transform.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationBottomBar.Transform)
		if res == false then return end
		if AccessoryTransformPane.Visible == true then AccessoryTransformPane.Visible = false else AccessoryTransformPane.Visible = true end
	end)

	CustomizationBottomBar.Particles.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationBottomBar.Particles)
		if res == false then return end
		if AccessoryParticlePane.Visible == true then AccessoryParticlePane.Visible = false else AccessoryParticlePane.Visible = true end
	end)

	CustomizationBottomBar.Info.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationBottomBar.Info)
		if res == false then return end
		if CharacterTraitsPane.Visible == true then CharacterTraitsPane.Visible = false else CharacterTraitsPane.Visible = true end
	end)

end


-- Animations

do
	print("Indexing animations.")
	local CurrentAnimation = nil

	local function StopAllAnimations()
		for i, v in pairs(AnimationsTable) do
			v:Stop()
		end
	end


	for i, v in pairs(AnimationsUI.Frame.Bin:GetChildren()) do
		if v:IsA("TextButton") then
			v.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(v)
				if res == false then return end
				if CurrentAnimation == v.Name then
					CurrentAnimation = nil
					StopAllAnimations()
				elseif CurrentAnimation ~= nil then
					StopAllAnimations()
					CurrentAnimation = v.Name
					AnimationsTable[v.Name]:Play()
				elseif CurrentAnimation == nil then
					CurrentAnimation = v.Name
					AnimationsTable[v.Name]:Play()
				end
			end)
		end
	end
end

-- Customization

local ClearAccessoryHistory = function() end

function LoadCharacterSlot(Slot)

	MajorDebounce = true
	IgnoreIncomingAccessory = true
	table.clear(SelectedAccessories)
	local returned = CustomizationInvoke:InvokeServer("Load", Slot)
	if returned == false then ErrorReport("Error while attempting to load character slot. Chances are that there was no slot to load or you have a tool equipped.") return end
	MajorDebounce = false
	CharacterTable = returned
	warn("NEW CHARACTER INFO:", returned)

	RefreshAccessoryList(nil, returned, true)
	wait()
	IgnoreIncomingAccessory = false
	ClearAccessoryHistory()

	UpdateProperties()

	RecalculateAccessories()
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local head = character:FindFirstChild("Head")


	local collisionPart = character:FindFirstChild("CollisionPart", true)
	if collisionPart and collisionPart:IsA("BasePart") then
		collisionPart.Transparency = 1
	end



end

function LoadLegacyCharacterSlot(Slot)

	MajorDebounce = true
	IgnoreIncomingAccessory = true
	local returned = CustomizationInvoke:InvokeServer("LoadLegacy", Slot)
	if returned == false then ErrorReport("Error while attempting to load legacy character slot. Chances are that there was no slot to load.") return end
	MajorDebounce = false
	CharacterTable = returned
	warn("NEW CHARACTER INFO:", returned)

	RefreshAccessoryList(nil, returned, true)
	wait()
	IgnoreIncomingAccessory = false
	ClearAccessoryHistory()

	UpdateProperties()



end

function CreateNewItemPackTable(child)
	print("Creating new item pack table", child)
	local handle = child:WaitForChild("Handle")
	local weld = handle:WaitForChild("AccessoryWeld")
	local TableToReturn = {
		["IsItemPack"] = true,
		["WeaponName"] = child.Name,
		["AccessoryFrame"] = nil,
		["Object"] = child,
		["Name"] = child.Name,
		["AccessoryWeld"] = {["C0"] = handle.CFrame:ToObjectSpace(weld.Part1.CFrame), ["C1"] = CFrame.new(0,0,0)},
		["WeldPart"] = weld.Part1.Name,
		["OriginalC0"] = handle.CFrame:ToObjectSpace(weld.Part1.CFrame),
		["RevertC0"] = handle.CFrame:ToObjectSpace(weld.Part1.CFrame),
		["OriginalC1"] = CFrame.new(0,0,0),
		["DistanceFromOrigin"] = Vector3.new(0,0,0),
		["RotationsApplied"] = Vector3.new(0,0,0),
		["DistanceFromOriginC1"] = Vector3.new(0,0,0),
	}

	local X,Y,Z = TableToReturn.OriginalC0:Inverse():ToEulerAnglesXYZ()

	TableToReturn.RootRotation = Vector3.new(X,Y,Z)
	return TableToReturn
end

function CreateNewAccessoryTable(child)
	wait()
	warn("Creating new accessory table", child)
	local handle = child.Handle
	if handle:FindFirstChildOfClass("Highlight") then handle:FindFirstChildOfClass("Highlight"):Destroy() end
	local mesh
	local attachment = handle:FindFirstChildOfClass("Attachment")
	local weld = handle:FindFirstChildOfClass("Weld")
	local HeadScale = CharacterTable.Scale.Head
	local Width = CharacterTable.Scale.Width
	local Depth = CharacterTable.Scale.Depth
	local Height = CharacterTable.Scale.Height

	local TableToReturn
	if handle:IsA("MeshPart") then -- meshpart
		mesh = handle
		local AccessoryId = child:WaitForChild("AccessoryId", 2)
		if not AccessoryId then warn("CreateNewAccessoryTable : MeshPartFold : ", handle.Name, "is not valid") return end
		AccessoryId = AccessoryId.Value

		TableToReturn = {
			["Object"] = child,
			["AccessoryId"] = AccessoryId,
			["IsMeshPart"] = true,
			["Name"] = child.Name,
			["Material"] = handle.Material,
			["TextureId"] = mesh.TextureID,
			["Color"] = Vector3.new(1,1,1),
			["OColor"] = Color3.new(1,1,1),
			["ColorMode"] = "VertexColor",
			["Transparency"] = handle.Transparency,
			["OTransparency"] = 0.5,
			["Particle"] = "None",
			["ParticleColor"] = Color3.fromRGB(255,255,255),
			["ParticleSize"] = 0,
			["ParticleTransparency"] = 0,
			["ParticleRate"] = 0,

			["OriginalOColor"] = Color3.new(1,1,1),
			["OriginalTransparency"] = handle.Transparency,

			["OriginalTextureId"] = mesh.TextureID,

			["OriginalColor"] = Vector3.new(1,1,1),

			["OriginalMaterial"] = handle.Material


		}
		-- note, i just removed all the useless properties. we have to load these by their Accessory IDs, so.
	else
		repeat task.wait() mesh = handle:FindFirstChildOfClass("SpecialMesh") until mesh

		TableToReturn = {
			["Object"] = child,
			["IsMeshPart"] = false,
			["Name"] = child.Name,
			["MeshId"] = mesh.MeshId,
			["HandleSize"] = handle.Size,
			["TextureId"] = mesh.TextureId,
			["Color"] = mesh.VertexColor,
			["OColor"] = Color3.new(1,1,1),
			["ColorMode"] = "VertexColor",
			["Transparency"] = handle.Transparency,
			["OTransparency"] = 0.5,
			["Material"] = handle.Material,
			["Scale"] = mesh.Scale,
			["Offset"] = mesh.Offset,
			["OriginalSize"] = handle:WaitForChild("OriginalSize").Value,
			["AccessoryWeld"] = {["C0"] = handle.CFrame:ToObjectSpace(weld.Part1.CFrame), ["C1"] = CFrame.new(0,0,0)},
			["DistanceFromOrigin"] = Vector3.new(0,0,0),
			["RotationsApplied"] = Vector3.new(0,0,0),
			["DistanceFromOriginC1"] = Vector3.new(0,0,0),
			["WeldPart"] = weld.Part1.Name,
			["OriginalC0"] = handle.CFrame:ToObjectSpace(weld.Part1.CFrame),
			["RevertC0"] = handle.CFrame:ToObjectSpace(weld.Part1.CFrame),
			["OriginalC1"] = CFrame.new(0,0,0),
			["RevertScale"] = mesh.Scale,
			["RootScale"] = mesh.Scale,
			["Particle"] = "None",
			["ParticleColor"] = Color3.fromRGB(255,255,255),
			["ParticleSize"] = 0,
			["ParticleTransparency"] = 0,
			["ParticleRate"] = 0,
			["OriginalMeshId"] = mesh.MeshId,
			["OriginalTextureId"] = mesh.TextureId,
			["OriginalColor"] = mesh.VertexColor,
			["OriginalOColor"] = Color3.new(1,1,1),
			["OriginalTransparency"] = handle.Transparency,
			["OriginalMaterial"] = handle.Material,
			["OriginalWeldPart"] = weld.Part1.Name,
			["AttachmentForward"] = child.AttachmentForward,
			["AttachmentPos"] = child.AttachmentPos,
			["AttachmentRight"] = child.AttachmentRight,
			["AttachmentUp"] = child.AttachmentUp,
			["Attachment"] = {["Name"] = attachment.Name, ["Axis"] = attachment.Axis, ["SecondaryAxis"] = attachment.SecondaryAxis, ["Orientation"] = attachment.Orientation, ["Position"] = attachment.Position}
		}


		if handle:FindFirstChild("HairAttachment") or handle:FindFirstChild("FaceFrontAttachment") or handle:FindFirstChild("HatAttachment") then
			TableToReturn.RootScale = Vector3.new(TableToReturn.RevertScale.X/HeadScale, TableToReturn.RevertScale.Y/HeadScale, TableToReturn.RevertScale.Z/HeadScale)
		else
			TableToReturn.RootScale = Vector3.new(TableToReturn.RevertScale.X/Width, TableToReturn.RevertScale.Y/Height, TableToReturn.RevertScale.Z/Depth)
		end

		local X,Y,Z = TableToReturn.OriginalC0:Inverse():ToEulerAnglesXYZ()

		TableToReturn.RootRotation = Vector3.new(X,Y,Z)
	end

	--weld.C0 = handle.CFrame:ToObjectSpace(weld.Part1.CFrame)
	--weld.C1 = CFrame.new()



	return TableToReturn


end

-- Top bar

local function CalculateHeight(units)

	units = units+0.1
	print("units", units)

	local totalinches = 60*units
	totalinches = math.round(totalinches)

	print("total inches", totalinches)


	local feet, inches = math.floor((totalinches/12)), (totalinches % 12)
	print("input:", units, "height feet", feet, "inches", inches)
	return feet, inches

end

local function CalculateInches(units)

	units = units+0.1


	local totalinches = 60*units
	totalinches = math.round(totalinches)




	return totalinches

end

-- Empowerment Stuff
do

	local CharacterBin = CharacterInfoPane.Bin
	local EmpowermentSelectionBox = CharacterBin.Powers.EmpowermentSelectionBox
	local EmpowermentInfoBox = CharacterBin.Powers.EmpowermentInformation
	local EmpowermentTypeBox = CharacterBin.Powers.EmpowermentTypeBox
	local EmpowermentCustomEntryBox = CharacterBin.Powers.EmpowermentCustomEntry



	CharacterBin.CharacterInfo.Submit.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CharacterBin.CharacterInfo.Submit)
		if res == false then return end
		if MajorDebounce then return end
		MajorDebounce = true
		local Name = CharacterBin.CharacterInfo.NameText.Text
		local Bio = CharacterBin.CharacterInfo.BioText.Text
		local Image = CharacterBin.CharacterInfo.ImgText.Text
		if tonumber(Image) == nil then Image = 0 end
		local returnedNameBioTable = CustomizationInvoke:InvokeServer("NameBio", {["Name"] = Name, ["Bio"] = Bio, ["Image"] = Image})
		if returnedNameBioTable then
			local f = ReplicatedStorage.Info[Client.Name]
			CharacterBin.CharacterInfo.NameText.Text = f.CName.Value
			CharacterBin.CharacterInfo.BioText.Text = f.CBio.Value
			CharacterTable["CharacterInformation"]["CharacterName"] = f.CName.Value
			CharacterTable["CharacterInformation"]["CharacterBio"] = f.CBio.Value
			if tonumber(Image) ~= nil then CharacterTable["CharacterInformation"]["CharacterImg"] = Image; CharacterBin.CharacterInfo.ImgText.reference.Image = "rbxthumb://type=Asset&id=" .. tostring(Image) .. "&w=420&h=420" end
		else
			ErrorReport("Unable to properly filter the text. The service might be out.")
		end
		wait(0.5)
		MajorDebounce = false
	end)

	for i,v in pairs(EmpowermentTypeBox.Bin:GetChildren()) do
		if v:IsA("TextButton") then
			v.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(v)
				if res == false then return end
				if CurrentEmpowermentSelectionBoxVisible then if CurrentEmpowermentSelectionBoxVisible.Name == v.Name then return end end
				local Box = EmpowermentSelectionBox:FindFirstChild(v.Name)
				if Box then
					Box.Visible = true
					EmpowermentSelectionBox.Visible = true
					CharacterTable["CharacterInformation"].EmpowermentType = v.Name
					if CurrentEmpowermentSelectionBoxVisible then
						CurrentEmpowermentSelectionBoxVisible.Visible = false
						CurrentEmpowermentSelectionBoxVisible = Box
					else
						CurrentEmpowermentSelectionBoxVisible = Box
					end

				end
			end)

		end

	end

	for i, v in pairs(EmpowermentSelectionBox:GetChildren()) do
		for x, Button in pairs(v:GetChildren()) do
			if Button:IsA("TextButton") then
				Button.MouseButton1Down:Connect(function()
					local res = TweenButtonClick(Button)
					if res == false then return end
					if MajorDebounce then return end
					MajorDebounce = true
					if Button.Name ~= "Custom" then
						EmpowermentInfoBox.Visible = true
						EmpowermentCustomEntryBox.Visible = false
						CharacterTable["CharacterInformation"].EmpowermentType = Button.Parent.Name
						CharacterTable["CharacterInformation"]["EmpowermentTitle"] = Button.Name
						CharacterTable["CharacterInformation"]["Empowerment"] = Empowerments[Button.Parent.Name][Button.Name]
						EmpowermentInfoBox.Title.Text = CharacterTable["CharacterInformation"].EmpowermentTitle
						CharacterTable["CharacterInformation"]["IsCustomEmpowerment"] = false
						EmpowermentInfoBox.Description.Text = CharacterTable["CharacterInformation"]["Empowerment"]
						CustomizationInvoke:InvokeServer("Empowerment", {["Type"] = CharacterTable["CharacterInformation"].EmpowermentType, ["Title"] =Button.Name, ["Description"] =CharacterTable["CharacterInformation"]["Empowerment"]}, false)
					else
						if GroupVerification.CheckRank(Client, "Community") == true then ErrorReport("You must be at least tier 1 in the group to use the Custom option.") return end
						CharacterTable["CharacterInformation"]["IsCustomEmpowerment"] = true
						EmpowermentCustomEntryBox.Visible = true
						EmpowermentInfoBox.Visible = false
					end
					wait(0.1)
					MajorDebounce = false
				end)
			end
		end
	end

	EmpowermentCustomEntryBox.Submit.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(EmpowermentCustomEntryBox.Submit)
		if res == false then return end
		if MajorDebounce then return end
		if GroupVerification.CheckRank(Client, "Community") == true then ErrorReport("You must be at least tier 1 in the group to use the Custom option.") return end
		MajorDebounce = true

		local returnedTable = CustomizationInvoke:InvokeServer("Empowerment", {["Type"] = CharacterTable["CharacterInformation"].EmpowermentType,["Title"] = EmpowermentCustomEntryBox.Title.Text,["Description"] =EmpowermentCustomEntryBox.Description.Text}, true)
		if returnedTable then
			CharacterTable["CharacterInformation"].EmpowermentType = returnedTable.Type
			CharacterTable["CharacterInformation"]["EmpowermentTitle"] = returnedTable.Title
			CharacterTable["CharacterInformation"]["Empowerment"] = returnedTable.Description
		else
			ErrorReport("Error filtering text.")
		end
		wait(0.1)
		MajorDebounce = false
	end)
end

-- skills
do
	local CharacterBin = CharacterInfoPane.Bin.Powers

	for si = 1, 5, 1 do -- loop it so we dont have to rewrite code
		local SelectionBox = CharacterBin["SkillSelectionBox" .. tostring(si)]
		local CustomEntryBox = CharacterBin["SkillCustomEntry" .. tostring(si)]
		local TypeBox = CharacterBin["SkillBox" .. tostring(si)]
		local InfoBox = CharacterBin["SkillInformation" .. tostring(si)]

		for i,v in pairs(TypeBox.Bin:GetChildren()) do -- skill type box so combat or lifestyle
			if v:IsA("TextButton") then
				v.MouseButton1Down:Connect(function()
					local res = TweenButtonClick(v)
					if res == false then return end
					if CurrentSkillSelectionBoxes[si] ~= false then if CurrentSkillSelectionBoxes[si].Name == v.Name then return end end
					if si > 3 and GroupVerification.CheckRank(Client, "Community") == true then ErrorReport("You have to be at least Tier 1 to use more than 3 skills.") return end
					local Box = SelectionBox:FindFirstChild(v.Name)
					if Box then
						Box.Visible = true
						SelectionBox.Visible = true
						CharacterTable["CharacterInformation"].Skills[si].Type = v.Name
						CharacterTable["CharacterInformation"].Skills[si].Title = ""
						CharacterTable["CharacterInformation"].Skills[si].Skill = ""
						if CurrentSkillSelectionBoxes[si] ~= false then
							CurrentSkillSelectionBoxes[si].Visible = false
							CurrentSkillSelectionBoxes[si] = Box
						else
							CurrentSkillSelectionBoxes[si] = Box
						end

					end
				end)

			end
		end

		for i, v in pairs(SelectionBox:GetChildren()) do -- options
			for x, Button in pairs(v:GetChildren()) do
				if Button:IsA("TextButton") then
					Button.MouseButton1Down:Connect(function()
						local res = TweenButtonClick(Button)
						if res == false then return end
						if MajorDebounce then return end
						if si > 3 and GroupVerification.CheckRank(Client, "Community") == true then ErrorReport("You have to be at least Tier 1 to use more than 3 skills.") return end
						MajorDebounce = true
						if Button.Name ~= "Custom" then
							InfoBox.Visible = true
							CustomEntryBox.Visible = false
							CharacterTable["CharacterInformation"].Skills[si].Type = Button.Parent.Name
							CharacterTable["CharacterInformation"].Skills[si].Title = Button.Name
							CharacterTable["CharacterInformation"].Skills[si].Skill = Skills[Button.Parent.Name][Button.Name]
							InfoBox.Title.Text = CharacterTable["CharacterInformation"].Skills[si].Title
							CharacterTable["CharacterInformation"].Skills[si].IsCustomSkill = false
							InfoBox.Description.Text = CharacterTable["CharacterInformation"].Skills[si].Skill
							CustomizationInvoke:InvokeServer("Skill", {["Type"] = CharacterTable["CharacterInformation"].Skills[si].Type, ["Title"] =Button.Name, ["Description"] =CharacterTable["CharacterInformation"].Skills[si].Skill}, false, si)
						else
							if GroupVerification.CheckRank(Client, "Community") == true then ErrorReport("You must be at least tier 1 in the group to use the Custom option.") return end
							CharacterTable["CharacterInformation"].Skills[si]["IsCustomSkill"] = true
							CustomEntryBox.Visible = true
							InfoBox.Visible = false
						end
						wait(0.1)
						MajorDebounce = false
					end)
				end
			end
		end

		CustomEntryBox.Submit.MouseButton1Down:Connect(function()
			local res = TweenButtonClick(CustomEntryBox.Submit)
			if res == false then return end
			if MajorDebounce then return end
			if GroupVerification.CheckRank(Client, "Community") == true then ErrorReport("You must be at least tier 1 in the group to use the Custom option.") return end
			MajorDebounce = true

			local returnedTable = CustomizationInvoke:InvokeServer("Skill", {["Type"] = CharacterTable["CharacterInformation"].Skills[si].Type,["Title"] = CustomEntryBox.Title.Text,["Description"] =CustomEntryBox.Description.Text}, true, si)
			if returnedTable then
				CharacterTable["CharacterInformation"].Skills[si].Type = returnedTable.Type
				CharacterTable["CharacterInformation"].Skills[si].Title = returnedTable.Title
				CharacterTable["CharacterInformation"].Skills[si].Skill = returnedTable.Description
			else
				ErrorReport("Error filtering text.")
			end
			wait(0.1)
			MajorDebounce = false
		end)

	end
end
-- Customization room initilizingignnign

CustomizationUI.CustomizationRoom.MouseButton1Down:Connect(function()
	local res = TweenButtonClick(CustomizationUI.CustomizationRoom)
	if res == false then return end
	CustomizationUI.loading.Visible = true
	local join = MultiverseInvoke:InvokeServer("JoinNewServer", CustomizationRoomPlaceId, nil, CurrentSlot)
end)

CustomizationUI.BioButton.MouseButton1Down:Connect(function()
	local res = TweenButtonClick(CustomizationUI.BioButton)
	if res == false then return end
	CharacterInfoPane.Visible = not CharacterInfoPane.Visible
end)

-- Shirts and pants

do
	print("Indexing the shirt and pants section")
	if CharacterTable["ShirtTemplate"] == nil then CharacterTable["ShirtTemplate"] = "" end
	if CharacterTable["PantsTemplate"] == nil then CharacterTable["PantsTemplate"] = "" end
	if CharacterTable["FaceID"] == nil then CharacterTable["FaceID"] = "" end

	local ShirtBox = CustomizationUI.TraitsBox.Bin.Clothing.ShirtText
	local PantsBox = CustomizationUI.TraitsBox.Bin.Clothing.PantsText
	local FaceBox = CustomizationUI.TraitsBox.Bin.Clothing.FaceText

	ShirtBox.Text = CharacterTable["ShirtTemplate"]:match("%d+") or ""
	PantsBox.Text = CharacterTable["PantsTemplate"]:match("%d+") or ""
	FaceBox.Text = CharacterTable["FaceID"]:match("%d+") or ""

	ShirtBox.FocusLost:Connect(function(enterPressed)
		if enterPressed == false then return end
		if MajorDebounce == true then return end
		MajorDebounce = true
		local ID = ShirtBox.Text
		if tonumber(ID) == nil then ErrorReport("Please enter a valid number for the ID.") return end
		local result = CustomizationInvoke:InvokeServer("Shirt", ID, CharacterTable)
		if result == false then ErrorReport("Eror while attempting to update shirt. Did you make sure the ID is correct?") return end
		CharacterTable["ShirtTemplate"] = result
		CharacterTable["ShirtTemplateDisplay"] = ID
		wait(1)
		MajorDebounce = false
	end)

	PantsBox.FocusLost:Connect(function(enterPressed)
		if enterPressed == false then return end
		if MajorDebounce == true then return end
		MajorDebounce = true
		local ID = PantsBox.Text
		if tonumber(ID) == nil then ErrorReport("Please enter a valid number for the ID.") return end
		local result = CustomizationInvoke:InvokeServer("Pants", ID, CharacterTable)
		if result == false then ErrorReport("Eror while attempting to update pants. Did you make sure the ID is correct?") return end
		CharacterTable["PantsTemplate"] = result
		CharacterTable["PantsTemplateDisplay"] = ID
		wait(1)
		MajorDebounce = false
	end)

	FaceBox.FocusLost:Connect(function(enterPressed)
		if enterPressed == false then return end
		if MajorDebounce == true then return end
		MajorDebounce = true
		local ID = FaceBox.Text
		if tonumber(ID) == nil then ErrorReport("Please enter a valid number for the ID.") return end
		local result = CustomizationInvoke:InvokeServer("Face", ID)
		if result == false then ErrorReport("Eror while attempting to update face. Did you make sure the ID is correct?") return end
		CharacterTable["FaceID"] = result
		wait(1)
		MajorDebounce = false
	end)
end

-- Body Coloring / Limb coloring

do
	print("Indexing the skin color section")
	local CurrentColor = nil

	local CurrentSelected = nil
	local CurrentSelectedName = nil

	local BodyColorModule = require(script.BodyColor)
	local BodyColorUI = BodyColorModule.New(CustomizationUI, Client:GetMouse())
	local BodyColorWindow = BodyColorUI.Window
	BodyColorWindow.Visible = false

	BodyColorUI.Finished:Connect(function(color)
		if MajorDebounce then return end
		MajorDebounce = true
		local returned = CustomizationInvoke:InvokeServer("Color", CurrentSelectedName, color)

		if CurrentSelectedName ~= "All" then
			CharacterTable["BodyColors"][CurrentSelectedName]["R"] = returned.R
			CharacterTable["BodyColors"][CurrentSelectedName]["G"] = returned.G
			CharacterTable["BodyColors"][CurrentSelectedName]["B"] = returned.B
			CurrentSelected.BackgroundColor3 = returned

		else
			CharacterTable["BodyColors"]["Head"]["R"] = returned.R
			CharacterTable["BodyColors"]["Head"]["G"] = returned.G
			CharacterTable["BodyColors"]["Head"]["B"] = returned.B

			CharacterTable["BodyColors"]["Torso"]["R"] = returned.R
			CharacterTable["BodyColors"]["Torso"]["G"] = returned.G
			CharacterTable["BodyColors"]["Torso"]["B"] = returned.B

			CharacterTable["BodyColors"]["LeftArm"]["R"] = returned.R
			CharacterTable["BodyColors"]["LeftArm"]["G"] = returned.G
			CharacterTable["BodyColors"]["LeftArm"]["B"] = returned.B

			CharacterTable["BodyColors"]["LeftLeg"]["R"] = returned.R
			CharacterTable["BodyColors"]["LeftLeg"]["G"] = returned.G
			CharacterTable["BodyColors"]["LeftLeg"]["B"] = returned.B

			CharacterTable["BodyColors"]["RightArm"]["R"] = returned.R
			CharacterTable["BodyColors"]["RightArm"]["G"] = returned.G
			CharacterTable["BodyColors"]["RightArm"]["B"] = returned.B

			CharacterTable["BodyColors"]["RightLeg"]["R"] = returned.R
			CharacterTable["BodyColors"]["RightLeg"]["G"] = returned.G
			CharacterTable["BodyColors"]["RightLeg"]["B"] = returned.B

			for i, v in pairs(tbOfButtons) do
				v.BackgroundColor3 = returned
			end
		end

		wait()
		MajorDebounce = false
	end)

	BodyColorWindow.Close.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(BodyColorWindow.Close)
		if not res then return end
		BodyColorWindow.Visible = false
		CurrentSelected = nil
		CurrentSelectedName = nil
	end)

	for i, v in pairs(CustomizationUI.TraitsBox.Bin.LimbColor:GetChildren()) do -- 
		if v.Name:sub(1,5) == "Color" then
			table.insert(tbOfButtons, v)
		end
	end

	for i, v in pairs(tbOfButtons) do

		if v.Name ~= "ColorAll" then
			local temp = v.Name:sub(6,#v.Name)
			print(temp)
			v.BackgroundColor3 = Color3.new(CharacterTable["BodyColors"][temp]["R"], CharacterTable["BodyColors"][temp]["G"], CharacterTable["BodyColors"][temp]["B"])
		end
		v.MouseButton1Click:Connect(function()
			if CurrentSelected == v then return end
			CurrentSelected = v
			CurrentSelectedName = v.Name:sub(6,#v.Name)
			BodyColorWindow.Visible = true
			BodyColorUI:SetColor(v.BackgroundColor3)
		end)
	end

end





local HeightFeetBox, HeightInchesBox = CustomizationUI.TraitsBox.Bin.BodyScales.HeightFeet, CustomizationUI.TraitsBox.Bin.BodyScales.HeightInches
local WidthBox, DepthBox, HeadBox = CustomizationUI.TraitsBox.Bin.BodyScales.WidthValue, CustomizationUI.TraitsBox.Bin.BodyScales.DepthValue, CustomizationUI.TraitsBox.Bin.BodyScales.HeadValue
local ProportionalizeButton = CustomizationUI.TraitsBox.Bin.BodyScales.Proportionalize


local feet, inches = CalculateHeight(CharacterTable["Scale"]["Height"])

HeightFeetBox.Text = tostring(feet)
HeightInchesBox.Text = tostring(inches)
WidthBox.Text = tostring(CalculateInches(CharacterTable["Scale"]["Width"]))
DepthBox.Text = tostring(CalculateInches(CharacterTable["Scale"]["Depth"]))
HeadBox.Text = tostring(CalculateInches(CharacterTable["Scale"]["Head"]))

local LastHeightFeet = feet
local LastHeightInches = inches
local LastWidth = CalculateInches(CharacterTable["Scale"]["Width"])
local LastDepth = CalculateInches(CharacterTable["Scale"]["Depth"])
local LastHead = CalculateInches(CharacterTable["Scale"]["Head"])

local function HeightEntry(enter)
	if enter then
		if MajorDebounce == true then return end
		MajorDebounce = true
		local feet, inches = tonumber(HeightFeetBox.Text), tonumber(HeightInchesBox.Text)

		if feet == nil or inches == nil then
			ErrorReport("Either height feet or inches values are invalid.")
			return
		end

		feet, inches = math.round(math.clamp(feet,1,MaxHeight)), math.round(math.clamp(inches, 0,11))

		if not OwnsBetterCustomizationGamepass and feet == 6 then
			inches = math.round(math.clamp(inches, 0,5))
		end

		HeightFeetBox.Text = tostring(feet)
		HeightInchesBox.Text = tostring(inches)

		local TotalInches = math.round((feet*12)+inches)

		local Units = round(((1/60)*TotalInches)-0.1)

		if feet == LastHeightFeet and inches == LastHeightInches then MajorDebounce = false return end



		local returned = CustomizationInvoke:InvokeServer("Height", Units, CharacterTable)

		--UpdateAllAccessoriesInfo()



		if returned ==  false then ErrorReport("Error while attempting to update height.") return end
		wait(0.5)
		LastHeightFeet = feet
		LastHeightInches = inches
		CharacterTable.Scale.Height = returned.Scale.Height
		FixRevertScaleForAllAccessories(returned)
		RecalculateAccessories()

		CharacterTable["Scale"]["Height"] = Character.Humanoid.BodyHeightScale.Value
		MajorDebounce = false
	end
end

HeightFeetBox.FocusLost:Connect(HeightEntry)
HeightInchesBox.FocusLost:Connect(HeightEntry)


local function BoxEntry(enter)
	if enter then
		if MajorDebounce == true then return end
		MajorDebounce = true
		local WidthInches, DepthInches, HeadInches = tonumber(WidthBox.Text), tostring(DepthBox.Text), tostring(HeadBox.Text)

		if WidthInches== nil or DepthInches == nil or HeadInches == nil then ErrorReport("Either Width, Depth, or the head values are invalid.") return end

		WidthInches, DepthInches, HeadInches = math.round(math.clamp(WidthInches, 0,MaxInches)), math.round(math.clamp(DepthInches, 0,MaxInches)), math.round(math.clamp(HeadInches, 0,MaxInches))

		WidthBox.Text = tostring(WidthInches)
		DepthBox.Text = tostring(DepthInches)
		HeadBox.Text = tostring(HeadInches)

		local Widthv, Depthv, Headv = round(((1/60)*WidthInches)-0.1), round(((1/60)*DepthInches)-0.1), round(((1/60)*HeadInches)-0.1)

		if LastWidth == WidthInches and LastDepth == DepthInches and LastHead == HeadInches then MajorDebounce = false return end

		local returned = CustomizationInvoke:InvokeServer("Body", Widthv, Depthv, Headv, CharacterTable)

		--UpdateAllAccessoriesInfo()



		if returned == false then ErrorReport("Error while attempting to update Width, Depth, or Head.") return end
		wait(1)
		CharacterTable.Scale.Width = Widthv
		CharacterTable.Scale.Depth = Depthv
		CharacterTable.Scale.Head = Headv

		LastWidth = WidthInches
		LastHead = HeadInches
		LastDepth = DepthInches
		FixRevertScaleForAllAccessories(returned)
		RecalculateAccessories()
		UpdateProperties()
		MajorDebounce = false
	end
end

WidthBox.FocusLost:Connect(BoxEntry)
DepthBox.FocusLost:Connect(BoxEntry)
HeadBox.FocusLost:Connect(BoxEntry)

ProportionalizeButton.MouseButton1Down:Connect(function()
	local res = TweenButtonClick(ProportionalizeButton)
	if res == false then return end
	if MajorDebounce == true then return end
	MajorDebounce = true

	local returned = CustomizationInvoke:InvokeServer("Proportionalize", CharacterTable)

	--UpdateAllAccessoriesInfo()



	if returned == false then ErrorReport("Error while attempting to proportionalize avatar.") return end
	wait(0.5)
	CharacterTable.Scale.Head = returned.Scale.Head
	CharacterTable.Scale.Height = returned.Scale.Height
	CharacterTable.Scale.Width = returned.Scale.Width
	CharacterTable.Scale.Depth = returned.Scale.Depth
	FixRevertScaleForAllAccessories(returned)
	RecalculateAccessories()
	UpdateProperties()

	MajorDebounce = false
end)


-- Animations

do
	print("Indexing the aniimations section (customization)")
	local IdleBox, WalkBox, RunBox = CustomizationUI.TraitsBox.Bin.Animations.IdleAnimation, CustomizationUI.TraitsBox.Bin.Animations.WalkAnimation, CustomizationUI.TraitsBox.Bin.Animations.RunAnimation

	IdleBox.Text = tostring(Character.Humanoid.HumanoidDescription.IdleAnimation)
	WalkBox.Text = tostring(Character.Humanoid.HumanoidDescription.WalkAnimation)
	RunBox.Text = tostring(Character.Humanoid.HumanoidDescription.RunAnimation)

	local function AnimationEntry(enter)
		if not enter then return end
		if MajorDebounce then return end
		MajorDebounce = true

		local IdleID, WalkID, RunID = tonumber(IdleBox.Text), tonumber(WalkBox.Text), tonumber(RunBox.Text)

		if IdleID == nil or WalkID == nil or RunID == nil then ErrorReport("One or multiple animation IDs are invalid.") return end



		local returned = CustomizationInvoke:InvokeServer("Animations", IdleID, WalkID, RunID, CharacterTable)
		if returned == false then ErrorReport("Error while attempting to update animation ID") return end
		wait(1)
		CharacterTable.Animations.IdleAnimation = returned.Animations.IdleAnimation
		CharacterTable.Animations.RunAnimation = returned.Animations.RunAnimation
		CharacterTable.Animations.WalkAnimation = returned.Animations.WalkAnimation
		FixRevertScaleForAllAccessories(returned)
		RecalculateAccessories()
		MajorDebounce = false
	end


	IdleBox.FocusLost:Connect(AnimationEntry)
	WalkBox.FocusLost:Connect(AnimationEntry)
	RunBox.FocusLost:Connect(AnimationEntry)
end

-- Limb remover

do
	print("Indexing the limb remover")
	local Bin = CustomizationUI.TraitsBox.Bin.LimbVisibility

	for i, v in pairs(Bin:GetChildren()) do
		if v.Name ~= "misc" and v:IsA("TextButton") then

			v.MouseButton1Click:Connect(function()
				if MajorDebounce == true then return end
				MajorDebounce = true
				if CharacterTable["LimbRemover"][v.Name] == nil then
					CharacterTable["LimbRemover"][v.Name] = true
					local returned = CustomizationInvoke:InvokeServer("LimbRemover", v.Name, 1)
					v.BackgroundColor3 = Color3.new(0,1,0)
				else
					CharacterTable["LimbRemover"][v.Name] = nil
					local returned = CustomizationInvoke:InvokeServer("LimbRemover", v.Name, 0)
					v.BackgroundColor3 = Color3.fromRGB(33, 28, 59)
				end

				wait(0.1)
				MajorDebounce = false
			end)


		end
	end

end

-- Accessories tag



local function UpdateAccessoryTables(Property : string, Value : any, UpdateOverlayContextual : boolean)
	warn("Updating Selected Accessories")
	for i, tableAssociated in ipairs(SelectedAccessories) do
		if tableAssociated[Property] then -- making sure its valid
			if Property == "OColor" and UpdateOverlayContextual then
				if tableAssociated.IsMeshPart then
					tableAssociated[Property] = Value
				else
					if tableAssociated.ColorMode == "Overlay" then
						tableAssociated[Property] = Value
					end
				end
			elseif Property == "Color" and UpdateOverlayContextual then
				if tableAssociated.IsMeshPart then
					tableAssociated[Property] = Value
				else
					if tableAssociated.ColorMode == "VertexColor" then
						tableAssociated[Property] = Value
					end
				end
			else
				tableAssociated[Property] = Value
			end

		end

	end
end

local AccessoryUndoStack = {}
local AccessoryRedoStack = {}
local PendingAccessoryHistorySnapshot = nil
local IsApplyingAccessoryHistory = false
local AccessoryUndoButton = nil
local AccessoryRedoButton = nil

local function SetHistoryButtonText(button, text)
	if button and button:FindFirstChild("Slide") and button.Slide:FindFirstChild("displayText") then
		button.Slide.displayText.Text = text
		button.Text = ""
	elseif button then
		button.Text = text
	end
end

local function NormalizeHistoryButton(button)
	if not button then return end
	button.ClipsDescendants = true
	if button:FindFirstChild("Slide") then
		button.Slide.Position = UDim2.new(0, 0, -0.1, 0)
		button.Slide.ClipsDescendants = true
	end
end

local function UpdateAccessoryHistoryButtons()
	SetHistoryButtonText(AccessoryUndoButton, "Undo (" .. tostring(#AccessoryUndoStack) .. ")")
	SetHistoryButtonText(AccessoryRedoButton, "Redo (" .. tostring(#AccessoryRedoStack) .. ")")
end

local function CreateAccessoryHistorySnapshot()
	local snapshot = deepCopy(CharacterTable)
	for i, accessoryTable in pairs(snapshot.Accessories or {}) do
		accessoryTable.Object = nil
		accessoryTable.AccessoryFrame = nil
	end
	return snapshot
end

local function CreateAccessorySelectionSnapshot()
	local selectedIndices = {}
	for i, accessoryTable in ipairs(CharacterTable.Accessories or {}) do
		for _, selectedAccessory in ipairs(SelectedAccessories) do
			if selectedAccessory == accessoryTable or selectedAccessory.Object == accessoryTable.Object then
				table.insert(selectedIndices, i)
				break
			end
		end
	end
	return selectedIndices
end

local function RestoreAccessorySelection(selectedIndices)
	table.clear(SelectedAccessories)

	local framesToSelect = {}
	for _, accessoryIndex in ipairs(selectedIndices or {}) do
		local accessoryTable = CharacterTable.Accessories and CharacterTable.Accessories[accessoryIndex]
		if accessoryTable and accessoryTable.AccessoryFrame and accessoryTable.AccessoryFrame:FindFirstChild("AccessorySelected") then
			table.insert(framesToSelect, accessoryTable.AccessoryFrame)
		elseif accessoryTable then
			table.insert(SelectedAccessories, accessoryTable)
		end
	end

	local restoreSelectionEvent = AccessoriesBin.SelectionManagement:FindFirstChild("RestoreSelection")
	if restoreSelectionEvent then
		restoreSelectionEvent:Fire(framesToSelect)
	else
		if #SelectedAccessories == 0 then
			MainUI.NoMoreSelected:Fire("none")
		else
			MainUI.NoMoreSelected:Fire("some")
		end
	end
end

local function PushAccessoryHistory(beforeSnapshot, beforeSelection, afterSnapshot, afterSelection)
	if IsApplyingAccessoryHistory or not beforeSnapshot or not afterSnapshot then return end
	table.insert(AccessoryUndoStack, {
		Before = beforeSnapshot,
		BeforeSelection = beforeSelection or {},
		After = afterSnapshot,
		AfterSelection = afterSelection or {},
	})
	if #AccessoryUndoStack > Constants.AccessoryHistoryLimit then
		table.remove(AccessoryUndoStack, 1)
	end
	table.clear(AccessoryRedoStack)
	UpdateAccessoryHistoryButtons()
end

local function BeginAccessoryHistory()
	if IsApplyingAccessoryHistory then return end
	PendingAccessoryHistorySnapshot = {
		Snapshot = CreateAccessoryHistorySnapshot(),
		Selection = CreateAccessorySelectionSnapshot(),
	}
end

local function CommitAccessoryHistory()
	if IsApplyingAccessoryHistory then return end
	local beforeHistory = PendingAccessoryHistorySnapshot
	PendingAccessoryHistorySnapshot = nil
	if not beforeHistory then return end
	PushAccessoryHistory(
		beforeHistory.Snapshot,
		beforeHistory.Selection,
		CreateAccessoryHistorySnapshot(),
		CreateAccessorySelectionSnapshot()
	)
end

local function CancelAccessoryHistory()
	PendingAccessoryHistorySnapshot = nil
end

function ClearAccessoryHistory()
	PendingAccessoryHistorySnapshot = nil
	table.clear(AccessoryUndoStack)
	table.clear(AccessoryRedoStack)
	UpdateAccessoryHistoryButtons()
end

local function ApplyAccessoryHistorySnapshot(snapshot, selectedIndices)
	if MajorDebounce or IsApplyingAccessoryHistory then return false end
	IsApplyingAccessoryHistory = true
	MajorDebounce = true
	IgnoreIncomingAccessory = true
	local restoreData = CreateAccessoryHistorySnapshot()
	restoreData.Accessories = deepCopy(snapshot.Accessories or {})
	local returned = CustomizationInvoke:InvokeServer("RestoreAccessoryHistory", restoreData)
	if returned == false then
		IgnoreIncomingAccessory = false
		MajorDebounce = false
		IsApplyingAccessoryHistory = false
		ErrorReport("Error while attempting to restore accessory history.")
		return false
	end
	table.clear(SelectedAccessories)
	RefreshAccessoryList(nil, returned, true)
	task.wait()
	RestoreAccessorySelection(selectedIndices)
	UpdateProperties()
	IgnoreIncomingAccessory = false
	MajorDebounce = false
	IsApplyingAccessoryHistory = false
	return true
end

function UndoAccessoryChange()
	local entry = table.remove(AccessoryUndoStack)
	if not entry then return false end
	if ApplyAccessoryHistorySnapshot(entry.Before, entry.BeforeSelection) then
		table.insert(AccessoryRedoStack, entry)
		UpdateAccessoryHistoryButtons()
		return true
	end
	table.insert(AccessoryUndoStack, entry)
	UpdateAccessoryHistoryButtons()
	return false
end

function RedoAccessoryChange()
	local entry = table.remove(AccessoryRedoStack)
	if not entry then return false end
	if ApplyAccessoryHistorySnapshot(entry.After, entry.AfterSelection) then
		table.insert(AccessoryUndoStack, entry)
		UpdateAccessoryHistoryButtons()
		return true
	end
	table.insert(AccessoryRedoStack, entry)
	UpdateAccessoryHistoryButtons()
	return false
end

function ErrorReport(Text)
	MajorDebounce = true
	CustomizationUI.Error.Text = Text
	CustomizationUI.Error.Visible = true
	wait(5)
	CustomizationUI.Error.Visible = false
	MajorDebounce = false
	DSDebounce = false
end





-- Create new Accessory

CustomizationUI.AccessoriesBox.NewAccessory.FocusLost:Connect(function(enter)
	if not enter then return end
	if MajorDebounce then return end
	if not tonumber(CustomizationUI.AccessoriesBox.NewAccessory.Text) then return end
	if CountAccessories() > MaxAccessories then ErrorReport("Maximum Accessories reached. Buy the gamepass for more if you haven't already.") return end
	MajorDebounce = true
	BeginAccessoryHistory()
	local id = tonumber(CustomizationUI.AccessoriesBox.NewAccessory.Text)
	local returned = CustomizationInvoke:InvokeServer("AddAccessory", id)
	if returned == false then CancelAccessoryHistory(); ErrorReport("Error while attempting to create new accessory. Make sure the ID is correct.") return end
	wait(0.5)
	CommitAccessoryHistory()
	MajorDebounce = false
end)

-- create blank accessory

CustomizationUI.AccessoriesBox.BlankAccessory.MouseButton1Down:Connect(function()
	local res = TweenButtonClick(CustomizationUI.AccessoriesBox.BlankAccessory)
	if res == false then return end
	if CountAccessories() > MaxAccessories then ErrorReport("Maximum Accessories reached. Buy the gamepass for more if you haven't already.") return end
	MajorDebounce = true
	BeginAccessoryHistory()
	local id = 7375353949
	local returned = CustomizationInvoke:InvokeServer("BlankAccessory", id)
	if returned == false then CancelAccessoryHistory(); ErrorReport("Error while attempting to create new accessory.") return end
	wait(0.5)
	CommitAccessoryHistory()
	MajorDebounce = false
end)


-- Color

local CurrentColor = nil

local ColorModule = require(script.Color)

local ColorUI = ColorModule.New(AccessoryColorPane, Client:GetMouse())

local ParticleColorModule = require(script.ParticleColor)
local PColorUI = ParticleColorModule.New(AccessoryParticlePane.ColorFrame, Client:GetMouse())
-- NOTE ^ WE USE THIS LATER IN PARTICLES IT JUST HAS TO BE HERE BECAUSE OF UpdateProperties() SO IT CAN REFERENCE IT

ColorUI.Finished:Connect(function(color)
	if MajorDebounce then return end
	if not (#SelectedAccessories > 0) then ErrorReport("Please select an Accessory to edit.") return end
	MajorDebounce = true
	BeginAccessoryHistory()
	local result = CustomizationInvoke:InvokeServer("AColor", SelectedAccessories, color)
	if result then
		UpdateAccessoryTables("Color", result, true)
		result = Color3.new(result.X, result.Y, result.Z)
		UpdateAccessoryTables("OColor", result, true)
		CommitAccessoryHistory()
	else
		CancelAccessoryHistory()
	end
	wait()
	MajorDebounce = false
end)

-- Texture

local TbOfTextureIds = {
	["Alluminium"] = 10140766535,
	["Brick"] = 10140767517,
	["Cobblestone"] =  10140768548,
	["Concrete"] = 10140769179,
	["Plate"] = 10140769646,
	["Fabric"] = 10140770033,
	["Glass"] = 10140770392,
	["Granite"] = 10140770916,
	["Grass"] = 10140771748,
	["Ice"] = 10140772545,
	["Marble"] = 10140773149,
	["Metal"] = 10140773736,
	["Pebble"] = 10140774358,
	["Plastic"] = 10140774759,
	["Rust"] = 10140775547,
	["Sand"] = 10140775880,
	["Slate"] = 10140776311,
	["Wood"] =10140777242,
	["Planks"] = 10140778035,
}

AccessoryColorPane.TextureBox.InsertTexture.FocusLost:Connect(function(enterPressed)
	if not enterPressed then return end
	if MajorDebounce then return end
	if not (#SelectedAccessories > 0) then ErrorReport("Please select an Accessory to edit.") return end
	if tonumber(AccessoryColorPane.TextureBox.InsertTexture.Text) == nil then ErrorReport("Error while attempting to parse custom TextureId. Make sure you put in a valid number.") return end
	MajorDebounce = true
	local tripped = false
	for i, v in pairs(SelectedAccessories) do
		if v.IsMeshPart then tripped = true end
	end
	local value = tonumber(AccessoryColorPane.TextureBox.InsertTexture.Text)
	BeginAccessoryHistory()
	local returned = CustomizationInvoke:InvokeServer("Texture", SelectedAccessories, value)
	if returned == false then CancelAccessoryHistory(); ErrorReport("Error while attempting to update Texture Id. Make sure it's valid and has no letters.") return end
	UpdateAccessoryTables("TextureId", returned)
	CommitAccessoryHistory()
	wait()
	MajorDebounce = false
	if tripped then ErrorReport("Texturing Layered Clothing isn't supported yet, but Texture was applied to other acecssories (if any)") end
end)

for i, Button in pairs(AccessoryColorPane.TextureBox.Presets:GetChildren()) do
	if Button:IsA("TextButton") then
		Button.MouseButton1Down:Connect(function()
			local res = TweenButtonClick(Button)
			if not res then return end
			if MajorDebounce then return end
			if not (#SelectedAccessories > 0) then ErrorReport("Please select an Accessory to edit.") return end
			MajorDebounce = true
			local Value = TbOfTextureIds[Button.Name]
			BeginAccessoryHistory()
			local returned = CustomizationInvoke:InvokeServer("Texture", SelectedAccessories, Value)
			if returned == false then CancelAccessoryHistory(); ErrorReport("Error while attempting to update Texture Id with Preset.") return end
			UpdateProperties()
			UpdateAccessoryTables("TextureId", returned)
			CommitAccessoryHistory()
			wait()
			MajorDebounce = false
		end)
	end
end

-- transparency
--print(ColorUI.Window)

local AccessoryTransparencyFrame = ColorUI.Window.Properties.TransparencyFrame.Selection.Frame
local OverlayTransparencyFrame = ColorUI.Window.Properties.TransparencyFrame["Selection 2"].Frame
local OverlayFrame = ColorUI.Window.Properties.Overlay

AccessoryTransparencyFrame.TextBox.FocusLost:Connect(function(enterPressed)
	if not enterPressed then return end
	if MajorDebounce then return end
	if not (#SelectedAccessories > 0) then ErrorReport("Please select an Accessory to edit.") return end
	if tonumber(AccessoryTransparencyFrame.TextBox.Text) == nil then ErrorReport("Error while attempting to parse Transparency value. Make sure you put in a valid number.") return end
	MajorDebounce = true
	local value = math.clamp(tonumber(ColorUI.Window.Properties.TransparencyFrame.Selection.Frame.TextBox.Text), 0,1)
	BeginAccessoryHistory()
	local returned = CustomizationInvoke:InvokeServer("ATransparency", SelectedAccessories, value)
	if returned == false then CancelAccessoryHistory(); ErrorReport("Error while attempting to update Transparency.") return end
	UpdateAccessoryTables("Transparency", returned)
	AccessoryTransparencyFrame.TextBox.Text = tostring(value)
	CommitAccessoryHistory()
	wait()
	MajorDebounce = false
end)

OverlayTransparencyFrame.TextBox.FocusLost:Connect(function(enterPressed)
	if not enterPressed then return end
	if MajorDebounce then return end
	if not (#SelectedAccessories > 0) then ErrorReport("Please select an Accessory to edit.") return end
	if tonumber(OverlayTransparencyFrame.TextBox.Text) == nil then ErrorReport("Error while attempting to parse Transparency value. Make sure you put in a valid number.") return end
	MajorDebounce = true
	local value = math.clamp(tonumber(OverlayTransparencyFrame.TextBox.Text), 0,1)
	BeginAccessoryHistory()
	local returned = CustomizationInvoke:InvokeServer("OTransparency", SelectedAccessories, value)
	if returned == false then CancelAccessoryHistory(); ErrorReport("Error while attempting to update Transparency.") return end
	UpdateAccessoryTables("OTransparency", value)
	UpdateProperties()
	OverlayTransparencyFrame.TextBox.Text = tostring(value)
	CommitAccessoryHistory()

	wait()
	MajorDebounce = false
end)

OverlayFrame.Check.MouseButton1Click:Connect(function()
	if MajorDebounce then return end
	MajorDebounce = true
	BeginAccessoryHistory()
	if OverlayFrame.Check.Text == "X" then
		local returned = CustomizationInvoke:InvokeServer("OToggle", SelectedAccessories, "VertexColor")
		if returned == false then CancelAccessoryHistory(); ErrorReport("Error while attempting to update Overlay mode.") return end
		UpdateAccessoryTables("ColorMode", "VertexColor")
		OverlayFrame.Check.Text = ""
		CommitAccessoryHistory()
		task.wait(0.1)
		MajorDebounce = false
	elseif OverlayFrame.Check.Text == "-" or OverlayFrame.Check.Text == "" then
		local returned = CustomizationInvoke:InvokeServer("OToggle", SelectedAccessories, "Overlay")
		if returned == false then CancelAccessoryHistory(); ErrorReport("Error while attempting to update Overlay mode.") return end
		UpdateAccessoryTables("ColorMode", "Overlay")
		OverlayFrame.Check.Text = "X"
		CommitAccessoryHistory()
		task.wait(0.1)
		MajorDebounce = false
	else
		CancelAccessoryHistory()
	end
	UpdateProperties()
end)




-- meshes

do

	local TbOfMeshIds = {
		["Cube"] = 7375353949,
		["Cone"] = 10150044410,
		["Sphere"] = 439283829,
		["Cylinder"] = 10150012359,
		["Wedge"] = 10160304868,
	}

	local Options = AccessoryColorPane.TextureBox

	Options.Swap.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(Options.Swap)
		if not res then return end
		if Options.Presets.Visible == true then
			Options.Presets.Visible = false
			Options.TopBar.etc.Text = "Mesh Select"
			Options.Swap.Slide.displayText.Text = "Textures"
			Options.MeshPresets.Visible = true
		else
			Options.Presets.Visible = true
			Options.TopBar.etc.Text = "Texture Select"
			Options.Swap.Slide.displayText.Text = "Meshes"
			Options.MeshPresets.Visible = false
		end
	end)

	for i, button in pairs(AccessoryColorPane.TextureBox.MeshPresets:GetChildren()) do
		if button:IsA("TextButton") then
			button.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(button)
				if not res then return end
				if MajorDebounce then return end
				MajorDebounce = true
				if #SelectedAccessories == 0 then ErrorReport("Please select an Accessory to edit.") return end
				BeginAccessoryHistory()
				for z, AccessoryTable in ipairs(SelectedAccessories) do
					if not AccessoryTable.IsItemPack or not AccessoryTable.IsMeshPart then
						AccessoryTable.MeshId = "rbxassetid://" .. tostring(TbOfMeshIds[button.Name])
					end
				end
				local returned = CustomizationInvoke:InvokeServer("MeshId", SelectedAccessories)
				if not returned then CancelAccessoryHistory(); ErrorReport("Error updating mesh ID.") return end
				UpdateProperties()
				CommitAccessoryHistory()
				wait(1)
				MajorDebounce = false
			end)
		end
	end

	Options.InsertMesh.FocusLost:Connect(function(enter)
		if not enter then return end
		if MajorDebounce then return end
		if game.PlaceId ~= CustomizationRoomPlaceId then ErrorReport("This feature is only available inside your Customization Room due to the possibility of overscaled meshes.") return end
		if not OwnsCustomMeshGamepass then ErrorReport("You must own the Custom Meshes gamepass to use this feature.") return end
		if tonumber(Options.InsertMesh.Text) == nil then ErrorReport("Error while attempting to parse custom MeshId. Make sure you put in a number.") return end
		if #SelectedAccessories == 0 then ErrorReport("Please select an Accessory to edit.") return end
		local value = tonumber(Options.InsertMesh.Text)


		MajorDebounce = true
		BeginAccessoryHistory()

		for z, AccessoryTable in ipairs(SelectedAccessories) do
			AccessoryTable.MeshId = "rbxassetid://" .. tostring(value)
		end

		local returned = CustomizationInvoke:InvokeServer("MeshId", SelectedAccessories)
		if returned == false then CancelAccessoryHistory(); ErrorReport("Error while attempting to update Mesh Id") return end
		UpdateProperties()
		CommitAccessoryHistory()
		wait(0.5)
		MajorDebounce = false
	end)

end

do
	-- Setup variables
	local Options = AccessoryColorPane.TextureBox
	local ElectricButton = Options.Electric
	local MetalButton = Options.Metal

	local currentVal = Options.Electric.current
	local currentVal2 = Options.Metal.current

	-- Electric Button Functionality
	Options.Electric.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(Options.Electric)
		if not res then return end
		if MajorDebounce then return end
		MajorDebounce = true
		if #SelectedAccessories == 0 then  
			ErrorReport("Please select an accessory.") 
			return 
		end

		BeginAccessoryHistory()
		if currentVal.Value == 2 then
			currentVal.Value = 1
			ElectricButton.Slide.displayText.Text = "Electric: ON"
		elseif currentVal.Value == 1 then
			currentVal.Value = 0
			ElectricButton.Slide.displayText.Text = "Electric: OFF"
		elseif currentVal.Value == 0 then
			currentVal.Value = 1
			ElectricButton.Slide.displayText.Text = "Electric: ON"
		end

		for i, accessorytable in ipairs(SelectedAccessories) do
			if currentVal.Value == 1 then
				accessorytable.Material = Enum.Material.ForceField
				--warn("SENDING FF")
			elseif currentVal.Value == 0 then
				accessorytable.Material = Enum.Material.Plastic
				--warn("SENDING PLASTIC")
			end
		end

		local returned = CustomizationInvoke:InvokeServer("Material", SelectedAccessories)
		if returned == false then 
			CancelAccessoryHistory()
			ErrorReport("Error while attempting to update Material.") 
			return 
		end
		CommitAccessoryHistory()
		wait(0.1)
		MajorDebounce = false
		UpdateProperties()
	end)

	-- Metal Button Functionality
	Options.Metal.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(Options.Metal)
		if not res then return end
		if MajorDebounce then return end
		MajorDebounce = true
		if #SelectedAccessories == 0 then  
			ErrorReport("Please select an accessory.") 
			return 
		end

		BeginAccessoryHistory()
		if currentVal2.Value == 2 then
			currentVal2.Value = 1
			MetalButton.Slide.displayText.Text = "Metal: ON"
		elseif currentVal2.Value == 1 then
			currentVal2.Value = 0
			MetalButton.Slide.displayText.Text = "Metal: OFF"
		elseif currentVal2.Value == 0 then
			currentVal2.Value = 1
			MetalButton.Slide.displayText.Text = "Metal: ON"
		end

		for i, accessorytable in ipairs(SelectedAccessories) do
			if currentVal2.Value == 1 then
				accessorytable.Material = Enum.Material.Metal
				--warn("SENDING METAL")
			elseif currentVal2.Value == 0 then
				accessorytable.Material = Enum.Material.Plastic
				--warn("SENDING PLASTIC")
			end
		end

		local returned = CustomizationInvoke:InvokeServer("Material", SelectedAccessories)
		if returned == false then 
			CancelAccessoryHistory()
			ErrorReport("Error while attempting to update Material.") 
			return 
		end
		CommitAccessoryHistory()
		wait(0.1)
		MajorDebounce = false
		UpdateProperties()
	end)

end



-- Transform

local FocalPointPart = Instance.new("Part")
FocalPointPart.Transparency = 1
FocalPointPart.BrickColor = BrickColor.new("Royal purple")
FocalPointPart.Anchored = true
FocalPointPart.CanQuery = false
FocalPointPart.CanCollide = false
FocalPointPart.CanTouch = false
FocalPointPart.Size = Vector3.new(0.5,0.5,0.5)

do

	local PositionHandles = script.PositionHandles
	local SizeHandles = script.SizeHandles
	local RotationHandles = script.RotationHandles



	local CurrentFocalMode = "Collective"
	local CurrentMovementMode = "Local"
	local TransformIncrement = 0.1

	local SizeConstaints = 10



--[[
Possible Focal Modes:

Collective - It interpolates between all selected accessories positionally and favors the Root Part directioally if it is selected.
First - It is locked to the very first accessory selected both directionally and positionally
Dynamic - It interpolates between all selected accessories positionally and is locked directionally to the first accessory selected.

Possible Movement Modes:

Local - The accessories move on their own axis individually.
Global - All selected accessories will globally follow the axis of the current handles regardless if they match or not.

NOTE: Sizing will **always** be Local.

]]

	CustomizationUI.Focal.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationUI.Focal)
		if not res then return end
		if CurrentFocalMode == "Collective" then
			CurrentFocalMode = "First"
			CustomizationUI.Focal.Slide.displayText.Text = "Origin: " .. CurrentFocalMode
		elseif CurrentFocalMode == "First" then
			CurrentFocalMode = "Dynamic"
			CustomizationUI.Focal.Slide.displayText.Text = "Origin: " .. CurrentFocalMode
		elseif CurrentFocalMode == "Dynamic" then
			CurrentFocalMode = "Collective"
			CustomizationUI.Focal.Slide.displayText.Text = "Origin: " .. CurrentFocalMode
		end
	end)

	CustomizationUI.Mode.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationUI.Mode)
		if not res then return end
		if CurrentMovementMode == "Local" then
			CurrentMovementMode = "Global"
			CustomizationUI.Mode.Slide.displayText.Text = "Mode: " .. CurrentMovementMode
		elseif CurrentMovementMode == "Global" then
			CurrentMovementMode = "Local"
			CustomizationUI.Mode.Slide.displayText.Text = "Mode: " .. CurrentMovementMode
		end
	end)

	CustomizationUI.Increment.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationUI.Increment)
		if not res then return end
		if TransformIncrement == 0.1 then
			TransformIncrement = 0.5
			CustomizationUI.Increment.Slide.displayText.Text = "Increment: " .. tostring(TransformIncrement)
		elseif TransformIncrement == 0.5 then
			TransformIncrement = 1
			CustomizationUI.Increment.Slide.displayText.Text = "Increment: " .. tostring(TransformIncrement)
		elseif TransformIncrement == 1 then
			TransformIncrement = 0.1
			CustomizationUI.Increment.Slide.displayText.Text = "Increment: " .. tostring(TransformIncrement)
		end
	end)

	CustomizationUI.Copy.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationUI.Copy)
		if not res then return end
		if MajorDebounce then return end
		if CountAccessories() > MaxAccessories then ErrorReport("Maximum Accessories reached. Buy the gamepass for more if you haven't already.") return end
		if #SelectedAccessories == 0 then ErrorReport("Please select accessories to copy.") return end
		MajorDebounce = true
		IgnoreIncomingAccessory = true
		BeginAccessoryHistory()
		local returned2 = CustomizationInvoke:InvokeServer("Copy", SelectedAccessories)
		if not returned2 then CancelAccessoryHistory(); ErrorReport("Something went wrong trying to copy the accessories.") return end
		print("What we got back:", returned2)
		print("object?", returned2[1].Object)
		for i, returned in pairs(returned2) do
			warn("Indexing!", "i:", i, "returned:", returned, "object?", returned.Object)
			table.insert(CharacterTable["Accessories"], returned); warn("Added new accessory to character table", returned.Object)
			GenerateAccessory(returned.Object)
		end

		wait(0.1)
		CommitAccessoryHistory()
		MajorDebounce = false
		IgnoreIncomingAccessory = false
	end)

	CustomizationUI.Delete.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationUI.Delete)
		if res == false then return end
		if MajorDebounce then return end
		if #SelectedAccessories == 0 then ErrorReport("Please select accessories to delete.") return end
		MajorDebounce = true
		BeginAccessoryHistory()
		local returned = CustomizationInvoke:InvokeServer("Delete", SelectedAccessories)
		if returned == false then CancelAccessoryHistory(); ErrorReport("Error while attempting to delete accessory.") return end
		wait(0.1)
		CommitAccessoryHistory()
		MajorDebounce = false
	end)

	CustomizationUI.Revert.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationUI.Revert)
		if res == false then return end
		if MajorDebounce then return end
		if #SelectedAccessories == 0 then ErrorReport("Please select accessories to revert.") return end
		MajorDebounce = true
		BeginAccessoryHistory()
		local returnedOrg = CustomizationInvoke:InvokeServer("Revert", SelectedAccessories)
		if returnedOrg == false then CancelAccessoryHistory(); ErrorReport("Error while attempting to delete accessory.") return end

		for i, tableAssociated in pairs(SelectedAccessories) do
			if not tableAssociated.IsItemPack and not tableAssociated.IsMeshPart then
				local returned = returnedOrg[i]
				tableAssociated.AccessoryWeld.C0 = returned.AccessoryWeld.C0
				tableAssociated.AccessoryWeld.C1 = returned.AccessoryWeld.C1
				tableAssociated.WeldPart = returned.WeldPart
				tableAssociated.Scale = returned.Scale
				tableAssociated.MeshId = returned.MeshId
				tableAssociated.TextureId = returned.TextureId
				tableAssociated.Color = returned.Color
				tableAssociated.Transparency = returned.Transparency
				tableAssociated.Material = returned.Material
				tableAssociated.DistanceFromOrigin = Vector3.new(0,0,0)
				tableAssociated.RotationsApplied = Vector3.new(0,0,0)
				tableAssociated.Particle = "None"
				tableAssociated.ParticleColor = Color3.new(1,1,1)
				tableAssociated.ParticleTransparency = 0
				tableAssociated.ParticleRate = 0
				tableAssociated.ParticleSize = 0
				tableAssociated.OColor = returned.OColor
				tableAssociated.ColorMode = returned.ColorMode
				tableAssociated.OTransparency = returned.OTransparency
			elseif tableAssociated.IsMeshPart then
				local returned = returnedOrg[i]

				tableAssociated.MeshId = returned.MeshId
				tableAssociated.TextureId = returned.TextureId

				tableAssociated.Material = returned.Material

				tableAssociated.Particle = "None"
				tableAssociated.ParticleColor = Color3.new(1,1,1)
				tableAssociated.ParticleTransparency = 0
				tableAssociated.ParticleRate = 0
				tableAssociated.ParticleSize = 0

				tableAssociated.OColor = returned.OColor
				tableAssociated.ColorMode = returned.ColorMode
				tableAssociated.OTransparency = returned.OTransparency

			end
		end
		UpdateProperties()
		CommitAccessoryHistory()
		wait()
		MajorDebounce = false
	end)

	do
		local function FindAccessoryHistoryButton(name)
			local button = CustomizationUI:FindFirstChild(name, true)
			if button and button:IsA("GuiButton") then
				return button
			end
			warn("Accessory history button not found:", name)
			return nil
		end

		AccessoryUndoButton = FindAccessoryHistoryButton("UndoAccessory")
		AccessoryRedoButton = FindAccessoryHistoryButton("RedoAccessory")
		NormalizeHistoryButton(AccessoryUndoButton)
		NormalizeHistoryButton(AccessoryRedoButton)
		UpdateAccessoryHistoryButtons()

		if AccessoryUndoButton then
			AccessoryUndoButton.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(AccessoryUndoButton)
				if res == false then return end
				if #AccessoryUndoStack == 0 then return end
				UndoAccessoryChange()
			end)
		end

		if AccessoryRedoButton then
			AccessoryRedoButton.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(AccessoryRedoButton)
				if res == false then return end
				if #AccessoryRedoStack == 0 then return end
				RedoAccessoryChange()
			end)
		end
	end

	-- Renaming

	CustomizationUI.Rename.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationUI.Rename)
		if res == false then return end
		if CustomizationUI.RenameUI.Visible == false then CustomizationUI.RenameUI.Visible = true else CustomizationUI.RenameUI.Visible = false end
	end)
	CustomizationUI.RenameUI.Close.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationUI.RenameUI.Close)
		if res == false then return end
		CustomizationUI.RenameUI.Visible = false
	end)
	CustomizationUI.RenameUI.Insert.Enter.FocusLost:Connect(function(enter)
		if not enter then return end
		if #SelectedAccessories == 0 then ErrorReport("Please select accessories to rename.") return end
		local text = CustomizationUI.RenameUI.Insert.Enter.Text:sub(1,150)
		BeginAccessoryHistory()
		for i, AccessoryTable in pairs(SelectedAccessories) do

			for i, buttons in pairs(AccessoriesBin:GetChildren()) do
				if buttons:IsA("TextButton") then
					if buttons.AccessoryAssociated.Value == AccessoryTable.Object then
						buttons.Name = text
						AccessoryTable.Name = text
						buttons.AccessoryName.Text = text
					end
				end
			end


		end
		CommitAccessoryHistory()
	end)

	-- recalculate

	function RecalculateAccessories()
		local accessories = CharacterTable.Accessories
		for i, tableAssociated in pairs(accessories) do
			if not tableAssociated.IsMeshPart then
				local Obj = tableAssociated.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChildOfClass("Weld")

				local originCF = tableAssociated.OriginalC0:Inverse()
				local currentCF = Handle.CFrame
				local referenceCF = Weld.Part1.CFrame * CFrame.new(originCF.Position)
				local accCF = referenceCF:ToObjectSpace(CFrame.new() + currentCF.Position)
				tableAssociated.DistanceFromOrigin = Vector3.new(-accCF.Position.X, -accCF.Position.Y, -accCF.Position.Z)

				local Obj = tableAssociated.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChildOfClass("Weld")

				local originCF = tableAssociated.OriginalC0:Inverse()
				local originRx, originRy, originRz = tableAssociated.RootRotation.X, tableAssociated.RootRotation.Y, tableAssociated.RootRotation.Z
				local currentCF = tableAssociated.AccessoryWeld.C0:Inverse()
				local currentRx, currentRy, currentRz = currentCF:ToEulerAnglesXYZ()
				local referenceCF = Weld.Part1.CFrame * CFrame.new(originCF.Position)
				local X, Y, Z = currentRx-originRx, currentRy-originRy, currentRz-originRz
				tableAssociated.RotationsApplied = Vector3.new(X,Y,Z)
			end
		end

		warn("Finished recalculating accessories")
	end


	local CurrentFocalPoint = CFrame.new(0,0,0)
	local OverrideFocalPointRendering = false



	PositionHandles.Adornee = FocalPointPart
	SizeHandles.Adornee = FocalPointPart
	RotationHandles.Adornee = FocalPointPart

	local VisualizedBin = {}

	local HandlesSelected = true

	function UpdateProperties() -- refreshes the UI to reflect matches. handles everything for consistency sake.
		print("Updating properties!")

		local CharacterBin = CharacterInfoPane.Bin
		local EmpowermentSelectionBox = CharacterBin.Powers.EmpowermentSelectionBox
		local EmpowermentInfoBox = CharacterBin.Powers.EmpowermentInformation
		local EmpowermentTypeBox = CharacterBin.Powers.EmpowermentTypeBox
		local EmpowermentCustomEntryBox = CharacterBin.Powers.EmpowermentCustomEntry

		if CharacterTable.CharacterInformation.IsCustomEmpowerment == true then

			EmpowermentInfoBox.Visible = false
			EmpowermentCustomEntryBox.Visible = true
			EmpowermentCustomEntryBox.Title.Text = CharacterTable.CharacterInformation.EmpowermentTitle
			EmpowermentCustomEntryBox.Description.Text = CharacterTable.CharacterInformation.Empowerment

			for i, v in pairs(EmpowermentSelectionBox:GetChildren()) do

				if v.Name ~= CharacterTable.CharacterInformation.EmpowermentType then
					v.Visible = false
				else
					v.Visible = true
				end

			end
		else

			EmpowermentInfoBox.Visible = true
			EmpowermentCustomEntryBox.Visible = false
			if CharacterTable.CharacterInformation.EmpowermentType ~= "" or  CharacterTable.CharacterInformation.EmpowermentType ~= nil then
				EmpowermentInfoBox.Title.Text = CharacterTable.CharacterInformation.EmpowermentTitle
				EmpowermentInfoBox.Description.Text = CharacterTable.CharacterInformation.Empowerment
				EmpowermentSelectionBox.Visible = true
				for i, v in pairs(EmpowermentSelectionBox:GetChildren()) do

					if v.Name ~= CharacterTable.CharacterInformation.EmpowermentType then
						v.Visible = false
					else
						v.Visible = true
					end

				end
			else
				EmpowermentInfoBox.Title.Text = "None"
				EmpowermentInfoBox.Description.Text = "None."
				EmpowermentSelectionBox.Visible = false
				for i, v in pairs(EmpowermentSelectionBox:GetChildren()) do
					v.Visible = false
				end
			end
		end

		local SkillsTable = CharacterTable.CharacterInformation.Skills

		warn("reached skills")

		local function IsOccupiedSkills(i)
			local found = false
			for z, v in pairs(SkillsTable[i]) do
				warn("FOUND!")
				found = true
				break
			end
			return found
		end
		for si = 1, 5, 1 do
			warn("start skill check", si, "amount in skill table:",  #SkillsTable[si])
			local SelectionBox = CharacterBin.Powers["SkillSelectionBox" .. tostring(si)]
			local CustomEntryBox = CharacterBin.Powers["SkillCustomEntry" .. tostring(si)]
			local TypeBox = CharacterBin.Powers["SkillBox" .. tostring(si)]
			local InfoBox = CharacterBin.Powers["SkillInformation" .. tostring(si)]
			if IsOccupiedSkills(si) == true then
				warn("there is a skill", si)


				if SkillsTable[si].IsCustomSkill == true then
					InfoBox.Visible = false
					CustomEntryBox.Visible = true
					CustomEntryBox.Title.Text = SkillsTable[si].Title
					CustomEntryBox.Description.Text = SkillsTable[si].Skill



					for i, v in pairs(SelectionBox:GetChildren()) do
						if v.Name ~= SkillsTable[si].Type then
							v.Visible = false
						else
							CurrentSkillSelectionBoxes[si] = v
							v.Visible = true
						end
					end
				else -- not custom
					InfoBox.Visible = true
					CustomEntryBox.Visible = false

					InfoBox.Title.Text = SkillsTable[si].Title
					InfoBox.Description.Text = SkillsTable[si].Skill
					SelectionBox.Visible = true
					for i, v in pairs(SelectionBox:GetChildren()) do

						if v.Name ~= SkillsTable[si].Type then
							v.Visible = false
						else
							CurrentSkillSelectionBoxes[si] = v
							v.Visible = true
						end

					end


				end
			else

				InfoBox.Title.Text = "None"
				InfoBox.Description.Text = "None."
				SelectionBox.Visible = false
				CurrentSkillSelectionBoxes[si] = false
				for i, v in pairs(SelectionBox:GetChildren()) do
					v.Visible = false
				end
			end
		end
		local TraitsBin = CharacterTraitsPane.Bin

		CharacterBin.CharacterInfo.ImgText.Text = tostring(CharacterTable["CharacterInformation"]["CharacterImg"])
		CharacterBin.CharacterInfo.NameText.Text = CharacterTable["CharacterInformation"]["CharacterName"]
		CharacterBin.CharacterInfo.BioText.Text = CharacterTable["CharacterInformation"]["CharacterBio"]
		CharacterBin.CharacterInfo.ImgText.reference.Image = "rbxthumb://type=Asset&id=" .. tostring(CharacterTable["CharacterInformation"]["CharacterImg"]) .. "&w=420&h=420"

		local feet, inches = CalculateHeight(CharacterTable["Scale"]["Height"])

		HeightFeetBox.Text = tostring(feet)
		HeightInchesBox.Text = tostring(inches)
		WidthBox.Text = tostring(CalculateInches(CharacterTable["Scale"]["Width"]))
		DepthBox.Text = tostring(CalculateInches(CharacterTable["Scale"]["Depth"]))
		HeadBox.Text = tostring(CalculateInches(CharacterTable["Scale"]["Head"]))

		for i, v in pairs(TraitsBin.LimbColor:GetChildren()) do
			if v.Name:sub(1,5) == "Color" then
				local cutoff = v.Name:sub(6, #v.Name)

				if cutoff == "All" then
					v.BackgroundColor3 = Color3.new(1,1,1)
				else
					v.BackgroundColor3 = Color3.new(CharacterTable["BodyColors"][cutoff]["R"], CharacterTable["BodyColors"][cutoff]["G"], CharacterTable["BodyColors"][cutoff]["B"])
				end
			end
		end

		local IdleBox, WalkBox, RunBox = TraitsBin.Animations.IdleAnimation, TraitsBin.Animations.WalkAnimation, TraitsBin.Animations.RunAnimation

		IdleBox.Text = tostring(Character.Humanoid.HumanoidDescription.IdleAnimation)
		WalkBox.Text = tostring(Character.Humanoid.HumanoidDescription.WalkAnimation)
		RunBox.Text = tostring(Character.Humanoid.HumanoidDescription.RunAnimation)

		for i, v in pairs(TraitsBin.LimbVisibility:GetChildren()) do
			if v.Name ~= "etc" and v:IsA("TextButton") then
				v.BackgroundColor3 = Color3.fromRGB(33, 28, 59)
			end
		end

		for i, v in pairs(CharacterTable["LimbRemover"]) do
			if v == true then
				local Box = TraitsBin.LimbVisibility:FindFirstChild(i)
				if Box then
					Box.BackgroundColor3 = Color3.new(0,1,0)
				end
			end
		end

		local ShirtBox = TraitsBin.Clothing.ShirtText
		local PantsBox = TraitsBin.Clothing.PantsText
		local FaceBox = TraitsBin.Clothing.FaceText


		CharacterTable["ShirtTemplateDisplay"] = CharacterTable["ShirtTemplateDisplay"] or CharacterTable["ShirtTemplate"]:match("%d+") or ""
		CharacterTable["PantsTemplateDisplay"] = CharacterTable["PantsTemplateDisplay"] or CharacterTable["PantsTemplate"]:match("%d+") or ""

		ShirtBox.Text = CharacterTable["ShirtTemplateDisplay"]:match("%d+") or ""
		PantsBox.Text = CharacterTable["PantsTemplateDisplay"]:match("%d+") or ""
		FaceBox.Text = CharacterTable["FaceID"]:match("%d+") or ""


		if not (#SelectedAccessories > 0) then
			-- Color
			ColorUI:SetColor(Color3.new(1, 1, 1))

			-- Texture
			AccessoryColorPane.TextureBox.InsertTexture.Text = ""

			-- Transparency
			ColorUI.Window.Properties.TransparencyFrame.Selection.Frame.TextBox.Text = ""

			-- Mesh
			AccessoryColorPane.TextureBox.InsertMesh.Text = ""

			-- Position
			AccessoryTransformPane.PositionXYZ.X.Frame.TextBox.Text = ""
			AccessoryTransformPane.PositionXYZ.Y.Frame.TextBox.Text = ""
			AccessoryTransformPane.PositionXYZ.Z.Frame.TextBox.Text = ""

			-- Rotation
			AccessoryTransformPane.RotationXYZ.X.Frame.TextBox.Text = ""
			AccessoryTransformPane.RotationXYZ.Y.Frame.TextBox.Text = ""
			AccessoryTransformPane.RotationXYZ.Z.Frame.TextBox.Text = ""

			-- Size
			AccessoryTransformPane.SizeXYZ.X.Frame.TextBox.Text = ""
			AccessoryTransformPane.SizeXYZ.Y.Frame.TextBox.Text = ""
			AccessoryTransformPane.SizeXYZ.Z.Frame.TextBox.Text = ""

			-- Particles
			PColorUI:SetColor(Color3.new(1, 1, 1))
			PColorUI.Window.Properties.Particles.R.Frame.TextBox.Text = ""
			PColorUI.Window.Properties.Particles.S.Frame.TextBox.Text = ""
			PColorUI.Window.Properties.Particles.T.Frame.TextBox.Text = ""

			-- Material: Electric
			AccessoryColorPane.TextureBox.Electric.current.Value = 0
			AccessoryColorPane.TextureBox.Electric.Slide.displayText.Text = "Electric: OFF"

			-- Material: Metal
			AccessoryColorPane.TextureBox.Metal.current.Value = 0
			AccessoryColorPane.TextureBox.Metal.Slide.displayText.Text = "Metal: OFF"

			return
		end


		local ColorTheSame = true
		local lastcolor = nil


		local lastTexture = nil
		local TextureTheSame = true


		local lastTransparency = nil
		local TransparencyTheSame = true

		local lastPosition = nil
		local PositionTheSame = true

		local lastRotation = nil
		local RotationTheSame = true

		local lastSize = nil
		local SizeTheSame = true

		local lastPColor = nil
		local lastPRate = nil
		local lastPSize = nil
		local lastPTransparency = nil

		local PColorTheSame = true
		local PRateTheSame = true
		local PSizeTheSame = true
		local PTransparencyTheSame = true

		local lastMesh = nil
		local MeshTheSame = true

		local lastElecric = nil
		local ElectricTheSame = true

		local lastOColor = nil
		local OColorTheSame = true


		local lastOToggle = nil
		local OToggleTheSame = true

		local lastOTransparency= nil
		local OTransparencyTheSame = true

		local Range = 0.01

		for i, AccessoryTable in pairs(SelectedAccessories) do
			if AccessoryTable.IsItemPack then
				if not lastPosition then lastPosition = AccessoryTable.DistanceFromOrigin end
				if math.abs((lastPosition - AccessoryTable.DistanceFromOrigin).magnitude) > Range then PositionTheSame = false end
				if not lastRotation then lastRotation = AccessoryTable.RotationsApplied end
				if math.abs((lastRotation - AccessoryTable.RotationsApplied).magnitude) > Range then RotationTheSame = false end
			elseif not AccessoryTable.IsMeshPart then
				if not lastcolor then lastcolor = AccessoryTable.Color end
				if lastcolor ~= AccessoryTable.Color then ColorTheSame = false end
				if not lastTexture then lastTexture = AccessoryTable.TextureId end
				if lastTexture ~= AccessoryTable.TextureId then TextureTheSame = false end
				if not lastTransparency then lastTransparency = AccessoryTable.Transparency end
				if lastTransparency ~= AccessoryTable.Transparency then TransparencyTheSame = false end

				if not lastPosition then lastPosition = AccessoryTable.DistanceFromOrigin end
				if math.abs((lastPosition - AccessoryTable.DistanceFromOrigin).magnitude) > Range then PositionTheSame = false end
				if not lastRotation then lastRotation = AccessoryTable.RotationsApplied end
				if math.abs((lastRotation - AccessoryTable.RotationsApplied).magnitude) > Range then RotationTheSame = false end
				if not lastSize then lastSize = AccessoryTable.Scale end

				if math.abs((lastSize - AccessoryTable.Scale).magnitude) > Range then SizeTheSame = false end
				if not lastPColor then lastPColor = AccessoryTable.ParticleColor end
				if lastPColor ~= AccessoryTable.ParticleColor then PColorTheSame = false end
				if not lastPRate then lastPRate = AccessoryTable.ParticleRate end
				if lastPRate ~= AccessoryTable.ParticleRate then PRateTheSame = false end
				if not lastPSize then lastPSize = AccessoryTable.ParticleSize end
				if lastPSize ~= AccessoryTable.ParticleSize then PSizeTheSame = false end
				if not lastPTransparency then lastPTransparency = AccessoryTable.ParticleTransparency end
				if lastPTransparency~= AccessoryTable.ParticleTransparency then PTransparencyTheSame = false end

				if not lastMesh then lastMesh = AccessoryTable.MeshId end
				if lastMesh ~= AccessoryTable.MeshId then MeshTheSame = false end
				if not lastElecric then lastElecric = AccessoryTable.Material end
				if lastElecric ~= AccessoryTable.Material then ElectricTheSame = false end

				if not lastOColor then lastOColor = AccessoryTable.OColor end
				if lastOColor ~= AccessoryTable.OColor then OColorTheSame = false end
				if not lastOToggle then lastOToggle = AccessoryTable.ColorMode end
				if lastOToggle ~= AccessoryTable.ColorMode then OToggleTheSame = false end
				if not lastOTransparency then lastOTransparency = AccessoryTable.OTransparency end
				if lastOTransparency ~= AccessoryTable.OTransparency then OTransparencyTheSame = false end

			else -- meshparts

				if not lastElecric then lastElecric = AccessoryTable.Material end
				if lastElecric ~= AccessoryTable.Material then ElectricTheSame = false end
				if not lastOColor then lastOColor = AccessoryTable.OColor end
				if lastOColor ~= AccessoryTable.OColor then OColorTheSame = false end
				if not lastOToggle then lastOToggle = AccessoryTable.ColorMode end
				if lastOToggle ~= AccessoryTable.ColorMode then OToggleTheSame = false end
				if not lastOTransparency then lastOTransparency = AccessoryTable.OTransparency end
				if lastOTransparency ~= AccessoryTable.OTransparency then OTransparencyTheSame = false end

				if not lastPColor then lastPColor = AccessoryTable.ParticleColor end
				if lastPColor ~= AccessoryTable.ParticleColor then PColorTheSame = false end
				if not lastPRate then lastPRate = AccessoryTable.ParticleRate end
				if lastPRate ~= AccessoryTable.ParticleRate then PRateTheSame = false end
				if not lastPSize then lastPSize = AccessoryTable.ParticleSize end
				if lastPSize ~= AccessoryTable.ParticleSize then PSizeTheSame = false end
				if not lastPTransparency then lastPTransparency = AccessoryTable.ParticleTransparency end
				if lastPTransparency~= AccessoryTable.ParticleTransparency then PTransparencyTheSame = false end

				if not lastTexture then lastTexture = AccessoryTable.TextureId end
				if lastTexture ~= AccessoryTable.TextureId then TextureTheSame = false end
				if not lastTransparency then lastTransparency = AccessoryTable.Transparency end
				if lastTransparency ~= AccessoryTable.Transparency then TransparencyTheSame = false end

			end

		end

		if ColorTheSame and lastcolor then
			if not OToggleTheSame then
				ColorUI:SetColor(Color3.new(lastcolor.X, lastcolor.Y, lastcolor.Z))
			else
				ColorUI:SetColor(Color3.new(1,1,1))
			end

		else
			ColorUI:SetColor(Color3.new(1,1,1))
		end

		if TextureTheSame and lastTexture then
			AccessoryColorPane.TextureBox.InsertTexture.Text = IsolateNumbersInTextureID(lastTexture)
		else
			AccessoryColorPane.TextureBox.InsertTexture.Text = "(varied)"
		end

		if TransparencyTheSame and lastTransparency then
			ColorUI.Window.Properties.TransparencyFrame.Selection.Frame.TextBox.Text = lastTransparency
		else
			ColorUI.Window.Properties.TransparencyFrame.Selection.Frame.TextBox.Text = "?"
		end

		if PositionTheSame and lastPosition then
			AccessoryTransformPane.PositionXYZ.X.Frame.TextBox.Text = tostring(round(lastPosition.X))
			AccessoryTransformPane.PositionXYZ.Y.Frame.TextBox.Text = tostring(round(lastPosition.Y))
			AccessoryTransformPane.PositionXYZ.Z.Frame.TextBox.Text = tostring(round(lastPosition.Z))
		else
			AccessoryTransformPane.PositionXYZ.X.Frame.TextBox.Text = "var"
			AccessoryTransformPane.PositionXYZ.Y.Frame.TextBox.Text = "var"
			AccessoryTransformPane.PositionXYZ.Z.Frame.TextBox.Text = "var"
		end

		if RotationTheSame and lastRotation then
			AccessoryTransformPane.RotationXYZ.X.Frame.TextBox.Text = tostring(round(math.deg(lastRotation.X)))
			AccessoryTransformPane.RotationXYZ.Y.Frame.TextBox.Text = tostring(round(math.deg(lastRotation.Y)))
			AccessoryTransformPane.RotationXYZ.Z.Frame.TextBox.Text = tostring(round(math.deg(lastRotation.Z)))
		else
			AccessoryTransformPane.RotationXYZ.X.Frame.TextBox.Text = "var"
			AccessoryTransformPane.RotationXYZ.Y.Frame.TextBox.Text = "var"
			AccessoryTransformPane.RotationXYZ.Z.Frame.TextBox.Text = "var"
		end

		if SizeTheSame and lastSize then
			AccessoryTransformPane.SizeXYZ.X.Frame.TextBox.Text = tostring(round(lastSize.X))
			AccessoryTransformPane.SizeXYZ.Y.Frame.TextBox.Text = tostring(round(lastSize.Y))
			AccessoryTransformPane.SizeXYZ.Z.Frame.TextBox.Text = tostring(round(lastSize.Z))
		else
			AccessoryTransformPane.SizeXYZ.X.Frame.TextBox.Text = "var"
			AccessoryTransformPane.SizeXYZ.Y.Frame.TextBox.Text = "var"
			AccessoryTransformPane.SizeXYZ.Z.Frame.TextBox.Text = "var"
		end

		if PColorTheSame and lastPColor then
			PColorUI:SetColor(lastPColor)
		else
			PColorUI:SetColor(Color3.new(1,1,1))
		end

		if PRateTheSame and lastPRate then
			PColorUI.Window.Properties.Particles.R.Frame.TextBox.Text = tostring(round(lastPRate))
		else
			PColorUI.Window.Properties.Particles.R.Frame.TextBox.Text = ""
		end

		if PTransparencyTheSame and lastPTransparency then
			PColorUI.Window.Properties.Particles.T.Frame.TextBox.Text = tostring(round(lastPTransparency))
		else
			PColorUI.Window.Properties.Particles.T.Frame.TextBox.Text = ""
		end

		if PSizeTheSame and lastPSize then
			PColorUI.Window.Properties.Particles.S.Frame.TextBox.Text = tostring(round(lastPSize))
		else
			PColorUI.Window.Properties.Particles.S.Frame.TextBox.Text = ""
		end

		if MeshTheSame and lastMesh then
			AccessoryColorPane.TextureBox.InsertMesh.Text = lastMesh:match("%d+")
		else
			AccessoryColorPane.TextureBox.InsertMesh.Text = "(varied)"
		end

		if ElectricTheSame and lastElecric then
			if lastElecric == Enum.Material.Plastic then
				AccessoryColorPane.TextureBox.Electric.current.Value = 0
				AccessoryColorPane.TextureBox.Electric.Slide.displayText.Text = "Electric: OFF"
			elseif lastElecric == Enum.Material.ForceField then
				AccessoryColorPane.TextureBox.Electric.current.Value = 1
				AccessoryColorPane.TextureBox.Electric.Slide.displayText.Text = "Electric: ON"
			end
		else
			AccessoryColorPane.TextureBox.Electric.current.Value = 2
			AccessoryColorPane.TextureBox.Electric.Slide.displayText.Text = "Electric: VAR"
		end

		if OColorTheSame and lastOColor then
			if OToggleTheSame then
				ColorUI:SetColor(Color3.new(lastOColor.R, lastOColor.G, lastOColor.B))
			else
				ColorUI:SetColor(Color3.new(1,1,1))
			end
		else
			ColorUI:SetColor(Color3.new(1,1,1))
		end

		if OToggleTheSame and lastOToggle then
			if lastOToggle == "VertexColor" then
				ColorUI.Window.Properties["Overlay"].Check.Text = ""
				if lastcolor and ColorTheSame then
					ColorUI:SetColor(Color3.new(lastcolor.X, lastcolor.Y, lastcolor.Z))
				else
					ColorUI:SetColor(Color3.new(1,1,1))
				end
			else
				ColorUI.Window.Properties["Overlay"].Check.Text = "X"
			end

		else 
			if lastcolor and ColorTheSame then
				ColorUI:SetColor(Color3.new(lastcolor.X, lastcolor.Y, lastcolor.Z))
			else
				ColorUI:SetColor(Color3.new(1,1,1))
			end
			ColorUI.Window.Properties["Overlay"].Check.Text = "-"
		end

		if OTransparencyTheSame and lastOTransparency then
			ColorUI.Window.Properties.TransparencyFrame["Selection 2"].Frame.TextBox.Text = tostring(lastOTransparency)
		else
			ColorUI.Window.Properties.TransparencyFrame["Selection 2"].Frame.TextBox.Text = "VAR"
		end

		if #SelectedAccessories > 0 then
			if SelectedAccessories[1].IsItemPack then
				FocalPointPart.Size = SelectedAccessories[1].Object.Handle.Size
			elseif not SelectedAccessories[1].IsMeshPart then
				FocalPointPart.Size = SelectedAccessories[1].Scale
			end

		end
	end

	-- Handle rendering

	local function FindFocalPoint()
		if CurrentFocalMode == "Collective" or CurrentFocalMode == "Dynamic" then
			local total = #SelectedAccessories
			local SumX = 0
			local SumY = 0
			local SumZ = 0
			for i, AccessoryTable in ipairs(SelectedAccessories) do
				SumX += AccessoryTable.Object.Handle.Position.X
				SumY += AccessoryTable.Object.Handle.Position.Y
				SumZ += AccessoryTable.Object.Handle.Position.Z
			end

			local Midpoint = Vector3.new(SumX/total, SumY/total, SumZ/total)
			--warn("Focal point:", Midpoint)
			return Midpoint
		elseif CurrentFocalMode == "First" then
			return SelectedAccessories[1].Object.Handle.CFrame.Position
		end
	end

	local function DetermineRotation()

		if CurrentFocalMode == "Collective" then
			local PartToUse = nil
			for i, AccessoryTable in ipairs(SelectedAccessories) do

				local obj = AccessoryTable.Object
				local Weld
				if not AccessoryTable.IsItemPack then
					Weld = obj.Handle:FindFirstChildOfClass("Weld")
				else
					Weld =  obj.Handle:FindFirstChild("AccessoryWeld")
				end
				if i == 1 then
					PartToUse = Weld.Part1
				end
				if Weld.Part1.Name == "LowerTorso" then
					if RotationHandles.Visible == true or SizeHandles.Visible == true or CurrentMovementMode == "Local" then
						PartToUse = obj.Handle
					else
						PartToUse = Weld.Part1
					end
					break
				elseif Weld.Part1.Name == "UpperTorso" then
					if RotationHandles.Visible == true or SizeHandles.Visible == true or CurrentMovementMode == "Local"  then
						PartToUse = obj.Handle
					else
						PartToUse = Weld.Part1
					end
					break
				elseif Weld.Part1.Name == "Head" then
					if RotationHandles.Visible == true or SizeHandles.Visible == true or CurrentMovementMode == "Local" then
						PartToUse = obj.Handle
					else
						PartToUse = Weld.Part1
					end
					break
				end
			end

			return PartToUse.CFrame.Rotation

		elseif CurrentFocalMode == "First" or CurrentFocalMode == "Dynamic" then
			if CurrentMovementMode == "Local" or RotationHandles.Visible == true or SizeHandles.Visible == true then
				return SelectedAccessories[1].Object.Handle.CFrame.Rotation
			else
				return SelectedAccessories[1].Object.Handle:FindFirstChildOfClass("Weld").Part1.CFrame.Rotation
			end
		end

	end

	RunService.Heartbeat:Connect(function()
		if #SelectedAccessories > 0 and CustomizationUI.Visible == true then
			if OverrideFocalPointRendering == false then
				FocalPointPart.Parent = workspace
				CurrentFocalPoint = FindFocalPoint()
				local Rotation = DetermineRotation()
				FocalPointPart.CFrame = CFrame.new(CurrentFocalPoint) * Rotation
			end
		elseif FocalPointPart.Parent ~= script then
			PositionHandles.Visible = false
			SizeHandles.Visible = false
			RotationHandles.Visible = false
			FocalPointPart.Parent = script
		end
	end)

	AccessoryTransformPane.PositionHandles.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(AccessoryTransformPane.PositionHandles)
		if not res then return end
		if PositionHandles.Visible == false then
			PositionHandles.Visible = true
			lastHandles = PositionHandles
			SizeHandles.Visible = false
			RotationHandles.Visible = false
			FocalPointPart.Parent = workspace
			if #SelectedAccessories > 0 then
				local acc = SelectedAccessories[1]
				if acc.IsItemPack then
					local size = acc.Object.Handle.Size
					FocalPointPart.Size = size
				elseif acc.IsMeshPart then
					--FocalPointPart.Size = SelectedAccessories[1].Object.Handle.Size
				else
					FocalPointPart.Size = SelectedAccessories[1].Object.Handle:FindFirstChildOfClass("SpecialMesh").Scale
				end
			end
		else
			PositionHandles.Visible = false
			FocalPointPart.Parent = script
			lastHandles = nil
		end
	end)

	AccessoryTransformPane.RotationHandles.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(AccessoryTransformPane.RotationHandles)
		if not res then return end
		if RotationHandles.Visible == false then
			PositionHandles.Visible = false
			SizeHandles.Visible = false
			RotationHandles.Visible = true
			lastHandles = RotationHandles
			FocalPointPart.Parent = workspace
			if #SelectedAccessories > 0 then
				local acc = SelectedAccessories[1]
				if acc.IsItemPack then
					local size = acc.Object.Handle.Size
					FocalPointPart.Size = size
				elseif acc.IsMeshPart then
					--FocalPointPart.Size = SelectedAccessories[1].Object.Handle.Size
				else
					FocalPointPart.Size = SelectedAccessories[1].Object.Handle:FindFirstChildOfClass("SpecialMesh").Scale
				end
			end
		else
			RotationHandles.Visible = false
			FocalPointPart.Parent = script
			lastHandles = nil
		end
	end)

	AccessoryTransformPane.SizeHandles.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(AccessoryTransformPane.SizeHandles)
		if not res then return end
		if SizeHandles.Visible == false then
			PositionHandles.Visible = false
			SizeHandles.Visible = true
			lastHandles = SizeHandles
			RotationHandles.Visible = false
			FocalPointPart.Parent = workspace
			if #SelectedAccessories > 0 then
				local acc = SelectedAccessories[1]
				if acc.IsItemPack then
					local size = acc.Object.Handle.Size
					FocalPointPart.Size = size
				elseif acc.IsMeshPart then
					--FocalPointPart.Size = SelectedAccessories[1].Object.Handle.Size
				else
					FocalPointPart.Size = SelectedAccessories[1].Object.Handle:FindFirstChildOfClass("SpecialMesh").Scale
				end
			end
		else
			SizeHandles.Visible = false
			FocalPointPart.Parent = script
			lastHandles = nil
		end
	end)

	local LastNotedChange = 0

	local TransformC0
	local TransformC1 = CFrame.new(0,0,0)
	local Origin = nil

	local TempBin = {}

	local function AnchorCharacter(set : boolean)
		for i, v in pairs(Character:GetChildren()) do
			if v:IsA("BasePart") then
				v.Anchored = set
			end
		end
	end

	local function GetRawCFrameData(original)
		local copy = {}
		warn("GetRawCFrameData : SelectedAccessories", SelectedAccessories)
		for k, v in ipairs(SelectedAccessories) do
			if not v.IsMeshPart and not v.IsItemPack then
				copy[k] ={v.Object.Handle.CFrame, v.Object.Handle.CFrame:ToObjectSpace(FocalPointPart.CFrame), v.Object.Handle:FindFirstChildOfClass("SpecialMesh").Scale}
			elseif v.IsMeshPart then
				copy[k] ={v.Object.Handle.CFrame, v.Object.Handle.CFrame:ToObjectSpace(FocalPointPart.CFrame), v.Object.Handle.Size}		
			elseif v.IsItemPack then
				copy[k] ={v.Object.Handle.CFrame, v.Object.Handle.CFrame:ToObjectSpace(FocalPointPart.CFrame), v.Object:GetScale()}
			end		
		end

		return copy
	end

	-- Connections for all handles

	PositionHandles.MouseButton1Down:Connect(function()
		OverrideFocalPointRendering = true
		if #SelectedAccessories > 0 then BeginAccessoryHistory() end
		Origin = FocalPointPart.CFrame
		AnchorCharacter(true)
		TempBin = GetRawCFrameData(SelectedAccessories)
	end)
	SizeHandles.MouseButton1Down:Connect(function()
		OverrideFocalPointRendering = true
		if #SelectedAccessories > 0 then BeginAccessoryHistory() end
		Origin = FocalPointPart.CFrame
		AnchorCharacter(true)
		TempBin = GetRawCFrameData(SelectedAccessories)
	end)
	RotationHandles.MouseButton1Down:Connect(function()
		OverrideFocalPointRendering = true
		if #SelectedAccessories > 0 then BeginAccessoryHistory() end
		Origin = FocalPointPart.CFrame
		AnchorCharacter(true)
		TempBin = GetRawCFrameData(SelectedAccessories)
	end)

	PositionHandles.MouseButton1Up:Connect(function()
		OverrideFocalPointRendering = false
		AnchorCharacter(false)
		table.clear(TempBin)
		for i, tableAssociated in pairs(SelectedAccessories) do
			if tableAssociated.IsItemPack then
				local Obj = tableAssociated.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChild("AccessoryWeld")

				local originCF = tableAssociated.OriginalC0:Inverse()
				local currentCF = Handle.CFrame
				local referenceCF = Weld.Part1.CFrame * CFrame.new(originCF.Position)
				local accCF = referenceCF:ToObjectSpace(CFrame.new() + currentCF.Position)
				tableAssociated.DistanceFromOrigin = Vector3.new(-accCF.Position.X, -accCF.Position.Y, -accCF.Position.Z)
			elseif tableAssociated.IsMeshPart then
				--[[local Obj = tableAssociated.Object
				local Handle = Obj.Handle
				
				local Weld = Handle:FindFirstChildOfClass("Weld")

				local originCF = tableAssociated.OriginalC0:Inverse()
				local currentCF = Handle.CFrame
				local referenceCF = Weld.Part1.CFrame * CFrame.new(originCF.Position)
				local accCF = referenceCF:ToObjectSpace(CFrame.new() + currentCF.Position)
				tableAssociated.DistanceFromOrigin = Vector3.new(-accCF.Position.X, -accCF.Position.Y, -accCF.Position.Z)]]
			else
				local Obj = tableAssociated.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChildOfClass("Weld")

				local originCF = tableAssociated.OriginalC0:Inverse()
				local currentCF = Handle.CFrame
				local referenceCF = Weld.Part1.CFrame * CFrame.new(originCF.Position)
				local accCF = referenceCF:ToObjectSpace(CFrame.new() + currentCF.Position)
				tableAssociated.DistanceFromOrigin = Vector3.new(-accCF.Position.X, -accCF.Position.Y, -accCF.Position.Z)
			end

		end

		local returned = CustomizationInvoke:InvokeServer("Position", SelectedAccessories)
		if not returned then CancelAccessoryHistory(); ErrorReport("Error updating Position.") return end

		UpdateProperties()
		CommitAccessoryHistory()


	end)
	SizeHandles.MouseButton1Up:Connect(function()
		OverrideFocalPointRendering = false
		AnchorCharacter(false)
		table.clear(TempBin)
		local returned = CustomizationInvoke:InvokeServer("Size", SelectedAccessories)
		if not returned then CancelAccessoryHistory(); ErrorReport("Error updating Size.") return end

		UpdateProperties()
		CommitAccessoryHistory()
	end)
	RotationHandles.MouseButton1Up:Connect(function()
		OverrideFocalPointRendering = false
		AnchorCharacter(false)
		table.clear(TempBin)

		for i, tableAssociated in pairs(SelectedAccessories) do
			local Obj = tableAssociated.Object
			local Handle = Obj.Handle
			local Weld = Handle:FindFirstChildOfClass("Weld")

			local originCF = tableAssociated.OriginalC0:Inverse()
			local originRx, originRy, originRz = tableAssociated.RootRotation.X, tableAssociated.RootRotation.Y, tableAssociated.RootRotation.Z
			local currentCF = tableAssociated.AccessoryWeld.C0:Inverse()
			local currentRx, currentRy, currentRz = currentCF:ToEulerAnglesXYZ()
			local referenceCF = Weld.Part1.CFrame * CFrame.new(originCF.Position)
			local X, Y, Z = currentRx-originRx, currentRy-originRy, currentRz-originRz
			tableAssociated.RotationsApplied = Vector3.new(X,Y,Z)
		end


		local returned = CustomizationInvoke:InvokeServer("Rotation", SelectedAccessories)
		if not returned then CancelAccessoryHistory(); ErrorReport("Error updating Rotation.") return end

		UpdateProperties()
		CommitAccessoryHistory()
	end)

	-- Move Handles



	local function RenderMoveChanges(Change)

		--warn("Move changes:", Change, "FOCAL MODE:", CurrentFocalMode, "CURRENT MOVEMENT MODE:", CurrentMovementMode)

		local newCF = (Origin * Change)
		local max = MaxAccessoryDistance
		local last = FocalPointPart.CFrame

		FocalPointPart.CFrame = newCF

		if math.abs((FocalPointPart.Position - Character.HumanoidRootPart.Position).magnitude) > max then FocalPointPart.CFrame = last return end



		for i, accessorytable in ipairs(SelectedAccessories) do
			if accessorytable.IsItemPack then
				local Obj = accessorytable.Object
				local Handle = Obj.Handle
				local Weld = Handle.AccessoryWeld
				print("TempBin", TempBin)
				if CurrentMovementMode == "Local" then
					if #SelectedAccessories == 1 then
						local CF = (TempBin[i][1].Rotation + FocalPointPart.CFrame.Position):ToObjectSpace(Weld.Part1.CFrame)


						Weld.C0 = CF
						Weld.C1 = CFrame.new(0,0,0)
						accessorytable.AccessoryWeld.C0 = Weld.C0
						accessorytable.AccessoryWeld.C1 = Weld.C1
					else
						local CF = (TempBin[i][1] * Change):ToObjectSpace(Weld.Part1.CFrame)

						Weld.C0 = CF
						Weld.C1 = CFrame.new(0,0,0)
						accessorytable.AccessoryWeld.C0 = Weld.C0
						accessorytable.AccessoryWeld.C1 = Weld.C1
					end
				elseif CurrentMovementMode == "Global" then
					local CF = newCF* TempBin[i][2]:Inverse()
					local x,y,z, r00,r01, r02, r10, r11,r12,r20,r21,r22 = TempBin[i][1]:GetComponents()

					Weld.C0 = CF:ToObjectSpace(Weld.Part1.CFrame)
					Weld.C1 = CFrame.new(0,0,0)
					accessorytable.AccessoryWeld.C0 = Weld.C0
					accessorytable.AccessoryWeld.C1 = Weld.C1
				end
			elseif not accessorytable.IsMeshPart then
				local Obj = accessorytable.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChildOfClass("Weld")
				if CurrentMovementMode == "Local" then
					if #SelectedAccessories == 1 then
						local CF = (TempBin[i][1].Rotation + FocalPointPart.CFrame.Position):ToObjectSpace(Weld.Part1.CFrame)


						Weld.C0 = CF
						Weld.C1 = CFrame.new(0,0,0)
						accessorytable.AccessoryWeld.C0 = Weld.C0
						accessorytable.AccessoryWeld.C1 = Weld.C1
					else
						local CF = (TempBin[i][1] * Change):ToObjectSpace(Weld.Part1.CFrame)

						Weld.C0 = CF
						Weld.C1 = CFrame.new(0,0,0)
						accessorytable.AccessoryWeld.C0 = Weld.C0
						accessorytable.AccessoryWeld.C1 = Weld.C1
					end
				elseif CurrentMovementMode == "Global" then
					local CF = newCF* TempBin[i][2]:Inverse()
					local x,y,z, r00,r01, r02, r10, r11,r12,r20,r21,r22 = TempBin[i][1]:GetComponents()

					Weld.C0 = CF:ToObjectSpace(Weld.Part1.CFrame)
					Weld.C1 = CFrame.new(0,0,0)
					accessorytable.AccessoryWeld.C0 = Weld.C0
					accessorytable.AccessoryWeld.C1 = Weld.C1
				end
			end

		end	
	end



	PositionHandles.MouseDrag:Connect(function(Face, Distance)
		local unitmoved=math.round(Distance/TransformIncrement)

		if LastNotedChange ~= 0 and LastNotedChange == unitmoved then return end

		local Change = CFrame.new(0,0,0)
		if Face == Enum.NormalId.Front then
			LastNotedChange = unitmoved
			Change = CFrame.new(0,0,-Distance)
		elseif Face == Enum.NormalId.Back then
			LastNotedChange = unitmoved
			Change = CFrame.new(0,0,Distance)
		elseif Face == Enum.NormalId.Top then
			LastNotedChange = unitmoved
			Change = CFrame.new(0,Distance,0)
		elseif Face == Enum.NormalId.Bottom then
			LastNotedChange = unitmoved
			Change = CFrame.new(0,-Distance,0)
		elseif Face == Enum.NormalId.Left then
			LastNotedChange = unitmoved
			Change = CFrame.new(-Distance,0,0)
		elseif Face == Enum.NormalId.Right then
			LastNotedChange = unitmoved
			Change = CFrame.new(Distance,0,0)
		end

		RenderMoveChanges(Change)

	end)



	AccessoryTransformPane.PositionXYZ.X.Frame.TextBox.FocusLost:Connect(function(enter)
		if not enter then return end
		if #SelectedAccessories == 0 then ErrorReport("Please select an accessory.") return end
		local s = tonumber(AccessoryTransformPane.PositionXYZ.X.Frame.TextBox.Text)
		if not s then ErrorReport("Please enter a valid number.") return end
		local max = 5
		if OwnsBetterCustomizationGamepass then max = 10 end
		s = math.clamp(s, -max, max)
		BeginAccessoryHistory()
		for i, accessorytable in ipairs(SelectedAccessories) do
			if not accessorytable.IsMeshPart then
				local Obj = accessorytable.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChildOfClass("Weld")
				local distanceFromOrigin = accessorytable.DistanceFromOrigin
				local RotationsApplied = accessorytable.RotationsApplied
				local original = accessorytable.OriginalC0:Inverse()
				local weldPCF = Weld.Part1.CFrame
				local rx, ry, rz = RotationsApplied.X, RotationsApplied.Y, RotationsApplied.Z
				local originalrx, originalry, originalrz = accessorytable.RootRotation.X, accessorytable.RootRotation.Y, accessorytable.RootRotation.Z
				local PositionCF = (weldPCF * CFrame.new(original.X - s, original.Y - distanceFromOrigin.Y, original.Z - distanceFromOrigin.Z)).Position
				local RotationCF = weldPCF.Rotation * CFrame.fromEulerAnglesXYZ(originalrx+rx, originalry+ry, originalrz+rz)
				accessorytable.AccessoryWeld.C0 = (RotationCF + PositionCF):ToObjectSpace(weldPCF)
				accessorytable.AccessoryWeld.C1 = CFrame.new(0,0,0)
				accessorytable.DistanceFromOrigin = Vector3.new(s, distanceFromOrigin.Y, distanceFromOrigin.Z)
			end
		end

		local returned = CustomizationInvoke:InvokeServer("Position", SelectedAccessories)
		if not returned then CancelAccessoryHistory(); ErrorReport("Error updating Position.") return end

		UpdateProperties()
		CommitAccessoryHistory()
	end)

	AccessoryTransformPane.PositionXYZ.Y.Frame.TextBox.FocusLost:Connect(function(enter)
		if not enter then return end
		if #SelectedAccessories == 0 then ErrorReport("Please select an accessory.") return end
		local s = tonumber(AccessoryTransformPane.PositionXYZ.Y.Frame.TextBox.Text)
		if not s then ErrorReport("Please enter a valid number.") return end
		local max = 5
		if OwnsBetterCustomizationGamepass then max = 10 end
		s = math.clamp(s, -max, max)
		BeginAccessoryHistory()
		for i, accessorytable in ipairs(SelectedAccessories) do
			if not accessorytable.IsMeshPart then
				local Obj = accessorytable.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChildOfClass("Weld")
				local distanceFromOrigin = accessorytable.DistanceFromOrigin
				local RotationsApplied = accessorytable.RotationsApplied
				local original = accessorytable.OriginalC0:Inverse()
				local weldPCF = Weld.Part1.CFrame
				local rx, ry, rz = RotationsApplied.X, RotationsApplied.Y, RotationsApplied.Z
				local originalrx, originalry, originalrz = accessorytable.RootRotation.X, accessorytable.RootRotation.Y, accessorytable.RootRotation.Z
				local PositionCF = (weldPCF * CFrame.new(original.X - distanceFromOrigin.X, original.Y - s, original.Z - distanceFromOrigin.Z)).Position
				local RotationCF = weldPCF.Rotation * CFrame.fromEulerAnglesXYZ(originalrx+rx, originalry+ry, originalrz+rz)
				accessorytable.AccessoryWeld.C0 = (RotationCF + PositionCF):ToObjectSpace(weldPCF)
				accessorytable.AccessoryWeld.C1 = CFrame.new(0,0,0)
				accessorytable.DistanceFromOrigin = Vector3.new(distanceFromOrigin.X, s, distanceFromOrigin.Z)
			end
		end

		local returned = CustomizationInvoke:InvokeServer("Position", SelectedAccessories)
		if not returned then CancelAccessoryHistory(); ErrorReport("Error updating Position.") return end

		UpdateProperties()
		CommitAccessoryHistory()
	end)

	AccessoryTransformPane.PositionXYZ.Z.Frame.TextBox.FocusLost:Connect(function(enter)
		if not enter then return end
		if #SelectedAccessories == 0 then ErrorReport("Please select an accessory.") return end
		local s = tonumber(AccessoryTransformPane.PositionXYZ.Z.Frame.TextBox.Text)
		if not s then ErrorReport("Please enter a valid number.")return  end
		local max = 5
		if OwnsBetterCustomizationGamepass then max = 10 end
		s = math.clamp(s, -max, max)
		BeginAccessoryHistory()
		for i, accessorytable in ipairs(SelectedAccessories) do
			if not accessorytable.IsMeshPart then
				local Obj = accessorytable.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChildOfClass("Weld")
				local distanceFromOrigin = accessorytable.DistanceFromOrigin
				local RotationsApplied = accessorytable.RotationsApplied
				local original = accessorytable.OriginalC0:Inverse()
				local weldPCF = Weld.Part1.CFrame
				local rx, ry, rz = RotationsApplied.X, RotationsApplied.Y, RotationsApplied.Z
				local originalrx, originalry, originalrz = accessorytable.RootRotation.X, accessorytable.RootRotation.Y, accessorytable.RootRotation.Z
				local PositionCF = (weldPCF * CFrame.new(original.X - distanceFromOrigin.X, original.Y - distanceFromOrigin.Y, original.Z - s)).Position
				local RotationCF = weldPCF.Rotation * CFrame.fromEulerAnglesXYZ(originalrx+rx, originalry+ry, originalrz+rz)
				accessorytable.AccessoryWeld.C0 = (RotationCF + PositionCF):ToObjectSpace(weldPCF)
				accessorytable.AccessoryWeld.C1 = CFrame.new(0,0,0)
				accessorytable.DistanceFromOrigin = Vector3.new(distanceFromOrigin.X, distanceFromOrigin.Y, s)
			end
		end

		local returned = CustomizationInvoke:InvokeServer("Position", SelectedAccessories)
		if not returned then CancelAccessoryHistory(); ErrorReport("Error updating Position.") return end

		UpdateProperties()
		CommitAccessoryHistory()
	end)



	-- Rotation Handles

	local function RenderRotationChanges(Change)
		--warn("Rotation changes:", Change, "FOCAL MODE:", CurrentFocalMode, "CURRENT MOVEMENT MODE:", CurrentMovementMode)
		local newCF = (Origin * Change)
		FocalPointPart.CFrame = newCF

		for i, accessorytable in ipairs(SelectedAccessories) do
			if accessorytable.IsItemPack then
				local Obj = accessorytable.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChild("AccessoryWeld")
				if CurrentMovementMode == "Local" then
					Weld.C0 = (TempBin[i][1] * Change):ToObjectSpace(Weld.Part1.CFrame)
					Weld.C1 = CFrame.new(0,0,0)
					accessorytable.AccessoryWeld.C0 = Weld.C0
					accessorytable.AccessoryWeld.C1 = Weld.C1
				elseif CurrentMovementMode == "Global" then
					Weld.C0 = (newCF * TempBin[i][2]:Inverse()):ToObjectSpace(Weld.Part1.CFrame)
					Weld.C1 = CFrame.new(0,0,0)
					accessorytable.AccessoryWeld.C0 = Weld.C0
					accessorytable.AccessoryWeld.C1 = Weld.C1
				end
			elseif not accessorytable.IsMeshPart then
				local Obj = accessorytable.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChildOfClass("Weld")
				if CurrentMovementMode == "Local" then
					Weld.C0 = (TempBin[i][1] * Change):ToObjectSpace(Weld.Part1.CFrame)
					Weld.C1 = CFrame.new(0,0,0)
					accessorytable.AccessoryWeld.C0 = Weld.C0
					accessorytable.AccessoryWeld.C1 = Weld.C1
				elseif CurrentMovementMode == "Global" then
					Weld.C0 = (newCF * TempBin[i][2]:Inverse()):ToObjectSpace(Weld.Part1.CFrame)
					Weld.C1 = CFrame.new(0,0,0)
					accessorytable.AccessoryWeld.C0 = Weld.C0
					accessorytable.AccessoryWeld.C1 = Weld.C1
				end
			end

		end

	end

	RotationHandles.MouseDrag:Connect(function(Axis, RelativeAngle, deltaRadius)
		local degrees = math.deg(RelativeAngle)
		local unitmoved=math.round(degrees/6)
		--RotationOrigin = accessory.Handle.CFrame
		--local rcf = Origin - Origin.Position

		if LastNotedChange ~= 0 and LastNotedChange == unitmoved then print("NOT POSTING") return end

		local Change
		if Axis == Enum.Axis.X then
			Change = CFrame.fromEulerAnglesXYZ(math.rad(degrees),0,0)
		elseif Axis == Enum.Axis.Y then
			Change = CFrame.fromEulerAnglesXYZ(0,math.rad(degrees),0)
		elseif Axis == Enum.Axis.Z then
			Change = CFrame.fromEulerAnglesXYZ(0,0,math.rad(degrees))
		end

		RenderRotationChanges(Change)
	end)

	AccessoryTransformPane.RotationXYZ.X.Frame.TextBox.FocusLost:Connect(function(enter)
		if not enter then return end
		if #SelectedAccessories == 0 then ErrorReport("Please select an accessory.") return end
		local s = tonumber(AccessoryTransformPane.RotationXYZ.X.Frame.TextBox.Text)
		if not s then ErrorReport("Please enter a valid number.") return end
		s = math.clamp(s, -360, 360)
		BeginAccessoryHistory()
		for i, accessorytable in ipairs(SelectedAccessories) do
			if accessorytable.IsItemPack then
				local Obj = accessorytable.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChild("AccessoryWeld")
				local distanceFromOrigin = accessorytable.DistanceFromOrigin
				local RotationsApplied = accessorytable.RotationsApplied
				local original = accessorytable.OriginalC0:Inverse()
				local weldPCF = Weld.Part1.CFrame
				local rx, ry, rz = RotationsApplied.X, RotationsApplied.Y, RotationsApplied.Z
				rx = math.rad(s)
				local originalrx, originalry, originalrz = accessorytable.RootRotation.X, accessorytable.RootRotation.Y, accessorytable.RootRotation.Z
				local PositionCF = (weldPCF * CFrame.new(original.X - distanceFromOrigin.X, original.Y - distanceFromOrigin.Y, original.Z - distanceFromOrigin.Z)).Position
				local RotationCF = weldPCF.Rotation * CFrame.fromEulerAnglesXYZ(originalrx+rx, originalry+ry, originalrz+rz)
				accessorytable.AccessoryWeld.C0 = (RotationCF + PositionCF):ToObjectSpace(weldPCF)
				accessorytable.AccessoryWeld.C1 = CFrame.new(0,0,0)
				accessorytable.RotationsApplied = Vector3.new(rx, ry,rz)
			elseif not accessorytable.IsMeshPart then
				local Obj = accessorytable.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChildOfClass("Weld")
				local distanceFromOrigin = accessorytable.DistanceFromOrigin
				local RotationsApplied = accessorytable.RotationsApplied
				local original = accessorytable.OriginalC0:Inverse()
				local weldPCF = Weld.Part1.CFrame
				local rx, ry, rz = RotationsApplied.X, RotationsApplied.Y, RotationsApplied.Z
				rx = math.rad(s)
				local originalrx, originalry, originalrz = accessorytable.RootRotation.X, accessorytable.RootRotation.Y, accessorytable.RootRotation.Z
				local PositionCF = (weldPCF * CFrame.new(original.X - distanceFromOrigin.X, original.Y - distanceFromOrigin.Y, original.Z - distanceFromOrigin.Z)).Position
				local RotationCF = weldPCF.Rotation * CFrame.fromEulerAnglesXYZ(originalrx+rx, originalry+ry, originalrz+rz)
				accessorytable.AccessoryWeld.C0 = (RotationCF + PositionCF):ToObjectSpace(weldPCF)
				accessorytable.AccessoryWeld.C1 = CFrame.new(0,0,0)
				accessorytable.RotationsApplied = Vector3.new(rx, ry,rz)
			end

		end

		local returned = CustomizationInvoke:InvokeServer("Rotation", SelectedAccessories)
		if not returned then CancelAccessoryHistory(); ErrorReport("Error updating Rotation.") return end

		UpdateProperties()
		CommitAccessoryHistory()
	end)

	AccessoryTransformPane.RotationXYZ.Y.Frame.TextBox.FocusLost:Connect(function(enter)
		if not enter then return end
		if #SelectedAccessories == 0 then ErrorReport("Please select an accessory.") return end
		local s = tonumber(AccessoryTransformPane.RotationXYZ.Y.Frame.TextBox.Text)
		if not s then ErrorReport("Please enter a valid number.") return end
		s = math.clamp(s, -360, 360)
		BeginAccessoryHistory()
		for i, accessorytable in ipairs(SelectedAccessories) do
			if accessorytable.IsItemPack then
				local Obj = accessorytable.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChild("AccessoryWeld")
				local distanceFromOrigin = accessorytable.DistanceFromOrigin
				local RotationsApplied = accessorytable.RotationsApplied
				local original = accessorytable.OriginalC0:Inverse()
				local weldPCF = Weld.Part1.CFrame
				local rx, ry, rz = RotationsApplied.X, RotationsApplied.Y, RotationsApplied.Z
				ry = math.rad(s)
				local originalrx, originalry, originalrz = accessorytable.RootRotation.X, accessorytable.RootRotation.Y, accessorytable.RootRotation.Z
				local PositionCF = (weldPCF * CFrame.new(original.X - distanceFromOrigin.X, original.Y - distanceFromOrigin.Y, original.Z - distanceFromOrigin.Z)).Position
				local RotationCF = weldPCF.Rotation * CFrame.fromEulerAnglesXYZ(originalrx+rx, originalry+ry, originalrz+rz)
				accessorytable.AccessoryWeld.C0 = (RotationCF + PositionCF):ToObjectSpace(weldPCF)
				accessorytable.AccessoryWeld.C1 = CFrame.new(0,0,0)
				accessorytable.RotationsApplied = Vector3.new(rx, ry,rz)
			elseif not accessorytable.IsMeshPart then
				local Obj = accessorytable.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChildOfClass("Weld")
				local distanceFromOrigin = accessorytable.DistanceFromOrigin
				local RotationsApplied = accessorytable.RotationsApplied
				local original = accessorytable.OriginalC0:Inverse()
				local weldPCF = Weld.Part1.CFrame
				local rx, ry, rz = RotationsApplied.X, RotationsApplied.Y, RotationsApplied.Z
				ry = math.rad(s)
				local originalrx, originalry, originalrz = accessorytable.RootRotation.X, accessorytable.RootRotation.Y, accessorytable.RootRotation.Z
				local PositionCF = (weldPCF * CFrame.new(original.X - distanceFromOrigin.X, original.Y - distanceFromOrigin.Y, original.Z - distanceFromOrigin.Z)).Position
				local RotationCF = weldPCF.Rotation * CFrame.fromEulerAnglesXYZ(originalrx+rx, originalry+ry, originalrz+rz)
				accessorytable.AccessoryWeld.C0 = (RotationCF + PositionCF):ToObjectSpace(weldPCF)
				accessorytable.AccessoryWeld.C1 = CFrame.new(0,0,0)
				accessorytable.RotationsApplied = Vector3.new(rx, ry,rz)
			end
		end

		local returned = CustomizationInvoke:InvokeServer("Rotation", SelectedAccessories)
		if not returned then CancelAccessoryHistory(); ErrorReport("Error updating Rotation.") return end

		UpdateProperties()
		CommitAccessoryHistory()
	end)

	AccessoryTransformPane.RotationXYZ.Z.Frame.TextBox.FocusLost:Connect(function(enter)
		if not enter then return end
		if #SelectedAccessories == 0 then ErrorReport("Please select an accessory.") return end
		local s = tonumber(AccessoryTransformPane.RotationXYZ.Z.Frame.TextBox.Text)
		if not s then ErrorReport("Please enter a valid number.") return end
		s = math.clamp(s, -360, 360)
		BeginAccessoryHistory()
		for i, accessorytable in ipairs(SelectedAccessories) do
			if accessorytable.IsItemPack then
				local Obj = accessorytable.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChild("AccessoryWeld")
				local distanceFromOrigin = accessorytable.DistanceFromOrigin
				local RotationsApplied = accessorytable.RotationsApplied
				local original = accessorytable.OriginalC0:Inverse()
				local weldPCF = Weld.Part1.CFrame
				local rx, ry, rz = RotationsApplied.X, RotationsApplied.Y, RotationsApplied.Z
				rz = math.rad(s)
				local originalrx, originalry, originalrz = accessorytable.RootRotation.X, accessorytable.RootRotation.Y, accessorytable.RootRotation.Z
				local PositionCF = (weldPCF * CFrame.new(original.X - distanceFromOrigin.X, original.Y - distanceFromOrigin.Y, original.Z - distanceFromOrigin.Z)).Position
				local RotationCF = weldPCF.Rotation * CFrame.fromEulerAnglesXYZ(originalrx+rx, originalry+ry, originalrz+rz)
				accessorytable.AccessoryWeld.C0 = (RotationCF + PositionCF):ToObjectSpace(weldPCF)
				accessorytable.AccessoryWeld.C1 = CFrame.new(0,0,0)
				accessorytable.RotationsApplied = Vector3.new(rx, ry,rz)
			elseif not accessorytable.IsMeshPart then
				local Obj = accessorytable.Object
				local Handle = Obj.Handle
				local Weld = Handle:FindFirstChildOfClass("Weld")
				local distanceFromOrigin = accessorytable.DistanceFromOrigin
				local RotationsApplied = accessorytable.RotationsApplied
				local original = accessorytable.OriginalC0:Inverse()
				local weldPCF = Weld.Part1.CFrame
				local rx, ry, rz = RotationsApplied.X, RotationsApplied.Y, RotationsApplied.Z
				rz = math.rad(s)
				local originalrx, originalry, originalrz = accessorytable.RootRotation.X, accessorytable.RootRotation.Y, accessorytable.RootRotation.Z
				local PositionCF = (weldPCF * CFrame.new(original.X - distanceFromOrigin.X, original.Y - distanceFromOrigin.Y, original.Z - distanceFromOrigin.Z)).Position
				local RotationCF = weldPCF.Rotation * CFrame.fromEulerAnglesXYZ(originalrx+rx, originalry+ry, originalrz+rz)
				accessorytable.AccessoryWeld.C0 = (RotationCF + PositionCF):ToObjectSpace(weldPCF)
				accessorytable.AccessoryWeld.C1 = CFrame.new(0,0,0)
				accessorytable.RotationsApplied = Vector3.new(rx, ry,rz)
			end
		end

		local returned = CustomizationInvoke:InvokeServer("Rotation", SelectedAccessories)
		if not returned then CancelAccessoryHistory(); ErrorReport("Error updating Rotation.") return end

		UpdateProperties()
		CommitAccessoryHistory()
	end)

	-- Size Handles

	local function RenderSizeChanges(Change)



		for i, accessorytable in ipairs(SelectedAccessories) do
			if accessorytable.IsItemPack then
				--[[local Obj = accessorytable.Object
				local Handle = Obj.Handle
				Obj:ScaleTo(TempBin[i][3] + Change.magnitude)
				accessorytable.ScaleFactor = Obj:GetScale()]]
				-- ScaleTo isnt supported yet, so
			elseif accessorytable.IsMeshPart then
				--[[local Obj = accessorytable.Object
				local Handle = Obj.Handle				
				Handle.Size = TempBin[i][3] + Change	]]	
			else
				local Obj = accessorytable.Object
				local Handle = Obj.Handle
				Handle:FindFirstChildOfClass("SpecialMesh").Scale = TempBin[i][3] + Change
				accessorytable.Scale = TempBin[i][3] + Change

				if SelectedAccessories[1].IsItemPack then
					FocalPointPart.Size = SelectedAccessories[1].Object.Handle.Size
				elseif SelectedAccessories[1].IsMeshPart then
					--FocalPointPart.Size = SelectedAccessories[1].Object.Handle.Size
				else
					FocalPointPart.Size = SelectedAccessories[1].Object.Handle:FindFirstChildOfClass("SpecialMesh").Scale
				end
			end
		end
		if SelectedAccessories[1].IsItemPack then
			FocalPointPart.Size = SelectedAccessories[1].Object.Handle.Size
		else

			if SelectedAccessories[1].Object.Handle:IsA("MeshPart") then
				FocalPointPart.Size = SelectedAccessories[1].Object.Handle.Size
			else
				FocalPointPart.Size = SelectedAccessories[1].Object.Handle:FindFirstChildOfClass("SpecialMesh").Scale
			end

		end

	end

	SizeHandles.MouseDrag:Connect(function(Face, Distance)
		local unitmoved=math.round(Distance/TransformIncrement)
		if LastNotedChange ~= 0 and LastNotedChange == unitmoved then return end
		local Change
		if Face == Enum.NormalId.Front or Face == Enum.NormalId.Back then
			Change = Vector3.new(0,0,Distance)
		elseif Face == Enum.NormalId.Top or Face == Enum.NormalId.Bottom then
			Change = Vector3.new(0,Distance,0)
		elseif Face == Enum.NormalId.Left or Face == Enum.NormalId.Right then
			Change = Vector3.new(Distance,0,0)
		end

		RenderSizeChanges(Change)
	end)

	AccessoryTransformPane.SizeXYZ.X.Frame.TextBox.FocusLost:Connect(function(enter)
		if not enter then return end
		if MajorDebounce then return end
		local number = math.clamp(tonumber(AccessoryTransformPane.SizeXYZ.X.Frame.TextBox.Text), -SizeConstaints, SizeConstaints)
		if number == nil then ErrorReport("Please enter a valid number.") return end
		if #SelectedAccessories == 0 then ErrorReport("Please select an accessory.") return end
		MajorDebounce = true
		BeginAccessoryHistory()
		FocalPointPart.Size = Vector3.new(number, FocalPointPart.Size.Y, FocalPointPart.Size.Z)
		for i, accessorytable in ipairs(SelectedAccessories) do
			if not accessorytable.IsMeshPart or not accessorytable.IsItemPack then
				accessorytable.Scale = Vector3.new(number, accessorytable.Scale.Y, accessorytable.Scale.Z)
			end
		end

		local returned = CustomizationInvoke:InvokeServer("Size", SelectedAccessories)
		if not returned then CancelAccessoryHistory(); ErrorReport("Error updating Size.") return end
		wait()
		MajorDebounce = false
		CommitAccessoryHistory()
		UpdateProperties()
	end)

	AccessoryTransformPane.SizeXYZ.Y.Frame.TextBox.FocusLost:Connect(function(enter)
		if not enter then return end
		if MajorDebounce then return end
		local number = math.clamp(tonumber(AccessoryTransformPane.SizeXYZ.Y.Frame.TextBox.Text), -SizeConstaints, SizeConstaints)
		if number == nil then ErrorReport("Please enter a valid number.") return end
		if #SelectedAccessories == 0 then ErrorReport("Please select an accessory.") return end
		MajorDebounce = true
		BeginAccessoryHistory()
		FocalPointPart.Size = Vector3.new(number, FocalPointPart.Size.Y, FocalPointPart.Size.Z)
		for i, accessorytable in ipairs(SelectedAccessories) do
			if not accessorytable.IsMeshPart or not accessorytable.IsItemPack then
				accessorytable.Scale = Vector3.new(accessorytable.Scale.X, number, accessorytable.Scale.Z)
			end
		end

		local returned = CustomizationInvoke:InvokeServer("Size", SelectedAccessories)
		if not returned then CancelAccessoryHistory(); ErrorReport("Error updating Size.") return end
		wait()
		MajorDebounce = false
		CommitAccessoryHistory()
		UpdateProperties()
	end)

	AccessoryTransformPane.SizeXYZ.Z.Frame.TextBox.FocusLost:Connect(function(enter)
		if not enter then return end
		if MajorDebounce then return end
		local number = math.clamp(tonumber(AccessoryTransformPane.SizeXYZ.Z.Frame.TextBox.Text), -SizeConstaints, SizeConstaints)
		if number == nil then ErrorReport("Please enter a valid number.") return end
		if #SelectedAccessories == 0 then ErrorReport("Please select an accessory.") return end
		MajorDebounce = true
		BeginAccessoryHistory()
		FocalPointPart.Size = Vector3.new(number, FocalPointPart.Size.Y, FocalPointPart.Size.Z)
		for i, accessorytable in ipairs(SelectedAccessories) do
			if not accessorytable.IsMeshPart or not accessorytable.IsItemPack then
				accessorytable.Scale = Vector3.new(accessorytable.Scale.X, accessorytable.Scale.Y , number)
			end
		end

		local returned = CustomizationInvoke:InvokeServer("Size", SelectedAccessories)
		if not returned then CancelAccessoryHistory(); ErrorReport("Error updating Size.") return end
		wait()
		MajorDebounce = false
		CommitAccessoryHistory()
		UpdateProperties()
	end)

	-- Body Part Selection

	do
		local MirrorAccessoryButton = CustomizationUI:FindFirstChild("MirrorAccessory", true)
		if MirrorAccessoryButton and MirrorAccessoryButton:IsA("GuiButton") then
			MirrorAccessoryButton.MouseButton1Down:Connect(function()
				local res = if MirrorAccessoryButton:FindFirstChild("Slide") then TweenButtonClick(MirrorAccessoryButton) else true
				if res == false then return end
				if MajorDebounce then return end
				if #SelectedAccessories == 0 then ErrorReport("Please select an accessory to mirror.") return end

				MajorDebounce = true
				BeginAccessoryHistory()
				local returned = CustomizationInvoke:InvokeServer("MirrorAccessory", SelectedAccessories)
				if returned == false then CancelAccessoryHistory(); ErrorReport("Unable to mirror selected accessory. Make sure it is attached to a left/right body part.") return end

				for i, returnedAccessoryTable in ipairs(returned) do
					for _, selectedAccessoryTable in ipairs(SelectedAccessories) do
						if selectedAccessoryTable.Object == returnedAccessoryTable.Object then
							selectedAccessoryTable.WeldPart = returnedAccessoryTable.WeldPart
							selectedAccessoryTable.AccessoryWeld.C0 = returnedAccessoryTable.AccessoryWeld.C0
							selectedAccessoryTable.AccessoryWeld.C1 = returnedAccessoryTable.AccessoryWeld.C1
							selectedAccessoryTable.DistanceFromOrigin = returnedAccessoryTable.DistanceFromOrigin
							selectedAccessoryTable.RotationsApplied = returnedAccessoryTable.RotationsApplied
							break
						end
					end
				end

				CommitAccessoryHistory()
				UpdateProperties()
				MajorDebounce = false
			end)
		else
			warn("MirrorAccessory button not found under Customization")
		end

		for i, button in pairs(AccessoryBodyPartPane._Weld:GetChildren()) do
			if button:IsA("TextButton") then
				button.MouseButton1Click:Connect(function()
					if MajorDebounce then return end
					if #SelectedAccessories == 0 then ErrorReport("Please select an accessory to adjust.") return end
					MajorDebounce = true
					BeginAccessoryHistory()
					local flagged = false
					local partName = button.Name:sub(5,#button.Name)
					for z, accessorytable in ipairs(SelectedAccessories) do
						if not accessorytable.IsMeshPart then
							accessorytable.WeldPart = partName
						else
							flagged = true
						end				
					end
					local returned = CustomizationInvoke:InvokeServer("WeldPart", SelectedAccessories, partName)
					if not returned then CancelAccessoryHistory(); ErrorReport("Unable to change body part attachment.") return end
					wait()
					CommitAccessoryHistory()

					MajorDebounce = false
					if flagged then ErrorReport("Changes applied except to Layered Clothing due to Roblox limitations.") end
				end)
			end
		end
	end

	-- Particles

	do

		-- adding particles
		local function evalNS(ns, Time)
			-- If we are at 0 or 1, return the first or last value respectively
			if Time == 0 then return ns.Keypoints[1].Value end
			if Time == 1 then return ns.Keypoints[#ns.Keypoints].Value end
			-- Step through each sequential pair of keypoints and see if alpha
			-- lies between the points' time values.
			for i = 1, #ns.Keypoints - 1 do
				local this = ns.Keypoints[i]
				local Next = ns.Keypoints[i + 1]
				if Time >= this.Time and Time < Next.Time then
					-- Calculate how far alpha lies between the points
					local alpha = (Time - this.Time) / (Next.Time - this.Time)
					-- Evaluate the real value between the points using alpha
					return (Next.Value - this.Value) * alpha + this.Value
				end
			end
		end

		for i, button in pairs(AccessoryParticlePane.Presets:GetChildren()) do
			if button:IsA("TextButton") then
				button.MouseButton1Down:Connect(function()
					local res = TweenButtonClick(button)
					if not res then return end
					if not OwnsBetterCustomizationGamepass then return end
					if #SelectedAccessories == 0 then ErrorReport("Please select an accessory.") return end
					if MajorDebounce then return end
					MajorDebounce = true
					BeginAccessoryHistory()
					local result = CustomizationInvoke:InvokeServer("Particle", SelectedAccessories, button.Name)
					if result == false then CancelAccessoryHistory(); ErrorReport("Error while attempting to update particles.") return end

					for index, accessorytable in ipairs(SelectedAccessories) do
						local Handle = accessorytable.Object.Handle

						accessorytable.Particle = button.Name
						local emitter = Handle:FindFirstChildOfClass("ParticleEmitter")
						if emitter then
							if emitter.Name == "GentleAura" then
								accessorytable.ParticleSize = evalNS(emitter.Size, 0.5)
								--accessorytable.ParticleColor = Color3.new(1,1,1)
								accessorytable.ParticleTransparency = evalNS(emitter.Transparency, 0.5)
								accessorytable.ParticleRate = emitter.Rate
							elseif emitter.Name == "HardSmoke" then
								accessorytable.ParticleSize = evalNS(emitter.Size, 0.3)
								--accessorytable.ParticleColor = Color3.new(1,1,1)
								accessorytable.ParticleTransparency = evalNS(emitter.Transparency, 0.5)
								accessorytable.ParticleRate = emitter.Rate
							elseif emitter.Name == "SoftSmoke" then
								accessorytable.ParticleSize = evalNS(emitter.Size, 0.3)
								--accessorytable.ParticleColor = Color3.new(1,1,1)
								accessorytable.ParticleTransparency = evalNS(emitter.Transparency, 0.5)
								accessorytable.ParticleRate = emitter.Rate
							elseif emitter.Name == "Lightning" then
								accessorytable.ParticleSize = evalNS(emitter.Size, 0)
								--accessorytable.ParticleColor = Color3.new(1,1,1)
								accessorytable.ParticleTransparency = evalNS(emitter.Transparency, 0)
								accessorytable.ParticleRate = emitter.Rate
							elseif emitter.Name == "Fire" then
								accessorytable.ParticleSize = evalNS(emitter.Size, 0)
								--accessorytable.ParticleColor = Color3.new(1,1,1)
								accessorytable.ParticleTransparency = evalNS(emitter.Transparency, 0)
								accessorytable.ParticleRate = emitter.Rate
							end
						else
							accessorytable.ParticleSize = 0
							accessorytable.ParticleColor = Color3.new(1,1,1)
							accessorytable.ParticleTransparency = 0
							accessorytable.ParticleRate = 0
						end
					end
					UpdateProperties()
					CommitAccessoryHistory()
					wait()
					MajorDebounce = false
				end)


			end
		end



		-- particle color


		PColorUI.Finished:Connect(function(color)
			if MajorDebounce then return end
			if not OwnsBetterCustomizationGamepass then return end
			if #SelectedAccessories == 0 then ErrorReport("Please select an Accessory to edit.") return end
			MajorDebounce = true
			BeginAccessoryHistory()
			for i, accessorytable in ipairs(SelectedAccessories) do
				accessorytable.ParticleColor = color
			end
			local result = CustomizationInvoke:InvokeServer("PColor", SelectedAccessories)
			if not result then CancelAccessoryHistory(); ErrorReport("Unable to set Particle color.") return end
			UpdateProperties()
			CommitAccessoryHistory()
			wait()
			MajorDebounce = false
		end)

		local ParticleWindow = PColorUI.Window.Properties.Particles
		ParticleWindow.R.Frame.TextBox.FocusLost:Connect(function(enter)
			if not enter then return end
			if not OwnsBetterCustomizationGamepass then return end
			if MajorDebounce then return end
			if #SelectedAccessories == 0 then ErrorReport("Please select an accessory to edit.") return end
			local number = tonumber(ParticleWindow.R.Frame.TextBox.Text)
			if not number then ErrorReport("Please enter a valid number.") return end
			number = math.clamp(number, 0, 500)
			MajorDebounce = true
			BeginAccessoryHistory()
			for index, AccessoryTable in ipairs(SelectedAccessories) do
				if AccessoryTable.Particle ~= "Fire" and AccessoryTable.Particle ~= "None" then
					AccessoryTable.ParticleRate = math.clamp(number, 0, 50)
				else
					AccessoryTable.ParticleRate = number
				end
			end
			local result = CustomizationInvoke:InvokeServer("ParticleAdjust", SelectedAccessories)
			if not result then CancelAccessoryHistory(); ErrorReport("Unable to set Particle adjustment.") return end
			wait()
			print("Number:", number, "Rate after set:", SelectedAccessories[1].ParticleRate, "Particle name:", SelectedAccessories[1].Particle)
			ParticleWindow.R.Frame.TextBox.Text = tostring(number)
			MajorDebounce = false
			CommitAccessoryHistory()
			UpdateProperties()
		end)

		ParticleWindow.T.Frame.TextBox.FocusLost:Connect(function(enter)
			if not enter then return end
			if not OwnsBetterCustomizationGamepass then return end
			if MajorDebounce then return end
			if #SelectedAccessories == 0 then ErrorReport("Please select an accessory to edit.") return end
			local number = tonumber(ParticleWindow.T.Frame.TextBox.Text)
			if not number then ErrorReport("Please enter a valid number.") return end
			number = math.clamp(number, 0, 1)
			MajorDebounce = true
			BeginAccessoryHistory()
			for index, AccessoryTable in ipairs(SelectedAccessories) do
				AccessoryTable.ParticleTransparency = number
			end
			local result = CustomizationInvoke:InvokeServer("ParticleAdjust", SelectedAccessories)
			if not result then CancelAccessoryHistory(); ErrorReport("Unable to set Particle adjustment.") return end
			wait()
			ParticleWindow.T.Frame.TextBox.Text = tostring(number)
			MajorDebounce = false
			CommitAccessoryHistory()
			UpdateProperties()
		end)

		ParticleWindow.S.Frame.TextBox.FocusLost:Connect(function(enter)
			if not enter then return end
			if not OwnsBetterCustomizationGamepass then return end
			if MajorDebounce then return end
			if #SelectedAccessories == 0 then ErrorReport("Please select an accessory to edit.") return end
			local number = tonumber(ParticleWindow.S.Frame.TextBox.Text)
			if not number then ErrorReport("Please enter a valid number.") return end
			number = math.clamp(number, 0, 1.5)
			MajorDebounce = true
			BeginAccessoryHistory()
			for index, AccessoryTable in ipairs(SelectedAccessories) do
				AccessoryTable.ParticleSize = number
			end
			local result = CustomizationInvoke:InvokeServer("ParticleAdjust", SelectedAccessories)
			if not result then CancelAccessoryHistory(); ErrorReport("Unable to set Particle adjustment.") return end
			wait()
			ParticleWindow.S.Frame.TextBox.Text = tostring(number)
			MajorDebounce = false
			CommitAccessoryHistory()
			UpdateProperties()
		end)



	end

	MainUI.NoMoreSelected.Event:Connect(function(arg)
		if arg == "none" then 

			FocalPointPart.Parent = script
			FocalPointPart.Size = Vector3.new(0.5,0.5,0.5)
			PositionHandles.Adornee = nil
			SizeHandles.Adornee = nil
			RotationHandles.Adornee = nil

		elseif arg == "some" then
			FocalPointPart.Parent = workspace
			PositionHandles.Adornee = FocalPointPart
			SizeHandles.Adornee = FocalPointPart
			RotationHandles.Adornee = FocalPointPart
			if #SelectedAccessories == 1 and SizeHandles.Visible == true then
				FocalPointPart.Size = SelectedAccessories[1].Object.Handle:FindFirstChildOfClass("SpecialMesh").Scale
			end
		end
	end)

end

function IsolateNumbersInTextureID(id)
	local textureid
	if id:sub(1,70) == "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=" then
		textureid = id:sub(71, #id):match("%d+") or ""
	else
		textureid = id:match("%d+") or ""
	end

	return textureid
end

-- This finds a table with the accessory in mind so we don't have to make a new table.

local function ReadTableWithAccessory(accessory)
	for Index, Value in pairs(CharacterTable["Accessories"]) do
		if Value.Object == accessory then
			return Index,Value
		end
	end
end

function RemoveAccessoryFromSelectedAccessories(tableAssociated)

	for i, v in ipairs(SelectedAccessories) do
		if v.Object == tableAssociated.Object then
			print("Found accessory and removing from selected", v.Object.Name)
			table.remove(SelectedAccessories, i)
		end
	end

	--[[warn("DEBUG : CURRENT SELECTED ACCESSORIES")
	for i, v in ipairs(SelectedAccessories) do
		warn("DEBUG ITEM:", i, v.Object.Name)
	end]]
end



-- Main function of generating accessories (our main thing)

function GenerateAccessory(accessory)
	print("Generating new accessory frame", accessory)
	wait()
	local tableIndex, tableAssociated = ReadTableWithAccessory(accessory)

	local newFrame = AccessoryTemplate:Clone()
	newFrame.AccessoryAssociated.Value = accessory
	if tableAssociated.IsItemPack then
		newFrame.ItemPack.Value = true
		newFrame.BackgroundColor3 = Color3.fromRGB(15, 39, 19)
	end
	newFrame.Parent = AccessoriesBin


	tableAssociated["AccessoryFrame"] = newFrame


	newFrame.Name = accessory.Name
	newFrame.AccessoryName.Text = accessory.Name

	newFrame.AccessorySelected.Changed:Connect(function()
		local value = newFrame.AccessorySelected.Value
		if value == true then
			print("Adding accessory")
			table.insert(SelectedAccessories, tableAssociated)
			--[[warn("DEBUG : CURRENT SELECTED ACCESSORIES")
			for i, v in ipairs(SelectedAccessories) do
				warn("DEBUG ITEM:", i, v.Object.Name)
			end]]
		else
			RemoveAccessoryFromSelectedAccessories(tableAssociated)
		end
		UpdateProperties()
	end)
end

-- Accessory Detection and Adding

function RefreshAccessoryList(child, NewTable, Override)
	if not Override and IgnoreIncomingAccessory == true then return end




	if child then 
		if not child:IsA("Accessory") then


			if child.Parent ~= Character then
				print("Destroying", child.Name)
				for x, z in pairs(CharacterTable["Accessories"]) do
					if z.Object == child then
						local thing = z.AccessoryFrame
						if thing then thing:Destroy() end
						Character:FindFirstChild(CharacterTable["Accessories"][x].WeldPart).Anchored = false

						table.remove(CharacterTable["Accessories"], x)
						RemoveAccessoryFromSelectedAccessories(z)
						warn("Found removed accessory!", child)

						break
					end
				end
			else
				if child:GetAttribute("displayAccessory") == true then
					local currentlyexists = false
					for x, z in pairs(CharacterTable["Accessories"]) do
						if z.Object == child then
							currentlyexists = true
							GenerateAccessory(child)
						end
					end
					if not currentlyexists then
						print("Brand new accessory found!", child)
						wait()
						local newTable = CreateNewItemPackTable(child)
						table.insert(CharacterTable["Accessories"], newTable); warn("Added new Item Pack Item to character table", child)
						GenerateAccessory(child)
					end
				end	
			end
			return 	
		end



		if child.Parent ~= Character then
			print("Destroying")
			for x, z in pairs(CharacterTable["Accessories"]) do
				if z.Object == child then
					local thing = z.AccessoryFrame
					if thing then thing:Destroy() end
					if not CharacterTable["Accessories"][x].IsMeshPart then
						Character:FindFirstChild(CharacterTable["Accessories"][x].WeldPart).Anchored = false
					end
					table.remove(CharacterTable["Accessories"], x)
					RemoveAccessoryFromSelectedAccessories(z)
					warn("Found removed accessory!", child)

					break
				end
			end
			return	
		else

			local currentlyexists = false
			for x, z in pairs(CharacterTable["Accessories"]) do
				if z.Object == child then
					currentlyexists = true
					GenerateAccessory(child)
				end
			end
			if not currentlyexists then
				print("Brand new accessory found!", child)
				wait()
				local newTable = CreateNewAccessoryTable(child)
				if not newTable then return end
				for i, v in pairs(CharacterTable["Accessories"]) do
					--print("Character table check", i, v)
				end
				table.insert(CharacterTable["Accessories"], newTable); warn("Added new accessory to character table", child)
				GenerateAccessory(child)
			end

		end


	else

		for i, v in pairs(CustomizationUI.AccessoriesBox.Bin:GetChildren()) do
			if v:IsA("TextButton") then
				v:Destroy()
			end
		end

		for i, v in pairs(CustomizationUI.OptionsBin:GetChildren()) do
			v:Destroy()
		end

		for i, v in pairs(script.HandlesBin:GetChildren()) do
			v:Destroy()
		end

		if NewTable then
			print("Refreshing accessories with new table.")
			CharacterTable = NewTable
			for i, v in pairs(NewTable["Accessories"]) do
				GenerateAccessory(v.Object)
			end
		else
			print("Refreshing accessories without new table")
			CharacterTable["Accessories"] = {}
			for i, child in pairs(Character:GetChildren()) do
				if child:IsA("Accessory") then

					local currentlyexists = false
					for x, z in pairs(CharacterTable["Accessories"]) do
						if z.Object == child then
							currentlyexists = true
							GenerateAccessory(child)
						end
					end
					if not currentlyexists then
						print("Brand new accessory found!", child)
						local newTable = CreateNewAccessoryTable(child)
						if not newTable then return end
						table.insert(CharacterTable["Accessories"], newTable); warn("Added new accessory to character table", child)
						GenerateAccessory(child)
					end
				elseif child:GetAttribute("displayAccessory") == true then
					local currentlyexists = false
					for x, z in pairs(CharacterTable["Accessories"]) do
						if z.Object == child then
							currentlyexists = true
							GenerateAccessory(child)
						end
					end
					if not currentlyexists then
						print("Brand new accessory found!", child)
						local newTable = CreateNewItemPackTable(child)
						table.insert(CharacterTable["Accessories"], newTable); warn("Added new accessory to character table", child)
						GenerateAccessory(child)
					end
				end
			end



		end





	end
end

Character.ChildAdded:Connect(RefreshAccessoryList)
Character.ChildRemoved:Connect(RefreshAccessoryList)

RefreshAccessoryList()


-- Camera Controls

do
	local Camera = workspace.CurrentCamera
	local Mode = true
	local UIVisible = false

	local FocalPoint = Instance.new("Part")
	FocalPoint.CanCollide = false
	FocalPoint.Massless = true
	FocalPoint.Anchored = true

	FocalPoint.Transparency = 1
	FocalPoint.Size = Vector3.new(1,1,1)
	FocalPoint.Name = "CameraFocalPoint"
	FocalPoint.Parent = Character

	CustomizationUI.Camera.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationUI.Camera)
		if res == false then return end
		if Mode == false then 
			Mode = true
			CustomizationUI.Camera.Slide.displayText.Text = "Focused Camera: ON"
			Camera.CameraType = Enum.CameraType.Follow
		else
			CustomizationUI.Camera.Slide.displayText.Text = "Focused Camera: OFF"
			Mode = false
			Camera.CameraType = Enum.CameraType.Custom
			Camera.CameraSubject = Character.Humanoid
			FocalPoint.Parent = script
		end
	end)

	local function FindFocalPoint()

		local total = #SelectedAccessories
		local SumX = 0
		local SumY = 0
		local SumZ = 0
		for i, AccessoryTable in ipairs(SelectedAccessories) do
			if not AccessoryTable.IsMeshPart then
				SumX = Character[AccessoryTable.WeldPart].Position.X + SumX
				SumY = Character[AccessoryTable.WeldPart].Position.Y + SumY
				SumZ = Character[AccessoryTable.WeldPart].Position.Z + SumZ
			else
				SumX = Character.HumanoidRootPart.Position.X + SumX
				SumY = Character.HumanoidRootPart.Position.Y + SumY
				SumZ = Character.HumanoidRootPart.Position.Z + SumZ
			end
		end

		local Midpoint = Vector3.new(SumX/total, SumY/total, SumZ/total)
		--warn("Focal point:", Midpoint)
		return Midpoint		

	end

	RunService.Heartbeat:Connect(function()
		if Mode == true and UIVisible == true then
			if #SelectedAccessories ~= 0 then
				local pos = FindFocalPoint()
				FocalPoint.CFrame = CFrame.new(pos)
				Camera.CameraSubject = FocalPoint
			else
				Camera.CameraSubject = Character.LowerTorso
			end

		end
	end)

	CustomizationUI.Changed:Connect(function()
		if CustomizationUI.Visible == false then
			UIVisible = false
			Camera.CameraType = Enum.CameraType.Custom
			Camera.CameraSubject = Character.Humanoid
			FocalPoint.Parent = script
		else
			UIVisible = true
			if Mode == true then
				Camera.CameraType = Enum.CameraType.Follow

			end
		end
	end)

end

-- Saving and Loading
do
	print("Indexing the save slots")

	local SlotFrame = script:FindFirstChild("SlotFrame")
	local LegacySlotFrame = script:FindFirstChild("LegacySlotFrame")

	local cancel = false

	local conn1 
	local conn2
	local conn3
	local conn4


	local function SlotSelect(SlotObject)

		if conn1 then conn1:Disconnect(); conn1 = nil end
		if conn2 then conn2:Disconnect(); conn2 = nil end
		if conn3 then conn3:Disconnect(); conn3 = nil end
		if conn4 then conn4:Disconnect(); conn4 = nil end

		SlotFrame.Buttons.Visible = true
		SlotFrame.Naming.Visible = false
		SlotFrame.Parent = SlotObject
		local finished = false
		local ticked 
		cancel = true

		conn1 = SlotFrame.Buttons.Load.MouseButton1Click:Connect(function()
			conn1:Disconnect()
			conn2:Disconnect()
			conn3:Disconnect()
			conn4:Disconnect()
			finished = true
			SlotFrame.Buttons.Visible = true
			SlotFrame.Naming.Visible = false
			SlotFrame.Parent = script
			ticked = "Load"

		end)

		conn2 = SlotFrame.Buttons.Save.MouseButton1Click:Connect(function()
			SlotFrame.Buttons.Visible = false
			SlotFrame.Naming.Visible = true
		end)

		conn3 = SlotFrame.Naming.Close.MouseButton1Click:Connect(function()
			conn1:Disconnect()
			conn2:Disconnect()
			conn3:Disconnect()
			conn4:Disconnect()
			cancel = true
			SlotFrame.Parent = script

		end)

		conn4 = SlotFrame.Naming.NameButton.FocusLost:Connect(function(enterPressed)

			if enterPressed then
				local input = SlotFrame.Naming.NameButton.Text
				input = input:sub(1,30)
				SlotFrame.Naming.NameButton.Text = input
				conn1:Disconnect()
				conn2:Disconnect()
				conn3:Disconnect()
				conn4:Disconnect()
				ticked = "Save"
				finished = true
				SlotFrame.Parent = script
			end


		end)
		cancel = false
		repeat wait() until finished == true or cancel == true 
		print("f", finished, "c", cancel)
		if cancel == true then
			cancel = false
			conn1:Disconnect()
			conn2:Disconnect()
			conn3:Disconnect()
			conn4:Disconnect()
			return false
		end
		conn1:Disconnect()
		conn2:Disconnect()
		conn3:Disconnect()
		conn4:Disconnect()
		return ticked
	end

	local function LegacySlotSelect(SlotObject)

		if conn1 then conn1:Disconnect(); conn1 = nil end

		LegacySlotFrame.Buttons.Visible = true
		--LegacySlotFrame.Naming.Visible = false
		LegacySlotFrame.Parent = SlotObject
		local finished = false
		local ticked 
		cancel = true

		conn1 = LegacySlotFrame.Buttons.Load.MouseButton1Click:Connect(function()
			conn1:Disconnect()
			finished = true
			LegacySlotFrame.Buttons.Visible = true
			LegacySlotFrame.Parent = script
			ticked = "Load"
		end)


		cancel = false
		repeat wait() until finished == true or cancel == true 
		print("f", finished, "c", cancel)
		if cancel == true then
			cancel = false
			conn1:Disconnect()
			return false
		end
		conn1:Disconnect()

		return ticked
	end

	-- save/load

	print("Indexing the save slots loading functionality")
	for i, v in pairs(CustomizationUI.SaveSlots.Bin:GetChildren()) do
		if v:IsA("TextButton") then

			v.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(v)
				if res == false or MajorDebounce == true then return end


				local OptionSelected = SlotSelect(v)
				print("OptionSelected:", OptionSelected)
				if OptionSelected == false or OptionSelected == nil then return end

				if OptionSelected == "Save" then
					MajorDebounce = true
					IgnoreIncomingAccessory = true
				local Slot = tonumber(v.Name)
				local TableToSend = CharacterTable
				local SlotName = SlotFrame.Naming.NameButton.Text
				local returned = CustomizationInvoke:InvokeServer("Save", TableToSend, SlotName, Slot)
				if returned == false then ErrorReport("Error while attempting to save character slot.") return end
				MajorDebounce = false
				IgnoreIncomingAccessory = false
				v.Slide.displayText.Text = SlotName
				CurrentSlot = tonumber(v.Name)

			elseif OptionSelected == "Load" then
				CurrentSlot = tonumber(v.Name)
				LoadCharacterSlot(tonumber(v.Name))
			end
		end)

	end
end

for i, v in pairs(CustomizationUI.LegacySaveSlots.Bin:GetChildren()) do
	if v:IsA("TextButton") then

		v.MouseButton1Down:Connect(function()
			local res = TweenButtonClick(v)
			if res == false or MajorDebounce == true then return end


			local OptionSelected = LegacySlotSelect(v)
			print("OptionSelected:", OptionSelected)
			if OptionSelected == false or OptionSelected == nil then return end


			if OptionSelected == "Load" then
				CurrentSlot = nil
				LoadLegacyCharacterSlot(tonumber(v.Name))
			end
		end)

	end
end
	
	CustomizationUI.Swap.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CustomizationUI.Swap)
		if not res then return end
		if CustomizationUI.LegacySaveSlots.Visible == false then
 			CustomizationUI.LegacySaveSlots.Visible = true; CustomizationUI.SaveSlots.Visible = false; CustomizationUI.Swap.Slide.displayText.Text = "Regular"
		else 
			CustomizationUI.LegacySaveSlots.Visible = false; CustomizationUI.SaveSlots.Visible = true; CustomizationUI.Swap.Slide.displayText.Text = "Legacy"
		end
	end)
	
	
	do
		print("Indexing the AllData section")
		wait()
		local LoadingText = MainUI.Loading
		task.spawn(function()
			LoadingText.Visible = true
			for i = 1, 0, -0.01 do
				RunService.Heartbeat:Wait()
				LoadingText.TextTransparency = i
				LoadingText.TextStrokeTransparency = if i > 0.8 then i else 0.8
			end
		end)
		
		local returnedTableOfInformation = CustomizationInvoke:InvokeServer("AllData")
		print("Got all data, trying legacy data")
		local returnedTableOfLegacyInformation = CustomizationInvoke:InvokeServer("AllLegacyData")
		print("Got all legacy data")
		if returnedTableOfInformation == false then
			print("New player.")
		else
			print("Not a new player")
			for i, v in pairs(returnedTableOfInformation) do
				CustomizationUI.SaveSlots.Bin[tostring(i)].Slide.displayText.Text = v
			end
		end

		CustomizationUI.SavesLoading.Visible = false
		task.spawn(function()
			for i = 0, 1, 0.01 do
				RunService.Heartbeat:Wait()
				LoadingText.TextTransparency = i
				LoadingText.TextStrokeTransparency = if i < 0.8 then 0.8 else i
			end

			LoadingText.Visible = false
		end)
		

		if returnedTableOfLegacyInformation == false then
			print("Not an old player")
		else
			for i, v in pairs(returnedTableOfLegacyInformation) do
				if v ~= false then
					CustomizationUI.LegacySaveSlots.Bin[tostring(i)].Slide.displayText.Text = v.SlotName
				end
			end
		end

		for i, v in pairs(CustomizationUI.SaveSlots.Bin:GetChildren()) do
			if v:IsA("TextButton") then
				v.Visible = false
			end
		end

		for i = 1, MaxSlots do
			CustomizationUI.SaveSlots.Bin[tostring(i)].Visible = true
		end

		local FollowPreference = MultiverseInvoke:InvokeServer("GetFollowPreference")

		AllowsFollows = FollowPreference

		if AllowsFollows == true then AllowFollowsButton.Slide.displayText.Text = "Allow Follows: ON" else AllowFollowsButton.Slide.displayText.Text = "Allow Follows: OFF" end

		if teleportData then
			if Client.PlayerScripts.Fixer.Loaded.Value == false then 
				print("LOADED ISNT LOADED")
				if teleportData["Destination"] then
					print("WE HAVE DESTINATION")
					local dest = MultiverseInvoke:InvokeServer("Teleport", teleportData["Destination"])
					--Character.HumanoidRootPart.CFrame = ReplicatedStorage:WaitForChild("TeleportDestinations"):FindFirstChild(teleportData["Destination"]).CFrame
				end
				if teleportData["CurrentSlot"] ~= nil then
					print("WE HAVE A LAST USED SLOT", teleportData["CurrentSlot"])
					CurrentSlot = teleportData["CurrentSlot"]
					LoadCharacterSlot(teleportData["CurrentSlot"])
				end
				if teleportData["FromPlace"] ~= nil and game.PlaceId == CustomizationRoomPlaceId then
					warn("We have last place in Customization Room")
					local d = MultiverseInvoke:InvokeServer("CustomizationSwitch", teleportData["FromPlace"])
				end
			end
		end

		local i = Instance.new("IntValue")
		i.Name = "Loaded"
		i.Parent = Client

	end

end
print("Past AllData, asking server and finishing finalization until id saving.")
OOCToggle = true
CustomizationUI.Visible = false
BottomBar.Visible = true; 
--MainUI.GeneralSettings["Toggle Prompts"].Visible = true; 
MainUI.GeneralSettings["ToggleVisualizations"].Visible = true;
MainUI.Leaderboard.Visible = true
if lastHandles then
	lastHandles.Visible = false
end
CustomizingEvent:FireServer(false)
CustomizingEvent:FireServer(false)
CurrentUI = nil
CustomizationInvoke:InvokeServer("OOC", OOCToggle)

-- id saving and loading

do
	print("Indexing id saving and loading")
	local CreateIDBox = CustomizationUI.CreateID
	local LoadIDBox = CustomizationUI.LoadID
	
	local CreateIDButton = CustomizationUI.ID
	local LoadIDButton = CustomizationUI.LID
	local RefreshIDButton = CustomizationUI.Refresh
	local SaveIDButton = CustomizationUI.SaveID
	
	local CurrentID
	local CurrentCreator
	
	local outfitbuttonconnection
	local accessorybuttonconnection
	local con1
	local con2
	
	local OutfitProductId = 1262255317
	local AccessoryProductId = 1327469254
	

	local PurchaseHandlingEvent = ReplicatedStorage:WaitForChild("PurchaseHandling")
	
	local function ClearAllConnections()
		if outfitbuttonconnection then outfitbuttonconnection:Disconnect(); outfitbuttonconnection = nil end
		if accessorybuttonconnection then accessorybuttonconnection:Disconnect(); accessorybuttonconnection = nil end
		if con1 then con1:Disconnect(); con1 = nil end
		if con2 then con2:Disconnect(); con2 = nil end
	end
	
	local OutfitEditable = false
	local AccessoryEditable = true
	CreateIDBox.OutfitMode.Edit.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CreateIDBox.OutfitMode.Edit)
		if not res then return end
		if OutfitEditable == false then
			OutfitEditable = true
			CreateIDBox.OutfitMode.Edit.Slide.displayText.Text = "Editable: No"
		else
			OutfitEditable = false
			CreateIDBox.OutfitMode.Edit.Slide.displayText.Text = "Editable: Yes"
		end
	end)
	
	
	CreateIDBox.Close.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CreateIDBox.Close)
		if not res then return end
		ClearAllConnections()
		CreateIDBox.OutfitMode.IDGenerated.Text = "The ID will appear here."
		CreateIDBox.AccessoryMode.IDGenerated.Text = "The ID will appear here."
		CreateIDBox.Visible = false
		CreateIDBox.OutfitMode.Visible = false
		CreateIDBox.ModeSelect.Visible = true
		CreateIDBox.AccessoryMode.Visible = false
	end)
	LoadIDBox.Close.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(LoadIDBox.Close)
		if not res then return end
		ClearAllConnections()
		LoadIDBox.Visible = false
		LoadIDBox.Insert.Visible = true
		LoadIDBox.ModeSelect.Visible = false
		
	end)
	
	CreateIDButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(CreateIDButton)
		if not res then return end
		if LoadIDBox.Visible == true then return end
		if CreateIDBox.Visible == true then
			CreateIDBox.Visible = false
			CreateIDBox.OutfitMode.Visible = false
			CreateIDBox.ModeSelect.Visible = true
			CreateIDBox.AccessoryMode.Visible = false
			ClearAllConnections()
			CreateIDBox.OutfitMode.IDGenerated.Text = "The ID will appear here."
			CreateIDBox.AccessoryMode.IDGenerated.Text = "The ID will appear here."
			CreateIDBox.Visible = false
			CreateIDBox.OutfitMode.Visible = false
			CreateIDBox.ModeSelect.Visible = true
			CreateIDBox.AccessoryMode.Visible = false
		else
			CreateIDBox.Visible = true
			CreateIDBox.OutfitMode.Visible = false
			CreateIDBox.ModeSelect.Visible = true
			CreateIDBox.AccessoryMode.Visible = false
			
			if outfitbuttonconnection then outfitbuttonconnection:Disconnect(); outfitbuttonconnection = nil end
			if accessorybuttonconnection then accessorybuttonconnection:Disconnect(); accessorybuttonconnection = nil end
			if con1 then con1:Disconnect(); con1 = nil end
			if con2 then con2:Disconnect(); con2 = nil end
		

			
			outfitbuttonconnection = CreateIDBox.ModeSelect.Outfit.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(CreateIDBox.ModeSelect.Outfit)
				if not res then return end
				ClearAllConnections()
				CreateIDBox.ModeSelect.Visible = false
				CreateIDBox.OutfitMode.Visible = true
				 
				con1 = CreateIDBox.OutfitMode.Create.MouseButton1Down:Connect(function()
					local res = TweenButtonClick(CreateIDBox.OutfitMode.Create)
					if not res then return end
					local isPurchased = true

					--[[if not GroupVerification.CheckRank(Client, "Staff") then MarketplaceService:PromptProductPurchase(Client, OutfitProductId)
						local userid, productid, Purchased = MarketplaceService.PromptProductPurchaseFinished:Wait(); isPurchased = Purchased 
					elseif GroupVerification.CheckRank(Client, "Staff") or GamepassWhitelist[Client.UserId] then
						isPurchased = true 
					end]]

					if isPurchased == true then
						local copy = deepCopy(CharacterTable)
						for i, accessorytable in pairs(copy.Accessories) do
							if accessorytable.IsItemPack then
								table.remove(copy.Accessories, i)
							end
						end
						local returned1, returned2 = CustomizationInvoke:InvokeServer("SaveOutfitID", nil, copy, OutfitEditable)
						if returned1 == false then ErrorReport("Error while attempting to save Outfit ID.") con1:Disconnect(); con1 = nil return end
						CurrentID = returned1
						CreateIDBox.OutfitMode.IDGenerated.Text = tostring(CurrentID)
						CurrentCreator = Client.UserId
						warn("Outfit ID saved. ID:", CurrentID, "Creator:", CurrentCreator)
						CustomizationUI.CurrentID.Text = "Current ID: " .. tostring(CurrentID)
						con1:Disconnect()
						con1 = nil
					else
						CreateIDBox.Visible = false
						CreateIDBox.OutfitMode.Visible = false
						CreateIDBox.ModeSelect.Visible = true
						CreateIDBox.AccessoryMode.Visible = false
						con1:Disconnect()
						con1 = nil
					end
				end)
			end)
			
			accessorybuttonconnection = CreateIDBox.ModeSelect.Accessory.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(CreateIDBox.ModeSelect.Accessory)
				if not res then return end
				ClearAllConnections()
				CreateIDBox.ModeSelect.Visible = false
				CreateIDBox.AccessoryMode.Visible = true
				
				con2 = CreateIDBox.AccessoryMode.Create.MouseButton1Down:Connect(function()
					local res = TweenButtonClick(CreateIDBox.AccessoryMode.Create)
					if not res then return end
					local isPurchased = true
					if #SelectedAccessories == 0 then ErrorReport("Please select accessories to save to the ID.") return end
					--[[if not GroupVerification.CheckRank(Client, "Staff") then MarketplaceService:PromptProductPurchase(Client, AccessoryProductId)
						local userid, productid, Purchased = MarketplaceService.PromptProductPurchaseFinished:Wait(); isPurchased = Purchased 
					elseif GroupVerification.CheckRank(Client, "Staff") or GamepassWhitelist[Client.UserId] then
						isPurchased = true 
					end]]

					if isPurchased == true then
						local copy = deepCopy(SelectedAccessories)
						for i, accessorytable in pairs(copy) do
							if accessorytable.IsItemPack then
								table.remove(copy, i)
							end
						end
						
						local returned1, returned2 = CustomizationInvoke:InvokeServer("SaveAccessoryID", nil, copy)
						if returned1 == false then ErrorReport("Error while attempting to save Accessory ID.") return end
						if returned1 then CreateIDBox.AccessoryMode.IDGenerated.Text = tostring(returned1) end
						con2:Disconnect(); con2 = nil
					else
						CreateIDBox.Visible = false
						CreateIDBox.OutfitMode.Visible = false
						CreateIDBox.ModeSelect.Visible = true
						CreateIDBox.AccessoryMode.Visible = false
						con2:Disconnect()
						con2 = nil
					end
				end)
				
			end)
			
			
			
		end
	end)
	
	LoadIDButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(LoadIDButton)
		if not res then return end
		if CreateIDBox.Visible == true then return end
		if LoadIDBox.Visible == false then
			LoadIDBox.Visible = true
			LoadIDBox.Insert.Visible = false
			LoadIDBox.ModeSelect.Visible = true
			ClearAllConnections()
			outfitbuttonconnection = LoadIDBox.ModeSelect.Outfit.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(LoadIDBox.ModeSelect.Outfit)
				if not res then return end
				ClearAllConnections()
				LoadIDBox.Insert.Visible = true
				LoadIDBox.ModeSelect.Visible = false
				con1 = LoadIDBox.Insert.Enter.FocusLost:Connect(function(enter)
					if not enter then return end
					local text = tonumber(LoadIDBox.Insert.Enter.Text);
					if not text then ErrorReport("Please enter a valid number.") return end
					if DSDebounce then ErrorReport("The load/save cooldown is active. Wait a few seconds.") return end
					DSDebounce = true
					IgnoreIncomingAccessory = true
					table.clear(SelectedAccessories)
					local returned = CustomizationInvoke:InvokeServer("LoadOutfitID", text)
					if returned == false then ErrorReport("Error while attempting to load Outfit ID. This most likely means the ID is invalid.") return end
					DSDebounce = false
					CharacterTable = returned
					CurrentID = text
					CurrentCreator = (if CharacterTable["LockedID"] then CharacterTable["LockedID"] else nil)
					warn("Loaded outfit ID, stats:", CurrentID, CurrentCreator)
					ClearAllConnections()
					RefreshAccessoryList(nil, returned, true)
					wait()
					IgnoreIncomingAccessory = false
					ClearAccessoryHistory()

					UpdateProperties()
					CustomizationUI.CurrentID.Text = "Current ID: " .. tostring(CurrentID)
					LoadIDBox.Visible = false
					LoadIDBox.Insert.Visible = false
					LoadIDBox.ModeSelect.Visible = true
				end)
			end)
			
			accessorybuttonconnection = LoadIDBox.ModeSelect.Accessory.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(LoadIDBox.ModeSelect.Accessory)
				if not res then return end
				ClearAllConnections()
				LoadIDBox.Insert.Visible = true
				LoadIDBox.ModeSelect.Visible = false
				con1 = LoadIDBox.Insert.Enter.FocusLost:Connect(function(enter)
					if not enter then return end
					local text = tonumber(LoadIDBox.Insert.Enter.Text);
					if not text then ErrorReport("Please enter a valid number.") return end
					if DSDebounce then ErrorReport("The load/save cooldown is active. Wait a few seconds.") return end
					DSDebounce = true
					IgnoreIncomingAccessory = true
					BeginAccessoryHistory()
					local returned = CustomizationInvoke:InvokeServer("LoadAccessoryID", text)
					if returned == false then CancelAccessoryHistory(); DSDebounce = false; IgnoreIncomingAccessory = false; ErrorReport("Error while attempting to load Accessory ID. This most likely means the ID is invalid or the package is too big for your current accessory count.") return end
					
					for i, AccessoryTable in pairs(returned) do
						table.insert(CharacterTable.Accessories, AccessoryTable)
					end
					RefreshAccessoryList(nil, CharacterTable, true)
					IgnoreIncomingAccessory = false
					UpdateProperties()
					CommitAccessoryHistory()
					LoadIDBox.Visible = false
					LoadIDBox.Insert.Visible = false
					LoadIDBox.ModeSelect.Visible = true
					wait(10)
					DSDebounce = false
					
					
				end)
			end)
			
		else
			LoadIDBox.Visible = false
			LoadIDBox.Insert.Visible = false
			LoadIDBox.ModeSelect.Visible = true
			
		end
	end)
	
	RefreshIDButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(RefreshIDButton)
		if not res then return end
		if DSDebounce then ErrorReport("The load/save cooldown is active. Wait a few seconds.") return end
		if not CurrentID then ErrorReport("You need to create or load an Outfit ID first.") return end
		DSDebounce = true
		IgnoreIncomingAccessory = true
		table.clear(SelectedAccessories)
		local returned = CustomizationInvoke:InvokeServer("LoadOutfitID", CurrentID)
		if returned == false then ErrorReport("Error while attempting to load Outfit ID. This most likely means the ID is invalid.") return end
		
		CharacterTable = returned
		
		
		warn("Refreshed outfit ID, stats:", CurrentID, CurrentCreator)
		ClearAllConnections()
		RefreshAccessoryList(nil, returned, true)
		wait()
		IgnoreIncomingAccessory = false
		ClearAccessoryHistory()

		UpdateProperties()
		CustomizationUI.CurrentID.Text = "Current ID: " .. tostring(CurrentID)
		wait(5)
		DSDebounce = false
	end)
	
	
	SaveIDButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(SaveIDButton)
		if not res then return end
		if DSDebounce then ErrorReport("The load/save cooldown is active. Wait a few seconds.") return end
		if not CurrentID then ErrorReport("You need to create or load an Outfit ID first.") return end
		warn(CurrentID, CurrentCreator)
		if CurrentCreator ~= Client.UserId and CurrentCreator ~= nil then ErrorReport("This ID is locked. You cannot update its look, but you can save it to your own Save Slots.") return end
		DSDebounce = true
		local returned = CustomizationInvoke:InvokeServer("SaveOutfitID", CurrentID, CharacterTable)
		if returned == false then ErrorReport("Error while attempting to save Outfit ID.") return end
		wait(10)
		DSDebounce = false
	end)
	
	
end



-- Multiverse

local ServerBuffers = ReplicatedStorage:WaitForChild("ServerBuffers")
local ServerFolderContainer = ReplicatedStorage:WaitForChild("Servers")
local CurrentDestination = nil

do
	print("Indexing multiverse")
	local ServerBrowserBin = script.Parent.ServerBrowser
	local MiniBrowser = script.MiniBrowser
	local JobIdTemplate = script.ServerTemplate
	
	local TeleporterUIOpen = false
	
	local UpdatedContainersFirstTime = false
	
	local function SetUpServers()
		print("Setting up servers for UI")
		
		for i, ServerFolder in pairs(ServerFolderContainer:GetChildren()) do
			warn("Found server bin for", ServerFolder)
			local UI
			
			if ServerBrowserBin:FindFirstChild(tostring(ServerFolder.PlaceId.Value)) then
				print("Found pre-existent UI")
				UI = ServerBrowserBin:FindFirstChild(tostring(ServerFolder.PlaceId.Value))
			else
				print("Creating new UI")
				UI = MiniBrowser:Clone();
				UI.Parent = ServerBrowserBin
				UI.Visible = false
				UI.Name = tostring(ServerFolder.PlaceId.Value)
				UI.PlaceName.Text = ServerFolder.PlaceName.Value
				UI.DisplayImage.Image = "rbxassetid://" .. ServerFolder.DisplayImage.Value
				
				
				local Deb = false
				local ServerBin = UI.ServerBin
				
				local SelectedAccessCode = nil
				local SelectedJobId = nil
				local SelectedPlaceId = ServerFolder.PlaceId.Value
				local SelectedType = nil
				
				local NoServers = false
				
				local function ClearAllOtherSelected()
					for i, v in pairs(ServerBin:GetChildren()) do
						if v:IsA("TextButton") then
							SelectedJobId = nil
							SelectedAccessCode = nil
							v.SelectedByUser.Visible = false
						end
						
					end
				end
				
				local conns = {}
				
				local function SetUpIndividualServers()
					print("Refreshing server list for", SelectedPlaceId)
					
					local Container = ServerFolder.Container
					
					local function UpdateContainer(ServerInstance)
						wait()
						--print("Updating container")
						UpdatedContainersFirstTime = true
						NoServers = false
						if ServerInstance.Parent ~= ServerFolder.Container then return end
						local ExistentBox = ServerBin:FindFirstChild(ServerInstance.JobId.Value)
						if ExistentBox then
							--print("Found UI Previously")
							ExistentBox.TotalPlayers.Text = "Total Players: " .. tostring(#ServerInstance.Players:GetChildren()) .. "/" .. tostring(ServerInstance.MaxPlayerCount.Value);
							local PlayersWhoAreFriends = {}
							for IndexPlayers, PlayerBinPlayer in pairs(ServerInstance.Players:GetChildren()) do
								if Client:IsFriendsWith(PlayerBinPlayer.Value) then
									table.insert(PlayersWhoAreFriends, PlayerBinPlayer.Name)
								end
							end

							ExistentBox.Friends.Text = "Friends inside: "

							for IndexFriends, Friend in pairs(PlayersWhoAreFriends) do
								ExistentBox.Friends.Text = ExistentBox.Friends.Text .. Friend .. ", "
							end
							
							ExistentBox.ServerType.Text = "Server Type: " .. ServerInstance.ServerType.Value

						else
						print("Creating new UI")


							ExistentBox = JobIdTemplate:Clone()
							ExistentBox.Name = ServerInstance.JobId.Value
							--ExistentBox.JobId.Text = "Server ID:" .. ServerInstance.JobId.Value
							ExistentBox.PlaceImage.Image = ServerInstance.Parent.Parent.DisplayImage.Value
							ExistentBox.TotalPlayers.Text = "Total Players: " .. tostring(#ServerInstance.Players:GetChildren()) .. "/" .. tostring(ServerInstance.MaxPlayerCount.Value);
							ExistentBox.ServerType.Text = "Server Type: " .. ServerInstance.ServerType.Value

							ExistentBox.Parent = ServerBin

							local v
							
							v = ServerInstance.AncestryChanged:Connect(function()
								ExistentBox:Destroy()
							end)

							ExistentBox.MouseButton1Click:Connect(function()
								if Deb then return end
								Deb = true
								SelectedJobId = ServerInstance.JobId.Value
								SelectedType = ServerInstance.ServerType.Value
								if ServerInstance.AccessCode.Value ~= "" then SelectedAccessCode = ServerInstance.AccessCode.Value end
								ExistentBox.SelectedByUser.Text = "Joining..."
								local TeleportResult = MultiverseInvoke:InvokeServer("JoinServer", SelectedPlaceId, SelectedJobId, SelectedAccessCode, SelectedType, CurrentDestination, CurrentSlot)
								if TeleportResult == "PermissionDenied" or TeleportResult == false then ExistentBox.SelectedByUser.Text = "User lacks permission"; wait(5); ExistentBox.SelectedByUser.Text = "Click to join"; Deb = false end

							end)
						end	
					end
					
					
					if  #Container:GetChildren() == 0 then
						NoServers = true
					end
					
					
					task.spawn(function()
						while true do
							wait(0.5)
							--print("Update container loop")
							for i, z in pairs(conns) do
								conns[i]:Disconnect()
								conns[i] = nil
							end

							for i, ServerInstance in pairs(Container:GetChildren()) do
								UpdateContainer(ServerInstance)
							end
							UpdatedContainersFirstTime = true

						end
					end)
				
						
					
				end
				
				
				
				local function FoundServer(SelectedPlaceId, Type)
					for i, v in pairs(ServerFolderContainer:FindFirstChild(tostring(SelectedPlaceId)).Container:GetChildren()) do
						if v.ServerType.Value == Type then
							return true
						end
					end
					return false
				end
				
				UI.JoinCanonical.MouseButton1Down:Connect(function()
					print("UpdateContainersFirstTime:", UpdatedContainersFirstTime)
					local res = TweenButtonClick(UI.JoinCanonical)
					if res == false then return end
					if Deb == true then return end
					if UpdatedContainersFirstTime == false then return end
					print("Passed all checks")
					if FoundServer(SelectedPlaceId, "Canonical") == false then
						Deb = true
						print("No servers")
						if not ServerBuffers:FindFirstChild(tostring(SelectedPlaceId)) then
							print("requesting to teleport to new server")
							UI.Error.Visible = true
							UI.Error.Text = "Requesting a new server allocation. Be aware, this can take up to 30 seconds."
							local TeleportResult = MultiverseInvoke:InvokeServer("JoinNewServer", SelectedPlaceId, "Canonical", CurrentDestination, CurrentSlot)
							local otherErr=false
							print("TELEPORT RESULT", TeleportResult)
							if TeleportResult == "WaitForNew" then
								UI.Error.Visible = true
								UI.Error.Text = "Someone else is currently reserving a server of this type. Please wait until it shows."
								wait(5)
								UI.Error.Visible = false
								otherErr = true
							elseif TeleportResult == "PermissionDenied" then
								UI.Error.Visible = true
								UI.Error.Text = "You lack the permissions to create a Canonical server."
								wait(5)
								UI.Error.Visible = false
								otherErr = true
							elseif TeleportResult == "ClickOne" then
								UI.Error.Visible = true
								UI.Error.Text = "Please select a server."
								wait(5)
								UI.Error.Visible = false
								otherErr = true
							elseif TeleportResult == "AllowServerToGather" then
								UI.Error.Visible = true
								UI.Error.Text = "The server you are currently in is still gathering other servers. Please wait."
								wait(5)
								UI.Error.Visible = false
								otherErr = true
							end
							
							wait(5)
							UI.Error.Visible = false
							UI.Error.Text = ""
							Deb = false
							return
								
						else
							UI.Error.Visible = true
							UI.Error.Text = "Someone is creating a server and a cooldown is present. Please wait."
							wait(5)
							UI.Error.Visible = false
							Deb = false
						end
						return
					else
						UI.Error.Visible = true
						UI.Error.Text = "A server is already present of this type. Please join it instead."
						wait(5)
						UI.Error.Visible = false
						Deb = false
						return
					end

				end)
				
				UI.JoinFreeform.MouseButton1Down:Connect(function()
					print("UpdateContainersFirstTime:", UpdatedContainersFirstTime)
					local res = TweenButtonClick(UI.JoinFreeform)
					if res == false then return end
					if Deb == true then return end
					if UpdatedContainersFirstTime == false then return end
					print("Passed all checks")
					if FoundServer(SelectedPlaceId, "Freeform") == false then
						Deb = true
						print("No servers")
						if not ServerBuffers:FindFirstChild(tostring(SelectedPlaceId)) then
							print("requesting to teleport to new server")
							UI.Error.Visible = true
							UI.Error.Text = "Requesting a new server allocation. Be aware, this can take up to 30 seconds."
							local TeleportResult = MultiverseInvoke:InvokeServer("JoinNewServer", SelectedPlaceId, "Freeform", CurrentDestination, CurrentSlot)
							local otherErr=false
							print("TELEPORT RESULT", TeleportResult)
							if TeleportResult == "WaitForNew" then
								UI.Error.Visible = true
								UI.Error.Text = "Someone else is currently reserving a server. Please wait until it shows."
								wait(5)
								UI.Error.Visible = false
								otherErr = true
							elseif TeleportResult == "ClickOne" then
								UI.Error.Visible = true
								UI.Error.Text = "Please select a server."
								wait(5)
								UI.Error.Visible = false
								otherErr = true
							elseif TeleportResult == "AllowServerToGather" then
								UI.Error.Visible = true
								UI.Error.Text = "The server you are currently in is still gathering other servers. Please wait."
								wait(5)
								UI.Error.Visible = false
								otherErr = true
							end

							wait(5)
							UI.Error.Visible = false
							UI.Error.Text = ""
							Deb = false
							return

						else
							UI.Error.Visible = true
							UI.Error.Text = "Someone is creating a server and a cooldown is present. Please wait."
							wait(5)
							UI.Error.Visible = false
							Deb = false
						end
						return
					else
						UI.Error.Visible = true
						UI.Error.Text = "A server is already present of this type. Please join it instead."
						wait(5)
						UI.Error.Visible = false
						Deb = false
						return
				
						
					end
					
				
				end)
					
					UI.JoinExperimental.MouseButton1Down:Connect(function()
						print("UpdateContainersFirstTime:", UpdatedContainersFirstTime)
						local res = TweenButtonClick(UI.JoinExperimental)
						if res == false then return end
						if Deb == true then return end
						if UpdatedContainersFirstTime == false then return end
						print("Passed all checks")
						if FoundServer(SelectedPlaceId, "Supporter Preview") == false then
							Deb = true
							print("No servers")
							if not ServerBuffers:FindFirstChild(tostring(SelectedPlaceId)) then
								print("requesting to teleport to new server")
								UI.Error.Visible = true
								UI.Error.Text = "Requesting a new server allocation. Be aware, this can take up to 30 seconds."
								local TeleportResult = MultiverseInvoke:InvokeServer("JoinNewServer", SelectedPlaceId, "Supporter Preview", CurrentDestination, CurrentSlot)
								local otherErr=false
								print("TELEPORT RESULT", TeleportResult)
								if TeleportResult == "WaitForNew" then
									UI.Error.Visible = true
									UI.Error.Text = "Someone else is currently reserving a server. Please wait until it shows."
									wait(5)
									UI.Error.Visible = false
									otherErr = true
								elseif TeleportResult == "ClickOne" then
									UI.Error.Visible = true
									UI.Error.Text = "Please select a server."
									wait(5)
									UI.Error.Visible = false
									otherErr = true
								elseif TeleportResult == "AllowServerToGather" then
									UI.Error.Visible = true
									UI.Error.Text = "The server you are currently in is still gathering other servers. Please wait."
									wait(5)
									UI.Error.Visible = false
									otherErr = true
								end

								wait(5)
								UI.Error.Visible = false
								UI.Error.Text = ""
								Deb = false
								return
								
							else
							UI.Error.Visible = true
							UI.Error.Text = "Someone is creating a server and a cooldown is present. Please wait."
							wait(5)
							UI.Error.Visible = false
							Deb = false
						end
						return
					else
						UI.Error.Visible = true
						UI.Error.Text = "A server is already present of this type. Please join it instead."
						wait(5)
						UI.Error.Visible = false
						Deb = false
						return
					end
				end)
				
				UI.Close.MouseButton1Down:Connect(function()
					local res = TweenButtonClick(UI.Close)
					if res == false then return end
					TeleporterUIOpen = false
					UI.Visible = false
					Deb = false
					CurrentDestination = nil
				end)
				
				SetUpIndividualServers()
			end
		end
	end
	
	function CreateNewBrowserUI(ServerFolder)
		
		local UI
		
		print("Creating new UI but only for a specific server folder")

		if ServerBrowserBin:FindFirstChild(tostring(ServerFolder.PlaceId.Value)) then
			print("Found pre-existent UI")
			UI = ServerBrowserBin:FindFirstChild(tostring(ServerFolder.PlaceId.Value))
		else
			print("Creating new UI")
			UI = MiniBrowser:Clone();
			UI.Parent = ServerBrowserBin
			UI.Visible = false
			UI.Name = tostring(ServerFolder.PlaceId.Value)
			UI.PlaceName.Text = ServerFolder.PlaceName.Value
			UI.DisplayImage.Image = ServerFolder.DisplayImage.Value


			local Deb = false
			local ServerBin = UI.ServerBin

			local SelectedAccessCode = nil
			local SelectedJobId = nil
			local SelectedType = nil
			local SelectedPlaceId = ServerFolder.PlaceId.Value

			local NoServers = false

			local function ClearAllOtherSelected()
				for i, v in pairs(ServerBin:GetChildren()) do
					if v:IsA("TextButton") then
						SelectedJobId = nil
						SelectedAccessCode = nil
						v.SelectedByUser.Visible = false
					end

				end
			end

			local conns = {}

			local function SetUpIndividualServers()
				print("Refreshing server list for", SelectedPlaceId)

				local Container = ServerFolder.Container

				local function UpdateContainer(ServerInstance)
					wait()
					print("Updating container")
					UpdatedContainersFirstTime = true
					NoServers = false
					local ExistentBox = ServerBin:FindFirstChild(ServerInstance.JobId.Value)
					if ExistentBox then
						print("Found UI Previously")
						ExistentBox.TotalPlayers.Text = "Total Players: " .. tostring(#ServerInstance.Players:GetChildren()) .. "/" .. tostring(ServerInstance.MaxPlayerCount.Value);
						local PlayersWhoAreFriends = {}
						for IndexPlayers, PlayerBinPlayer in pairs(ServerInstance.Players:GetChildren()) do
							if Client:IsFriendsWith(PlayerBinPlayer.Value) then
								table.insert(PlayersWhoAreFriends, PlayerBinPlayer.Name)
							end
						end

						ExistentBox.Friends.Text = "Friends inside: "

						for IndexFriends, Friend in pairs(PlayersWhoAreFriends) do
							ExistentBox.Friends.Text = ExistentBox.Friends.Text .. Friend .. ", "
						end

					else
						print("Creating new UI")


						ExistentBox = JobIdTemplate:Clone()
						ExistentBox.Name = ServerInstance.JobId.Value
						ExistentBox.JobId.Text = "Server ID:" .. ServerInstance.JobId.Value
						ExistentBox.TotalPlayers.Text = "Total Players: " .. tostring(#ServerInstance.Players:GetChildren()) .. "/" .. tostring(ServerInstance.MaxPlayerCount.Value);


						ExistentBox.Parent = ServerBin

						local v

						v = ServerInstance.AncestryChanged:Connect(function()
							ExistentBox:Destroy()
						end)

						ExistentBox.MouseButton1Click:Connect(function()
							if Deb then return end
							Deb = true
							SelectedJobId = ServerInstance.JobId.Value
							SelectedType = ServerInstance.ServerType.Value
							if ServerInstance.AccessCode.Value ~= "" then SelectedAccessCode = ServerInstance.AccessCode.Value end
							ExistentBox.SelectedByUser.Text = "Joining..."
							local TeleportResult = MultiverseInvoke:InvokeServer("JoinServer", SelectedPlaceId, SelectedJobId, SelectedAccessCode, SelectedType, CurrentDestination, CurrentSlot)
							if TeleportResult == "PermissionDenied" or TeleportResult == false then ExistentBox.SelectedByUser.Text = "User lacks permission"; wait(5); ExistentBox.SelectedByUser.Text = "Click to join"; Deb = false end
							
						end)
					end	
				end


				if  #Container:GetChildren() == 0 then
					NoServers = true
				end



				while true do
					wait(0.5)
					--print("Update container loop")
					for i, z in pairs(conns) do
						conns[i]:Disconnect()
						conns[i] = nil
					end

					for i, ServerInstance in pairs(Container:GetChildren()) do
						UpdateContainer(ServerInstance)
					end
					UpdatedContainersFirstTime = true

				end


			end


			UI.Close.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(UI.Close)
				if res == false then return end
				TeleporterUIOpen = false
				UI.Visible = false
				Deb = false
				CurrentDestination = nil
			end)

			SetUpIndividualServers()
		
			
	end
		return UI
	end
	
	task.spawn(function()

		local Teleporters = workspace:WaitForChild("Teleporters", 30)
		local TpUI = MainUI:WaitForChild("TeleportUI")

		local function HandleTeleportUI(part)
			if TeleporterUIOpen == true then return end
			TeleporterUIOpen = true
			local ID = part:FindFirstChild("ID")
			if not ID then return end

			local TPUI = ServerBrowserBin:FindFirstChild(tostring(ID.Value))
			if TPUI then
				print("Found associated UI")
				TPUI.Visible = true
			else
				print("Couldn't find associated UI")
				local ServerFolderFound = ServerFolderContainer:FindFirstChild(tostring(ID.Value))
				if ServerFolderFound then
					print("Found server folder, creating")
					local CreatedUI = CreateNewBrowserUI(ServerFolderFound)
					CreatedUI.Visible = true
				end
			end

			if part:FindFirstChild("Destination") then
				CurrentDestination = part.Destination.Value
			end
		end

		if Teleporters then
			print("Found teleporters!")
			for i, part in pairs(Teleporters:GetChildren()) do
				local ProximityPrompt = Instance.new("ProximityPrompt", part)
				ProximityPrompt.HoldDuration = 0.5
				ProximityPrompt.ActionText = "Open Server Browser for " .. part.Name

				ProximityPrompt.Triggered:Connect(function(player)
					if player == Client then
						HandleTeleportUI(part)
					end
				end)

				Character.Humanoid.Died:Connect(function()
					ProximityPrompt:Destroy()
				end)
			end
			SetUpServers()
		end

		if TpUI then
			for _, v in pairs(TpUI.Server:GetChildren()) do
				if v:FindFirstChild("ID") then
					v.FindServer.MouseButton1Down:Connect(function()
						TpUI.Visible = false
						HandleTeleportUI(v)  -- Use the same function for the UI button
					end)
				end
			end
		end

	end)

end

-- Leaderboard system
do
	print("Indexing the leaderboard")
	
	local LeaderboardUI = MainUI.Leaderboard
	local HoverFrame = LeaderboardUI.HoverFrame
	local TopBar = LeaderboardUI.TopBar
	local Bin = LeaderboardUI.Background.Bin
	local Background = LeaderboardUI.Background
	local PlayerLeaderboardTemplate = script.PlayerLeaderboardTemplate
	
	local CurrentfilterMode = "Global"
	
	local RankCache = {}
	local RoleCache = {}
	
	local LeaderboardCollapsedSize = UDim2.new(0.15,0, 0.517, 0)
	local TopBarCollapsedSize = UDim2.new(0.15, 0,0.03, 0)
	local LeaderboardExpandedSize = UDim2.new(0.337, 0, 0.517, 0)
	local TopBarExpandedSize = UDim2.new(0.337, 0,0.03, 0)

	local LeaderboardCollapsedPosition = UDim2.new(0.85, 0,0, 0)
	local TopBarCollapsedPosition = UDim2.new(0.85, 0,0, 0)
	local LeaderboardExpandedPosition = UDim2.new(0.663, 0,0, 0)
	local TopBarExpandedPosition = UDim2.new(0.663, 0,0, 0)
	
	local CurrentLeaderboardFilterMode = MultiverseInvoke:InvokeServer("GetLastLeaderboardFilterMode") or "Global"
	local updatedeb = false
	GeneralSettings.LeaderboardFilter.Slide.displayText.Text = "Filter: " .. CurrentLeaderboardFilterMode
	
	local function ExpandFrames(OutOrIn)
		
		for i, v in pairs(Bin:GetChildren()) do
			if v:IsA("Frame") then
				if OutOrIn then
					v.ExpandedBin.Visible = true
					v.CollapsedBin.Visible = false
				else
					v.ExpandedBin.Visible = false
					v.CollapsedBin.Visible = true
				end
			end
		end
		if OutOrIn then
			TopBar.ExpandedBin.Visible = true
			TopBar.CollapsedBin.Visible = false
		else
			TopBar.ExpandedBin.Visible = false
			TopBar.CollapsedBin.Visible = true
		end
	end
	
	HoverFrame.MouseEnter:Connect(function()
		if LeaderboardHidden == false then
		Background:TweenSizeAndPosition(LeaderboardExpandedSize, LeaderboardExpandedPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.5, true)
		HoverFrame:TweenSizeAndPosition(LeaderboardExpandedSize, LeaderboardExpandedPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.5, true)
		TopBar:TweenSizeAndPosition(TopBarExpandedSize, TopBarExpandedPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.5, true)
			ExpandFrames(true)
			--GeneralSettings.servertype.Visible = false
		end
	end)
	
	HoverFrame.MouseLeave:Connect(function()
		if LeaderboardHidden == false then
		Background:TweenSizeAndPosition(LeaderboardCollapsedSize, LeaderboardCollapsedPosition, Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.5, true)
		HoverFrame:TweenSizeAndPosition(LeaderboardCollapsedSize, LeaderboardCollapsedPosition, Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.5, true)
		TopBar:TweenSizeAndPosition(TopBarCollapsedSize, TopBarCollapsedPosition, Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.5, true)
			ExpandFrames(false)
			--GeneralSettings.servertype.Visible = true
		end
	end)
	
	local function GetRoleInGroup(RealPlayer)
		local succ, result = pcall(function()
			if RoleCache[RealPlayer.UserId] == nil then RoleCache[RealPlayer.UserId] = RealPlayer:GetRoleInGroup(GroupId) end
			return RoleCache[RealPlayer.UserId]
		end)
		if succ then
			return result
		else
			RoleCache[RealPlayer.UserId] = nil
			return "Player"
		end
	end
	
	local function GetRankInGroup(RealPlayer)
		local succ, result = pcall(function()
			if RankCache[RealPlayer.UserId] == nil then RankCache[RealPlayer.UserId] = RealPlayer:GetRankInGroup(GroupId) end
			return RankCache[RealPlayer.UserId]
		end)
		if succ then
			return result
		else
			RoleCache[RealPlayer.UserId] = nil
			return "Player"
		end
	end
	

	
	local function UpdateOrCreatePlayerButton(InfoTable)
		local ExistentBox = Bin:FindFirstChild(tostring(InfoTable.UserId))
		
		if not ExistentBox then
			ExistentBox = PlayerLeaderboardTemplate:Clone()
			ExistentBox.Name = tostring(InfoTable.UserId)
			ExistentBox.Parent = Bin
			
			ExistentBox.ExpandedBin.Teleport.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(ExistentBox.ExpandedBin.Teleport)
				if res == false then return end
				if MajorDebounce == true then return end
				if ExistentBox.UserId.Value == Client.UserId then return end
				MajorDebounce = true
				
				
				if Players:FindFirstChild(ExistentBox.PlayerName.Value) then
					local res = MultiverseInvoke:InvokeServer("Teleport", ExistentBox.UserId.Value)
					if res == false then
						ExistentBox.ExpandedBin.Teleport.Slide.displayText.Text = "Rejected"
						wait(1)
						ExistentBox.ExpandedBin.Teleport.Slide.displayText.Text = "Go to"
					end
				else
					--if ExistentBox.AllowsFollows.Value == true or  ClientGroupRank >= 250  then
				
						print("Requesting teleport to user", ExistentBox.PlayerName.Value)
						CurrentDestination = ExistentBox.UserId.Value
						local TeleportResult = MultiverseInvoke:InvokeServer("JoinServer", ExistentBox.PlaceId.Value, ExistentBox.JobId.Value, ExistentBox.AccessCode.Value, ExistentBox.ServerType.Value, CurrentDestination, CurrentSlot, CurrentDestination)
						if TeleportResult == false then
							ExistentBox.ExpandedBin.Teleport.Slide.displayText.Text = "Rejected"
							wait(1)
							ExistentBox.ExpandedBin.Teleport.Slide.displayText.Text = "Go to"
						else
							ExistentBox.ExpandedBin.Teleport.Slide.displayText.Text = "Going..."
							wait(1)
							ExistentBox.ExpandedBin.Teleport.Slide.displayText.Text = "Go to"
						end
					
				end
				
				
				wait(0.5)
				CurrentDestination = nil
				MajorDebounce = false
			end)
			
			local RealPlayer = Players:FindFirstChild(InfoTable.PlayerName)

			if RealPlayer then
				ExistentBox.ExpandedBin.PlayerName.MouseEnter:Connect(function()
					ExistentBox.ExpandedBin.PlayerName.Text = ExistentBox.PlayerName.Value
				end)

				ExistentBox.ExpandedBin.PlayerName.MouseLeave:Connect(function()
					ExistentBox.ExpandedBin.PlayerName.Text = ExistentBox.DisplayName.Value
				end)

				ExistentBox.CollapsedBin.PlayerName.MouseEnter:Connect(function()
					ExistentBox.CollapsedBin.PlayerName.Text = ExistentBox.PlayerName.Value
				end)

				ExistentBox.CollapsedBin.PlayerName.MouseLeave:Connect(function()
					ExistentBox.CollapsedBin.PlayerName.Text = ExistentBox.DisplayName.Value
				end)
			end
			
			if CurrentLeaderboardFilterMode == "Local" then

				if RealPlayer then ExistentBox.Visible = true else ExistentBox.Visible = false end

			elseif CurrentLeaderboardFilterMode == "Type" then
				if ExistentBox.ServerType.Value == ReplicatedStorage.ServerType.Value then
					ExistentBox.Visible = true
				else
					ExistentBox.Visible = false
				end
			elseif  CurrentLeaderboardFilterMode == "Global" then
				ExistentBox.Visible = true
			end
			
			
			task.spawn(function()
				local PI = ServerFolderContainer[tostring(InfoTable.PlaceId)].Container[InfoTable.JobId].Players:FindFirstChild(InfoTable.PlayerName)
				if PI then
					PI.AncestryChanged:Wait()
					ExistentBox:Destroy()
				end
			end)
			
			
		end
		
		if InfoTable.AccessCode then ExistentBox.AccessCode.Value = InfoTable.AccessCode end
		ExistentBox.UserId.Value = InfoTable.UserId
		ExistentBox.JobId.Value = InfoTable.JobId
		ExistentBox.PlaceId.Value = InfoTable.PlaceId
		ExistentBox.ServerType.Value = InfoTable.ServerType
		--ExistentBox.AllowsFollows.Value = InfoTable.AllowsFollows
		--ExistentBox.DisplayName.Value = InfoTable.DisplayName
		ExistentBox.PlayerName.Value = InfoTable.PlayerName
		--ExistentBox.Role.Value = InfoTable.Role
		--ExistentBox.Rank.Value = InfoTable.Rank
		
		local RealPlayer = Players:FindFirstChild(InfoTable.PlayerName)
		
		if RealPlayer then
			
			ExistentBox.Role.Value = GetRoleInGroup(RealPlayer)
			
			ExistentBox.Rank.Value = GetRankInGroup(RealPlayer)
			ExistentBox.DisplayName.Value = RealPlayer.DisplayName
			
			ExistentBox.CollapsedBin.PlayerName.Text = RealPlayer.DisplayName
			ExistentBox.ExpandedBin.PlayerName.Text = RealPlayer.DisplayName
			ExistentBox.CollapsedBin.RankName.Text = RoleCache[InfoTable.UserId]
			ExistentBox.ExpandedBin.RankName.Text = RoleCache[InfoTable.UserId]
			ExistentBox.ExpandedBin.ServerType.Text = InfoTable.ServerType
			ExistentBox.LayoutOrder = -RankCache[InfoTable.UserId]
		else
			ExistentBox.LayoutOrder = 1
			ExistentBox.Rank.Value = 1
			ExistentBox.CollapsedBin.PlayerName.Text = InfoTable.PlayerName
			ExistentBox.ExpandedBin.PlayerName.Text = InfoTable.PlayerName
			ExistentBox.ExpandedBin.ServerType.Text = InfoTable.ServerType
		end
		
		
		if CurrentLeaderboardFilterMode == "Local" then
			
			if RealPlayer then ExistentBox.Visible = true else ExistentBox.Visible = false end

		elseif CurrentLeaderboardFilterMode == "Type" then
			if ExistentBox.ServerType.Value == ReplicatedStorage.ServerType.Value then
				ExistentBox.Visible = true
			else
				ExistentBox.Visible = false
			end
		elseif  CurrentLeaderboardFilterMode == "Global" then
			ExistentBox.Visible = true
		end
		ExistentBox.Parent = Bin
		
		
		ExistentBox.ExpandedBin.CurrentLocation.Text = InfoTable.PlaceName
		
		if ExistentBox.Rank.Value < 60 then
			ExistentBox.ExpandedBin.RankName.Text = "Player"
			ExistentBox.CollapsedBin.RankName.Text = "Player"
		end
		
		return ExistentBox
	end
	
	task.spawn(function()
		while true do
			wait(math.random(1,2))
			if not MainUI.Leaderboard.Visible then
				continue
			end
			
			--print("Refreshing leaderboard")
			local succ, result = pcall(function()
				local TbOfPlayerInfo = {}

				for PlaceIdi, PlaceFolder in pairs(ServerFolderContainer:GetChildren()) do
					local PlaceId = PlaceFolder.PlaceId.Value
					local PlaceName = PlaceFolder.PlaceName.Value

					for JobIdi, JobFolder in pairs(PlaceFolder.Container:GetChildren()) do
						local JobId = JobFolder.JobId.Value
						local AccessCode = JobFolder.AccessCode.Value
						local ServerType = JobFolder.ServerType.Value

						for PlayerIdi, PlayerInstance in pairs(JobFolder.Players:GetChildren()) do
							table.insert(TbOfPlayerInfo, 
								{["UserId"] = PlayerInstance.Value,
									["PlayerName"] = PlayerInstance.Name,
									--["DisplayName"] = PlayerInstance.DisplayName.Value,
									["PlaceId"] = PlaceId,
									["JobId"] = JobId,
									["AccessCode"] = AccessCode,
									["ServerType"] = ServerType,
									--["Role"] = PlayerInstance.Role.Value,
									--["Rank"] = PlayerInstance.Rank.Value,
									["PlaceName"] = PlaceInformationTable[PlaceId].Name
								})
						end
					end
				end
				local TbOfBoxes = {}
				for i, v in pairs(TbOfPlayerInfo) do
					local succ, result = pcall(function()
						local box=UpdateOrCreatePlayerButton(v)
						table.insert(TbOfBoxes, box)
					end)
					if not succ then warn(result) end
				end
			end)
			
			if not succ then
				warn(result)
			end
			
		end
	end)
	
	
	
	game:GetService("UserInputService").InputBegan:Connect(function(InputObject, gameProcessedEvent)
		if gameProcessedEvent == false then
			
			if InputObject.KeyCode == Enum.KeyCode.Tab then
				if LeaderboardHidden then
					LeaderboardHidden = false
					Bin.Parent:TweenPosition(UDim2.new(0.85,0,0,0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.1, true)
					TopBar:TweenPosition(UDim2.new(0.85,0,0,0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.1, true)
					MainUI.GeneralSettings.Visible = true
				else
					LeaderboardHidden = true
					Bin.Parent:TweenPosition(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.1, true)
					TopBar:TweenPosition(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.1, true)
					MainUI.GeneralSettings.Visible = false
				end
			elseif InputObject.KeyCode == Enum.KeyCode.E and CurrentForeignVisualization then
				local bar = script.Parent.PlayerNameDisplay.VisualizationDelete.box.bar
				bar.Size = UDim2.new(0.01, 0,0.4, 0)
				DeleteVisualizationToggle = true
				bar:TweenSize(UDim2.new(0.81, 0,0.4, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 1.2, true)
				local currenttime = tick()
				repeat wait() until (tick() - currenttime) > 1.2 or DeleteVisualizationToggle == false
				if DeleteVisualizationToggle == false then
					bar:TweenSize(UDim2.new(0.01, 0,0.4, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.15, true)
					
					DeleteVisualizationToggle = false
				else
					CurrentForeignVisualization:FindFirstChildOfClass("RemoteEvent"):FireServer()
					DeleteVisualizationToggle = false
					bar.Size = UDim2.new(0.01, 0,0.4, 0)
				end
			elseif InputObject.KeyCode == Enum.KeyCode.E and CurrentForeignProp then
				local bar = script.Parent.PlayerNameDisplay.VisualizationDelete.box.bar
				bar.Size = UDim2.new(0.01, 0,0.4, 0)
				DeleteVisualizationToggle = true
				bar:TweenSize(UDim2.new(0.81, 0,0.4, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 1.2, true)
				local currenttime = tick()
				repeat wait() until (tick() - currenttime) > 1.2 or DeleteVisualizationToggle == false
				if DeleteVisualizationToggle == false then
					bar:TweenSize(UDim2.new(0.01, 0,0.4, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.15, true)

					DeleteVisualizationToggle = false
				else
					print('Current foreign prop:', CurrentForeignProp)
					PropPlacer.DeleteProp(CurrentForeignProp)
					DeleteVisualizationToggle = false
					bar.Size = UDim2.new(0.01, 0,0.4, 0)
				end
			end
			
			
		end
	end)
	
	
	
	local function FilterLeaderboard(FilterType)
		for i, v in pairs(Bin:GetChildren()) do
			if v:IsA("Frame") then
				if FilterType == "Local" then
					local RealPlayer = Players:FindFirstChild(v.PlayerName.Value)
					if RealPlayer then v.Visible = true else v.Visible = false end
					
				elseif FilterType == "Type" then
					if v.ServerType.Value == ReplicatedStorage.ServerType.Value then
						v.Visible = true
					else
						v.Visible = false
					end
				elseif FilterType == "Global" then
					v.Visible = true
				end
			end
		end
	end

	GeneralSettings.LeaderboardFilter.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(GeneralSettings.LeaderboardFilter)
		if res == false then return end
		if updatedeb then return end
		updatedeb = true
		if CurrentLeaderboardFilterMode == "Local" then
			CurrentLeaderboardFilterMode = "Type"
		elseif CurrentLeaderboardFilterMode == "Type" then
			CurrentLeaderboardFilterMode = "Global"
		elseif CurrentLeaderboardFilterMode == "Global" then
			CurrentLeaderboardFilterMode = "Local"
		end
		MultiverseInvoke:InvokeServer("UpdateLeaderboardFilterMode", CurrentLeaderboardFilterMode)
		FilterLeaderboard(CurrentLeaderboardFilterMode)
		GeneralSettings.LeaderboardFilter.Slide.displayText.Text = "Filter: " .. CurrentLeaderboardFilterMode
		wait(0.5)
		updatedeb = false
	end)
	

	GeneralSettings.Freecam.MouseButton1Down:Connect(function()
		
	end)
	
end

-- Visualizer

do
	print("Indexing the visualizer")
	local ControlDeb = false
	local CurrentWidth = 4
	local CurrentHeight = 1
	local VisualizerText = script.DisplayText
	VisualizerText.Adornee = CurrentVisuzaliserAsset
	
	local ThrowableAttachment = Character.HumanoidRootPart:WaitForChild("ThrowableAttachment")
	
	local function newSize()
		if CurrentVisualizerMode == "AOE" then
			if CurrentVisuzaliserAsset.Name == "AOEArea" then
				CurrentVisuzaliserAsset.Size = Vector3.new(CurrentWidth, 0.25, CurrentWidth)
			elseif CurrentVisuzaliserAsset.Name == "AOEPull" or CurrentVisuzaliserAsset.Name == "AOEPush" then
				local CornerTakeoff = (CurrentWidth/2)-((CurrentWidth/2)/4)
				CurrentVisuzaliserAsset.Size = Vector3.new(CurrentWidth, 0.25, CurrentWidth)
				CurrentVisuzaliserAsset.Back.Position = Vector3.new(0,-0.5, CurrentWidth/2)
				CurrentVisuzaliserAsset.Front.Position = Vector3.new(0,-0.5, -(CurrentWidth/2))
				CurrentVisuzaliserAsset.Left.Position = Vector3.new(-(CurrentWidth/2),-0.5, 0)
				CurrentVisuzaliserAsset.Right.Position = Vector3.new(CurrentWidth/2,-0.5, 0)
				CurrentVisuzaliserAsset.BackRight.Position = Vector3.new(CornerTakeoff, -0.5, CornerTakeoff)
				CurrentVisuzaliserAsset.BackLeft.Position = Vector3.new(-CornerTakeoff, -0.5, CornerTakeoff)
				CurrentVisuzaliserAsset.FrontRight.Position = Vector3.new(CornerTakeoff, -0.5, -CornerTakeoff)
				CurrentVisuzaliserAsset.FrontLeft.Position = Vector3.new(-CornerTakeoff, -0.5, -CornerTakeoff)
			end
			
		elseif CurrentVisualizerMode == "AtoB" then
			if CurrentVisuzaliserAsset.Name == "AtoBSolid" or CurrentVisuzaliserAsset.Name == "AtoBCone" then
				CurrentVisuzaliserAsset.Size = Vector3.new(CurrentWidth/2, CurrentWidth/2, CurrentWidth/2)
			elseif CurrentVisuzaliserAsset.Name == "AtoBDirectional" then
				CurrentVisuzaliserAsset.Size = Vector3.new(CurrentWidth/2, CurrentWidth/2, CurrentWidth/2)
				CurrentVisuzaliserAsset.Back.Position = Vector3.new(0,0,CurrentVisuzaliserAsset.Size.Z/2)
				CurrentVisuzaliserAsset.Front.Position = Vector3.new(0,0,-(CurrentVisuzaliserAsset.Size.Z/2))
			end
		elseif CurrentVisualizerMode == "Throwable" then
			CurrentVisuzaliserAsset.Size = Vector3.new(CurrentWidth/2, CurrentWidth/2, CurrentWidth/2)
		end
	end
	
	local Mouse = Client:GetMouse()
	game:GetService("UserInputService").InputBegan:Connect(function(InputObject, gameProcessedEvent)
		if gameProcessedEvent then return end
		if InputObject.KeyCode == Enum.KeyCode.LeftControl then
			ControlDeb = true
		elseif InputObject.KeyCode == Enum.KeyCode.Q then
			if ControlDeb == true then
				CurrentHeight = CurrentHeight - 1
				CurrentHeight = math.clamp(CurrentHeight, 1, 30)
			else
				CurrentWidth = CurrentWidth - 1
				CurrentWidth = math.clamp(CurrentWidth, 1, 30)
			end
			newSize()
		elseif InputObject.KeyCode == Enum.KeyCode.E then
			if ControlDeb == true then
				CurrentHeight = CurrentHeight + 1
				CurrentHeight = math.clamp(CurrentHeight, 1, 30)
			else
				CurrentWidth = CurrentWidth + 1
				CurrentWidth = math.clamp(CurrentWidth, 1, 30)
			end
			newSize()
		end
	end)
	game:GetService("UserInputService").InputEnded:Connect(function(InputObject, gameProcessedEvent)
		if gameProcessedEvent then return end
		if InputObject.KeyCode == Enum.KeyCode.LeftControl then
			ControlDeb = false
		elseif InputObject.KeyCode == Enum.KeyCode.E then
			DeleteVisualizationToggle = false
		end
	end)
	
	local ColorSelector = VisualizerUI.Settings.ColorSelection
	math.randomseed(tick())
	CurrentVisuzaliserAsset.BrickColor = BrickColor.palette(math.random(0,126))
	local CurrentColor = CurrentVisuzaliserAsset.Color
	local SizeInstructions = VisualizerUI.SizeInstructions
	local Settings = VisualizerUI.Settings
	
	
	local PromptsToggle = true
	local VisualizationsToggle = true
	
	local AOESettings = Settings.AOE
	local AtoBSettings = Settings.AtoB
	local ThrowableSettings = Settings.Throwable
	local PingSettings = Settings.PingTool
	local HelpButton = VisualizerUI.Help
	local HelpMenu = VisualizerUI.HelpMenu
	local HelpMenuCloseButton = HelpMenu.Close
	
	local LastModeForAOE = "AOEArea"
	local LastModeForAtoB = "AtoBSolid"
	local LastModeForThrowable = "Throwable"
	local LastModeForPing = "Ping"
	
	local TempConstructs = 0
	local PermConstructs = 0
	
	local AtoBPointOne = nil
	local AtoBPointTwo = nil
	
	local PlayerCentric = Settings.PlayerCentric
	local TextInput = VisualizerUI.TextInput
	local TextInputBox = TextInput.Input
	local AOEButton = VisualizerUI.AOE
	local AtoBButton = VisualizerUI.AtoB
	local PingButton = VisualizerUI.Ping
	local ThrowableButton = VisualizerUI.Throwable
	
	local function SetNewAsset()
		if CurrentVisuzaliserAsset then CurrentVisuzaliserAsset:Destroy(); CurrentVisuzaliserAsset = nil end
		if CurrentVisualizerMode == "AOE" then
			CurrentVisuzaliserAsset = script.Visualizer:FindFirstChild(LastModeForAOE):Clone()
			CurrentVisuzaliserAsset.Parent = WorkspaceVisualizedFolder
			VisualizerText.Adornee = CurrentVisuzaliserAsset
			CurrentVisuzaliserAsset.Color = CurrentColor
			script.Visualizer:FindFirstChild("Ping").Ping.Enabled = false
		elseif CurrentVisualizerMode == "AtoB" then
			CurrentVisuzaliserAsset = script.Visualizer:FindFirstChild(LastModeForAtoB):Clone()
			CurrentVisuzaliserAsset.Parent = WorkspaceVisualizedFolder
			VisualizerText.Adornee = CurrentVisuzaliserAsset
			CurrentVisuzaliserAsset.Color = CurrentColor
			script.Visualizer:FindFirstChild("Ping").Ping.Enabled = false
		elseif CurrentVisualizerMode == "Throwable" then
			CurrentVisuzaliserAsset = script.Visualizer:FindFirstChild(LastModeForThrowable):Clone()
			CurrentVisuzaliserAsset.Parent = WorkspaceVisualizedFolder
			VisualizerText.Adornee = CurrentVisuzaliserAsset
			CurrentVisuzaliserAsset.DirectionalArc.Attachment0 = CurrentVisuzaliserAsset.Destination
			CurrentVisuzaliserAsset.DirectionalArc.Attachment1 = ThrowableAttachment
			CurrentVisuzaliserAsset.Color = CurrentColor
			CurrentVisuzaliserAsset.DirectionalArc.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, CurrentColor), ColorSequenceKeypoint.new(1, CurrentColor)})
			script.Visualizer:FindFirstChild("Ping").Ping.Enabled = false
		elseif CurrentVisualizerMode == "Ping" then
			CurrentVisuzaliserAsset = script.Visualizer:FindFirstChild(LastModeForPing):Clone()
			CurrentVisuzaliserAsset.Parent = WorkspaceVisualizedFolder
			VisualizerText.Adornee = CurrentVisuzaliserAsset
			CurrentVisuzaliserAsset.Color = CurrentColor
			CurrentVisuzaliserAsset.Ping.ImageLabel.ImageColor3 = CurrentColor
			CurrentVisuzaliserAsset.Ping.Enabled = true
		end
		newSize()
	end
	
	local function SetActiveButton(button)
		wait(0.12)
		if CurrentVisualizerMode == "AOE" then
			AOEButton.BackgroundColor3 = Color3.new(1,0,0)
			AOESettings.Visible = true
		else
			AOEButton.BackgroundColor3 = Color3.new(1,1,1)
			AOESettings.Visible = false
		end
		
		if CurrentVisualizerMode == "AtoB" then
			AtoBButton.BackgroundColor3 = Color3.new(1,0,0)
			AtoBSettings.Visible = true
		else
			AtoBButton.BackgroundColor3 = Color3.new(1,1,1)
			AtoBSettings.Visible = false
		end
		
		if CurrentVisualizerMode == "Throwable" then
			ThrowableButton.BackgroundColor3 = Color3.new(1,0,0)
			ThrowableSettings.Visible = true
		else
			ThrowableButton.BackgroundColor3 = Color3.new(1,1,1)
			ThrowableSettings.Visible = false
		end
		
		if CurrentVisualizerMode == "Ping" then
			PingButton.BackgroundColor3 = Color3.new(1,0,0)
			PingSettings.Visible = true
		else
			PingButton.BackgroundColor3 = Color3.new(1,1,1)
			PingSettings.Visible = false
		end
		
	end
	
	local HelpOpen = false
	
	HelpButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(HelpButton)
		if not res then return end
		if HelpOpen == false then HelpOpen = true; HelpMenu.Visible = true; else HelpOpen = false; HelpMenu.Visible = false end
	end)
	
	HelpMenuCloseButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(HelpMenuCloseButton)
		if not res then return end
		if HelpOpen == true then HelpOpen = false; HelpMenu.Visible = false; end
	end)
	
	AOEButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(AOEButton)
		if not res then return end
		CurrentVisualizerMode = "AOE"
		SetActiveButton()
		SetNewAsset()
	end)
	
	AtoBButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(AtoBButton)
		if not res then return end
		CurrentVisualizerMode = "AtoB"
		SetActiveButton()
		SetNewAsset()
	end)
	
	ThrowableButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(ThrowableButton)
		if not res then return end
		CurrentVisualizerMode = "Throwable"
		SetActiveButton()
		SetNewAsset()
	end)
	
	PingButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(PingButton)
		if not res then return end
		CurrentVisualizerMode = "Ping"
		SetActiveButton()
		SetNewAsset()
	end)
	
	
	local PlayerCentricDeb = false
	
	PlayerCentric.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(PlayerCentric)
		if res == false then return end
		if PlayerCentricDeb then PlayerCentricDeb = false; PlayerCentric.Slide.displayText.Text = "Player Centric: OFF"; AtoBPointOne = nil; newSize() 
		else PlayerCentricDeb = true; PlayerCentric.Slide.displayText.Text = "Player Centric: ON"; AtoBPointOne = nil; newSize()
		end
	end)
	
	AOESettings.Sphere.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(AOESettings.Sphere)
		if res == false then return end
		CurrentVisuzaliserAsset:Destroy()
		CurrentVisuzaliserAsset = nil
		CurrentVisuzaliserAsset = VisualizerFolder.AOEArea:Clone()
		CurrentVisuzaliserAsset.Parent = WorkspaceVisualizedFolder
		VisualizerText.Adornee = CurrentVisuzaliserAsset
		CurrentVisuzaliserAsset.Color = CurrentColor
		LastModeForAOE = CurrentVisuzaliserAsset.Name
		newSize()
	end)
	
	AOESettings.Pull.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(AOESettings.Pull)
		if res == false then return end
		CurrentVisuzaliserAsset:Destroy()
		CurrentVisuzaliserAsset = nil
		CurrentVisuzaliserAsset = VisualizerFolder.AOEPull:Clone()
		CurrentVisuzaliserAsset.Parent = WorkspaceVisualizedFolder
		VisualizerText.Adornee = CurrentVisuzaliserAsset
		CurrentVisuzaliserAsset.Color = CurrentColor
		LastModeForAOE = CurrentVisuzaliserAsset.Name
		newSize()
	end)
	
	AOESettings.Push.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(AOESettings.Push)
		if res == false then return end
		CurrentVisuzaliserAsset:Destroy()
		CurrentVisuzaliserAsset = nil
		CurrentVisuzaliserAsset = VisualizerFolder.AOEPush:Clone()
		CurrentVisuzaliserAsset.Parent = WorkspaceVisualizedFolder
		VisualizerText.Adornee = CurrentVisuzaliserAsset
		CurrentVisuzaliserAsset.Color = CurrentColor
		LastModeForAOE = CurrentVisuzaliserAsset.Name
		newSize()
	end)
	
	-- AtoB
	
	AtoBSettings.Solid.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(AtoBSettings.Solid)
		if res == false then return end
		CurrentVisuzaliserAsset:Destroy()
		CurrentVisuzaliserAsset = nil
		CurrentVisuzaliserAsset = VisualizerFolder.AtoBSolid:Clone()
		CurrentVisuzaliserAsset.Parent = WorkspaceVisualizedFolder
		VisualizerText.Adornee = CurrentVisuzaliserAsset
		CurrentVisuzaliserAsset.Color = CurrentColor
		LastModeForAtoB = CurrentVisuzaliserAsset.Name
		newSize()
	end)
	
	AtoBSettings.Cone.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(AtoBSettings.Cone)
		if res == false then return end
		CurrentVisuzaliserAsset:Destroy()
		CurrentVisuzaliserAsset = nil
		CurrentVisuzaliserAsset = VisualizerFolder.AtoBCone:Clone()
		CurrentVisuzaliserAsset.Parent = WorkspaceVisualizedFolder
		VisualizerText.Adornee = CurrentVisuzaliserAsset
		CurrentVisuzaliserAsset.Color = CurrentColor
		LastModeForAtoB = CurrentVisuzaliserAsset.Name
		newSize()
	end)
	
	AtoBSettings.Directional.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(AtoBSettings.Directional)
		if res == false then return end
		CurrentVisuzaliserAsset:Destroy()
		CurrentVisuzaliserAsset = nil
		CurrentVisuzaliserAsset = VisualizerFolder.AtoBDirectional:Clone()
		CurrentVisuzaliserAsset.Parent = WorkspaceVisualizedFolder
		VisualizerText.Adornee = CurrentVisuzaliserAsset
		CurrentVisuzaliserAsset.Color = CurrentColor
		LastModeForAtoB = CurrentVisuzaliserAsset.Name
		newSize()
	end)
	
	local function CustomEntry(enter)
		if enter then
			if MajorDebounce == true then return end
			MajorDebounce = true

			local Rnumber = tonumber(ColorSelector.Manual.R.Text)
			local Gnumber = tonumber(ColorSelector.Manual.G.Text)
			local Bnumber = tonumber(ColorSelector.Manual.B.Text)

			if Rnumber == nil or Gnumber == nil or Bnumber == nil then
				return
			end

			Rnumber = math.clamp(Rnumber, 0, 255)
			Gnumber = math.clamp(Gnumber, 0, 255)
			Bnumber = math.clamp(Bnumber, 0, 255)
			local color = Color3.fromRGB(Rnumber,Gnumber,Bnumber)
			CurrentColor = color
			CurrentVisuzaliserAsset.Color = color
			if CurrentVisuzaliserAsset.Name == "Throwable" then
				CurrentVisuzaliserAsset.DirectionalArc.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, CurrentColor), ColorSequenceKeypoint.new(1, CurrentColor)})
			end
			if CurrentVisuzaliserAsset.Name == "Ping" then
				CurrentVisuzaliserAsset.Ping.ImageLabel.ImageColor3 = CurrentColor
			end

		end
	end

	ColorSelector.Manual.R.FocusLost:Connect(CustomEntry)
	ColorSelector.Manual.G.FocusLost:Connect(CustomEntry)
	ColorSelector.Manual.B.FocusLost:Connect(CustomEntry)

	for i, v in pairs(ColorSelector.Scroller.Bin:GetChildren()) do
		if v:IsA("TextButton") then
			v.MouseButton1Click:Connect(function()
				if MajorDebounce == true then return end
				MajorDebounce = true

				local color = v.BackgroundColor3
				ColorSelector.Manual.R.Text = tostring(math.round(color.R*255))
				ColorSelector.Manual.G.Text = tostring(math.round(color.G*255))
				ColorSelector.Manual.B.Text = tostring(math.round(color.B*255))
				local vector = color
				CurrentColor = color
				CurrentVisuzaliserAsset.Color = color
				
				if CurrentVisuzaliserAsset.Name == "Throwable" then
					CurrentVisuzaliserAsset.Color = color
					CurrentVisuzaliserAsset.DirectionalArc.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, CurrentColor), ColorSequenceKeypoint.new(1, CurrentColor)})
				end
				if CurrentVisuzaliserAsset.Name == "Ping" then
					CurrentVisuzaliserAsset.Ping.ImageLabel.ImageColor3 = CurrentColor
				end
			end)
		end
	end
	
	local lastText = ""
	
	TextInputBox:GetPropertyChangedSignal("Text"):Connect(function()
		local textN = #TextInputBox.Text
		if textN > 150 then
			TextInputBox.Text = lastText
		else
			lastText = TextInputBox.Text
			VisualizerText.text.Text = lastText
		end
	end)
	
	local CurrentCamera = workspace.CurrentCamera
	
	local PlayerTable = {}
	
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	
	local function RefreshVisualizerRaycastFilter()
		table.clear(PlayerTable)
		for i, v in pairs(Players:GetPlayers()) do
			if v.Character then
				table.insert(PlayerTable, v.Character)
			end
		end
		table.insert(PlayerTable, WorkspaceVisualizedFolder)
		params.FilterDescendantsInstances = PlayerTable
	end

	for i, v in pairs(Players:GetPlayers()) do
		v.CharacterAdded:Connect(RefreshVisualizerRaycastFilter)
		v.CharacterRemoving:Connect(function()
			task.defer(RefreshVisualizerRaycastFilter)
		end)
	end

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(RefreshVisualizerRaycastFilter)
		player.CharacterRemoving:Connect(function()
			task.defer(RefreshVisualizerRaycastFilter)
		end)
		RefreshVisualizerRaycastFilter()
	end)

	Players.PlayerRemoving:Connect(function()
		task.defer(RefreshVisualizerRaycastFilter)
	end)
	RefreshVisualizerRaycastFilter()
	
	local function UpdateConstructsRemaining()
		VisualizerUI.tempavail.Text = tostring(TempConstructs) .. "/3 Temporary Visualizations"
		VisualizerUI.permavail.Text = tostring(PermConstructs) .. "/1 Permanent Visualizations"
	end
	
	local ActiveVisualizations = workspace:WaitForChild("ActiveVisualizations")
	
	for i, v in pairs(ActiveVisualizations:GetChildren()) do
		local p = v:FindFirstChildOfClass("RemoteEvent")
		
		if p:FindFirstChildOfClass("Script").Player.Value == Client.Name then
			task.spawn(function()
				local name = p.Name
				if name == "TemporaryEvent" then
					TempConstructs = TempConstructs + 1
				else
					PermConstructs = PermConstructs + 1
				end
				UpdateConstructsRemaining()
				v.AncestryChanged:Wait()
				if name == "TemporaryEvent" then
					TempConstructs = TempConstructs - 1
				else
					PermConstructs = PermConstructs - 1
				end
				UpdateConstructsRemaining()
			end)
		else
			if not GroupVerification.CheckRank(Client, "Staff") then
				--p.Enabled = false
			end
			--if PromptsToggle == false then p.Enabled = false end
		end
	end
	
	UpdateConstructsRemaining()
	
	ActiveVisualizations.ChildAdded:Connect(function(child)
		
		wait(0.1)
		local p = child:FindFirstChildOfClass("RemoteEvent")
		
		if VisualizationsToggle == false then
			child.Transparency = 1
			for i, v in pairs(child:GetDescendants()) do
				if v:IsA("Beam") then
					v.Enabled = false
				elseif v:IsA("TextLabel") then
					v.Visible = false
				end
			end
		end
		
			if p:FindFirstChildOfClass("Script").Player.Value == Client.Name then
				child.AncestryChanged:Wait()
					local name = p.Name
					if name == "TemporaryEvent" then
						TempConstructs = TempConstructs - 1
					else
						PermConstructs = PermConstructs - 1
					end
				
					UpdateConstructsRemaining()
			
		else
			
			
			end
		
		
	end)
	
	-- Type can be either "Temporary" or "Permanent"
	-- Mode is either AOE, AtoB, Throwable or Ping
	-- AssetName is the name of the Asset being used
	-- Color is the color of the asset used
	-- CFrameUsed is the CFrame of the Asset
	-- Size is the size like
	-- InputtedText is the text the player wants to be displayed.
	
	--[[GeneralSettings["Toggle Prompts"].MouseButton1Down:Connect(function()
		local res = TweenButtonClick(GeneralSettings["Toggle Prompts"])
		if res == false then return end
		if PromptsToggle == false then PromptsToggle = true; GeneralSettings["Toggle Prompts"].Slide.displayText.Text = "Prompts: ON" else PromptsToggle = false; GeneralSettings["Toggle Prompts"].Slide.displayText.Text = "Prompts: OFF" end
			for i, child in pairs(ActiveVisualizations:GetChildren()) do
				local p = child:FindFirstChildOfClass("ProximityPrompt")
					if PromptsToggle == false then 
						p.Enabled = false 			
					else
						if ClientGroupRank >= 249 or p.Player.Value == Client.Name then p.Enabled = true end
					end
			end
	end)--]]
	
	GeneralSettings.ToggleVisualizations.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(GeneralSettings.ToggleVisualizations)
		if res == false then return end
		if VisualizationsToggle == false then VisualizationsToggle = true; GeneralSettings.ToggleVisualizations.Slide.displayText.Text = "Visualizations: ON"  else VisualizationsToggle = false GeneralSettings.ToggleVisualizations.Slide.displayText.Text = "Visualizations: OFF" end
		for i, child in pairs(ActiveVisualizations:GetChildren()) do
			if VisualizationsToggle == true then
				child.Transparency = 0.25
				for i, v in pairs(child:GetDescendants()) do
					if v:IsA("Beam") then
						v.Enabled = true
					elseif v:IsA("TextLabel") then
						v.Visible = true
					end
				end
			else
				child.Transparency = 1
				for i, v in pairs(child:GetDescendants()) do
					if v:IsA("Beam") then
						v.Enabled = false
					elseif v:IsA("TextLabel") then
						v.Visible = false
					end
				end
			end
		end
	end)
	
	
	
	local PlacementDeb = false
	
	
	
	-- mouse buttons
	
	Mouse.Button1Down:Connect(function()
		print("Control Deb:", ControlDeb, "PlacementDeb", PlacementDeb)
		if CurrentUI ~= "Visualizer" then return end
		if PlacementDeb == true then return end
		PlacementDeb = true
		
		if ControlDeb == false then
			if CurrentVisualizerMode == "AtoB" then
				if AtoBPointOne == nil then
					local CamP = CurrentCamera.CFrame.Position
					local MouseP = Mouse.Hit.Position
					local result = workspace:Raycast(CamP, (MouseP - CamP).Unit*200, params)
					if result then
						local P = result.Position
						local N = result.Normal
						AtoBPointOne = (CFrame.new(P, N+P) * CFrame.new(0,0,-CurrentHeight)).Position
					end
					
				else
					
					
						if TempConstructs < 3 then
						TempConstructs = TempConstructs + 1
							VisualizerEvent:FireServer("Temporary", CurrentVisuzaliserAsset.Name, CurrentColor, CurrentVisuzaliserAsset.CFrame, CurrentVisuzaliserAsset.Size, lastText, PlayerCentricDeb, Character.HumanoidRootPart.CFrame)
						AtoBPointOne = nil
						
						UpdateConstructsRemaining()
							
						end
					
					
				end
				
			else
				
					if TempConstructs < 3 then
					TempConstructs = TempConstructs + 1
						VisualizerEvent:FireServer("Temporary", CurrentVisuzaliserAsset.Name, CurrentColor, CurrentVisuzaliserAsset.CFrame, CurrentVisuzaliserAsset.Size, lastText, PlayerCentricDeb, Character.HumanoidRootPart.CFrame)
						AtoBPointOne = nil
						
					
					UpdateConstructsRemaining()
						
					end
				
			end
			
		else
			
			if CurrentVisualizerMode == "AtoB" then
				if AtoBPointOne == nil then
					local CamP = CurrentCamera.CFrame.Position
					local MouseP = Mouse.Hit.Position
					local result = workspace:Raycast(CamP, (MouseP - CamP).Unit*200, params)
					if result then
						local P = result.Position
						local N = result.Normal
						AtoBPointOne = (CFrame.new(P, N+P) * CFrame.new(0,0,-CurrentHeight)).Position
					end

				else

					
						if PermConstructs < 1 then
						PermConstructs = PermConstructs + 1
							VisualizerEvent:FireServer("Permanent", CurrentVisuzaliserAsset.Name, CurrentColor, CurrentVisuzaliserAsset.CFrame, CurrentVisuzaliserAsset.Size, lastText, PlayerCentricDeb, Character.HumanoidRootPart.CFrame)
							AtoBPointOne = nil
						
						
						UpdateConstructsRemaining()
							
						end
				

				end

			else
				
					if PermConstructs < 1 then
					PermConstructs = PermConstructs + 1
						VisualizerEvent:FireServer("Permanent", CurrentVisuzaliserAsset.Name, CurrentColor, CurrentVisuzaliserAsset.CFrame, CurrentVisuzaliserAsset.Size, lastText, PlayerCentricDeb, Character.HumanoidRootPart.CFrame)
						AtoBPointOne = nil
						
					
					UpdateConstructsRemaining()
					end
				
			end
			
			
		end	
		
		wait(1)
		PlacementDeb= false
		
	end)
	
	
	
	
	
	-- main update event/loop
	
	RunService.Heartbeat:Connect(function()
		if CurrentUI == "Visualizer" then
			--print("Mode:", CurrentVisualizerMode, "Asset:", CurrentVisuzaliserAsset)
			if CurrentVisualizerMode == "AOE" then
				
				if not PlayerCentricDeb then
					
					local CamP = CurrentCamera.CFrame.Position
					local MouseP = Mouse.Hit.Position
					local result = workspace:Raycast(CamP, (MouseP - CamP).Unit*200, params)
					if result then
						local P = result.Position
						local N = result.Normal
						CurrentVisuzaliserAsset.CFrame = CFrame.new(P, N+P) * CFrame.Angles(math.rad(90),0,0) * CFrame.new(0,-(0.3/2), 0)
						SizeInstructions.Visible = true
					else
						SizeInstructions.Visible = false
					end
					SizeInstructions.Position = GetMouseScreenPosition(Mouse)
					
				else
					
					local Origin = Character.HumanoidRootPart.CFrame
					local result = workspace:Raycast(Origin.Position, (-Origin.UpVector)*200, params)
					if result then
						local P = result.Position
						local N = result.Normal
						CurrentVisuzaliserAsset.CFrame = CFrame.new(P, N+P) * CFrame.Angles(math.rad(90),0,0) * CFrame.new(0,-(0.3/2), 0)
						SizeInstructions.Visible = true
					else
						SizeInstructions.Visible = false
					end
					SizeInstructions.Position = GetMouseScreenPosition(Mouse)
					
				end
				
			elseif CurrentVisualizerMode == "AtoB" then
				
				
					if CurrentVisuzaliserAsset.Name == "AtoBSolid" then
						local Size = CurrentVisuzaliserAsset.Size
						if PlayerCentricDeb == true then 
							AtoBPointOne = Character.HumanoidRootPart.Position - Vector3.new(0,Size.Y/2,0)
						end
							
						local CamP = CurrentCamera.CFrame.Position
						local MouseP = Mouse.Hit.Position
						local result = workspace:Raycast(CamP, (MouseP - CamP).Unit*200, params)
						if result then
							local P = result.Position
							local N = result.Normal
								
							if AtoBPointOne then
									
								local distance = math.clamp((AtoBPointOne - MouseP).magnitude, 0, 30)
								CurrentVisuzaliserAsset.Size = Vector3.new(CurrentVisuzaliserAsset.Size.X, Size.Y, distance)
								P = (CFrame.new(P, N+P) * CFrame.new(0,0,-CurrentHeight)).Position
								CurrentVisuzaliserAsset.CFrame = CFrame.new(AtoBPointOne, P) * CFrame.new(0,0,-distance / 2) * CFrame.new(0,(Size.Y/2), 0)
							else
									
								P = (CFrame.new(P, N+P) * CFrame.new(0,0,-CurrentHeight)).Position
								CurrentVisuzaliserAsset.CFrame = CFrame.new(P, N+P) * CFrame.new(0,0,-(Size.Y/2))
							end
							
						end	
					
					
				elseif CurrentVisuzaliserAsset.Name == "AtoBDirectional" then
					local Size = CurrentVisuzaliserAsset.Size
					if PlayerCentricDeb == true then 
						AtoBPointOne = Character.HumanoidRootPart.Position - Vector3.new(0,Size.Y/2,0)
					end

					local CamP = CurrentCamera.CFrame.Position
					local MouseP = Mouse.Hit.Position
					local result = workspace:Raycast(CamP, (MouseP - CamP).Unit*200, params)
					if result then
						local P = result.Position
						local N = result.Normal

						if AtoBPointOne then

							local distance = math.clamp((AtoBPointOne - MouseP).magnitude, 0, 30)
							CurrentVisuzaliserAsset.Size = Vector3.new(CurrentVisuzaliserAsset.Size.X, Size.Y, distance)
							P = (CFrame.new(P, N+P) * CFrame.new(0,0,-CurrentHeight)).Position
							CurrentVisuzaliserAsset.CFrame = CFrame.new(AtoBPointOne, P) * CFrame.new(0,0,-distance / 2) * CFrame.new(0,(Size.Y/2), 0)
						else

							P = (CFrame.new(P, N+P) * CFrame.new(0,0,-CurrentHeight)).Position
							CurrentVisuzaliserAsset.CFrame = CFrame.new(P, N+P) * CFrame.new(0,0,-(Size.Y/2))
						end

						
							CurrentVisuzaliserAsset.Back.Position = Vector3.new(0,0,Size.Z/2)
							CurrentVisuzaliserAsset.Front.Position = Vector3.new(0,0,-(Size.Z/2))
							CurrentVisuzaliserAsset.DirectionalStraight.TextureLength = Size.Z/2
							CurrentVisuzaliserAsset.DirectionalStraight.Width0 = Size.X
							CurrentVisuzaliserAsset.DirectionalStraight.Width1 = Size.Y
						


					end	
				
				elseif CurrentVisuzaliserAsset.Name == "AtoBCone" then
					local Size = CurrentVisuzaliserAsset.Size
					if PlayerCentricDeb == true then 
						AtoBPointOne = Character.HumanoidRootPart.Position - Vector3.new(0,0,0)
					end

					local CamP = CurrentCamera.CFrame.Position
					local MouseP = Mouse.Hit.Position
					local result = workspace:Raycast(CamP, (MouseP - CamP).Unit*200, params)
					if result then
						local P = result.Position
						local N = result.Normal

						if AtoBPointOne then
							
							local distance = math.clamp((AtoBPointOne - MouseP).magnitude, 0, 30)
							CurrentVisuzaliserAsset.Size = Vector3.new(CurrentVisuzaliserAsset.Size.X, distance, Size.Z)
							P = (CFrame.new(P, N+P) * CFrame.new(0,0,-CurrentHeight)).Position
							CurrentVisuzaliserAsset.CFrame = ((CFrame.new(AtoBPointOne, P) * CFrame.Angles(math.rad(90),0,0)) * CFrame.new(0,-(distance / 2),0)) --  CFrame.new(0,0,-(CurrentVisuzaliserAsset.Size.Z/2)
						else
							
							P = (CFrame.new(P, N+P) * CFrame.new(0,0,-CurrentHeight)).Position
							CurrentVisuzaliserAsset.CFrame = CFrame.new(P, N+P) * CFrame.new(0,0,-(Size.Y/2))
						end
					end

					
				end
				
			elseif CurrentVisualizerMode == "Throwable" then
				
				local CamP = CurrentCamera.CFrame.Position
				local MouseP = Mouse.Hit.Position
				local result = workspace:Raycast(CamP, (MouseP - CamP).Unit*200, params)
				if result then
					local P = result.Position
					local N = result.Normal
					CurrentVisuzaliserAsset.CFrame = CFrame.new(P, N+P) * CFrame.new(0,0,-(CurrentHeight/2))
					SizeInstructions.Visible = true
				else
					SizeInstructions.Visible = false
				end
				
				
			elseif CurrentVisualizerMode == "Ping" then
				
				CurrentVisuzaliserAsset.Ping.Enabled = true
				local CamP = CurrentCamera.CFrame.Position
				local MouseP = Mouse.Hit.Position
				local result = workspace:Raycast(CamP, (MouseP - CamP).Unit*200, params)
				if result then
					local P = result.Position
					local N = result.Normal
					CurrentVisuzaliserAsset.CFrame = CFrame.new(P, N+P) * CFrame.new(0,0,-(CurrentHeight/2))
					SizeInstructions.Visible = true
				else
					SizeInstructions.Visible = false
				end
				
			end
			SizeInstructions.Position = GetMouseScreenPosition(Mouse)
			SizeInstructions.Visible = true

		else
		SizeInstructions.Visible = false
		end
	end)
	
	
end


-- Info section

local InfoUI = MainUI.Info

do
	print("Indexing the info section")
	InfoUI.PatchNotesButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(InfoUI.PatchNotesButton)
		if not res then return end
		InfoUI.PatchNotes.Visible = true
		InfoUI.CombatGuide.Visible = false
		InfoUI.Damage.Visible = false
		InfoUI.Tiers.Visible = false
	end)
	
	InfoUI.CombatGuideButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(InfoUI.CombatGuideButton)
		if not res then return end
		InfoUI.PatchNotes.Visible = false
		InfoUI.CombatGuide.Visible = true
		InfoUI.Damage.Visible = false
		InfoUI.Tiers.Visible = false
	end)
	
	InfoUI.DamageButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(InfoUI.DamageButton)
		if not res then return end
		InfoUI.PatchNotes.Visible = false
		InfoUI.CombatGuide.Visible = false
		InfoUI.Damage.Visible = true
		InfoUI.Tiers.Visible = false
	end)
	
	InfoUI.TiersButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(InfoUI.TiersButton)
		if not res then return end
		InfoUI.PatchNotes.Visible = false
		InfoUI.CombatGuide.Visible = false
		InfoUI.Damage.Visible = false
		InfoUI.Tiers.Visible = true
	end)
	
end

-- player cards AND event system

do
	local InspectionFrame = MainUI.InspectionFrame
	local InspectionCardClone = script:WaitForChild("InspectionCard")
	
	local Mouse = Client:GetMouse()
	
	-- event system vars
	
	local TimeIncrement = 5

	local EventInvoke = ReplicatedStorage:WaitForChild("EventInvoke")
	local CurrentEvents = ReplicatedStorage:WaitForChild("CurrentEvents")
	local EventSystemUI = MainUI.EventSystem
	local HoverFrame = EventSystemUI.HoverFrame
	local EntryHoverFrame = EventSystemUI.EntryHoverFrame
	local EventsBox = EventSystemUI.EventsBox
	local EventBin = EventsBox.EventBin
	local EventTemplate = script:WaitForChild("EventTemplate")
	local PlayerTurnOrderEntryTemplate = script:WaitForChild("PlayerTurnOrderEntryTemplate")
	
	local ClockUI = EventSystemUI.Clock
	
	local ActiveEvent = EventSystemUI.EventsBox.CurrentEvent
	local ActiveTurnOrderBin = ActiveEvent.TurnOrderBin

	local ChildAddedEventCon = nil
	local PlayerTurnCycleEvents = {}
	local RemoveButtonConnections = nil
	local ClockConnection = nil
	local ClockTempConnection = nil

	local CurrentEventSelected = nil
	local CurrentEventBrowsing = nil
	local ClockTickSound = script:WaitForChild("ClockTick")
	
	
	-- clock
	
	local SubmitMode = true
	local SubmitTurnButton = ClockUI.Submit
	local Submitdeb = false

	
	EventSystemUI.Visible = true
	
	local function ResetSubmitButton()
		SubmitMode = true
		SubmitTurnButton.Slide.displayText.Text = "Submit Turn"
		Submitdeb = false
	end
	
	local function EstablishEventConnections()
		warn("Establishing new event connections. Currently browsing : ", CurrentEventBrowsing, "The event we're in : ", CurrentEventSelected)
		EventsBox:TweenPosition(UDim2.new(0, 0,0.439, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.7, true)
		EventBin.Visible = false
		ActiveEvent.Visible = true
		ActiveEvent.TopBar.Join.Visible = if not CurrentEventSelected then true else false
		ActiveEvent.TopBar.Leave.Visible = if not CurrentEventSelected then false else true
		ActiveEvent.TopBar.EventName.Text = CurrentEventBrowsing.Name or "Error"
		for i, v in pairs(PlayerTurnCycleEvents) do
			if v then v:Disconnect() end
		end
		PlayerTurnCycleEvents = {}
		for i, v in pairs(ActiveTurnOrderBin:GetChildren()) do
			if v:IsA("Frame") then v:Destroy() end
		end
		if ChildAddedEventCon then ChildAddedEventCon:Disconnect(); ChildAddedEventCon = nil end
		if RemoveButtonConnections then RemoveButtonConnections:Disconnect(); RemoveButtonConnections = nil end
		if ClockTempConnection then ClockTempConnection:Disconnect(); ClockTempConnection = nil end
		
		local function ToggleRemoveButtons(arg)
			for i, PlayerCard in pairs(ActiveTurnOrderBin:GetChildren()) do
				if PlayerCard:IsA("Frame") then
					PlayerCard.RemoveButton.Visible = arg
				end
			end
		end
		
		local function NewPlayerButtonCreation(PlayerInEvent)
			local new = PlayerTurnOrderEntryTemplate:Clone()
			new.Name = PlayerInEvent.Name
			local con
			con = PlayerInEvent.Changed:Connect(function(value)
				if value == true then
					new.IsActive.BackgroundColor3 = Color3.fromRGB(0,255,0)
				else
					new.IsActive.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
					if PlayerInEvent.Name == Client.Name then
						ResetSubmitButton()
					end
				end
			end)
			table.insert(PlayerTurnCycleEvents, con)
			local value = PlayerInEvent.Value
			if value == true then
				new.IsActive.BackgroundColor3 = Color3.fromRGB(0,255,0)
			else
				new.IsActive.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			end
			new.Player.Text = PlayerInEvent.Name
			
			if PlayerInEvent.Name == Client.Name then
				-- us
				if PlayerInEvent:GetAttribute("Host") then
					ToggleRemoveButtons(true)
				end
				RemoveButtonConnections = PlayerInEvent:GetAttributeChangedSignal("Host"):Connect(function()
					if PlayerInEvent:GetAttribute("Host") == true then
						ToggleRemoveButtons(true)
					else
						ToggleRemoveButtons(false)
					end
				end)
			end
					
				
			PlayerInEvent.AncestryChanged:Connect(function(child, parent)
				
					if not parent then
						new:Destroy()
						if PlayerInEvent.Name == Client.Name then
							-- this is us

							ActiveEvent.TopBar.Join.Visible =  true
							ActiveEvent.TopBar.Leave.Visible = false

							CurrentEventSelected = nil
							ClockUI.Visible = false
						end
					end

				end)

			local deb = false
			new.RemoveButton.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(new.RemoveButton)
				if not res then return end
				if deb then return end
				deb = true
				local p = Players:FindFirstChild(PlayerInEvent.Name)
				if p then
					EventInvoke:InvokeServer("Remove", p)
				end
			end)
			new.Parent = ActiveTurnOrderBin
		end

		ChildAddedEventCon = CurrentEventBrowsing.ChildAdded:Connect(NewPlayerButtonCreation)

		
		for i, PlayerInEvent in pairs(CurrentEventBrowsing:GetChildren()) do
			NewPlayerButtonCreation(PlayerInEvent)
		end
		
		if CurrentEventSelected == CurrentEventBrowsing then -- main clock ui toggling
			ClockUI.Visible = true
			
			if ClockConnection then ClockConnection:Disconnect(); ClockConnection = nil end
			
			if CurrentEventSelected:GetAttribute("CurrentTurn") ~= 0 then
				local var = CurrentEventSelected:GetAttribute("CurrentTurn")
				local Seconds = TimeIncrement * var
				local Minutes = if (Seconds / 60) < 1 then 0 else (Seconds / 60)
				local LeftoverSeconds = Seconds % 60
				local fullConcat = (if Minutes == 0 then "0" elseif Minutes > 9 then tostring(Minutes) else "0" .. tostring(Minutes)) .. ":" .. if LeftoverSeconds > 9 then tostring(LeftoverSeconds) else "0" .. tostring(LeftoverSeconds)
				ClockUI.ClockTime.Text = fullConcat
			else
				ClockUI.ClockTime.Text = "0:00"
			end
			
			
			ClockConnection = CurrentEventSelected:GetAttributeChangedSignal("CurrentTurn"):Connect(function()
				
				local var = CurrentEventSelected:GetAttribute("CurrentTurn")
				if var == 0 then ClockUI.ClockTime.Text = "0:00"; ResetSubmitButton() return end
				local Seconds = TimeIncrement * var
				local Minutes = if (Seconds / 60) < 1 then 0 else (Seconds / 60)
				local LeftoverSeconds = Seconds % 60
				local fullConcat = (if Minutes == 0 then "0" elseif Minutes > 9 then tostring(Minutes) else "0" .. tostring(Minutes)) .. ":" .. if LeftoverSeconds > 9 then tostring(LeftoverSeconds) else "0" .. tostring(LeftoverSeconds)
				ClockUI.ClockTime.Text = fullConcat
				ClockTickSound:Play()
				--ResetSubmitButton()
			end)
		end
		
		-- top bar time display
		if CurrentEventBrowsing:GetAttribute("CurrentTurn") ~= 0 then
		local var = CurrentEventBrowsing:GetAttribute("CurrentTurn")
		local Seconds = TimeIncrement * var
		local Minutes = if (Seconds / 60) < 1 then 0 else (Seconds / 60)
		local LeftoverSeconds = Seconds % 60
			local fullConcat = (if Minutes == 0 then "0" elseif Minutes > 9 then tostring(Minutes) else "0" .. tostring(Minutes)) .. ":" .. if LeftoverSeconds > 9 then tostring(LeftoverSeconds) else "0" .. tostring(LeftoverSeconds)
			ActiveEvent.TopBar.TimeLeft.Text = "RTP: " .. fullConcat
		else
			ActiveEvent.TopBar.TimeLeft.Text = "RTP: 0:00"
		end
		
		ClockTempConnection = CurrentEventBrowsing:GetAttributeChangedSignal("CurrentTurn"):Connect(function()
			local var = CurrentEventBrowsing:GetAttribute("CurrentTurn")
			if var == 0 then ActiveEvent.TopBar.TimeLeft.Text = "RTP: 0:00" return end
			local Seconds = TimeIncrement * var
			local Minutes = if (Seconds / 60) < 1 then 0 else (Seconds / 60)
			local LeftoverSeconds = Seconds % 60
			local fullConcat = (if Minutes == 0 then "0" elseif Minutes > 9 then tostring(Minutes) else "0" .. tostring(Minutes)) .. ":" .. if LeftoverSeconds > 9 then tostring(LeftoverSeconds) else "0" .. tostring(LeftoverSeconds)
			ActiveEvent.TopBar.TimeLeft.Text = "RTP: " .. fullConcat
		end)
		
	end
	
	local function FindEventFromPlayer(player)
		for i, v in pairs(CurrentEvents:GetChildren()) do
			if v:FindFirstChild(player.Name) then
				return v
			end
		end
	end
	
	local function DisplayFrame(t)
		local p = Players:FindFirstChild(t.Name)
		if p then
			local Folder = ReplicatedStorage.Info:FindFirstChild(p.Name)
			if Folder then
				if InspectionFrame:FindFirstChild(p.Name) then return end
				local clone = InspectionCardClone:Clone()
				
			
				clone.Parent = InspectionFrame
				clone.Name = p.Name
				
				local powercard = clone.EmpowermentFrame
				local skillcard = clone.SkillFrame
				local biocard = clone.BioFrame
				
				local heightCon = nil
				
				local feet, inches = CalculateHeight(p.Character.Humanoid.BodyHeightScale.Value)
				biocard.height.Text = "Height: " .. tostring(feet) .. "'" .. tostring(inches)
			
				
				heightCon = p.Character.Humanoid.BodyHeightScale.Changed:Connect(function(val)
					local feet, inches = CalculateHeight(val)
					biocard.height.Text = "Height: " .. tostring(feet) .. "'" .. tostring(inches)
				end)
				
				clone.Close.MouseButton1Down:Connect(function()
					local res = TweenButtonClick(clone.Close)
					if not res then return end
					heightCon:Disconnect()
					heightCon = nil
					clone:Destroy()
				end)
				
				clone.PowerButton.MouseButton1Down:Connect(function()
					local res = TweenButtonClick(clone.PowerButton)
					if not res then return end
					powercard.Visible = true
					biocard.Visible = false
					skillcard.Visible = false
				end)
				
				clone.BioButton.MouseButton1Down:Connect(function()
					local res = TweenButtonClick(clone.BioButton)
					if not res then return end
					powercard.Visible = false
					biocard.Visible = true
					skillcard.Visible = false
				end)
				
				clone.SkillsButton.MouseButton1Down:Connect(function()
					local res = TweenButtonClick(clone.SkillsButton)
					if not res then return end
					powercard.Visible = false
					biocard.Visible = false
					skillcard.Visible = true
				end)
				
				local invitedeb = false
		
				clone.Invite.MouseButton1Down:Connect(function()
					local res = TweenButtonClick(clone.Invite)
					if not res then return end
					if invitedeb then return end
					if CurrentEventSelected then if CurrentEventSelected:FindFirstChild(p.Name) then return end end
					invitedeb = true
					local result = EventInvoke:InvokeServer("Invite", p)
					if result ~= false then
						if CurrentEventSelected ~= result then
							CurrentEventSelected = result
							CurrentEventBrowsing = result
							EstablishEventConnections()
						end
					end
					if result == false then wait(5); invitedeb = false end
				end)
				
				clone.Join.MouseButton1Down:Connect(function()
					local res = TweenButtonClick(clone.Join)
					if not res then return end
					local Event = FindEventFromPlayer(p)
					if Event then
						if Event == CurrentEventSelected then return end
						local result = EventInvoke:InvokeServer("Join", Event)
						if result then
							CurrentEventSelected = Event
							CurrentEventBrowsing = Event
							EstablishEventConnections()
						end
					end
					
				end)
				
				local function Update()
					print("Updating")
					local CustomName = p:GetAttribute("CustomName")
					local CBio = Folder.CBio.Value
					local CName = Folder.CName.Value
					local EmpType = Folder.EmpowermentType.Value
					local EmpTitle = Folder.EmpowermentTitle.Value
					local EmpDesc = Folder.Empowerment.Value
					local CImage = Folder.CImage.Value
					if CImage == 0 or CImage == nil then CImage = 0 end
					local CImage = "rbxthumb://type=Asset&id=" .. tostring(Folder.CImage.Value) .. "&w=420&h=420"

					if CBio == "" then CBio = "(No bio inputted)"; biocard.CBio.TextScaled = false  end
					if CName == "" then CName = "(No name inputted)"; biocard.CName.TextScaled = false end
					if EmpType == "" then EmpType = "(No type selected)"; powercard.EmpowermentType.TextScaled = false end
					if EmpTitle == "" then EmpTitle = "(No title inputted)"; powercard.EmpowermentTitle.TextScaled = false end
					if EmpDesc == "" then EmpDesc = "(No description inputted)" powercard.Description.TextScaled = false end
					
					biocard.CBio.Text = CBio; biocard.CBio.TextScaled = true
					biocard.CName.Text = CName; biocard.CName.TextScaled = true
					clone.CImage.Image = CImage; 
					powercard.EmpowermentTitle.Text = EmpTitle; powercard.EmpowermentTitle.TextScaled = true
					powercard.Description.Text = EmpDesc; powercard.Description.TextScaled = true
					powercard.EmpowermentType.Text = EmpType; powercard.EmpowermentType.TextScaled = true
					
					if CustomName == nil or CustomName == "" then
						clone.TopBar.Username.Text = p.Name .. " (" .. p.DisplayName .. ")"
					else
						clone.TopBar.Username.Text = CustomName .. " (" .. CustomName .. ")"
					end
					
					
					

					for i = 1, 5, 1 do
						local Type = Folder["Skill" .. tostring(i) .. "Type"].Value
						local Title = Folder["Skill" .. tostring(i) .. "Title"].Value
						local Description = Folder["Skill" .. tostring(i) .. "Description"].Value

						local Bin = skillcard:FindFirstChild(tostring(i))

						if Type ~= "" and Title ~= "" and Description ~= "" then
							Bin.SkillTitle.Text = Title; Bin.SkillTitle.TextScaled = true
							Bin.SkillType.Text = Type; Bin.SkillType.TextScaled = true
							Bin.SkillDescription.Text = Description; Bin.SkillDescription.TextScaled = true
						else
							Bin.SkillTitle.Text = "(None)"; Bin.SkillTitle.TextScaled = false
							Bin.SkillType.Text = "(None)"; Bin.SkillType.TextScaled = false
							Bin.SkillDescription.Text = "(None)"; Bin.SkillDescription.TextScaled = false
						end

					end
				end
				
				Update()
				task.spawn(function()
					local ServerTick = ReplicatedStorage.ServerTick
					while true do
						wait(1)
						if clone.Parent == InspectionFrame then
							local val = Folder.lastBioChanged.Value
							local current = ServerTick.Value
							val = math.round(math.abs(current-val))
							if val < 5 then
								Update()
							end
							clone.lastBio.Text = "Time since Bio changed: " .. tostring(val)
							
							local val = Folder.lastEmpChanged.Value
							local current = ServerTick.Value
							val = math.round(math.abs(current-val))
							if val < 5 then
								Update()
							end
							clone.lastEmp.Text = "Time since Emp changed: " .. tostring(val)
							
							local val = Folder.lastD20.Value
							if val == 0 then
								clone.lastD20.Text = "Last D20: None"
							else
								clone.lastD20.Text = "Last D20: " .. tostring(val)
							end
						else
							warn("clone deleted")
							break
						end
					end
				end)
				local obj = DraggableObject.new(clone)
				obj:Enable()
				
			end
			
		end
	end
	Mouse.Button1Down:Connect(function()
		local t = Mouse.Target
		if t then
			if t.Parent ~= workspace then
				if t.Parent:FindFirstChild("Humanoid") then
					DisplayFrame(t.Parent)
				elseif t.Parent:IsA("Accessory") then
					if t.Parent.Parent:FindFirstChild("Humanoid") then
						DisplayFrame(t.Parent.Parent)
					end
				end
			end

		end
	end)
	
	
	-- event system connections 
	
		EntryHoverFrame.MouseEnter:Connect(function()
			if CurrentEventSelected == nil and not CurrentUI and CurrentUI ~= "" then
				EventsBox:TweenPosition(UDim2.new(0, 0,0.439, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.7, true)
			end
		end)

		HoverFrame.MouseLeave:Connect(function()
			if CurrentEventSelected == nil then
				EventsBox:TweenPosition(UDim2.new(-0.16, 0,0.439, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.7, true)
			end
		end)

	local function SetUpRegularEventConnections(Event)
		local newEvent = EventTemplate:Clone()
		newEvent.Name = Event.Name
		Event:GetPropertyChangedSignal("Name"):Connect(function()
			wait()
			newEvent.Name = Event.Name
		end)
		newEvent.Parent = EventBin
		
		newEvent:FindFirstChild("Players").Text = "Players: " .. tostring(#Event:GetChildren())
		newEvent.MouseButton1Click:Connect(function()
			CurrentEventBrowsing = Event
			ActiveEvent.Visible = true
			EventBin.Visible = false
			EstablishEventConnections()
		end)
		newEvent.EventType.Text = Event:GetAttribute("Type")
		
		Event.ChildAdded:Connect(function(newPlayer)
			
			newEvent:FindFirstChild("Players").Text = "Players: " .. tostring(#Event:GetChildren())
			local p = Players:FindFirstChild(newPlayer.Name)
			if p then
				if p == Client then
					CurrentEventSelected = Event
					CurrentEventBrowsing = Event
					EstablishEventConnections()
				end
			end
		end)
		
		Event.ChildRemoved:Connect(function(player)
			newEvent.Players.Text = "Players: " .. tostring(#Event:GetChildren())
		end)
		
		Event.AncestryChanged:Connect(function(child,parent)
			if not parent then
				warn("Destroy tripped")
				if CurrentEventBrowsing == Event then
					
						CurrentEventBrowsing = nil
						ActiveEvent.Visible = false
						EventBin.Visible = true
				end
				if CurrentEventSelected == Event then
					CurrentEventSelected = nil
					ClockUI.Visible = false
					if ClockConnection then ClockConnection:Disconnect() end
				end
				newEvent:Destroy()
			end
			
		end)
		
	end

		for index_1, Event in pairs(CurrentEvents:GetChildren()) do
		SetUpRegularEventConnections(Event)
	end
	
	CurrentEvents.ChildAdded:Connect(function(Event)
		SetUpRegularEventConnections(Event)
	end)
		
	-- top bar for active events
	
	ActiveEvent.TopBar.Join.MouseButton1Click:Connect(function()
		if not CurrentEventBrowsing then return end
		print("currently browsing:", CurrentEventBrowsing)
		local temp = CurrentEventSelected
		CurrentEventSelected = CurrentEventBrowsing
		
		local res = EventInvoke:InvokeServer("Join", CurrentEventSelected)
		if res then
			EstablishEventConnections()
		else
			CurrentEventSelected = temp
		end
	end)
	
	ActiveEvent.TopBar.Leave.MouseButton1Click:Connect(function()
		local temp = CurrentEventSelected
		local res = EventInvoke:InvokeServer("Leave", CurrentEventSelected)
	end)
	
	ActiveEvent.TopBar.Back.MouseButton1Click:Connect(function()
		ActiveEvent.Visible = false
		EventBin.Visible = true
	end)
	

	
	SubmitTurnButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(SubmitTurnButton)
		if not res then return end
		if not CurrentEventSelected then return end
		if Submitdeb then return end
		Submitdeb = true
		if SubmitMode then
			EventInvoke:InvokeServer("Submit")
			SubmitMode = false
			SubmitTurnButton.Slide.displayText.Text = "Rescind"
		else
			EventInvoke:InvokeServer("Rescind")
			SubmitMode = true
			SubmitTurnButton.Slide.displayText.Text = "Submit Turn"
		end
		wait(0.1)
		Submitdeb = false
	end)

end



-- XP system

do
	local XPEvent = ReplicatedStorage:WaitForChild("XPEvent")
	local XPCounter = Client:WaitForChild("XP")
	MainUI.XP.number.Text = tonumber(XPCounter.Value)
	local UserInputService = game:GetService("UserInputService")

	UserInputService.InputBegan:Connect(function(input, gameprocessed)
		if gameprocessed == true and input.KeyCode == Enum.KeyCode.V then
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
				print("Was a paste")
				XPEvent:FireServer(true)
				
			else
				print("Was not a paste")
			end
		end
	end)
	
	
	
	XPCounter.Changed:Connect(function()
		local val = XPCounter.Value
		MainUI.XP.number.Text = tonumber(val)
		MainUI.XP.number.flyoff.Visible = true
	end)
end

-- shop

do
	local ShopUI = MainUI.Shop
	local MainShop = ShopUI.Main
	local ViewBox = MainShop.ViewBox
	local TpUi = MainUI.TeleportUI
	local WViewBox = MainShop.ViewBoxWeapons
	local ItemTemplate = script:WaitForChild("ShopItemTemplate")
	local CurrentAssetSelected = nil
	
	GeneralSettings.Shop.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(GeneralSettings.Shop)
		if not res then return end
		ShopUI.Visible = not ShopUI.Visible
	end)
	
	GeneralSettings.Teleport.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(GeneralSettings.Teleport)
		if not res then return end
		TpUi.Visible = not TpUi.Visible
	end)
	
	MainShop.Topbar.Close.MouseButton1Click:Connect(function()
		ShopUI.Visible = false
	end)
	
	
	for i, gamepass in pairs(GamepassList) do
		local asset = MarketplaceService:GetProductInfo(i, Enum.InfoType.GamePass)
		local price = asset.PriceInRobux
		local description = asset.Description
		local Image = asset.IconImageAssetId
		print("gamepasses", asset.Name, price, Image)
		local NewTemplate = ItemTemplate:Clone()
		NewTemplate.ItemName.Text = asset.Name
		NewTemplate.ItemImage.Image = "rbxassetid://" .. tostring(Image)
		NewTemplate:SetAttribute("Description", description)
		NewTemplate:SetAttribute("AssetId", i)
		NewTemplate.Parent = MainShop.ItemsList.Gamepasses
	end
	
	for i, weaponpacks in pairs(WeaponsPackList) do
		local asset = MarketplaceService:GetProductInfo(i, Enum.InfoType.GamePass)
		local price = asset.PriceInRobux
		local description = asset.Description
		local Image = asset.IconImageAssetId
		print("gamepasses", asset.Name, price, Image)
		local NewTemplate = ItemTemplate:Clone()
		NewTemplate.ItemName.Text = asset.Name
		NewTemplate.ItemImage.Image = "rbxassetid://" .. tostring(Image)
		NewTemplate:SetAttribute("Description", description)
		NewTemplate:SetAttribute("AssetId", i)
		NewTemplate.Parent = MainShop.ItemsList.WeaponPacks
	end
	
	local function DeselectAllItems(frame)
		for i, v in pairs(frame:GetChildren()) do
			if v:IsA("TextButton") then v.Text = "" end
		end
	end
	
	local function DeselectAllModesExcept(item)
		for i, frame in pairs(MainShop.ItemsList:GetChildren()) do
			if frame:IsA("ScrollingFrame") then
				if frame.Name ~= item then
					frame.Visible = false
				else
					frame.Visible = true
				end
			end
		end
	end
	
	local function DeleteWeapons(bin)
		for i, x in pairs(bin:GetChildren()) do
			if x:IsA("Frame") then
				x:Destroy()
			end
		end
	end
		
	for i, button in pairs(MainShop.SelectionBar:GetChildren()) do
		if button:IsA("TextButton") then
			button.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(button)
				if not res then return end
				DeselectAllModesExcept(button.Name)
			end)
		end
	end
	
	for i, frame in pairs(MainShop.ItemsList:GetChildren()) do
		
		for z, button in pairs(frame:GetChildren()) do
			if button:IsA("TextButton") then
				button.MouseButton1Click:Connect(function()
				
					DeselectAllItems(frame)
					CurrentAssetSelected = button:GetAttribute("AssetId")
					button.Text = "Selected"
					DeleteWeapons(WViewBox.OwnedWeapons)
					
					if button.Parent.Name == "WeaponPacks" then
						WViewBox.Visible = true
						ViewBox.Visible = false
						WViewBox.ItemDesc.Text = button:GetAttribute("Description")
						WViewBox.ItemName.Text = button.ItemName.Text
						WViewBox.ItemImage.Image = button.ItemImage.Image
						local id = tonumber(button:GetAttribute("AssetId"))
						
						local UserOwnsPass = MarketplaceService:UserOwnsGamePassAsync(Client.UserId, id)
						if UserOwnsPass then print("USER OWNS IT DEFAULTLY") end
						if GroupVerification.CheckRank(Client, "Gamemaster") == true then print("GROUP RANK GRANTS") UserOwnsPass = true end
						if GamepassWhitelist[Client.UserId] then print("WHITELIST GRANTS")  UserOwnsPass = true end
						if RunService:IsStudio() then print("STUDIO GRANTS")  UserOwnsPass = true end
						if WeaponsPackList[CurrentAssetSelected].Owned == true then print("WEAPON PACKLIST PREV OWNERSHIP GRANTS") UserOwnsPass = true end
						print("RUNNING CHECK")
						if UserOwnsPass then
							print("THEY OWN IT")
							WViewBox.Purchase.Visible = false
							WViewBox.OwnedWeapons.Visible = true
							WeaponsPackList[CurrentAssetSelected].Owned = true
							
							for Windex, Weapon in pairs(WeaponsPackList[CurrentAssetSelected].Weapons) do
								local NewWClone = script.WeaponTemplate:Clone()
								NewWClone.Name = Weapon
								NewWClone.ItemName.Text = Weapon
								NewWClone.Parent = WViewBox.OwnedWeapons
								NewWClone.Insert.MouseButton1Down:Connect(function()
									local res = TweenButtonClick(NewWClone.Insert)
									if not res then return end
									if MajorDebounce then return end
									if CountAccessories() > MaxAccessories then ErrorReport("Maximum Accessories reached. Buy the gamepass for more if you haven't already.") return end
									MajorDebounce = true
									local returned = CustomizationInvoke:InvokeServer("AddItem", Weapon)
									wait(0.5)
									MajorDebounce = false
								end)
							end
							
						else
							print("THEY DONT OWN IT")
							WViewBox.Purchase.Visible = true
							WViewBox.OwnedWeapons.Visible = false
							WViewBox.Purchase.Slide.displayText.Text = "Purchase"
						end
						
					
					else
						WViewBox.Visible = false
						ViewBox.Visible = true
						ViewBox.ItemDesc.Text = button:GetAttribute("Description")
						ViewBox.ItemName.Text = button.ItemName.Text
						ViewBox.ItemImage.Image = button.ItemImage.Image
						ViewBox.Purchase.Visible = true
						local id = tonumber(button:GetAttribute("AssetId"))
						local UserOwnsPass = MarketplaceService:UserOwnsGamePassAsync(Client.UserId, id)
						if GroupVerification.CheckRank(Client, "Gamemaster") == true then UserOwnsPass = true end
						if GamepassWhitelist[Client.UserId] then UserOwnsPass = true end
						if RunService:IsStudio() then UserOwnsPass = true end
						if GamepassList[CurrentAssetSelected].Owned == true then UserOwnsPass = true end
						if UserOwnsPass then
							ViewBox.Purchase.Slide.displayText.Text = "Owned"
							GamepassList[CurrentAssetSelected].Owned = true
						else
							ViewBox.Purchase.Slide.displayText.Text = "Purchase"
						end
					end
					
					
				end)
				button.MouseEnter:Connect(function()
					if button.Text == "Selected" then return end
					button.Text = "Click to select"
				end)
				button.MouseLeave:Connect(function()
					if button.Text == "Selected" then return end
					button.Text = ""
				end)
				
				
				
			end
		end
	end
	local PurchaseDeb = false
	ViewBox.Purchase.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(ViewBox.Purchase)
		if not res then return end
		if ViewBox.Purchase.Slide.displayText.Text == "Purchase" then
			if PurchaseDeb then return end
			PurchaseDeb = true
			local result = promptPurchaseInvoke:InvokeServer(CurrentAssetSelected)
			if result == true then
				GamepassList[CurrentAssetSelected]:ExecuteCode()
				GamepassList[CurrentAssetSelected].Owned = true
				ViewBox.Purchase.Slide.displayText.Text = "Item purchased!"
				wait(3)
				ViewBox.Purchase.Slide.displayText.Text = "Owned"
				PurchaseDeb = false
			else
				ViewBox.Purchase.Slide.displayText.Text = "Canceled"
				wait(3)
				ViewBox.Purchase.Slide.displayText.Text = "Purchase"
				PurchaseDeb = false
			end
		end
	end)
	
	
	WViewBox.Purchase.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(WViewBox.Purchase)
		if not res then return end
		if WViewBox.Purchase.Slide.displayText.Text == "Purchase" then
			if PurchaseDeb then return end
			PurchaseDeb = true
			local result = promptPurchaseInvoke:InvokeServer(CurrentAssetSelected)
			if result == true then
				WeaponsPackList[CurrentAssetSelected].Owned = true
				WViewBox.Purchase.Visible = false
				WViewBox.OwnedWeapons.Visible = true
				for Windex, Weapon in pairs(WeaponsPackList[CurrentAssetSelected].Weapons) do
					local NewWClone = script.WeaponTemplate:Clone()
					NewWClone.Name = Weapon
					NewWClone.ItemName.Text = Weapon
					NewWClone.Parent = WViewBox.OwnedWeapons
					NewWClone.Insert.MouseButton1Down:Connect(function()
						local res = TweenButtonClick(NewWClone.Insert)
						if not res then return end
						if MajorDebounce then return end
						if CountAccessories() > MaxAccessories then ErrorReport("Maximum Accessories reached. Buy the gamepass for more if you haven't already.") return end
						MajorDebounce = true
						local returned = CustomizationInvoke:InvokeServer("AddItem", Weapon)
						wait(0.5)
						MajorDebounce = false
					end)
				end
				PurchaseDeb = false
			else
				WViewBox.Purchase.Slide.displayText.Text = "Canceled"
				wait(3)
				WViewBox.Purchase.Slide.displayText.Text = "Purchase"
				PurchaseDeb = false
			end
		end
	end)
	
	
end

-- event system


-- help

do
	local HelpUI = MainUI.Help
	local HelpEvent = ReplicatedStorage:WaitForChild("Help")
	local helpMessage = HelpUI.main.Content.Message
	local discord = HelpUI.main.Content.Discord
	local HelpDeb = false

	HelpUI.main.Content.userfill.Text = Client.Name

	local function HelpError(msg, DontReset)
		HelpDeb = true
		HelpUI.main.Content.err.Visible = true
		HelpUI.main.Content.err.Text = msg
		wait(3)
		if not DontReset then HelpDeb = false end
	end

	GeneralSettings.Help.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(GeneralSettings.Help)
		if res == false then return end
		HelpUI.Visible = not HelpUI.Visible
	end)

	HelpUI.main.Close.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(HelpUI.main.Close)
		if res == false then return end
		HelpUI.Visible = false
	end)

	HelpUI.main.Content.Submit.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(HelpUI.main.Content.Submit)
		if res == false then return end
		if HelpDeb then HelpError("You are still on a cooldown from your last request.", true) return end
		if #discord.Text == 0 then HelpError("Please provide your discord username."); return end
		if #helpMessage.Text < 30 then HelpError("Please provide a more detailed message so moderators can help you.") return end
		HelpDeb = true
		HelpEvent:FireServer(discord.Text, helpMessage.Text)
		HelpUI.main.Content.Submit.Slide.displayText.Text = "Sent!"
		wait(3)
		HelpUI.main.Content.Submit.Slide.displayText.Text = "On cooldown"
		wait(600)
		HelpUI.main.Content.Submit.Slide.displayText.Text = "Submit"
		HelpDeb = false
	end)


end



--wait(5)

do
	print("Indexing the player name display hover system")
	local PlayerNameDisplay = script.Parent.PlayerNameDisplay
	local VisualizationDelete = PlayerNameDisplay.VisualizationDelete
	local Mouse = Client:GetMouse()
	
	local function findFirstAncestorWithAttribute(startInstance, attribute : string)
		local function sort()
			startInstance = startInstance.Parent
			local val = startInstance:GetAttribute(attribute)
			if val then
				return startInstance, val
			else
				return findFirstAncestorWithAttribute(startInstance, attribute)
			end
		end
		
		
		return sort()
	end
	
	local lastHoverUpdate = 0
	RunService.RenderStepped:Connect(function() -- player name display and visualization + prop deletion
		if tick() - lastHoverUpdate < 0.05 then return end
		lastHoverUpdate = tick()
		local t = Mouse.Target
		local f = false
		if t then
			if t.Parent ~= workspace then
				if t.Parent:FindFirstChild("Humanoid") then
					local player = Players:GetPlayerFromCharacter(t.Parent)
					local CustomName = nil
					if player then
						CustomName = player:GetAttribute("CustomName")
					end
					PlayerNameDisplay.Visible = true
					VisualizationDelete.Visible = false
					PlayerNameDisplay.Position = GetMouseScreenPosition(Mouse)
					if CustomName == "" or CustomName == nil then
						PlayerNameDisplay.Text = t.Parent.Name
					else
						PlayerNameDisplay.Text = CustomName
					end
					CurrentForeignVisualization = nil
					f = true
				elseif t.Parent:IsA("Accessory") then
					if t.Parent.Parent:FindFirstChild("Humanoid") then
						local player = Players:GetPlayerFromCharacter(t.Parent.Parent)
						local CustomName = nil
						if player then
							CustomName = player:GetAttribute("CustomName")
						end
						PlayerNameDisplay.Visible = true
						VisualizationDelete.Visible = false
						PlayerNameDisplay.Position = GetMouseScreenPosition(Mouse)
						if CustomName == "" or CustomName == nil then
							PlayerNameDisplay.Text = t.Parent.Parent.Name
						else
							PlayerNameDisplay.Text = CustomName
						end
						
						CurrentForeignVisualization = nil
						f = true
					end
				elseif t.Parent.Name == "ActiveVisualizations" then
					local PlayerVal = t:FindFirstChildOfClass("RemoteEvent"):FindFirstChildOfClass("Script").Player
					local CustomName = nil
					if PlayerVal.Value then
						local Player = Players:FindFirstChild(PlayerVal.Value)
						if Player then
							CustomName = Player:GetAttribute("CustomName")
						end
					end
					
						PlayerNameDisplay.Visible = true
						VisualizationDelete.Visible = false
						PlayerNameDisplay.Position = GetMouseScreenPosition(Mouse)
						if CustomName == nil or CustomName == "" then
							PlayerNameDisplay.Text = t.Name
						else
							PlayerNameDisplay.Text = CustomName .. "'s visualization"
						end
						CurrentForeignVisualization = t
					f = true
					if PlayerVal.Value == Client.Name or GroupVerification.CheckRank(Client, "Gamemaster") == true then
						VisualizationDelete.Visible = true
						VisualizationDelete.Timer.Text = tostring(PlayerVal.Parent.TimeLeft.Value)
					end
				elseif t.Parent.Name == "EventBorder" then
					PlayerNameDisplay.Visible = true
					VisualizationDelete.Visible = false
					PlayerNameDisplay.Position = GetMouseScreenPosition(Mouse)
					PlayerNameDisplay.Text = t.Name
					CurrentForeignVisualization = nil
					f = true
				elseif t:FindFirstAncestor("PlayerProp") then
					local playerFolder = t:FindFirstAncestorOfClass("Folder")
					local PropModel, PlayerValue = findFirstAncestorWithAttribute(t, "Owner")
					PlayerValue = Players:FindFirstChild(PlayerValue)
					if PlayerValue then
						if GroupVerification.CheckRank(Client, "Gamemaster") == true or PlayerValue == Client then
							local CustomName = PlayerValue:GetAttribute("CustomName")
							PlayerNameDisplay.Visible = true
							VisualizationDelete.Visible = true
							VisualizationDelete.Timer.Text = ""
							PlayerNameDisplay.Position = GetMouseScreenPosition(Mouse)
							if CustomName == nil or CustomName == "" then
								PlayerNameDisplay.Text = PlayerValue.Name .. "'s " .. PropModel.Name
							else
								PlayerNameDisplay.Text = CustomName .. "'s " .. PropModel.Name
							end
							CurrentForeignProp = PropModel
								f = true
						end
					end
				end
			end
		end
		if f == false then PlayerNameDisplay.Visible = false; VisualizationDelete.Visible = false; CurrentForeignVisualization = nil; CurrentForeignProp = nil end
	end)
	
end

task.spawn(function()
	print("Indexing the occasional majordebounce false-setter")
	while true do
		wait(0.5)
		MajorDebounce = false
	end
end)

-- tutorial
wait()
do
	print("indexing tutorial")
	local TutorialUI = MainUI.Tutorial
	local TBox = TutorialUI.TutorialBox
	local ContinueButton = TBox.Continue
	local Message = TBox.Background.Message
	local tutorialOrder = {
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Message"] = "Welcome to Edge of Oblivion! It seems like you haven't played before, so you'll have to complete this short tutorial.";
			["Position"] = UDim2.new(0.427, 0,0.388, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Message"] = "This is a Roleplay game, meaning you play as a character by typing your actions rather than physically doing them.";
			["Position"] = UDim2.new(0.427, 0,0.388, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Message"] = "In order to progress, you roleplay with other players and their characters, either by fighting, negotiating, or simply interacting with them.";
			["Position"] = UDim2.new(0.427, 0,0.388, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Message"] = "For now, though, let's focus on understanding the menu and make you a new example character.";
			["Position"] = UDim2.new(0.427, 0,0.388, 0)
		};
		
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Message"] = "This is the Multiverse leaderboard. Not only does it list players and their ranks, but if you hover your mouse over it, it'll expand and allow you to teleport to them cross-servers.";
			["Position"] = UDim2.new(0.686, 0,0.175, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Message"] = "These buttons are your Toggles, and your shop. The Shop has our gamepasses and Weapon Packs, while the other buttons are simply preferences, such as the Filter mode for the leaderboard or if you want to block people from teleporting to you.";
			["Position"] = UDim2.new(0.712, 0,0.619, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Message"] = "Below is your Bottom Bar. If you hover your mouse over it, you'll see the main features of the Multiverse suite, such as the Customization system, the Prop Placer, the Information tab, and the OOC toggle.";
			["Position"] = UDim2.new(0.558, 0,0.686, 0)
		};
		{
			["Connection"] = BottomBar.OOC.MouseButton1Up;
			["Condition"] = "OOCToggle";
			["Message"] = "First, let's toggle your Out Of Character Mode (OOC Mode) off. Click the button to de-activate your OOC mode. You can tell you're In Character when your character is fully visible.";
			["Position"] = UDim2.new(0.845, 0,0.708, 0)
		};
		{
			["Connection"] = BottomBar.Info.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "Next, let's take a look at the game's Information tab.";
			["Position"] = UDim2.new(0.697, 0,0.726, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "Here you can find information on all of the game's concepts.";
			["Position"] = UDim2.new(0.145, 0,0.224, 0)
		};
		{
			["Connection"] = InfoUI.Close.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "For now, lets move on by closing the menu.";
			["Position"] = UDim2.new(0.536, 0,0.037, 0)
		};
		{
			["Connection"] = BottomBar.AttackVisualizer.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "Now, let's open the Attack Visualizer.";
			["Position"] = UDim2.new(0.544, 0,0.702, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "This is the Attack Visualizer, which allows you to place 3D shapes and text to show other players how you're affecting the space. The middle shows the type, the textbox below lets you input text, and the right lets you select color and shape variations.";
			["Position"] = UDim2.new(0.55, 0,0.43, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "For the sake of time and paywall, we will skip the Prop Placer tab. However, below is the Animations tab, which allow you to pose your character. You can try a few if you want.";
			["Position"] = UDim2.new(0.155, 0,0.69, 0)
		};
		{
			["Connection"] = BottomBar.Customization.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "For the last section of the tutorial, we will enter the Customization menu - the most complex, but the most useful in bringing your Character to life. Click the button to open it.";
			["Position"] = UDim2.new(0.002, 0,0.693, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "On the left is the list of Accessories. You can select multiple accessories via clicking and holding Control. To add accessories, insert an 'Accessory ID' from the URL of any Roblox Accessory into the top white textbox. We also support Layered Clothing.";
			["Position"] = UDim2.new(0.157, 0,0.439, 0)
		};
		{
			["Connection"] = CustomizationUI.CustomizationBottomBar.Color.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "The buttons that have replaced the Bottom Bar open panels that enable you to edit different properties of the selected accessories. Let's open the Appearance panel.";
			["Position"] = UDim2.new(0.155, 0,0.693, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "In the Appearance panel, you can edit the color of the accessory via the Color Wheel, change its Transparency, change its Texture Id, or even it's Mesh (shape) if you own the gamepass. The buttons on the top are preset textures we have available, alongside an Electric material.";
			["Position"] = UDim2.new(0.305, 0,0.511, 0)
		};
		{
			["Connection"] = CustomizationUI.CustomizationBottomBar.Transform.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "The next panel is the Transform panel. Let's open it.";
			["Position"] = UDim2.new(0.31, 0,0.719, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "The Transform panel allows you to adjust the Position, Size, and Rotation of the selected accessories via 3D handles. If you click 'Handles', you will see them, and can otherwise insert manual values into the white boxes. For now though, lets move on.";
			["Position"] = UDim2.new(0.315, 0,0.429, 0)
		};
		{
			["Connection"] = CustomizationUI.CustomizationBottomBar.WeldPart.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "Please open the Body Attachment panel.";
			["Position"] = UDim2.new(0.54, 0,0.711, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "Here you can set the selected accessories to attach to specific bodyparts, such as making a gun accessory that'd defaults to your hip be set to your upper back, or even your hand, as if you're holding it.";
			["Position"] = UDim2.new(0.531, 0,0.429, 0)
		};
		{
			["Connection"] = CustomizationUI.CustomizationBottomBar.Particles.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "Open the Particles panel.";
			["Position"] = UDim2.new(0.697, 0,0.702, 0)
		};
		{
			["Connection"] = CustomizationUI.CustomizationBottomBar.Info.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "The Particles panel requires Customization+ (found in the Shop) and enables you to set Particles onto accessories, such as fire, lightning, smoke, etc. To continue, open the Traits panel.";
			["Position"] = UDim2.new(0.85, 0,0.701, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "The Traits panel enables you to change your character's clothes by inserting their ID, changing their face, making limbs go invisible, and even letting you adjust their height, weight, and width.";
			["Position"] = UDim2.new(0.712, 0,0.585, 0)
		};
		{
			["Connection"] = CustomizationUI.BioButton.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "To change your character's name, biography, open the Character Information window.";
			["Position"] = UDim2.new(0.58, 0,0.07, 0)
		};
		{
			["Connection"] = CustomizationUI.BioButton.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "As you can see, you can edit your character's name, image, and biography here. Though, let's close this window and finish the tutorial.";
			["Position"] = UDim2.new(0.58, 0,0.07, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "These few buttons with 'ID' in them are for your Outfit and Accessory IDs, which enable you to transfer Accessories or Outfits to other people, or across your own Saves using a unique 6 digit code.";
			["Position"] = UDim2.new(0.627, 0,0.249, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "The others below the ID-related buttons are for controls of when editing via the Transform panel. You can find more information on them, and all buttons, by hovering your mouse over them.";
			["Position"] = UDim2.new(0.627, 0,0.249, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "To finalize the tutorial, the panel next to the buttons is your Save Slots. You can purchase more and even increase your accessory limit by purchasing the gamepasses within the Shop.";
			["Position"] = UDim2.new(0.627, 0,0.249, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "Thank you for completing this tutorial! We spent a lot of time and energy on creating these systems for a perfect roleplay experience, so we hope you can use it to your best advantage! If you need more detailed explanations or tips and tricks, please visit our Discord!";
			["Position"] = UDim2.new(0.416, 0,0.344, 0)
		};
		{
			["Connection"] = ContinueButton.MouseButton1Up;
			["Condition"] = nil;
			["Message"] = "If you need to use this tutorial again, simply use the button under the Leaderboard. Bye!";
			["Position"] = UDim2.new(0.416, 0,0.344, 0)
		};

	};
	
	local tutorialOn = false
	
	local function RunTutorial(checkConf : boolean)
		tutorialOn = true
		if checkConf then
			TutorialUI.Visible = true
			TutorialUI.Confirmation.Visible = true
			local con1
			local con2
			local returnedRes = nil
			con1 = TutorialUI.Confirmation.Continue.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(TutorialUI.Confirmation.Continue)
				if not res then return end
				returnedRes = "y"
				con1:Disconnect()
				con2:Disconnect()
				con1 = nil
				con2 = nil
			end)
			con2 = TutorialUI.Confirmation.Cancel.MouseButton1Down:Connect(function()
				local res = TweenButtonClick(TutorialUI.Confirmation.Cancel)
				if not res then return end
				returnedRes = "n"
				con1:Disconnect()
				con2:Disconnect()
				con1 = nil
				con2 = nil
			end)
			repeat task.wait() until returnedRes
			if returnedRes == "n" then TutorialUI.Visible = false;
				TutorialUI.Confirmation.Visible = false; tutorialOn = false return end
		end
		
		TutorialUI.Confirmation.Visible = false
		tutorialOn = true
		InfoUI.Visible = false
		TutorialUI.Visible = true
		
		if OOCToggle == false then
			OOCToggle = true
			CustomizingEvent:FireServer(false)
			--CustomizingEvent:FireServer(false)
			
			CustomizationInvoke:InvokeServer("OOC", OOCToggle)
		end
		CurrentUI = nil
		
		CustomizationUI.Visible = false
		BottomBar.Visible = true; 
		--MainUI.GeneralSettings["Toggle Prompts"].Visible = true; 
		MainUI.GeneralSettings["ToggleVisualizations"].Visible = true;
		MainUI.Leaderboard.Visible = true
		if lastHandles then
			lastHandles.Visible = false
		end
		
		wait()
		for i, v in pairs(tutorialOrder) do
			TBox.Visible = true
			TBox.Position = v.Position
			if v.Connection ~= ContinueButton.MouseButton1Up then
				ContinueButton.Visible = false
			else
				ContinueButton.Visible = true
			end
			Message.Text = v.Message
			v.Connection:Wait()
		end
		TBox.Visible = false
		tutorialOn = false
	end

	ContinueButton.MouseButton1Down:Connect(function()
		TweenButtonClick(ContinueButton)
	end)
	
	local hasCompletedTutorial = CustomizationInvoke:InvokeServer("Tutorial")
	if not hasCompletedTutorial then
		if game.PlaceId == MainLobbyPlaceId then
		RunTutorial(false)
		
		CustomizationInvoke:InvokeServer("SetTutorial", true)
		end
	else
		TutorialUI.Visible = false
	end
	
	GeneralSettings.Tutorial.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(GeneralSettings.Tutorial)
		if not res then return end
		if tutorialOn then  return end
		
		RunTutorial(true)
		
	end)
	
	
end

-- d20

do
	local cooldown = false
	local D20Button = GeneralSettings.D20
	local D20Invoke = ReplicatedStorage:WaitForChild("D20")
	
	D20Button.MouseButton1Down:Connect(function()
		
		print("Test")
		MainUI.Dice.Visible = not MainUI.Dice.Visible

	end)
	
end

-- performance mode

do
	local toggle = true
	local PerformanceButton = GeneralSettings.Rendering
	local RenderingActor = script:WaitForChild("client_rendering")
	PerformanceButton.MouseButton1Down:Connect(function()
		local res = TweenButtonClick(PerformanceButton)
		if not res then return end
		toggle = not toggle
		RenderingActor.Enabled = toggle
		if toggle == true then
			PerformanceButton.Slide.displayText.Text = "Performance Mode: ON"
		else
			PerformanceButton.Slide.displayText.Text = "Performance Mode: OFF"
		end
	end)
end

-- anti tool spam
do
	local timer
	local isCounting = false
	local amount = 0
	local startAmt
	local warning = MainUI.warning
	local warnings = 3
	Character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			amount += 1
			print("found tool during spam check", child, "amount:", amount)
			
			if not isCounting then
				print("Counting!")
				startAmt = amount
				isCounting = true
				task.wait(1)
					warn("finished counting, amount:", amount, "start amount:", startAmt)
					if (amount - startAmt)  > 6 then
						if warnings <= 0 then
							Client:Kick("Do not spam the tools.")
						else
							game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
							warnings -= 1
							warning.Text = "Do not spam equip the tools. (" .. tostring(warnings) .. " warnings left)"
							warning.Visible = true
							wait(5)
							warning.Visible = false
							game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
						end
					else
						
					end
				isCounting = false
				amount = 0
				
			else
				
			end
			
			
		end
	end)
end

script.Parent.Tooltips.Disabled = false
