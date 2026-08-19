

--[[

░█████╗░██╗░░░██╗░██████╗████████╗░█████╗░███╗░░░███╗██╗███████╗░█████╗░████████╗██╗░█████╗░███╗░░██╗
██╔══██╗██║░░░██║██╔════╝╚══██╔══╝██╔══██╗████╗░████║██║╚════██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║
██║░░╚═╝██║░░░██║╚█████╗░░░░██║░░░██║░░██║██╔████╔██║██║░░███╔═╝███████║░░░██║░░░██║██║░░██║██╔██╗██║
██║░░██╗██║░░░██║░╚═══██╗░░░██║░░░██║░░██║██║╚██╔╝██║██║██╔══╝░░██╔══██║░░░██║░░░██║██║░░██║██║╚████║
╚█████╔╝╚██████╔╝██████╔╝░░░██║░░░╚█████╔╝██║░╚═╝░██║██║███████╗██║░░██║░░░██║░░░██║╚█████╔╝██║░╚███║
░╚════╝░░╚═════╝░╚═════╝░░░░╚═╝░░░░╚════╝░╚═╝░░░░░╚═╝╚═╝╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝




░█──░█ ░█▀▀█ ▀█▀ ▀▀█▀▀ ▀▀█▀▀ ░█▀▀▀ ░█▄─░█ 　 ░█▀▀█ ░█──░█ 　 ░█▀▀▀ ░█─── ░█─── ▀█▀ ░█▀▀▀█ 
░█░█░█ ░█▄▄▀ ░█─ ─░█── ─░█── ░█▀▀▀ ░█░█░█ 　 ░█▀▀▄ ░█▄▄▄█ 　 ░█▀▀▀ ░█─── ░█─── ░█─ ─▀▀▀▄▄ 
░█▄▀▄█ ░█─░█ ▄█▄ ─░█── ─░█── ░█▄▄▄ ░█──▀█ 　 ░█▄▄█ ──░█── 　 ░█▄▄▄ ░█▄▄█ ░█▄▄█ ▄█▄ ░█▄▄▄█

This script handles everything to do with Customization requests from the client.

UPDATED BY SAM.KABOOM
8/11/2026
redid serialization and rewrote logic for save handling

--]]

-- Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local Constants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants"))
local CustomizingEvent = ReplicatedStorage:WaitForChild("CustomizingEvent")

local PreFixSlots = DataStoreService:GetDataStore("CharacterSaves11")
local NewSlots = DataStoreService:GetDataStore("CharacterSaves12")

local SlotNameDS = DataStoreService:GetDataStore("SlotNames")

local OutfitIDsDataStore = DataStoreService:GetDataStore("OutfitIDs")
local AccessoryIDsDataStore = DataStoreService:GetDataStore("AccessoryIDs")
local TutorialDataStore = DataStoreService:GetDataStore("Tutorial")

local TextService = game:GetService("TextService")
local InsertService = game:GetService("InsertService")
local HttpService = game:GetService("HttpService")

