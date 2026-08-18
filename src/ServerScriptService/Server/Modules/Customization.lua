

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

local SerializeVector3 = Serialization.SerializeVector3
local DeserializeVector3 = Serialization.DeserializeVector3
local SerializeColor3 = Serialization.SerializeColor3
local DeserializeColor3 = Serialization.DeserializeColor3
local SerializeCFrame = Serialization.SerializeCFrame
local DeserializeCFrame = Serialization.DeserializeCFrame
local SerializeMaterial = Serialization.SerializeMaterial
local DeserializeMaterial = Serialization.DeserializeMaterial

local function SerializeParticleData(AccessoryTable)
	if AccessoryTable.Particle == nil then
		AccessoryTable.Particle = "None"
		AccessoryTable.ParticleColor = {["R"] = 1, ["G"] = 1, ["B"] = 1}
		AccessoryTable.ParticleSize = 0
		AccessoryTable.ParticleTransparency = 0
		AccessoryTable.ParticleRate = 0
	else
		AccessoryTable.ParticleColor = SerializeColor3(AccessoryTable.ParticleColor)
	end
end

local function DeserializeParticleData(AccessoryTable)
	if AccessoryTable.Particle == nil then
		AccessoryTable.Particle = "None"
		AccessoryTable.ParticleColor = Color3.fromRGB(255,255,255)
		AccessoryTable.ParticleSize = 0
		AccessoryTable.ParticleTransparency = 0
		AccessoryTable.ParticleRate = 0
	else
		AccessoryTable.ParticleColor = DeserializeColor3(AccessoryTable.ParticleColor)
		if AccessoryTable.ParticleSize == nil then
			AccessoryTable.ParticleSize = 0
			AccessoryTable.ParticleTransparency = 0
			AccessoryTable.ParticleRate = 0
		end
	end
end

local function SerializeTransformData(AccessoryTable, IncludeRevertC0)
	AccessoryTable.AccessoryWeld.C0 = SerializeCFrame(AccessoryTable.AccessoryWeld.C0)
	AccessoryTable.AccessoryWeld.C1 = SerializeCFrame(AccessoryTable.AccessoryWeld.C1)

	if not AccessoryTable.RootRotation then
		local X, Y, Z = AccessoryTable.OriginalC0:Inverse():ToEulerAnglesXYZ()
		AccessoryTable.RootRotation = {["X"] = X, ["Y"] = Y, ["Z"] = Z}
	else
		AccessoryTable.RootRotation = SerializeVector3(AccessoryTable.RootRotation)
	end

	if IncludeRevertC0 then
		AccessoryTable.RevertC0 = SerializeCFrame(AccessoryTable.RevertC0 or AccessoryTable.OriginalC0)
	end

	AccessoryTable.OriginalC0 = SerializeCFrame(AccessoryTable.OriginalC0)

	if AccessoryTable.DistanceFromOriginC0 then
		AccessoryTable.DistanceFromOrigin = AccessoryTable.DistanceFromOriginC0
		AccessoryTable.DistanceFromOriginC0 = nil
	end
	AccessoryTable.DistanceFromOrigin = SerializeVector3(AccessoryTable.DistanceFromOrigin)

	AccessoryTable.OriginalC1 = SerializeCFrame(AccessoryTable.OriginalC1)

	if AccessoryTable.RotationsApplied then
		AccessoryTable.RotationsApplied = SerializeVector3(AccessoryTable.RotationsApplied)
	end
end

local function DeserializeTransformData(AccessoryTable, IncludeRevertC0)
	AccessoryTable.AccessoryWeld.C0 = DeserializeCFrame(AccessoryTable.AccessoryWeld.C0)
	AccessoryTable.AccessoryWeld.C1 = DeserializeCFrame(AccessoryTable.AccessoryWeld.C1)

	if IncludeRevertC0 then
		AccessoryTable.RevertC0 = DeserializeCFrame(AccessoryTable.RevertC0 or AccessoryTable.OriginalC0)
	end

	AccessoryTable.OriginalC0 = DeserializeCFrame(AccessoryTable.OriginalC0)
	if not AccessoryTable.RootRotation then
		local X, Y, Z = AccessoryTable.OriginalC0:Inverse():ToEulerAnglesXYZ()
		AccessoryTable.RootRotation = Vector3.new(X,Y,Z)
	else
		AccessoryTable.RootRotation = DeserializeVector3(AccessoryTable.RootRotation)
	end

	AccessoryTable.OriginalC1 = DeserializeCFrame(AccessoryTable.OriginalC1)

	if AccessoryTable.DistanceFromOriginC0 then
		AccessoryTable.DistanceFromOrigin = DeserializeVector3(AccessoryTable.DistanceFromOriginC0)
		AccessoryTable.DistanceFromOriginC0 = nil
	else
		AccessoryTable.DistanceFromOrigin = DeserializeVector3(AccessoryTable.DistanceFromOrigin)
	end

	if AccessoryTable.RotationsApplied then
		AccessoryTable.RotationsApplied = DeserializeVector3(AccessoryTable.RotationsApplied)
	end
end

local function SerializeStandardAccessoryData(AccessoryTable, IncludeRevertC0)
	if not AccessoryTable.OColor then AccessoryTable.OColor = Color3.new(1,1,1) end
	AccessoryTable.OColor = SerializeColor3(AccessoryTable.OColor)

	if not AccessoryTable.OriginalOColor then AccessoryTable.OriginalOColor = Color3.new(1,1,1) end
	AccessoryTable.OriginalOColor = SerializeColor3(AccessoryTable.OriginalOColor)

	if not AccessoryTable.ColorMode then AccessoryTable.ColorMode = "VertexColor" end
	SerializeParticleData(AccessoryTable)

	AccessoryTable.Object = nil
	AccessoryTable.Color = SerializeVector3(AccessoryTable.Color)
	AccessoryTable.OriginalColor = SerializeVector3(AccessoryTable.OriginalColor)
	AccessoryTable.Material = SerializeMaterial(AccessoryTable.Material)
	AccessoryTable.OriginalMaterial = SerializeMaterial(AccessoryTable.OriginalMaterial)
	AccessoryTable.OriginalSize = SerializeVector3(AccessoryTable.OriginalSize)
	AccessoryTable.HandleSize = SerializeVector3(AccessoryTable.HandleSize)

	SerializeTransformData(AccessoryTable, IncludeRevertC0)

	AccessoryTable.Scale = SerializeVector3(AccessoryTable.Scale)
	AccessoryTable.RevertScale = SerializeVector3(AccessoryTable.RevertScale)
	AccessoryTable.RootScale = SerializeVector3(AccessoryTable.RootScale)
	AccessoryTable.Offset = SerializeVector3(AccessoryTable.Offset)

	AccessoryTable.Attachment.Axis = SerializeVector3(AccessoryTable.Attachment.Axis)
	AccessoryTable.Attachment.Orientation = SerializeVector3(AccessoryTable.Attachment.Orientation)
	AccessoryTable.Attachment.SecondaryAxis = SerializeVector3(AccessoryTable.Attachment.SecondaryAxis)
	AccessoryTable.Attachment.Position = SerializeVector3(AccessoryTable.Attachment.Position)

	AccessoryTable.AttachmentForward = SerializeVector3(AccessoryTable.AttachmentForward)
	AccessoryTable.AttachmentPos = SerializeVector3(AccessoryTable.AttachmentPos)
	AccessoryTable.AttachmentRight = SerializeVector3(AccessoryTable.AttachmentRight)
	AccessoryTable.AttachmentUp = SerializeVector3(AccessoryTable.AttachmentUp)
end

local function SerializeItemPackData(AccessoryTable)
	AccessoryTable.Object = nil
	SerializeTransformData(AccessoryTable, true)
end

local function SerializeMeshPartData(AccessoryTable)
	if not AccessoryTable.OColor then AccessoryTable.OColor = Color3.new(1,1,1) end
	AccessoryTable.OColor = SerializeColor3(AccessoryTable.OColor)

	if not AccessoryTable.OriginalOColor then AccessoryTable.OriginalOColor = Color3.new(1,1,1) end
	AccessoryTable.OriginalOColor = SerializeColor3(AccessoryTable.OriginalOColor)

	AccessoryTable.Material = SerializeMaterial(AccessoryTable.Material)
	AccessoryTable.OriginalMaterial = SerializeMaterial(AccessoryTable.OriginalMaterial)
	SerializeParticleData(AccessoryTable)
end