local ServerAssets = script.Parent.Parent:WaitForChild("ServerAssets")
local DefaultAccessory = ServerAssets:WaitForChild("Custom Accessory")
local ParticlesFolder = script:WaitForChild("Particles")
local CustomizationModules = script.Parent:WaitForChild("CustomizationModules")
local Serialization = require(CustomizationModules:WaitForChild("Serialization"))
local AccessoryConversion = require(CustomizationModules:WaitForChild("AccessoryConversion"))
local OverlayService = require(CustomizationModules:WaitForChild("OverlayService"))
local ParticleService = require(CustomizationModules:WaitForChild("ParticleService"))
local AccessoryScaling = require(CustomizationModules:WaitForChild("AccessoryScaling"))
local ValidationService = require(CustomizationModules:WaitForChild("ValidationService"))
local AccessoryTransform = require(CustomizationModules:WaitForChild("AccessoryTransform"))
local ClothingService = require(CustomizationModules:WaitForChild("ClothingService"))
local LimbService = require(CustomizationModules:WaitForChild("LimbService"))
local CharacterInfoService = require(CustomizationModules:WaitForChild("CharacterInfoService"))
local FaceService = require(CustomizationModules:WaitForChild("FaceService"))
local AccessoryEditService = require(CustomizationModules:WaitForChild("AccessoryEditService"))
local CharacterScaleService = require(CustomizationModules:WaitForChild("CharacterScaleService"))
local SaveDataService = require(CustomizationModules:WaitForChild("SaveDataService"))
local CustomizationUtil = require(CustomizationModules:WaitForChild("CustomizationUtil"))
local PlayerIndexService = require(CustomizationModules:WaitForChild("PlayerIndexService"))
local BodyColorService = require(CustomizationModules:WaitForChild("BodyColorService"))
local ShareIdService = require(CustomizationModules:WaitForChild("ShareIdService"))
local CharacterLoadService = require(CustomizationModules:WaitForChild("CharacterLoadService"))
local CharacterLegacyLoadService = require(CustomizationModules:WaitForChild("CharacterLegacyLoadService"))
local AccessoryFixService = require(CustomizationModules:WaitForChild("AccessoryFixService"))
local AccessoryLifecycleService = require(CustomizationModules:WaitForChild("AccessoryLifecycleService"))

local DefaultType = 0.25
local DefaultProportion = 0

local vipwhitelist = {
}

-- Module table

local GroupVerif = require(script.Parent.GroupVerification)

local CurrentLegacyDataStore = "TestStore1"

local CachedCharacterData = {}
local CachedPlayerSlotNames = {}
local CachedLegacyCharacterData = {}
local GroupID = 2962831

local function CreateOverlay(accessory : Accessory, Transparency : number, Color : Color3)
	return OverlayService.CreateOverlay(accessory, Transparency, Color, ServerAssets)
end

local function DeleteOverlay(Accessory : Accessory)
	return OverlayService.DeleteOverlay(Accessory)
end

local function ChangeOverlay(Accessory : Accessory, Transparency : number, Color : Color3)
	return OverlayService.ChangeOverlay(Accessory, Transparency, Color)
end

local function ConvertToSpecialMesh(playerCharacter, accessory)
	return AccessoryConversion.ConvertToSpecialMesh(playerCharacter, accessory, DefaultAccessory)
end

local function FindToolFromItem(player, accessory)
	return CustomizationUtil.FindToolFromItem(player, accessory)
end

local function IsOccupiedSkills(SkillsValueSlot)
	return CustomizationUtil.IsOccupiedSkills(SkillsValueSlot)
end

local function GETSaveFromSlot(UserId, ForceTrueGET, Slot)
	return SaveDataService.GetSaveFromSlot(UserId, ForceTrueGET, Slot, NewSlots, CachedCharacterData, DeserializeTable)
end


local function GETLegacySave(Client)
	return SaveDataService.GetLegacySave(Client, CachedLegacyCharacterData)
end

local function GetAllLegacyData(Client)
	return SaveDataService.GetAllLegacyData(Client, DataStoreService, CurrentLegacyDataStore, HttpService)
end


local function POSTSave(UserId, Table, Slot, IgnoreCache) -- loading
	return SaveDataService.PostSave(UserId, Table, Slot, IgnoreCache, NewSlots, CachedCharacterData, CachedPlayerSlotNames, SerializeTable)
end

local function SerializeTable(Table)
	return Serialization.SerializeTable(Table, HttpService)
end

local function SerializeAccessoryTable(Table)
	return Serialization.SerializeAccessoryTable(Table, HttpService)
end

local function DeserializeTable_Old(Table)
	return Serialization.DeserializeTable_Old(Table, HttpService)
end

local function DeserializeTable(Table)
	return Serialization.DeserializeTable(Table, HttpService)
end

local function DeserializeAccessoryTable(Table)
	return Serialization.DeserializeAccessoryTable(Table, HttpService)
end
local CachedAccessoriesUniversal= {}

local TARGET_HEAD_ASSET_ID = AccessoryScaling.TargetHeadAssetId
local HEAD_SCALE_MULTIPLIER = AccessoryScaling.HeadScaleMultiplier

local function MeshIdMatches(meshId, targetId)
	return AccessoryScaling.MeshIdMatches(meshId, targetId)
end

local function ApplyHeadBoostAccessoryScale(AccessoryTable, NewAccessory, NewMesh)
	return AccessoryScaling.ApplyHeadBoostAccessoryScale(AccessoryTable, NewAccessory, NewMesh)
end

local function ApplyLiveInsertedHeadAccessoryCounterScale(accessory, character)
	return AccessoryScaling.ApplyLiveInsertedHeadAccessoryCounterScale(accessory, character)
end


local function ApplyParticleColor(AccessoryTable, ParticleEmitter)
	return ParticleService.ApplyParticleColor(AccessoryTable, ParticleEmitter)
end

local function ConfigureParticleEmitter(AccessoryTable, P)
	return ParticleService.ConfigureParticleEmitter(AccessoryTable, P)
end

local function ApplyParticleData(AccessoryTable, Handle)
	return ParticleService.ApplyParticleData(AccessoryTable, Handle, ParticlesFolder)
end

local function GetClassicClothingTemplate(assetId, className, templateProperty)
	return ClothingService.GetClassicClothingTemplate(assetId, className, templateProperty, InsertService)
end

function LoadCharacter(Player, SlotData)
	return CharacterLoadService.LoadCharacter(Player, SlotData, {
		HttpService = HttpService,
		ReplicatedStorage = ReplicatedStorage,
		GetClassicClothingTemplate = GetClassicClothingTemplate,
		IsOccupiedSkills = IsOccupiedSkills,
		DefaultType = DefaultType,
		DefaultProportion = DefaultProportion,
		HeadScaleMultiplier = HEAD_SCALE_MULTIPLIER,
		FindToolFromItem = FindToolFromItem,
		DefaultAccessory = DefaultAccessory,
		ApplyHeadBoostAccessoryScale = ApplyHeadBoostAccessoryScale,
		MeshIdMatches = MeshIdMatches,
		TargetHeadAssetId = TARGET_HEAD_ASSET_ID,
		CreateOverlay = CreateOverlay,
		ApplyParticleData = ApplyParticleData,
		InsertService = InsertService,
		SpawnGamepassItem = script.Parent.SpawnGamepassItem,
	})
end
local function LimbRemover(Client, LimbToRemove, Transparency)
	return LimbService.ApplyStoredLimbTransparency(Client, LimbToRemove, Transparency)
end

function deepCopy(original)
	return CustomizationUtil.DeepCopy(original)
end

local function LoadLegacyCharacterSlot(Client, Slot, value)
	return CharacterLegacyLoadService.LoadLegacyCharacterSlot(Client, Slot, value, {
		DeepCopy = deepCopy,
		DefaultAccessory = DefaultAccessory,
		LimbRemover = LimbRemover,
	})
end
function round(n)
	return CustomizationUtil.Round(n)
end

local function ValidateAccessoryOwner(Player, Accessory)
	return ValidationService.ValidateAccessoryOwner(Player, Accessory)
end

local OppositeBodyParts = AccessoryTransform.OppositeBodyParts

local function MirrorCFrameAcrossCharacter(cframe)
	return AccessoryTransform.MirrorCFrameAcrossCharacter(cframe)
end

local function RecalculateAccessoryTransformData(accessoryTable, character)
	return AccessoryTransform.RecalculateAccessoryTransformData(accessoryTable, character)
end

local function GetMaxAccessoriesForPlayer(player)
	return ValidationService.GetMaxAccessoriesForPlayer(player, Constants, MarketplaceService, RunService, GroupVerif, vipwhitelist)
end

local function GetFilteredBroadcastText(textObject)
	return ValidationService.GetFilteredBroadcastText(textObject)
end