function SerializeTable(Table) -- makes it so datastores can use them
	print("Serializer")
	if type(Table) == "string" then warn("Table is already serialized.") return Table end

	local SlotValue = Table
	for Index, AccessoryTable in pairs(SlotValue["Data"]["Accessories"]) do
		if not AccessoryTable.IsItemPack and not AccessoryTable.IsMeshPart then
			if typeof(AccessoryTable.AccessoryWeld.C0) == "table" then warn("Already serialized, breaking off.") break end
			SerializeStandardAccessoryData(AccessoryTable, true)
		elseif AccessoryTable.IsItemPack then
			SerializeItemPackData(AccessoryTable)
		elseif AccessoryTable.IsMeshPart then
			if typeof(AccessoryTable.OColor) == "table" then warn("Already serialized, breaking off.") break end
			SerializeMeshPartData(AccessoryTable)
		end
	end

	Table = HttpService:JSONEncode(Table)
	warn("TABLE SIZE:", #Table)
	return Table
end

function SerializeAccessoryTable(Table) -- makes it so datastores can use them
	print("Serializer", Table)
	if type(Table) == "string" then warn("Table is already serialized.") return Table end

	for Index, AccessoryTable in pairs(Table["Data"]) do
		if not AccessoryTable.IsMeshPart then
			if typeof(AccessoryTable.AccessoryWeld.C0) == "table" then warn("Already serialized, breaking off.") break end
			SerializeStandardAccessoryData(AccessoryTable, false)
		else
			if typeof(AccessoryTable.OColor) == "table" then warn("Already serialized, breaking off.") break end
			SerializeMeshPartData(AccessoryTable)
		end
	end

	Table = HttpService:JSONEncode(Table)
	return Table
end

function DeserializeTable_Old(Table)
	print("DESERIALIZING TABLE")
	if not Table then return end
	if type(Table) == "string" then print("Have to decode it."); Table = HttpService:JSONDecode(Table) end


	for Slot, SlotValue in pairs(Table) do

		if SlotValue["Data"]["CharacterInformation"] == nil then
			print("Old table pre-empowerment update.")
			SlotValue["Data"]["CharacterName"] = nil;
			SlotValue["Data"]["CharacterInformation"] = {
				["CharacterName"] = "",
				["CharacterBio"] = "",
				["EmpowermentType"] = "",
				["IsCustomEmpowerment"] = false,
				["EmpowermentTitle"] = "",
				["Empowerment"] = "",
				["Skills"] = {
					{}, {}, {}, {}, {}
				}
			}
		end

		for Index, AccessoryTable in pairs(SlotValue["Data"]["Accessories"]) do
			if typeof(AccessoryTable["AccessoryWeld"]["C0"]) == "CFrame" then warn ("Already deserialized, breaking off.") return Table end

			if AccessoryTable["Particle"] == nil then
				AccessoryTable.Particle = "None"
				AccessoryTable.ParticleColor = Color3.fromRGB(255,255,255)
				AccessoryTable.ParticleSize = 0; AccessoryTable.ParticleTransparency = 0; AccessoryTable.ParticleRate = 0
			else
				AccessoryTable.ParticleColor = Color3.new(AccessoryTable.ParticleColor.R, AccessoryTable.ParticleColor.G, AccessoryTable.ParticleColor.B)
				if AccessoryTable.ParticleSize == nil then
					AccessoryTable.ParticleSize = 0; AccessoryTable.ParticleTransparency = 0; AccessoryTable.ParticleRate = 0
				end
			end

			AccessoryTable["Color"] = Vector3.new(AccessoryTable["Color"]["X"], AccessoryTable["Color"]["Y"], AccessoryTable["Color"]["Z"])

			AccessoryTable["OriginalColor"] = Vector3.new(AccessoryTable["OriginalColor"]["X"], AccessoryTable["OriginalColor"]["Y"], AccessoryTable["OriginalColor"]["Z"])



			if AccessoryTable["Material"] == "Default" then
				AccessoryTable["Material"] = Enum.Material.Plastic
			elseif AccessoryTable["Material"] == "Electric"  then
				AccessoryTable["Material"] = Enum.Material.ForceField
			elseif AccessoryTable["Material"] == Enum.Material.Metal then
				AccessoryTable["Material"] = "Metal"
			else
				AccessoryTable["Material"] = Enum.Material.Plastic
			end;

			if AccessoryTable["OriginalMaterial"] == "Default" then
				AccessoryTable["OriginalMaterial"] = Enum.Material.Plastic
			elseif AccessoryTable["OriginalMaterial"] == "Electric"  then
				AccessoryTable["OriginalMaterial"] = Enum.Material.ForceField
			elseif AccessoryTable["OriginalMaterial"] == "Metal"  then
				AccessoryTable["OriginalMaterial"] = Enum.Material.Metal
			else
				AccessoryTable.OriginalMaterial = Enum.Material.Plastic
			end;

			AccessoryTable["OriginalSize"] = Vector3.new(AccessoryTable.OriginalSize.X, AccessoryTable.OriginalSize.Y, AccessoryTable.OriginalSize.Z)
			AccessoryTable["HandleSize"] = Vector3.new(AccessoryTable.HandleSize.X, AccessoryTable.HandleSize.Y, AccessoryTable.HandleSize.Z)


			AccessoryTable["AccessoryWeld"]["C0"] = 
				CFrame.new(
					AccessoryTable["AccessoryWeld"]["C0"]["X"],
					AccessoryTable["AccessoryWeld"]["C0"]["Y"],
					AccessoryTable["AccessoryWeld"]["C0"]["Z"],
					AccessoryTable["AccessoryWeld"]["C0"]["R00"],
					AccessoryTable["AccessoryWeld"]["C0"]["R01"],
					AccessoryTable["AccessoryWeld"]["C0"]["R02"],
					AccessoryTable["AccessoryWeld"]["C0"]["R10"],
					AccessoryTable["AccessoryWeld"]["C0"]["R11"],
					AccessoryTable["AccessoryWeld"]["C0"]["R12"],
					AccessoryTable["AccessoryWeld"]["C0"]["R20"],
					AccessoryTable["AccessoryWeld"]["C0"]["R21"],
					AccessoryTable["AccessoryWeld"]["C0"]["R22"]
				)

			AccessoryTable["AccessoryWeld"]["C1"] = 
				CFrame.new(
					AccessoryTable["AccessoryWeld"]["C1"]["X"],
					AccessoryTable["AccessoryWeld"]["C1"]["Y"],
					AccessoryTable["AccessoryWeld"]["C1"]["Z"],
					AccessoryTable["AccessoryWeld"]["C1"]["R00"],
					AccessoryTable["AccessoryWeld"]["C1"]["R01"],
					AccessoryTable["AccessoryWeld"]["C1"]["R02"],
					AccessoryTable["AccessoryWeld"]["C1"]["R10"],
					AccessoryTable["AccessoryWeld"]["C1"]["R11"],
					AccessoryTable["AccessoryWeld"]["C1"]["R12"],
					AccessoryTable["AccessoryWeld"]["C1"]["R20"],
					AccessoryTable["AccessoryWeld"]["C1"]["R21"],
					AccessoryTable["AccessoryWeld"]["C1"]["R22"]
				)

			if AccessoryTable["RevertC0"] then
				AccessoryTable["RevertC0"] = CFrame.new(
					AccessoryTable["RevertC0"]["X"],
					AccessoryTable["RevertC0"]["Y"],
					AccessoryTable["RevertC0"]["Z"],
					AccessoryTable["RevertC0"]["R00"],
					AccessoryTable["RevertC0"]["R01"],
					AccessoryTable["RevertC0"]["R02"],
					AccessoryTable["RevertC0"]["R10"],
					AccessoryTable["RevertC0"]["R11"],
					AccessoryTable["RevertC0"]["R12"],
					AccessoryTable["RevertC0"]["R20"],
					AccessoryTable["RevertC0"]["R21"],
					AccessoryTable["RevertC0"]["R22"]
				)
			else
				AccessoryTable["RevertC0"] = CFrame.new(
					AccessoryTable["OriginalC0"]["X"],
					AccessoryTable["OriginalC0"]["Y"],
					AccessoryTable["OriginalC0"]["Z"],
					AccessoryTable["OriginalC0"]["R00"],
					AccessoryTable["OriginalC0"]["R01"],
					AccessoryTable["OriginalC0"]["R02"],
					AccessoryTable["OriginalC0"]["R10"],
					AccessoryTable["OriginalC0"]["R11"],
					AccessoryTable["OriginalC0"]["R12"],
					AccessoryTable["OriginalC0"]["R20"],
					AccessoryTable["OriginalC0"]["R21"],
					AccessoryTable["OriginalC0"]["R22"]
				)
			end

			AccessoryTable["OriginalC0"] = 
				CFrame.new(
					AccessoryTable["OriginalC0"]["X"],
					AccessoryTable["OriginalC0"]["Y"],
					AccessoryTable["OriginalC0"]["Z"],
					AccessoryTable["OriginalC0"]["R00"],
					AccessoryTable["OriginalC0"]["R01"],
					AccessoryTable["OriginalC0"]["R02"],
					AccessoryTable["OriginalC0"]["R10"],
					AccessoryTable["OriginalC0"]["R11"],
					AccessoryTable["OriginalC0"]["R12"],
					AccessoryTable["OriginalC0"]["R20"],
					AccessoryTable["OriginalC0"]["R21"],
					AccessoryTable["OriginalC0"]["R22"]
				)


			if not AccessoryTable.RootRotation then
				local X,Y,Z = AccessoryTable.OriginalC0:Inverse():ToEulerAnglesXYZ()
				AccessoryTable.RootRotation = Vector3.new(X,Y,Z)
			else
				AccessoryTable.RootRotation = Vector3.new(AccessoryTable.RootRotation.X, AccessoryTable.RootRotation.Y, AccessoryTable.RootRotation.Z)
			end

			AccessoryTable["OriginalC1"] = 
				CFrame.new(
					AccessoryTable["OriginalC1"]["X"],
					AccessoryTable["OriginalC1"]["Y"],
					AccessoryTable["OriginalC1"]["Z"],
					AccessoryTable["OriginalC1"]["R00"],
					AccessoryTable["OriginalC1"]["R01"],
					AccessoryTable["OriginalC1"]["R02"],
					AccessoryTable["OriginalC1"]["R10"],
					AccessoryTable["OriginalC1"]["R11"],
					AccessoryTable["OriginalC1"]["R12"],
					AccessoryTable["OriginalC1"]["R20"],
					AccessoryTable["OriginalC1"]["R21"],
					AccessoryTable["OriginalC1"]["R22"]
				)

			if AccessoryTable.DistanceFromOriginC0 then
				AccessoryTable.DistanceFromOrigin = 
					Vector3.new(
						AccessoryTable["DistanceFromOriginC0"].X,
						AccessoryTable["DistanceFromOriginC0"].Y,
						AccessoryTable["DistanceFromOriginC0"].Z
					)
				AccessoryTable.DistanceFromOriginC0 = nil
			else
				AccessoryTable["DistanceFromOrigin"] =
					Vector3.new(
						AccessoryTable["DistanceFromOrigin"].X,
						AccessoryTable["DistanceFromOrigin"].Y,
						AccessoryTable["DistanceFromOrigin"].Z
					)
			end



			if AccessoryTable.RotationsApplied then
				AccessoryTable["RotationsApplied"] = 
					Vector3.new(
						AccessoryTable["RotationsApplied"].X,
						AccessoryTable["RotationsApplied"].Y,
						AccessoryTable["RotationsApplied"].Z
					)
			end

			AccessoryTable["Scale"] = Vector3.new(
				AccessoryTable["Scale"].X,
				AccessoryTable["Scale"].Y,
				AccessoryTable["Scale"].Z
			)
			AccessoryTable["RootScale"] = Vector3.new(
				AccessoryTable["RootScale"].X,
				AccessoryTable["RootScale"].Y,
				AccessoryTable["RootScale"].Z
			);
			AccessoryTable["RevertScale"] = Vector3.new(
				AccessoryTable["RevertScale"].X,
				AccessoryTable["RevertScale"].Y,
				AccessoryTable["RevertScale"].Z
			);
			AccessoryTable["Offset"] = Vector3.new(
				AccessoryTable["Offset"].X,
				AccessoryTable["Offset"].Y,
				AccessoryTable["Offset"].Z
			)

			AccessoryTable["Attachment"]["Axis"] = Vector3.new(
				AccessoryTable["Attachment"]["Axis"].X,
				AccessoryTable["Attachment"]["Axis"].Y,
				AccessoryTable["Attachment"]["Axis"].Z
			)

			AccessoryTable["Attachment"]["SecondaryAxis"] = Vector3.new(
				AccessoryTable["Attachment"]["SecondaryAxis"].X,
				AccessoryTable["Attachment"]["SecondaryAxis"].Y,
				AccessoryTable["Attachment"]["SecondaryAxis"].Z
			)

			AccessoryTable["Attachment"]["Position"] = Vector3.new(
				AccessoryTable["Attachment"]["Position"].X,
				AccessoryTable["Attachment"]["Position"].Y,
				AccessoryTable["Attachment"]["Position"].Z
			)

			AccessoryTable["Attachment"]["Orientation"] = Vector3.new(
				AccessoryTable["Attachment"]["Orientation"].X,
				AccessoryTable["Attachment"]["Orientation"].Y,
				AccessoryTable["Attachment"]["Orientation"].Z
			)

			AccessoryTable["AttachmentForward"] = Vector3.new(
				AccessoryTable["AttachmentForward"].X,
				AccessoryTable["AttachmentForward"].Y,
				AccessoryTable["AttachmentForward"].Z
			)

			AccessoryTable["AttachmentPos"] = Vector3.new(
				AccessoryTable["AttachmentPos"].X,
				AccessoryTable["AttachmentPos"].Y,
				AccessoryTable["AttachmentPos"].Z
			)

			AccessoryTable["AttachmentUp"] = Vector3.new(
				AccessoryTable["AttachmentUp"].X,
				AccessoryTable["AttachmentUp"].Y,
				AccessoryTable["AttachmentUp"].Z
			)

			AccessoryTable["AttachmentRight"] = Vector3.new(
				AccessoryTable["AttachmentRight"].X,
				AccessoryTable["AttachmentRight"].Y,
				AccessoryTable["AttachmentRight"].Z
			)


		end
	end
	return Table
end

local function DeserializeStandardAccessoryData(AccessoryTable, IncludeRevertC0)
	if not AccessoryTable.OColor then AccessoryTable.OColor = {R = 1, G = 1, B = 1} end
	AccessoryTable.OColor = DeserializeColor3(AccessoryTable.OColor)

	if not AccessoryTable.ColorMode then AccessoryTable.ColorMode = "VertexColor" end
	if not AccessoryTable.OTransparency then AccessoryTable.OTransparency = 0.5 end

	if not AccessoryTable.OriginalOColor then AccessoryTable.OriginalOColor = {R = 1, G = 1, B = 1} end
	AccessoryTable.OriginalOColor = DeserializeColor3(AccessoryTable.OriginalOColor)

	DeserializeParticleData(AccessoryTable)

	AccessoryTable.Color = DeserializeVector3(AccessoryTable.Color)
	AccessoryTable.OriginalColor = DeserializeVector3(AccessoryTable.OriginalColor)
	AccessoryTable.Material = DeserializeMaterial(AccessoryTable.Material)
	AccessoryTable.OriginalMaterial = DeserializeMaterial(AccessoryTable.OriginalMaterial)
	AccessoryTable.OriginalSize = DeserializeVector3(AccessoryTable.OriginalSize)
	AccessoryTable.HandleSize = DeserializeVector3(AccessoryTable.HandleSize)

	DeserializeTransformData(AccessoryTable, IncludeRevertC0)

	AccessoryTable.Scale = DeserializeVector3(AccessoryTable.Scale)
	AccessoryTable.RootScale = DeserializeVector3(AccessoryTable.RootScale)
	AccessoryTable.RevertScale = DeserializeVector3(AccessoryTable.RevertScale)
	AccessoryTable.Offset = DeserializeVector3(AccessoryTable.Offset)

	AccessoryTable.Attachment.Axis = DeserializeVector3(AccessoryTable.Attachment.Axis)
	AccessoryTable.Attachment.SecondaryAxis = DeserializeVector3(AccessoryTable.Attachment.SecondaryAxis)
	AccessoryTable.Attachment.Position = DeserializeVector3(AccessoryTable.Attachment.Position)
	AccessoryTable.Attachment.Orientation = DeserializeVector3(AccessoryTable.Attachment.Orientation)

	AccessoryTable.AttachmentForward = DeserializeVector3(AccessoryTable.AttachmentForward)
	AccessoryTable.AttachmentPos = DeserializeVector3(AccessoryTable.AttachmentPos)
	AccessoryTable.AttachmentUp = DeserializeVector3(AccessoryTable.AttachmentUp)
	AccessoryTable.AttachmentRight = DeserializeVector3(AccessoryTable.AttachmentRight)
end

local function DeserializeItemPackData(AccessoryTable)
	DeserializeTransformData(AccessoryTable, true)
end

local function DeserializeMeshPartData(AccessoryTable, SetColorMode)
	if not AccessoryTable.OColor then AccessoryTable.OColor = {R = 1, G = 1, B = 1} end
	AccessoryTable.OColor = DeserializeColor3(AccessoryTable.OColor)

	if SetColorMode and not AccessoryTable.ColorMode then
		AccessoryTable.ColorMode = "VertexColor"
	end

	if not AccessoryTable.OriginalOColor then AccessoryTable.OriginalOColor = {R = 1, G = 1, B = 1} end
	AccessoryTable.OriginalOColor = DeserializeColor3(AccessoryTable.OriginalOColor)

	AccessoryTable.Material = DeserializeMaterial(AccessoryTable.Material)
	AccessoryTable.OriginalMaterial = DeserializeMaterial(AccessoryTable.OriginalMaterial)
	DeserializeParticleData(AccessoryTable)
end

function DeserializeTable(Table)
	print("DESERIALIZING TABLE")
	if not Table then return end
	if type(Table) == "string" then print("Have to decode it."); Table = HttpService:JSONDecode(Table) end

	local SlotValue = Table
	if SlotValue["Data"] == nil and #SlotValue > 0 then SlotValue = SlotValue[1] end -- outfit ids used to have a bug where it was a table inside a table rather than just a table like every other save

	if SlotValue["Data"]["CharacterInformation"] == nil then
		print("Old table pre-empowerment update.")
		SlotValue["Data"]["CharacterName"] = nil
		SlotValue["Data"]["CharacterInformation"] = {
			["CharacterName"] = "",
			["CharacterBio"] = "",
			["EmpowermentType"] = "",
			["IsCustomEmpowerment"] = false,
			["EmpowermentTitle"] = "",
			["Empowerment"] = "",
			["Skills"] = {{}, {}, {}, {}, {}}
		}
	end

	for Index, AccessoryTable in pairs(SlotValue["Data"]["Accessories"]) do
		if not AccessoryTable.IsItemPack and not AccessoryTable.IsMeshPart then
			if typeof(AccessoryTable.AccessoryWeld.C0) == "CFrame" then warn("Already deserialized, breaking off.") return Table end
			DeserializeStandardAccessoryData(AccessoryTable, true)
		elseif AccessoryTable.IsItemPack then
			DeserializeItemPackData(AccessoryTable)
		elseif AccessoryTable.IsMeshPart then
			if typeof(AccessoryTable.OColor) == "Color3" then warn("Already deserialized, breaking off.") return Table end
			DeserializeMeshPartData(AccessoryTable, true)
		end
	end

	warn("STILL EXISTS?", SlotValue)
	return SlotValue
end

function DeserializeAccessoryTable(Table)
	if not Table then return end
	if type(Table) == "string" then print("Have to decode it."); Table = HttpService:JSONDecode(Table) end

	for Index, AccessoryTable in pairs(Table["Data"]) do
		if not AccessoryTable.IsMeshPart then
			if typeof(AccessoryTable.AccessoryWeld.C0) == "CFrame" then warn("Already deserialized, breaking off.") return Table end
			DeserializeStandardAccessoryData(AccessoryTable, false)
		else
			if typeof(AccessoryTable.OColor) == "Color3" then warn("Already deserialized, breaking off.") return Table end
			DeserializeMeshPartData(AccessoryTable, false)
		end
	end

	return Table
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

	print("Load Character", Player, SlotData)
	warn(Player.Name, "Save Data amount:", #HttpService:JSONEncode(SlotData))
	SlotData = SlotData["Data"]

	local Character = Player.Character

	if Character:FindFirstChild("Shirt") == nil then local s = Instance.new("Shirt", Character); s.Name = "Shirt" end
	if Character:FindFirstChild("Pants") == nil then local p = Instance.new("Pants", Character); p.Name = "Pants" end

	local function HideCollisionParts(Character)
		for _, obj in ipairs(Character:GetDescendants()) do
			if obj.Name == "CollisionPart" and obj:IsA("BasePart") then
				obj.Transparency = 1
				obj.CastShadow = false
			end
		end
	end

	if tonumber(SlotData["ShirtTemplate"]) then
		local id = GetClassicClothingTemplate(SlotData["ShirtTemplate"], "Shirt", "ShirtTemplate")

		Character.Shirt.ShirtTemplate = id or "http://www.roblox.com/asset/?id=5574405815"
	else
		Character.Shirt.ShirtTemplate = SlotData["ShirtTemplate"] or "http://www.roblox.com/asset/?id=5574405815"
	end

	if tonumber(SlotData["PantsTemplate"]) then
		local id = GetClassicClothingTemplate(SlotData["PantsTemplate"], "Pants", "PantsTemplate")
		Character.Pants.PantsTemplate = id or "http://www.roblox.com/asset/?id=5574405815"
	else
		Character.Pants.PantsTemplate = SlotData["PantsTemplate"] or "http://www.roblox.com/asset/?id=5574420285"
	end





	-- PUT SOME CODE FOR THE NAME AND BIO SYSTEM

	if SlotData["CharacterInformation"] == nil then
		SlotData["CharacterInformation"] = {
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
		}
	end

	local Folder = ReplicatedStorage.Info[Player.Name]
	Folder.CName.Value = SlotData["CharacterInformation"]["CharacterName"]
	Folder.CBio.Value = SlotData["CharacterInformation"]["CharacterBio"]
	if SlotData["CharacterInformation"]["CharacterImg"] == nil then SlotData["CharacterInformation"]["CharacterImg"] = 0 end
	if SlotData["CharacterInformation"]["CharacterImg"] ~= 0 then
		Folder.CImage.Value = SlotData["CharacterInformation"]["CharacterImg"]
	end
	Folder.EmpowermentTitle.Value = SlotData["CharacterInformation"]["EmpowermentTitle"]
	Folder.EmpowermentType.Value = SlotData["CharacterInformation"]["EmpowermentType"]
	Folder.Empowerment.Value = SlotData["CharacterInformation"]["Empowerment"]


	for i = 1, 5, 1 do 
		local val = SlotData["CharacterInformation"].Skills[i]
		warn("SKILL SLOT:", i, "VAL:", val)
		if IsOccupiedSkills(val) then
			print("MORE THAN 0, HAS INFO")
			Folder["Skill" .. tostring(i) .. "Type"].Value = val.Type
			Folder["Skill" .. tostring(i) .. "Title"].Value = val.Title
			Folder["Skill" .. tostring(i) .. "Description"].Value = val.Skill
		else
			print("REMOVE")
			Folder["Skill" .. tostring(i) .. "Type"].Value = ""
			Folder["Skill" .. tostring(i) .. "Title"].Value = ""
			Folder["Skill" .. tostring(i) .. "Description"].Value = ""
		end
	end

	local Humanoid = Character.Humanoid
	Humanoid.BodyWidthScale.Value = SlotData["Scale"]["Width"]
	Humanoid.BodyHeightScale.Value = SlotData["Scale"]["Height"]
	Humanoid.BodyDepthScale.Value = SlotData["Scale"]["Depth"]
	Humanoid.BodyTypeScale.Value = DefaultType
	Humanoid.BodyProportionScale.Value = DefaultProportion
	local boostedHeadScale = (SlotData["Scale"]["Head"] or 1) * HEAD_SCALE_MULTIPLIER
	Humanoid.HeadScale.Value = boostedHeadScale

	local Description = Humanoid:GetAppliedDescription()
	Description.RunAnimation = SlotData.Animations.RunAnimation
	Description.IdleAnimation = SlotData.Animations.IdleAnimation
	Description.WalkAnimation = SlotData.Animations.WalkAnimation
	Description.HeightScale = SlotData.Scale.Height
	Description.HeadScale = boostedHeadScale
	Description.DepthScale = SlotData.Scale.Depth
	Description.WidthScale = SlotData.Scale.Width

	Humanoid:ApplyDescription(Description)

	Humanoid.BodyWidthScale.Value = SlotData["Scale"]["Width"]-0.01
	Humanoid.BodyHeightScale.Value = SlotData["Scale"]["Height"]-0.01
	Humanoid.BodyDepthScale.Value = SlotData["Scale"]["Depth"]-0.01
	Humanoid.BodyTypeScale.Value = 0.8-0.01
	Humanoid.HeadScale.Value = boostedHeadScale - 0.01

	Humanoid.BodyWidthScale.Value = SlotData["Scale"]["Width"]
	Humanoid.BodyHeightScale.Value = SlotData["Scale"]["Height"]
	Humanoid.BodyDepthScale.Value = SlotData["Scale"]["Depth"]
	Humanoid.BodyTypeScale.Value = DefaultType
	Humanoid.BodyProportionScale.Value = DefaultProportion
	Humanoid.HeadScale.Value = boostedHeadScale

	Character.Head.face.Texture = "rbxthumb://type=Asset&id=" .. tostring(SlotData["FaceID"]) .. "&w=420&h=420"

	Character["Body Colors"].HeadColor3 = Color3.new(SlotData.BodyColors.Head.R, SlotData.BodyColors.Head.G, SlotData.BodyColors.Head.B)
	Character["Body Colors"].RightArmColor3 = Color3.new(SlotData.BodyColors.RightArm.R, SlotData.BodyColors.RightArm.G, SlotData.BodyColors.RightArm.B)
	Character["Body Colors"].LeftArmColor3 = Color3.new(SlotData.BodyColors.LeftArm.R, SlotData.BodyColors.LeftArm.G, SlotData.BodyColors.LeftArm.B)
	Character["Body Colors"].TorsoColor3 = Color3.new(SlotData.BodyColors.Torso.R, SlotData.BodyColors.Torso.G, SlotData.BodyColors.Torso.B)
	Character["Body Colors"].RightLegColor3 = Color3.new(SlotData.BodyColors.RightLeg.R, SlotData.BodyColors.RightLeg.G, SlotData.BodyColors.RightLeg.B)
	Character["Body Colors"].LeftLegColor3 = Color3.new(SlotData.BodyColors.LeftLeg.R, SlotData.BodyColors.LeftLeg.G, SlotData.BodyColors.LeftLeg.B)

	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("BasePart") or v:IsA("MeshPart") then
			if v.Name ~= "HumanoidRootPart" then
				v.Transparency = 0
			end
		end
	end

	for LimbName, v in pairs(SlotData["LimbRemover"]) do
		if v == true then
			local Limb = Character:FindFirstChild(LimbName)
			if Limb then
				Limb.Transparency = 1
			end
		end
	end

	for i, Accessory in pairs(Character:GetChildren()) do
		if Accessory:IsA("Accessory") then
			Accessory:Destroy()
		elseif Accessory:GetAttribute("displayAccessory") == true  then

			FindToolFromItem(Player, Accessory):Destroy()
			Accessory:Destroy()
		end
	end


	local NewAccessoryTable = {}
	local IsIncorrectIndex = false
	for i, AccessoryTable in pairs(SlotData["Accessories"]) do
		--print("i:", i, "table:", AccessoryTable)
		if not tonumber(i) then
			IsIncorrectIndex = true
		end
		if AccessoryTable.DistanceFromOriginC0 then
			AccessoryTable.DistanceFromOrigin = AccessoryTable.DistanceFromOriginC0
			AccessoryTable.DistanceFromOriginC0 = nil
		end

		if not AccessoryTable.IsItemPack and not AccessoryTable.IsMeshPart then -- regular accessories

			local NewAccessory = DefaultAccessory:Clone()
			NewAccessory.Name = AccessoryTable.Name
			NewAccessory.AttachmentForward = AccessoryTable.AttachmentForward
			NewAccessory.AttachmentPos = AccessoryTable.AttachmentPos
			NewAccessory.AttachmentRight = AccessoryTable.AttachmentRight
			NewAccessory.AttachmentUp = AccessoryTable.AttachmentUp

			AccessoryTable.Object = NewAccessory
			NewAccessory.Handle.OriginalSize.Value = AccessoryTable["OriginalSize"]


			NewAccessory.Handle.Size = AccessoryTable.HandleSize
			NewAccessory.Handle.Color = Color3.new(AccessoryTable.Color.X, AccessoryTable.Color.Y, AccessoryTable.Color.Z)

			local NewAttachment = NewAccessory.Handle:FindFirstChildOfClass("Attachment")
			NewAttachment.Name = AccessoryTable.Attachment.Name
			NewAttachment.Axis = AccessoryTable.Attachment.Axis
			NewAttachment.SecondaryAxis = AccessoryTable.Attachment.SecondaryAxis
			NewAttachment.Position = AccessoryTable.Attachment.Position
			NewAttachment.Orientation = AccessoryTable.Attachment.Orientation

			local NewMesh = NewAccessory.Handle:FindFirstChildOfClass("SpecialMesh")

			NewMesh.MeshId = AccessoryTable["MeshId"]
			NewMesh.TextureId = AccessoryTable.TextureId

			NewMesh.Offset = AccessoryTable.Offset
			ApplyHeadBoostAccessoryScale(AccessoryTable, NewAccessory, NewMesh)

			if MeshIdMatches(AccessoryTable["MeshId"], TARGET_HEAD_ASSET_ID) then
				local collisionPart = NewAccessory:FindFirstChild("CollisionPart", true)
				if collisionPart and collisionPart:IsA("BasePart") then
					collisionPart.Transparency = 1
					collisionPart.CastShadow = false
				end
			end

			NewAccessory.Handle.Transparency = AccessoryTable["Transparency"]
			NewAccessory.Handle.Material = AccessoryTable.Material

			NewAccessory.Parent = workspace
			Character.Humanoid:AddAccessory(NewAccessory)

			local NewWeld = NewAccessory.Handle:FindFirstChildOfClass("Weld")
			NewWeld.Part1 = Character:FindFirstChild(AccessoryTable["WeldPart"])

			NewMesh.Offset = AccessoryTable.Offset
			ApplyHeadBoostAccessoryScale(AccessoryTable, NewAccessory, NewMesh)

			if AccessoryTable.ColorMode == "Overlay" then
				local OTransparency = AccessoryTable.OTransparency
				local OColor = AccessoryTable.OColor or AccessoryTable.Color
				CreateOverlay(AccessoryTable.Object, OTransparency, OColor)
				NewMesh.VertexColor = AccessoryTable["Color"]
			else
				NewMesh.VertexColor = AccessoryTable["Color"]
			end


			ApplyParticleData(AccessoryTable, NewAccessory.Handle)


			--SlotData.Accessories[i].OriginalC0 = NewAccessory.Handle.CFrame:ToObjectSpace(NewWeld.Part1.CFrame)
			--SlotData.Accessories[i].OriginalC1 = CFrame.new(0,0,0)

			NewWeld.C0 = AccessoryTable.AccessoryWeld.C0
			NewWeld.C1 = CFrame.new(0,0,0)

			if not AccessoryTable["DistanceFromOrigin"] then
				AccessoryTable["DistanceFromOrigin"] = AccessoryTable["AccessoryWeld"]["C0"].Position - AccessoryTable["OriginalC0"].Position
			end


			if not AccessoryTable.RotationsApplied then
				local X, Y, Z = AccessoryTable["AccessoryWeld"]["C0"]:ToEulerAnglesXYZ()
				local X1, Y1, Z1 = AccessoryTable["OriginalC0"]:ToEulerAnglesXYZ()
				AccessoryTable["RotationsApplied"] = Vector3.new(X-X1, Y-Y1, Z-Z1)
			end

			if IsIncorrectIndex == true then
				table.insert(NewAccessoryTable, AccessoryTable)
			end


		elseif AccessoryTable.IsItemPack then -- its an item pack
			print("Item pack item detected", AccessoryTable.Name)
			local GamepassItemTool, GamepassItemCharacter = script.Parent.SpawnGamepassItem:Invoke(Player, AccessoryTable.WeaponName, AccessoryTable.AccessoryWeld.C0, AccessoryTable.Name)
			AccessoryTable.Object = GamepassItemCharacter
			AccessoryTable.Object.Handle:FindFirstChild("AccessoryWeld").Part1 = Player.Character:FindFirstChild(AccessoryTable.WeldPart)
			wait()
			if IsIncorrectIndex == true then
				table.insert(NewAccessoryTable, AccessoryTable)
			end

		elseif AccessoryTable.IsMeshPart then -- its layered clothing
			warn("Meshpart loading found!", AccessoryTable.AccessoryId)
			local AccessoryId = AccessoryTable.AccessoryId
			local InsertedAccessory = InsertService:LoadAsset(AccessoryId)
			InsertedAccessory.Parent = workspace
			InsertedAccessory = InsertedAccessory:FindFirstChildOfClass("Accessory")
			InsertedAccessory.Handle.Transparency = AccessoryTable.Transparency

			local newVal = Instance.new("IntValue")
			newVal.Value = AccessoryId
			newVal.Name = "AccessoryId"
			newVal.Parent = InsertedAccessory

			InsertedAccessory.Parent = workspace
			Humanoid:AddAccessory(InsertedAccessory)

			AccessoryTable.Object = InsertedAccessory

			if AccessoryTable.ColorMode == "Overlay" then
				local OTransparency = AccessoryTable.OTransparency
				local OColor = AccessoryTable.Color or AccessoryTable.OColor
				CreateOverlay(AccessoryTable.Object, OTransparency, OColor)
			end

			ApplyParticleData(AccessoryTable, InsertedAccessory.Handle)

		end
	end

	if IsIncorrectIndex == true then
		print("Incorrect index")
		SlotData["Accessories"] = NewAccessoryTable
	end
	HideCollisionParts(Character)

	local collisionConn
	collisionConn = Character.DescendantAdded:Connect(function(obj)
		if obj.Name == "CollisionPart" and obj:IsA("BasePart") then
			obj.Transparency = 1
			obj.CastShadow = false
		end
	end)

	task.delay(2, function()
		if collisionConn then
			collisionConn:Disconnect()
			collisionConn = nil
		end
	end)

	return SlotData
end

local function LimbRemover(Client, LimbToRemove, Transparency)
	return LimbService.ApplyStoredLimbTransparency(Client, LimbToRemove, Transparency)
end

function deepCopy(original)
	return CustomizationUtil.DeepCopy(original)
end

local function LoadLegacyCharacterSlot(Client, Slot, value)
	print("Loading legacy slot", Slot, "for", Client)

	-- TestStore1 is the one currently used.

	if value ~= nil then
		print("Entry does exist.")
		local Value = deepCopy(value)
		local Character = Client.Character
		print("Slot name:", Value.SlotName)
		local x = Character.Humanoid.HumanoidDescription:Clone()
		x.Shirt = string.match(tostring(Value["ShirtTemplate"]), "%d+")
		x.Pants = string.match(tostring(Value["PantsTemplate"]), "%d+")
		x.WidthScale = Value["Scale"]["Width"]
		x.HeightScale = Value["Scale"]["Height"]
		x.DepthScale = Value["Scale"]["Depth"]
		x.HeadScale = Value["Scale"]["Head"]
		if Value["Animations"] then
			print("ANIMATIONS: Is a new slot")
			x.WalkAnimation = Value["Animations"]["WalkAnimation"]
			x.RunAnimation = Value["Animations"]["RunAnimation"]
			x.JumpAnimation = Value["Animations"]["JumpAnimation"]
			x.FallAnimation = Value["Animations"]["FallAnimation"]
			x.SwimAnimation = Value["Animations"]["SwimAnimation"]
			x.ClimbAnimation = Value["Animations"]["ClimbAnimation"]
			x.IdleAnimation = Value["Animations"]["IdleAnimation"]
		else
			print("ANIMATIONS: Is an old slot")
			Value["Animations"] = {
				["WalkAnimation"] = x.WalkAnimation,
				["RunAnimation"] = x.RunAnimation,
				["JumpAnimation"] = x.JumpAnimation,
				["FallAnimation"] = x.FallAnimation,
				["SwimAnimation"] = x.SwimAnimation,
				["ClimbAnimation"] = x.ClimbAnimation,
				["IdleAnimation"] = x.IdleAnimation,
			}
		end




		--x.TorsoColor = Client.Character["Body Colors"].Torso
		--ApplyStoredAccessories(Client)




		--x.Face = string.match(tostring(Value["FaceID"]), "%d+")
		Client.Character.Humanoid:ApplyDescription(x)
		repeat wait() until Client.Character:FindFirstChild("HumanoidRootPart")


		--Client.Character.Pants.PantsTemplate = Value["PantsTemplate"]
		Client.Character.Head.face.Texture = Value["FaceID"]

		for x, v in pairs(Value["BodyColors"]) do
			print(x, " LOL", v.R, v.G, v.B)
			Character["Body Colors"][x .. "Color3"] = Color3.fromRGB(v.R*255, v.G*255, v.B*255)
		end

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
				["EmpowermentType"] = "",
				["IsCustomEmpowerment"] = false,
				["Empowerment"] = "",
				["EmpowermentTitle"] = "",
				["Skills"] = {
					{}, {}, {}, {}, {}
				}
			},
			["ShirtTemplate"] = Client.Character.Shirt.ShirtTemplate,
			["PantsTemplate"] = Client.Character.Pants.PantsTemplate,
			["FaceID"] = string.gsub(Character.Head.face.Texture, "%D", ""),
			["LimbRemover"] = {},
			["Scale"] = {
				["Height"] = Character.Humanoid.BodyHeightScale.Value,
				["Depth"] = Character.Humanoid.BodyDepthScale.Value,
				["Width"] = Character.Humanoid.BodyWidthScale.Value,
				["Head"] = Character.Humanoid.HeadScale.Value
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

		local laface = Character.Head.face.Texture
		if laface:sub(1,25) == "rbxthumb://type=Asset&id=" then
			print("CUSTOM FACE")
			local str = laface:sub(26, #laface-12)
			print("THE NUMBERS MASON", str)
			CharacterTable["FaceID"] = str
		end

		for i, x in pairs(Character:GetChildren()) do
			if x:IsA("Accessory") then x:Destroy() end
		end

		local NewAccessoryTable = {}
		for i, v in pairs(Value["Accessories"]) do

			local newAccessory = DefaultAccessory:Clone()
			newAccessory.Name = i
			newAccessory.AttachmentForward = Vector3.new(v.AttachmentForwardX, v.AttachmentForwardY, v.AttachmentForwardZ)
			newAccessory.AttachmentPos = Vector3.new(v.AttachmentPosX, v.AttachmentPosY, v.AttachmentPosZ)
			newAccessory.AttachmentRight = Vector3.new(v.AttachmentRightX, v.AttachmentRightY, v.AttachmentRightZ)
			newAccessory.AttachmentUp = Vector3.new(v.AttachmentUpX, v.AttachmentUpY, v.AttachmentUpZ)
			newAccessory.Handle.Size = Vector3.new(v.HandleSizeX, v.HandleSizeY, v.HandleSizeZ)
			newAccessory.Handle.Color = Color3.new(v.VertexColorRed, v.VertexColorGreen, v.VertexColorBlue)
			newAccessory.Handle.OriginalSize.Value = Vector3.new(v.HandleSizeX, v.HandleSizeY, v.HandleSizeZ)

			local NewAttachment = newAccessory.Handle:FindFirstChildOfClass("Attachment")

			NewAttachment.Orientation = Vector3.new(v.AttachmentOrientationX, v.AttachmentOrientationY, v.AttachmentOrientationZ)
			NewAttachment.Position = Vector3.new(v.AttachmentPositionX, v.AttachmentPositionY, v.AttachmentPositionZ)
			NewAttachment.SecondaryAxis = Vector3.new(v.AttachmentSecondaryAxisX, v.AttachmentSecondaryAxisY, v.AttachmentSecondaryAxisZ)
			NewAttachment.Name = v.AttachmentName

			local NewMesh = newAccessory.Handle:FindFirstChildOfClass("SpecialMesh")

			NewMesh.MeshId = v.MeshId
			NewMesh.TextureId = v.TextureId
			NewMesh.VertexColor = Vector3.new(v.VertexColorRed, v.VertexColorGreen, v.VertexColorBlue)

			NewMesh.Scale = Vector3.new(v.MeshScaleX, v.MeshScaleY, v.MeshScaleZ)

			newAccessory.Handle.OriginalSize.Value = Vector3.new(v.OriginalSizeX, v.OriginalSizeY, v.OriginalSizeZ)

			newAccessory.Parent = workspace
			Client.Character.Humanoid:AddAccessory(newAccessory)

			local function ConvertToAccessoryTable(child)
				wait()
				local handle = child.Handle
				local mesh = handle:FindFirstChildOfClass("SpecialMesh")
				local attachment = handle:FindFirstChildOfClass("Attachment")
				local weld = handle:FindFirstChildOfClass("Weld")

				local SavedTableToApply = {
					["Object"] = child,
					["Name"] = child.Name,
					["MeshId"] = mesh.MeshId,
					["HandleSize"] = handle.Size,
					["TextureId"] = mesh.TextureId,
					["Color"] = mesh.VertexColor,
					["Transparency"] = handle.Transparency,
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
					["OriginalC1"] = CFrame.new(0,0,0),
					["RevertScale"] = NewMesh.Scale,
					["RootScale"] =  NewMesh.Scale,
					["OriginalMeshId"] = mesh.MeshId,
					["Particle"] = "None",
					["ParticleColor"] = Color3.fromRGB(255,255,255),
					["ParticleSize"] = 0,
					["ParticleTransparency"] = 0,
					["ParticleRate"] = 0,
					["OriginalTextureId"] = v.OriginalTextureId,
					["OriginalColor"] = Vector3.new(1,1,1),
					["OriginalTransparency"] = handle.Transparency,
					["OriginalMaterial"] = handle.Material,
					["OriginalWeldPart"] = weld.Part1.Name,
					["AttachmentForward"] = child.AttachmentForward,
					["AttachmentPos"] = child.AttachmentPos,
					["AttachmentRight"] = child.AttachmentRight,
					["AttachmentUp"] = child.AttachmentUp,
					["Attachment"] = {["Name"] = attachment.Name, ["Axis"] = attachment.Axis, ["SecondaryAxis"] = attachment.SecondaryAxis, ["Orientation"] = attachment.Orientation, ["Position"] = attachment.Position}
				}

				local HeadScale = CharacterTable.Scale.Head
				local Width = CharacterTable.Scale.Width
				local Depth = CharacterTable.Scale.Depth
				local Height = CharacterTable.Scale.Height

				if handle:FindFirstChild("HairAttachment") or handle:FindFirstChild("FaceFrontAttachment") or handle:FindFirstChild("HatAttachment") then
					SavedTableToApply.RootScale = Vector3.new(SavedTableToApply.RevertScale.X/HeadScale, SavedTableToApply.RevertScale.Y/HeadScale, SavedTableToApply.RevertScale.Z/HeadScale)
				else
					SavedTableToApply.RootScale = Vector3.new(SavedTableToApply.RevertScale.X/Width, SavedTableToApply.RevertScale.Y/Height, SavedTableToApply.RevertScale.Z/Depth)
				end

				local X,Y,Z = SavedTableToApply.OriginalC0:ToEulerAnglesXYZ()

				SavedTableToApply.RootRotation = Vector3.new(X,Y,Z)

				return SavedTableToApply
			end

			local SavedTableToApply = ConvertToAccessoryTable(newAccessory)

			local weld = newAccessory.Handle:FindFirstChildOfClass("Weld")
			print("REVERT SCALE:", SavedTableToApply.RevertScale)
			weld.C0 = (CFrame.new(v.OriginalC0X, v.OriginalC0Y, v.OriginalC0Z, v.OriginalC0R00, v.OriginalC0R01, v.OriginalC0R02, v.OriginalC0R10, v.OriginalC0R11, v.OriginalC0R12, v.OriginalC0R20, v.OriginalC0R21, v.OriginalC0R22) * CFrame.Angles(math.rad(v.RotationX), math.rad(v.RotationY), math.rad(v.RotationZ))) + (Vector3.new(v.PositionX, v.PositionY, v.PositionZ)/10)

			local val
			if newAccessory.Handle:FindFirstChild("HairAttachment") or newAccessory.Handle:FindFirstChild("FaceFrontAttachment") or newAccessory.Handle:FindFirstChild("HatAttachment") then
				val = (Vector3.new(v.SizeX, v.SizeY, v.SizeZ)/10)*Client.Character.Humanoid.HeadScale.Value
			else
				val = (Vector3.new((v.SizeX/10)*Client.Character.Humanoid.BodyWidthScale.Value, (v.SizeY/10)*Client.Character.Humanoid.BodyHeightScale.Value, (v.SizeZ/10)*Client.Character.Humanoid.BodyDepthScale.Value))
			end
			newAccessory.Handle:FindFirstChildOfClass("SpecialMesh").Scale = Vector3.new(v.MeshScaleX, v.MeshScaleY, v.MeshScaleZ) + val
			SavedTableToApply["Scale"] = newAccessory.Handle:FindFirstChildOfClass("SpecialMesh").Scale
			weld.C1 = CFrame.new(v.OriginalC1X, v.OriginalC1Y, v.OriginalC1Z, v.OriginalC1R00, v.OriginalC1R01, v.OriginalC1R02, v.OriginalC1R10, v.OriginalC1R11, v.OriginalC1R12, v.OriginalC1R20, v.OriginalC1R21, v.OriginalC1R22)

			if v.WeldPart1 then
				print("Has")
				weld.Part1 = Client.Character:FindFirstChild(v.WeldPart1)

			else
				print("does not have weldpart property")
				v.WeldPart1 = weld.Part1.Name
				v.OriginalWeldPart1 = weld.Part1.Name

			end


			SavedTableToApply["WeldPart"] = v.WeldPart1
			SavedTableToApply["AccessoryWeld"]["C0"] = newAccessory.Handle.CFrame:ToObjectSpace(weld.Part1.CFrame)

			-- CONVERTING TABLE TO NEW SYSTEM

			table.insert(NewAccessoryTable, SavedTableToApply)
		end

		CharacterTable["Accessories"] = NewAccessoryTable

		if Value["LimbRemover"] ~= nil then
			print("Has Limb remover")
			for i, v in pairs(Client.Character:GetChildren()) do
				if v:IsA("BasePart") or v:IsA("UnionOperation") then
					if v.Name ~= "HumanoidRootPart" then
						if Value["LimbRemover"][v.Name] ~= nil then
							LimbRemover(Client, v.Name, Value["LimbRemover"][v.Name])
							CharacterTable["LimbRemover"][v.Name] = true
						else
							v.Transparency = 0
						end
					end
				end
			end
		else
			for i, v in pairs(Client.Character:GetChildren()) do
				if v:IsA("BasePart") or v:IsA("UnionOperation") then
					if v.Name ~= "HumanoidRootPart" then

						v.Transparency = 0

					end
				end
			end
		end		

		return CharacterTable
	else
		print("Entry does not exist.")
		return false
	end
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

local Customization = {

	FixAccessories_test = function(self,Player,CharacterTable)
		Player.Character.Humanoid.HeadScale.Value = CharacterTable["Scale"]["Head"]
		Player.Character.Humanoid.BodyHeightScale.Value = CharacterTable["Scale"]["Height"]
		Player.Character.Humanoid.BodyWidthScale.Value = CharacterTable["Scale"]["Width"]
		Player.Character.Humanoid.BodyDepthScale.Value = CharacterTable["Scale"]["Depth"]

		local CachedAccessoriesTable = CachedAccessoriesUniversal[Player.UserId]
		if CachedAccessoriesTable then
			for i, AccessoryTable in ipairs(CharacterTable.Accessories) do
				local Accessory = AccessoryTable.Object
				local Weld = Accessory.Handle:FindFirstChildOfClass("Weld")
				local NewC0Relative = Accessory.Handle.CFrame:ToObjectSpace(Weld.Part1.CFrame)

				AccessoryTable["OriginalC0"] = NewC0Relative

				AccessoryTable["OriginalC1"] = CFrame.new(0,0,0)

				Weld.Part1 = Player.Character:FindFirstChild(AccessoryTable.WeldPart)

				Weld.C0 = CachedAccessoriesTable[i].AccessoryWeld.C0
				Weld.C1 = CachedAccessoriesTable[i].AccessoryWeld.C1

				local Mesh = Accessory.Handle:FindFirstChildOfClass("SpecialMesh")
				local newScale = Mesh.Scale
				AccessoryTable.Scale = Mesh.Scale

				local val

				if Weld.Part0.Name == "Head" then
					print("ITS A HAIR, FACE, OR HAT ATTACHMENT")

					-- Use saved head scale, not the externally boosted visual head scale.
					local unboostedHeadScale = CharacterTable["Scale"]["Head"] or 1

					val = Vector3.new(
						unboostedHeadScale,
						unboostedHeadScale,
						unboostedHeadScale
					)
				else
					print("ITS A SHOULDER, NECK, OR BACK ATTACHMENT")
					val = Vector3.new(Player.Character.Humanoid.BodyWidthScale.Value, Player.Character.Humanoid.BodyHeightScale.Value, Player.Character.Humanoid.BodyDepthScale.Value)
				end
				AccessoryTable.RevertScale = Vector3.new(val.X * AccessoryTable.RootScale.X, val.Y * AccessoryTable.RootScale.Y, val.Z * AccessoryTable.RootScale.Z)
			end
		end

		table.remove(CachedAccessoriesUniversal, Player.UserId)
		return CharacterTable
	end,

	FixAccessories = function(self, Player, CharacterTable, DescriptionToApply)


		Player.Character.Humanoid.HeadScale.Value = CharacterTable["Scale"]["Head"]
		Player.Character.Humanoid.BodyHeightScale.Value = CharacterTable["Scale"]["Height"]
		Player.Character.Humanoid.BodyWidthScale.Value = CharacterTable["Scale"]["Width"]
		Player.Character.Humanoid.BodyDepthScale.Value = CharacterTable["Scale"]["Depth"]

		for index, AccessoryTable in pairs(CharacterTable["Accessories"]) do
			if not AccessoryTable.IsMeshPart then
				local Accessory = AccessoryTable.Object
				if Accessory then
					local Accessory : Accessory = AccessoryTable.Object
					if not ValidateAccessoryOwner(Player, Accessory) then return end
					local Attachment = Accessory.Handle:FindFirstChildOfClass("Attachment")
					if Attachment then
						local val

						-- itll fix scaling i think

						local Weld = Accessory.Handle:FindFirstChildOfClass("Weld")

						if Weld.Part0.Name == "Head" then
							print("ITS A HAIR, FACE, OR HAT ATTACHMENT")
							val = Vector3.new(Player.Character.Humanoid.HeadScale.Value, Player.Character.Humanoid.HeadScale.Value, Player.Character.Humanoid.HeadScale.Value)
						else
							print("ITS A SHOULDER, NECK, OR BACK ATTACHMENT")
							val = Vector3.new(Player.Character.Humanoid.BodyWidthScale.Value, Player.Character.Humanoid.BodyHeightScale.Value, Player.Character.Humanoid.BodyDepthScale.Value)
						end


						local Mesh = Accessory.Handle:FindFirstChildOfClass("SpecialMesh")
						local originalweldpart = Weld.Part1

						Weld.Part1 = Player.Character:FindFirstChild(AccessoryTable.WeldPart)

						local OriginalSavedC0 = AccessoryTable["OriginalC0"]
						local OriginalSavedC1 = AccessoryTable["OriginalC1"]


						AccessoryTable.RevertScale = Vector3.new(val.X * AccessoryTable.RootScale.X, val.Y * AccessoryTable.RootScale.Y, val.Z * AccessoryTable.RootScale.Z)

						local lastScale = AccessoryTable.Scale
						local newScale = Mesh.Scale
						AccessoryTable.Scale = Mesh.Scale



						local NewC0Relative = Accessory.Handle.CFrame:ToObjectSpace(Weld.Part1.CFrame)
						local LastOriginal = AccessoryTable["OriginalC0"]
						local LastC0 = AccessoryTable.AccessoryWeld.C0

						--NewC0Relative = NewC0Relative - NewC0Relative.Rotation

						local DistanceFromOrigin = AccessoryTable["DistanceFromOrigin"]
						--local newOriX, newOriY, newOriZ = NewC0Relative:ToEulerAnglesXYZ()

						AccessoryTable["RevertC0"] = NewC0Relative

						--AccessoryTable["OriginalC1"] = CFrame.new(0,0,0)


						local original = AccessoryTable.OriginalC0:Inverse()


						local distanceFromOrigin = AccessoryTable.DistanceFromOrigin
						local RotationsApplied = AccessoryTable.RotationsApplied

						local weldPCF = Weld.Part1.CFrame

						if not distanceFromOrigin then
							warn("MAKING DISTANCE FROM ORIGIN")
							AccessoryTable.DistanceFromOrigin = AccessoryTable.AccessoryWeld.C0:ToObjectSpace(original).Position
							distanceFromOrigin = AccessoryTable.DistanceFromOrigin
						end

						if not RotationsApplied then
							warn("MAKING ROTAITON FROM ORIGIN")
							local X, Y, Z =  AccessoryTable["AccessoryWeld"]["C0"]:ToObjectSpace(AccessoryTable.OriginalC0):ToEulerAnglesXYZ()
							AccessoryTable.RotationsApplied = Vector3.new(X,Y,Z)
							RotationsApplied = AccessoryTable.RotationsApplied
						end

						local distanceFromOrigin = AccessoryTable.DistanceFromOrigin
						local RotationsApplied = AccessoryTable.RotationsApplied
						local original = AccessoryTable.OriginalC0:Inverse()
						local weldPCF = Weld.Part1.CFrame
						local rx, ry, rz = RotationsApplied.X, RotationsApplied.Y, RotationsApplied.Z
						local originalrx, originalry, originalrz = AccessoryTable.RootRotation.X, AccessoryTable.RootRotation.Y, AccessoryTable.RootRotation.Z
						local PositionCF = (weldPCF * CFrame.new(original.X - distanceFromOrigin.X, original.Y - distanceFromOrigin.Y, original.Z - distanceFromOrigin.Z)).Position
						local RotationCF = weldPCF.Rotation * CFrame.fromEulerAnglesXYZ(originalrx+rx, originalry+ry, originalrz+rz)
						AccessoryTable.AccessoryWeld.C0 = (RotationCF + PositionCF):ToObjectSpace(weldPCF)
						AccessoryTable.AccessoryWeld.C1 = CFrame.new(0,0,0)
						AccessoryTable.DistanceFromOrigin = Vector3.new(distanceFromOrigin.X, distanceFromOrigin.Y, distanceFromOrigin.Z)
						Weld.C0 = AccessoryTable.AccessoryWeld.C0
						Weld.C1 = AccessoryTable.AccessoryWeld.C1 

					end



				end
			end
		end
		return CharacterTable
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
		if self[Player.Name] then
			print(Player,Id)

			local function isRealAccessory(accessoryid)
				local suc, ass = pcall(function()
					local ass1 = InsertService:LoadAsset(accessoryid)

					if ass1 then
						if ass1:FindFirstChildOfClass("Accessory") then
							return ass1:FindFirstChildOfClass("Accessory")
						else
							print(ass1:FindFirstChild())
							return false
						end
					else
						print(ass1:FindFirstChild())
						return false
					end
				end)

				if suc then
					if ass then
						return ass
					else
						return false
					end
				end
			end
			local result = isRealAccessory(Id)
			print("result:", result)
			if result == false or result == nil then return false end
			if result.Handle:IsA("MeshPart") then
				local newVal = Instance.new("IntValue")
				newVal.Value = Id
				newVal.Name = "AccessoryId"
				newVal.Parent = result
			end
			if result.Handle:IsA("MeshPart") and not result.Handle:FindFirstChildOfClass("WrapLayer") then
				result = ConvertToSpecialMesh(Player.Character, result)
				if not result then return false end

				task.wait()

				ApplyLiveInsertedHeadAccessoryCounterScale(result, Player.Character)

				return result
			end

			result.Parent = workspace
			Player.Character.Humanoid:AddAccessory(result)

			task.wait()

			ApplyLiveInsertedHeadAccessoryCounterScale(result, Player.Character)

			return result
		end
	end,
	AddItem= function(self, Player, Weapon)
		if self[Player.Name] then
			warn("AddItem", Player, Weapon)
			local GamepassItemTool, GamepassItemCharacter = script.Parent.SpawnGamepassItem:Invoke(Player, Weapon, CFrame.new(0,0,0))
			return GamepassItemCharacter
		end
	end,
	BlankAccessory = function(self,Player,Id)
		if self[Player.Name] then
			print(Player,Id)
			local NewAccessory = ServerAssets["Custom Accessory"]:Clone()
			NewAccessory.Handle.Mesh.MeshId = "rbxassetid://" .. tostring(Id)
			NewAccessory.Handle.Mesh.TextureId = "rbxassetid://" .. tostring(10140774759)
			NewAccessory.Parent = workspace
			Player.Character.Humanoid:AddAccessory(NewAccessory)

			task.wait()

			ApplyLiveInsertedHeadAccessoryCounterScale(NewAccessory, Player.Character)

			return true
		end
	end,
	Delete = function(self,Player,SelectedAccessories)
		if self[Player.Name] then
			for i, Table in pairs(SelectedAccessories) do
				local Accessory : Accessory = Table.Object
				if not ValidateAccessoryOwner(Player, Accessory) then return end
				if Table.IsItemPack then
					local tool = FindToolFromItem(Player, Table.Object)
					if not tool then return false end 
					tool:Destroy()
				end
				Table.Object:Destroy()
			end
			return true
		end
	end,

	OToggle = function(self, Player, SelectedAccessories, Value)
		return AccessoryEditService.SetOverlayMode(Player, SelectedAccessories, Value, ValidateAccessoryOwner, CreateOverlay, DeleteOverlay)
	end,

	OTransparency = function(self, Player, SelectedAccessories, Value)
		return AccessoryEditService.SetOverlayTransparency(Player, SelectedAccessories, Value, ValidateAccessoryOwner, ChangeOverlay)
	end,

	OColor = function(Self, Player, SelectedAccessories, Value)
		return AccessoryEditService.SetOverlayColor(Player, SelectedAccessories, Value, ValidateAccessoryOwner, ChangeOverlay)
	end,


	Revert = function(self,Player,SelectedAccessories)
		if self[Player.Name] then
			local CopyOfTable = deepCopy(SelectedAccessories)
			for i, Table in ipairs(CopyOfTable) do

				local Accessory : Accessory = Table.Object
				if not ValidateAccessoryOwner(Player, Accessory) then return end
				if not Table.IsMeshPart and not Table.IsItemPack then
					local handle = Accessory.Handle
					local weld = handle:FindFirstChildOfClass("Weld")
					local mesh = handle:FindFirstChildOfClass("SpecialMesh")
					local emitter = handle:FindFirstChildOfClass("ParticleEmitter")
					if emitter then emitter:Destroy() end
					Table["AccessoryWeld"]["C0"] = Table["RevertC0"]

					weld.C0 = Table["OriginalC0"]

					Table["AccessoryWeld"]["C1"] = Table["OriginalC1"]

					weld.C1 = Table["OriginalC1"]

					Table["WeldPart"] = Table["OriginalWeldPart"]
					weld.Part1 = Player.Character[Table["OriginalWeldPart"]]

					Table["Scale"] = Table["RevertScale"]
					mesh.Scale = Table.RevertScale

					Table["MeshId"] = Table["OriginalMeshId"]
					mesh.MeshId = Table["OriginalMeshId"]

					Table["TextureId"] = Table["OriginalTextureId"]
					mesh.TextureId = Table["OriginalTextureId"]

					Table["Color"] = Vector3.new(1,1,1)
					Table["OColor"] = Color3.new(Table["OriginalColor"].X, Table["OriginalColor"].Y, Table["OriginalColor"].Z)
					mesh.VertexColor = Table["OriginalColor"]

					Table["OTransparency"] = 0.5
					Table["ColorMode"] = "VertexColor"
					DeleteOverlay(Accessory)

					Table["Transparency"] = Table["OriginalTransparency"]
					handle.Transparency = Table["OriginalTransparency"]

					Table["Material"] = Table["OriginalMaterial"]
					handle.Material = Table["OriginalMaterial"]

					Table["DistanceFromOrigin"] = Vector3.new(0,0,0)

					Table.RotationsApplied = Vector3.new(0,0,0)
				elseif Table.IsMeshPart then
					Table["Color"] = Vector3.new(1,1,1)
					Table["OColor"] = Color3.new(1,1,1)
					Table["OriginalTextureId"] = Table["OriginalTextureId"] or Table["TextureId"]
					Table["TextureId"] = Table["OriginalTextureId"]


					Table.OriginalMaterial = Table.OriginalMaterial or Table.Material
					Table.Material = Table.OriginalMaterial

					Accessory.Handle.TextureID = Table["OriginalTextureId"]
					Accessory.Handle.Material = Table.OriginalMaterial

					Table["OTransparency"] = 0.5
					Table["ColorMode"] = "VertexColor"
					DeleteOverlay(Accessory)

					local Wrap = Accessory.Handle:FindFirstChildOfClass("WrapLayer")
					Wrap.Enabled = false; Wrap.Enabled = true


				end
			end


			return CopyOfTable

		end
	end,
	Copy = function(self,Player,SelectedAccessories)
		if self[Player.Name] then
			local Character = Player.Character
			local Humanoid = Character.Humanoid


			for i, Table in pairs(SelectedAccessories) do
				warn("Test:", i, Table.Name)
				local Accessory : Accessory = Table.Object
				if not ValidateAccessoryOwner(Player, Accessory) then return end
				if not Table.IsItemPack and not Table.IsMeshPart then

					local AccessoryTable = Table

					local NewAccessory = DefaultAccessory:Clone()
					NewAccessory.Name = AccessoryTable.Name
					NewAccessory.AttachmentForward = AccessoryTable.AttachmentForward
					NewAccessory.AttachmentPos = AccessoryTable.AttachmentPos
					NewAccessory.AttachmentRight = AccessoryTable.AttachmentRight
					NewAccessory.AttachmentUp = AccessoryTable.AttachmentUp

					AccessoryTable.Object = NewAccessory
					NewAccessory.Handle.OriginalSize.Value = AccessoryTable["OriginalSize"]


					NewAccessory.Handle.Size = AccessoryTable.HandleSize
					NewAccessory.Handle.Color = Color3.new(AccessoryTable.Color.X, AccessoryTable.Color.Y, AccessoryTable.Color.Z)

					local NewAttachment = NewAccessory.Handle:FindFirstChildOfClass("Attachment")
					NewAttachment.Name = AccessoryTable.Attachment.Name
					NewAttachment.Axis = AccessoryTable.Attachment.Axis
					NewAttachment.SecondaryAxis = AccessoryTable.Attachment.SecondaryAxis
					NewAttachment.Position = AccessoryTable.Attachment.Position
					NewAttachment.Orientation = AccessoryTable.Attachment.Orientation

					local NewMesh = NewAccessory.Handle:FindFirstChildOfClass("SpecialMesh")

					NewMesh.MeshId = AccessoryTable["MeshId"]
					NewMesh.TextureId = AccessoryTable.TextureId

					NewMesh.Offset = AccessoryTable.Offset
					NewMesh.Scale = AccessoryTable.Scale

					NewAccessory.Handle.Transparency = AccessoryTable["Transparency"]
					NewAccessory.Handle.Material = AccessoryTable.Material

					NewAccessory.Parent = workspace
					Character.Humanoid:AddAccessory(NewAccessory)

					local NewWeld = NewAccessory.Handle:FindFirstChildOfClass("Weld")
					NewWeld.Part1 = Character:FindFirstChild(AccessoryTable["WeldPart"])

					NewMesh.Offset = AccessoryTable.Offset
					NewMesh.Scale = AccessoryTable.Scale

					if AccessoryTable.ColorMode == "Overlay" then
						local OTransparency = AccessoryTable.OTransparency
						local OColor = AccessoryTable.OColor or AccessoryTable.Color
						CreateOverlay(AccessoryTable.Object, OTransparency, OColor)
						NewMesh.VertexColor = AccessoryTable["Color"]
					else
						NewMesh.VertexColor = AccessoryTable["Color"]
					end


					ApplyParticleData(AccessoryTable, NewAccessory.Handle)


					--SlotData.Accessories[i].OriginalC0 = NewAccessory.Handle.CFrame:ToObjectSpace(NewWeld.Part1.CFrame)
					--SlotData.Accessories[i].OriginalC1 = CFrame.new(0,0,0)

					NewWeld.C0 = AccessoryTable.AccessoryWeld.C0
					NewWeld.C1 = CFrame.new(0,0,0)

					if not AccessoryTable["DistanceFromOrigin"] then
						AccessoryTable["DistanceFromOrigin"] = AccessoryTable["AccessoryWeld"]["C0"].Position - AccessoryTable["OriginalC0"].Position
					end


					if not AccessoryTable.RotationsApplied then
						local X, Y, Z = AccessoryTable["AccessoryWeld"]["C0"]:ToEulerAnglesXYZ()
						local X1, Y1, Z1 = AccessoryTable["OriginalC0"]:ToEulerAnglesXYZ()
						AccessoryTable["RotationsApplied"] = Vector3.new(X-X1, Y-Y1, Z-Z1)
					end

				elseif Table.IsItemPack == true then
					local GamepassItemTool, GamepassItemCharacter = script.Parent.SpawnGamepassItem:Invoke(Player, Table.WeaponName, Table.AccessoryWeld.C0, Table.Name)
					Table.Object = GamepassItemCharacter
					wait()
					warn("OBJECT?", Table.Object)
				elseif Table.IsMeshPart == true then
					local AccessoryTable = Table

					warn("Meshpart loading found!", AccessoryTable.AccessoryId)
					local AccessoryId = AccessoryTable.AccessoryId
					local InsertedAccessory = InsertService:LoadAsset(AccessoryId)
					InsertedAccessory.Parent = workspace
					InsertedAccessory = InsertedAccessory:FindFirstChildOfClass("Accessory")
					InsertedAccessory.Handle.Transparency = AccessoryTable.Transparency

					local newVal = Instance.new("IntValue")
					newVal.Value = AccessoryId
					newVal.Name = "AccessoryId"
					newVal.Parent = InsertedAccessory

					InsertedAccessory.Parent = workspace
					Humanoid:AddAccessory(InsertedAccessory)

					AccessoryTable.Object = InsertedAccessory

					if AccessoryTable.ColorMode == "Overlay" then
						local OTransparency = AccessoryTable.OTransparency
						local OColor = AccessoryTable.OColor
						CreateOverlay(AccessoryTable.Object, OTransparency, OColor)
					end

					ApplyParticleData(AccessoryTable, InsertedAccessory.Handle)
				end
			end
			local newT = deepCopy(SelectedAccessories)
			print("test", newT[1].Object)

			return newT
		end
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