local function GetAccessoryLifecycleDependencies()
	return {
		InsertService = InsertService,
		ConvertToSpecialMesh = ConvertToSpecialMesh,
		ApplyLiveInsertedHeadAccessoryCounterScale = ApplyLiveInsertedHeadAccessoryCounterScale,
		ServerAssets = ServerAssets,
		ValidateAccessoryOwner = ValidateAccessoryOwner,
		FindToolFromItem = FindToolFromItem,
		DeleteOverlay = DeleteOverlay,
		ChangeOverlay = ChangeOverlay,
		DefaultAccessory = DefaultAccessory,
		CreateOverlay = CreateOverlay,
		ApplyParticleData = ApplyParticleData,
		DeepCopy = deepCopy,
		SpawnGamepassItem = script.Parent.SpawnGamepassItem,
		AccessoryEditService = AccessoryEditService,
	}
end

local Customization = {

	FixAccessories_test = function(self,Player,CharacterTable)
		return AccessoryFixService.FixAccessoriesTest(Player, CharacterTable, CachedAccessoriesUniversal)
	end,

	FixAccessories = function(self, Player, CharacterTable, DescriptionToApply)
		return AccessoryFixService.FixAccessories(Player, CharacterTable, DescriptionToApply, ValidateAccessoryOwner)
	end,
	NameBio = function(self, Player, NameBioTable)
		if self[Player.Name] then
			return CharacterInfoService.SetNameBio(Player, NameBioTable, ReplicatedStorage.Info, TextService, GetFilteredBroadcastText)
		end
	end,

	Empowerment = function(self, Player, EmpowermentTable, filter)
		if self[Player.Name] then
			return CharacterInfoService.SetEmpowerment(Player, EmpowermentTable, filter, ReplicatedStorage.Info, TextService, GetFilteredBroadcastText)
		end
	end,

	Skill = function(self, Player, SkillTable, filter, slot)
		return CharacterInfoService.SetSkill(Player, SkillTable, filter, slot, ReplicatedStorage.Info, TextService, GetFilteredBroadcastText)
	end,

	Shirt = function(self, Player, newShirtID, AccessoryTable)
		if self[Player.Name] then
			local result = GetClassicClothingTemplate(newShirtID, "Shirt", "ShirtTemplate")

			if result then
				Player.Character.Shirt.ShirtTemplate = result
				return result
			else
				return false
			end


		end
	end,

	Pants = function(self, Player, newPantsID, AccessoryTable)
		if self[Player.Name] then
			local result = GetClassicClothingTemplate(newPantsID, "Pants", "PantsTemplate")

			if result then
				Player.Character.Pants.PantsTemplate = result
				return result
			else
				return false
			end


		end
	end,

	Face2 = function(self, Player, ID)
		if self[Player.Name] then
			local result = FaceService.GetFaceTextureFromDecalAsset(ID, InsertService)

			if result == false or result == nil then return false end
			FaceService.SetFaceTexture(Player.Character, result)
			return result
		end
	end,

	Face = function(self, Player, ID)
		if self[Player.Name] then

			local newID = FaceService.GetThumbnailFaceTexture(ID)

			FaceService.SetFaceTexture(Player.Character, newID)
			return ID
		end
	end,

	Color = function(self, Player, BodyPart, Color)
		if self[Player.Name] then
			return BodyColorService.SetBodyColor(Player, BodyPart, Color)
		end
	end,

	AColor = function(self, Player : Player, UpdateTable : table, ColorInput : Color3)

		if self[Player.Name] then
			return AccessoryEditService.ApplyAccessoryColor(Player, UpdateTable, ColorInput, ValidateAccessoryOwner, ChangeOverlay)
		end
	end,

	PColor = function(self, Player, SelectedAccessories)
		if self[Player.Name] then
			return AccessoryEditService.ApplyParticleColor(Player, SelectedAccessories, ValidateAccessoryOwner, ApplyParticleColor)
		end
	end,

	Height = function(self, Player, Value, CharacterTable)
		if self[Player.Name] then
			return CharacterScaleService.SetHeight(Player, Value, CharacterTable, function(player, tableToFix)
				return self:FixAccessories(player, tableToFix)
			end)
		end
	end,

	Body = function(self, Player, Width, Depth, Head, CharacterTable)
		if self[Player.Name] then
			return CharacterScaleService.SetBody(Player, Width, Depth, Head, CharacterTable, function(player, tableToFix)
				return self:FixAccessories(player, tableToFix)
			end)
		end
	end,

	Proportionalize = function(self, Player, CharacterTable)
		return CharacterScaleService.Proportionalize(Player, CharacterTable, DefaultProportion, DefaultType, function(player, tableToFix)
			return self:FixAccessories(player, tableToFix)
		end)
	end,

	Animations = function(self, Player, IdleID, WalkID, RunID, CharacterTable)
		if self[Player.Name] then
			return CharacterScaleService.SetAnimations(Player, IdleID, WalkID, RunID, CharacterTable, InsertService, DefaultProportion, DefaultType, function(player, tableToFix)
				return self:FixAccessories(player, tableToFix)
			end)
		end
	end,
	ATransparency = function(self,Player,UpdateTable,Value)

		if self[Player.Name] then
			return AccessoryEditService.SetTransparency(Player, UpdateTable, Value, ValidateAccessoryOwner)
		end
	end,
	Material = function(self,Player,SelectedAccessories)


		if self[Player.Name] then
			return AccessoryEditService.SetMaterial(Player, SelectedAccessories, ValidateAccessoryOwner)
		end
	end,
	MeshId = function(self,Player,SelectedAccessories)

		return AccessoryEditService.SetMeshId(Player, SelectedAccessories, ValidateAccessoryOwner)
	end,
	Particle = function(self,Player,SelectedAccessories,ParticleType)
		if self[Player.Name] then
			return AccessoryEditService.SetParticle(Player, SelectedAccessories, ParticleType, ParticlesFolder, ValidateAccessoryOwner, ApplyParticleColor)
		end
	end,

	ParticleAdjust = function(self,Player,SelectedAccessories)
		if self[Player.Name] then
			return AccessoryEditService.AdjustParticle(Player, SelectedAccessories, ValidateAccessoryOwner, ConfigureParticleEmitter)
		end
	end,

	Texture = function(self,Player,UpdateTable, Value)
		if self[Player.Name] then
			return AccessoryEditService.SetTexture(Player, UpdateTable, Value, ValidateAccessoryOwner)
		end

	end,
	Position = function(self,Player,TableOfAccessories)
		if self[Player.Name] then
			return AccessoryEditService.SetWeldTransform(Player, TableOfAccessories, ValidateAccessoryOwner)
		end
	end,
	Size = function(self,Player,TableOfAccessories)
		if self[Player.Name] then
			return AccessoryEditService.SetSize(Player, TableOfAccessories, ValidateAccessoryOwner)
		end
	end,
	Rotation = function(self,Player,TableOfAccessories)
		if self[Player.Name] then
			return AccessoryEditService.SetWeldTransform(Player, TableOfAccessories, ValidateAccessoryOwner)
		end
	end,
	WeldPart = function(self, Player, SelectedAccessories, PartName)
		if self[Player.Name] then
			return AccessoryEditService.SetWeldPart(Player, SelectedAccessories, PartName, ValidateAccessoryOwner)
		end
	end,
	MirrorAccessory = function(self, Player, SelectedAccessories)
		if self[Player.Name] then
			return AccessoryEditService.MirrorAccessories(Player, SelectedAccessories, ValidateAccessoryOwner, OppositeBodyParts, MirrorCFrameAcrossCharacter, RecalculateAccessoryTransformData)
		end
	end,
	LimbRemover = function(self, Player, LimbName, SetType)
		if self[Player.Name] then
			LimbService.SetLiveLimbTransparency(Player, LimbName, SetType)
		end
		return true
	end,
	AddAccessory = function(self,Player,Id)
		return AccessoryLifecycleService.AddAccessory(self, Player, Id, GetAccessoryLifecycleDependencies())
	end,

	AddItem = function(self, Player, Weapon)
		return AccessoryLifecycleService.AddItem(self, Player, Weapon, GetAccessoryLifecycleDependencies())
	end,

	BlankAccessory = function(self,Player,Id)
		return AccessoryLifecycleService.BlankAccessory(self, Player, Id, GetAccessoryLifecycleDependencies())
	end,

	Delete = function(self,Player,SelectedAccessories)
		return AccessoryLifecycleService.Delete(self, Player, SelectedAccessories, GetAccessoryLifecycleDependencies())
	end,

	OToggle = function(self, Player, SelectedAccessories, Value)
		return AccessoryLifecycleService.OToggle(self, Player, SelectedAccessories, Value, GetAccessoryLifecycleDependencies())
	end,

	OTransparency = function(self, Player, SelectedAccessories, Value)
		return AccessoryLifecycleService.OTransparency(self, Player, SelectedAccessories, Value, GetAccessoryLifecycleDependencies())
	end,

	OColor = function(Self, Player, SelectedAccessories, Value)
		return AccessoryLifecycleService.OColor(Self, Player, SelectedAccessories, Value, GetAccessoryLifecycleDependencies())
	end,

	Revert = function(self,Player,SelectedAccessories)
		return AccessoryLifecycleService.Revert(self, Player, SelectedAccessories, GetAccessoryLifecycleDependencies())
	end,

	Copy = function(self,Player,SelectedAccessories)
		return AccessoryLifecycleService.Copy(self, Player, SelectedAccessories, GetAccessoryLifecycleDependencies())
	end,

	Save = function(self, Player, CharacterData, SlotName, Slot)
		print("Save", Player, CharacterData, SlotName, Slot)


		local NewSlot = {
			["SlotName"] = SlotName,
			["Data"] = deepCopy(CharacterData)
		}
		print("NEW SLOT:", NewSlot)
		local postreturn = POSTSave(Player.UserId, NewSlot, Slot)
		CachedPlayerSlotNames[Player.UserId][tostring(Slot)] = SlotName
		return postreturn
	end,

	Load = function(self, Player, Slot)
		print("Load", Player, Slot)
		if Player.Character:FindFirstChildOfClass("Tool") then return false end
		local CurrentInformation = GETSaveFromSlot(Player.UserId, false, Slot)
		warn("CURRENT INFORMATION FROM LOAD:", CurrentInformation)
		if CurrentInformation == false or CurrentInformation == nil then return false end
		warn("LOADED SLOT:", CurrentInformation)

		local ReturnTable = LoadCharacter(Player, CurrentInformation)
		return ReturnTable



	end,

	RestoreAccessoryHistory = function(self, Player, CharacterData)
		print("RestoreAccessoryHistory", Player)
		if Player.Character:FindFirstChildOfClass("Tool") then return false end
		if typeof(CharacterData) ~= "table" or typeof(CharacterData.Accessories) ~= "table" then return false end

		if #CharacterData.Accessories > GetMaxAccessoriesForPlayer(Player) then return false end

		local SlotData = {
			["SlotName"] = "UndoRedo",
			["Data"] = deepCopy(CharacterData)
		}

		return LoadCharacter(Player, SlotData)
	end,

	SaveOutfitID = function(self, Player, OutfitID, CharacterTable, LockID)
		return ShareIdService.SaveOutfitId(Player, OutfitID, CharacterTable, LockID, OutfitIDsDataStore, SerializeTable)
	end,

	LoadOutfitID = function(self, Player, OutfitID)
		return ShareIdService.LoadOutfitId(Player, OutfitID, OutfitIDsDataStore, DeserializeTable, LoadCharacter)
	end,

	SaveAccessoryID = function(self, Player, ID, SelectedAccessories, LockID)
		return ShareIdService.SaveAccessoryId(Player, ID, SelectedAccessories, LockID, AccessoryIDsDataStore, SerializeTable, SerializeAccessoryTable, GetMaxAccessoriesForPlayer)
	end,

	LoadAccessoryID = function(self, player, ID)
		return ShareIdService.LoadAccessoryId(player, ID, {
			AccessoryIDsDataStore = AccessoryIDsDataStore,
			DeserializeAccessoryTable = DeserializeAccessoryTable,
			GetMaxAccessoriesForPlayer = GetMaxAccessoriesForPlayer,
			DefaultAccessory = DefaultAccessory,
			InsertService = InsertService,
			CreateOverlay = CreateOverlay,
			ApplyParticleData = ApplyParticleData,
		})
	end,

	LoadLegacy = function(self, Player, Slot)
		print("LoadLegacy", Player, Slot)
		local CurrentInformation = GETLegacySave(Player)

		print("CURRENT INFO", CurrentInformation)
		if CurrentInformation == false then return false end
		local SpecificSlot = CurrentInformation[Slot]
		print("SPECIFIC SLOT", SpecificSlot)
		if SpecificSlot then
			local ReturnTable = LoadLegacyCharacterSlot(Player, Slot, SpecificSlot)
			return ReturnTable
		else
			return false
		end
	end,
	AllData = function(self, Player)
		repeat task.wait() until CachedPlayerSlotNames[Player.UserId] ~= nil
		return CachedPlayerSlotNames[Player.UserId]
	end,
	AllLegacyData = function(self, Player)
		local Table = CachedLegacyCharacterData[tostring(Player.UserId)]
		if Table then
			print("Giving player all legacy data.")
			return Table
		else
			warn("No legacy data detected.")
			return false
		end
	end,
	Tutorial = function(self, Player)
		return SaveDataService.GetTutorial(Player, TutorialDataStore)
	end,
	SetTutorial = function(self, Player, val)
		return SaveDataService.SetTutorial(Player, val, TutorialDataStore)
	end
}

-- Events

do
	for i, v in pairs(game.Players:GetChildren()) do
		Customization[v.Name] = v
	end
end

local function NormalizeCharacterAccessories(Character)
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("Accessory") then
			local Handle = v:WaitForChild("Handle")
			if Handle:IsA("MeshPart") and not Handle:FindFirstChildOfClass("WrapLayer") then
				ConvertToSpecialMesh(Character, v)
			elseif Handle:IsA("MeshPart") and Handle:FindFirstChildOfClass("WrapLayer") then
				v:Destroy()
			end
		end
	end
end

function Customization.IndexPlayer(player)
	return PlayerIndexService.IndexPlayer(player, Customization, CachedCharacterData, CachedPlayerSlotNames, CachedLegacyCharacterData, {
		Constants = Constants,
		MarketplaceService = MarketplaceService,
		GroupVerif = GroupVerif,
		RunService = RunService,
		vipwhitelist = vipwhitelist,
		SlotNameDS = SlotNameDS,
		GetSaveFromSlot = GETSaveFromSlot,
		GetAllLegacyData = GetAllLegacyData,
		NormalizeCharacterAccessories = NormalizeCharacterAccessories,
		DatastoresDownGui = script.DatastoresDown,
	})
end

game.Players.PlayerRemoving:Connect(function(player)
	PlayerIndexService.RemovePlayer(player, Customization, CachedCharacterData, CachedLegacyCharacterData, CachedPlayerSlotNames, SlotNameDS)
end)

CustomizingEvent.OnServerEvent:Connect(function(client, Arg)
	if type(Arg) == "boolean" then
		if Arg == false then
			if client.Character then
				local UI = client.Character:FindFirstChild("CustomizingGui")
				if UI then
					UI:Destroy()
				end
			end
		else
			if client.Character then
				local UIClone = script.CustomizingGui:Clone()
				UIClone.Parent = client.Character
				UIClone.PlayerToHideFrom = client
				UIClone.Adornee = client.Character.Head

			end
		end
	end

end)

task.spawn(function()
	for i, v in pairs(game.Players:GetChildren()) do
		Customization.IndexPlayer(v)
	end
end)


return Customization
