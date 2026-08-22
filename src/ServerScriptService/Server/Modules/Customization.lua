

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
local Overlays = require(CustomizationModules:WaitForChild("Overlays"))
local HeadAccessoryScaling = require(CustomizationModules:WaitForChild("HeadAccessoryScaling"))
local ParticleEffects = require(CustomizationModules:WaitForChild("ParticleEffects"))
local ServiceRetries = require(CustomizationModules:WaitForChild("ServiceRetries"))

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
local CachedGamePassOwnership = {}
local GroupID = 2962831
local RetryOperations = ServiceRetries.new({
	DataStoreService = DataStoreService,
	MarketplaceService = MarketplaceService,
	InsertService = InsertService,
	TextService = TextService,
	CachedGamePassOwnership = CachedGamePassOwnership,
	LongOperationWarnSeconds = 1,
	DataStoreMaxRetries = 5,
	DataStoreRetryDelay = 1,
	DataStoreBudgetMaxWait = 5
})

local WarnLongOperation = RetryOperations.WarnLongOperation
local SetAsyncInBackground = RetryOperations.SetAsyncInBackground
local GetAsyncWithBudget = RetryOperations.GetAsyncWithBudget
local UserOwnsGamePassWithCache = RetryOperations.UserOwnsGamePassWithCache
local LoadAssetWithRetry = RetryOperations.LoadAssetWithRetry
local FilterStringWithRetry = RetryOperations.FilterStringWithRetry
local GetFilteredBroadcastTextWithRetry = RetryOperations.GetFilteredBroadcastTextWithRetry

local function CreateOverlay(accessory : Accessory, Transparency : number, Color : Color3)
	return Overlays.Create(accessory, ServerAssets.Overlay, Transparency, Color)
end

local DeleteOverlay = Overlays.Delete
local ChangeOverlay = Overlays.Change

local function ConvertToSpecialMesh(playerCharacter, accessory)
	return AccessoryConversion.ConvertToSpecialMesh(playerCharacter, accessory, DefaultAccessory)
end

local function FindToolFromItem(player, accessory)
	for i, tool in pairs(player.Backpack:GetChildren()) do
		local associatedObject = tool:FindFirstChild("AssociatedObject")
		if associatedObject and associatedObject.Value == accessory then
			return tool
		end
	end
end

local function IsOccupiedSkills(SkillsValueSlot)
	for z, v in pairs(SkillsValueSlot) do
		warn("FOUND!")
		return true
	end
	return false
end

local function GETSaveFromSlot(UserId, ForceTrueGET, Slot)
	print("GET SAVE", UserId, "FORCETRUEGET?", ForceTrueGET, Slot)
	local success, response = pcall(function()
		local userKey = tostring(UserId)
		local slotKey = tostring(Slot)
		local dataStoreKey = userKey .. "_" .. slotKey

		local function GetSlotData(cacheResult)
			print("Getting forced new data for", UserId, "at slot", Slot)
			local getSuccess, returned = GetAsyncWithBudget(NewSlots, dataStoreKey, "NewSlots:GetAsync")
			if not getSuccess then
				return false
			end
			if returned then
				returned = DeserializeTable(returned)
				if cacheResult then
					if CachedCharacterData[userKey] == nil then
						CachedCharacterData[userKey] = {}
					end
					CachedCharacterData[userKey][slotKey] = returned
				end
				return returned
			else
				warn(returned)
				return returned
			end
		end

		if ForceTrueGET then
			return GetSlotData(false)
		end

		local function Execute()
			return GetSlotData(true)
		end

		if CachedCharacterData[userKey] == nil then print("No UserId slot"); return Execute() end
		warn("cache slot:",CachedCharacterData[userKey][slotKey])
		if CachedCharacterData[userKey][slotKey] == nil then print("No slot in general.");  return Execute() else

			return DeserializeTable(CachedCharacterData[userKey][slotKey])
		end
	end)

	if success then 
		return response
	else
		warn(response)
		return false
	end

end


local function GETLegacySave(Client)
	return CachedLegacyCharacterData[tostring(Client.UserId)] or false
end

local function GetAllLegacyData(Client)
	print("getting all data")
	local bigTable = {}
	local found = false
	for i = 1, 24, 1 do
		wait()

		local CharacterInfoDS = DataStoreService:GetDataStore(CurrentLegacyDataStore .. tostring(i))
		local success, value = GetAsyncWithBudget(CharacterInfoDS, Client.UserId, "LegacyCharacterInfo:GetAsync")

		if not success then
			warn("Data store isn't working!")
			return false
		end

		if value then 

			local Value = HttpService:JSONDecode(value)
			bigTable[i] = Value
			found = true
		else
			bigTable[i] = false
		end
	end
	wait()
	return found and bigTable or false
end

local function POSTSave(UserId, Table, Slot, IgnoreCache) -- loading
	local success, response = pcall(function()
		local userKey = tostring(UserId)
		local slotKey = tostring(Slot)
		local serializeStartedAt = os.clock()
		local ActualTable = SerializeTable(Table)
		WarnLongOperation("SerializeTable", serializeStartedAt)
		warn("POSTING NOW", UserId, Slot)

		if CachedCharacterData[userKey] == nil then CachedCharacterData[userKey] = {}; print("Had no cached data so POSTSave made it") end
		if IgnoreCache == nil or IgnoreCache == false then CachedCharacterData[userKey][slotKey] = Table end
		CachedPlayerSlotNames[UserId][slotKey] = Table.SlotName

		SetAsyncInBackground(NewSlots, userKey .. "_" .. slotKey, ActualTable, "NewSlots:SetAsync")

		return Table
	end)

	if success then
		return true
	else
		warn(response)
		return false
	end

end

local SerializeVector3 = Serialization.SerializeVector3
local DeserializeVector3 = Serialization.DeserializeVector3
local SerializeColor3 = Serialization.SerializeColor3
local DeserializeColor3 = Serialization.DeserializeColor3
local SerializeCFrame = Serialization.SerializeCFrame
local DeserializeCFrame = Serialization.DeserializeCFrame
local SerializeMaterial = Serialization.SerializeMaterial
local DeserializeMaterial = Serialization.DeserializeMaterial

local function SetDefaultSerializedParticleData(AccessoryTable)
	AccessoryTable.Particle = "None"
	AccessoryTable.ParticleColor = {["R"] = 1, ["G"] = 1, ["B"] = 1}
	AccessoryTable.ParticleSize = 0
	AccessoryTable.ParticleTransparency = 0
	AccessoryTable.ParticleRate = 0
end

local function SetDefaultParticleData(AccessoryTable)
	AccessoryTable.Particle = "None"
	AccessoryTable.ParticleColor = Color3.fromRGB(255,255,255)
	AccessoryTable.ParticleSize = 0
	AccessoryTable.ParticleTransparency = 0
	AccessoryTable.ParticleRate = 0
end

local function GetRootRotationFromC0(C0)
	local X, Y, Z = C0:Inverse():ToEulerAnglesXYZ()
	return X, Y, Z
end

local function SerializeOverlayColorData(AccessoryTable)
	if not AccessoryTable.OColor then AccessoryTable.OColor = Color3.new(1,1,1) end
	AccessoryTable.OColor = SerializeColor3(AccessoryTable.OColor)

	if not AccessoryTable.OriginalOColor then AccessoryTable.OriginalOColor = Color3.new(1,1,1) end
	AccessoryTable.OriginalOColor = SerializeColor3(AccessoryTable.OriginalOColor)
end

local function SerializeParticleData(AccessoryTable)
	if AccessoryTable.Particle == nil then
		SetDefaultSerializedParticleData(AccessoryTable)
	else
		AccessoryTable.ParticleColor = SerializeColor3(AccessoryTable.ParticleColor)
	end
end

local function DeserializeParticleData(AccessoryTable)
	if AccessoryTable.Particle == nil then
		SetDefaultParticleData(AccessoryTable)
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
		local X, Y, Z = GetRootRotationFromC0(AccessoryTable.OriginalC0)
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
		local X, Y, Z = GetRootRotationFromC0(AccessoryTable.OriginalC0)
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
	SerializeOverlayColorData(AccessoryTable)

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
	SerializeOverlayColorData(AccessoryTable)

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

local TARGET_HEAD_ASSET_ID = HeadAccessoryScaling.TargetHeadAssetId
local HEAD_SCALE_MULTIPLIER = HeadAccessoryScaling.HeadScaleMultiplier
local MeshIdMatches = HeadAccessoryScaling.MeshIdMatches
local ApplyHeadBoostAccessoryScale = HeadAccessoryScaling.ApplyHeadBoostAccessoryScale
local ApplyLiveInsertedHeadAccessoryCounterScale = HeadAccessoryScaling.ApplyLiveInsertedHeadAccessoryCounterScale
local ApplyParticleColor = ParticleEffects.ApplyParticleColor
local ConfigureParticleEmitter = ParticleEffects.ConfigureParticleEmitter

local function ApplyParticleData(AccessoryTable, Handle)
	return ParticleEffects.ApplyParticleData(AccessoryTable, Handle, ParticlesFolder)
end

local function GetClassicClothingTemplate(assetId, className, templateProperty)
	local success, template = pcall(function()
		local asset = LoadAssetWithRetry(assetId, "GetClassicClothingTemplate")
		if asset then
			local clothing = asset:FindFirstChildOfClass(className)
			if clothing then
				local result = clothing[templateProperty]
				asset:Destroy()
				return result
			else
				return false
			end
		else
			return false
		end
	end)

	if success then
		if template then
			return template
		else
			return false
		end
	end
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
			local InsertedAccessory = LoadAssetWithRetry(AccessoryId, "LoadCharacter MeshPart")
			if not InsertedAccessory then return end
			InsertedAccessory.Parent = workspace
			InsertedAccessory = InsertedAccessory:FindFirstChildOfClass("Accessory")
			if not InsertedAccessory then return end
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
	local x = Client.Character:FindFirstChild(LimbToRemove)
	if x then
		if Transparency == true then
			x.Transparency = 1
		else
			x.Transparency = 0
		end
		local v = x:FindFirstChild("IntendedTransparency")
		if v then
			if Transparency == true then
				v.Value = 1
			else
				v.Value = 0
			end
		else
			v = Instance.new("NumberValue")
			v.Name = "IntendedTransparency"
			if Transparency == true then
				v.Value = 1
			else
				v.Value = 0
			end
		end
	end

	return true
end

function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
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
	return math.round(n * 100) / 100
end

local function ValidateAccessoryOwner(Player, Accessory)
	if Accessory:FindFirstAncestorOfClass("Model") ~= Player.Character then
		Player:Kick("Invalid request")
		return false
	end
	return true
end

local OppositeBodyParts = {
	LeftUpperArm = "RightUpperArm",
	RightUpperArm = "LeftUpperArm",
	LeftLowerArm = "RightLowerArm",
	RightLowerArm = "LeftLowerArm",
	LeftHand = "RightHand",
	RightHand = "LeftHand",
	LeftUpperLeg = "RightUpperLeg",
	RightUpperLeg = "LeftUpperLeg",
	LeftLowerLeg = "RightLowerLeg",
	RightLowerLeg = "LeftLowerLeg",
	LeftFoot = "RightFoot",
	RightFoot = "LeftFoot",
	LeftArm = "RightArm",
	RightArm = "LeftArm",
	LeftLeg = "RightLeg",
	RightLeg = "LeftLeg",
}

local function MirrorVectorAcrossCharacter(vector)
	return Vector3.new(-vector.X, vector.Y, vector.Z)
end

local function MirrorCFrameAcrossCharacter(cframe)
	local position = MirrorVectorAcrossCharacter(cframe.Position)
	local right = cframe.RightVector
	local up = cframe.UpVector
	local back = -cframe.LookVector

	return CFrame.fromMatrix(
		position,
		Vector3.new(right.X, -right.Y, -right.Z),
		MirrorVectorAcrossCharacter(up),
		MirrorVectorAcrossCharacter(back)
	)
end

local function RecalculateAccessoryTransformData(accessoryTable, character)
	if accessoryTable.IsMeshPart then return end
	local accessory = accessoryTable.Object
	local handle = accessory and accessory:FindFirstChild("Handle")
	if not handle then return end

	local weld = handle:FindFirstChild("AccessoryWeld") or handle:FindFirstChildOfClass("Weld")
	if not weld or not weld.Part1 then return end

	local originCF = accessoryTable.OriginalC0:Inverse()
	local currentCF = handle.CFrame
	local referenceCF = weld.Part1.CFrame * CFrame.new(originCF.Position)
	local accCF = referenceCF:ToObjectSpace(CFrame.new() + currentCF.Position)
	accessoryTable.DistanceFromOrigin = Vector3.new(-accCF.Position.X, -accCF.Position.Y, -accCF.Position.Z)

	local originalRx, originalRy, originalRz = accessoryTable.RootRotation.X, accessoryTable.RootRotation.Y, accessoryTable.RootRotation.Z
	local currentCFInverse = accessoryTable.AccessoryWeld.C0:Inverse()
	local currentRx, currentRy, currentRz = currentCFInverse:ToEulerAnglesXYZ()
	accessoryTable.RotationsApplied = Vector3.new(currentRx - originalRx, currentRy - originalRy, currentRz - originalRz)
end

local function GetMaxAccessoriesForPlayer(player)
	local maxAccessories = Constants.MaxAccessories
	local ownsMoreAccessories = UserOwnsGamePassWithCache(player, 179828905)
	if ownsMoreAccessories then
		maxAccessories = Constants.MoreAccessoriesGamepassMaxAccessories
	end
	if vipwhitelist[player.UserId] or GroupVerif.CheckRank(player, "Gamemaster") or RunService:IsStudio() then
		maxAccessories = Constants.SpecialMaxAccessories
	end
	return maxAccessories
end

local function GetFilteredBroadcastText(textObject)
	local filteredMessage = GetFilteredBroadcastTextWithRetry(textObject, "GetFilteredBroadcastText")

	if filteredMessage then
		return filteredMessage
	end

	return false
end

local function FilterBroadcastText(text, userId, label)
	local textObject = FilterStringWithRetry(text, userId, label)
	if not textObject then
		return false
	end

	return GetFilteredBroadcastTextWithRetry(textObject, label)
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
			--Player = self[Player.Name]
			local Folder = ReplicatedStorage.Info[Player.Name]

			NameBioTable.Name = FilterBroadcastText(NameBioTable.Name, Player.UserId, "NameBio.Name")
			NameBioTable.Bio = FilterBroadcastText(NameBioTable.Bio, Player.UserId, "NameBio.Bio")
			if NameBioTable.Name == false or NameBioTable.Bio == false then return false end

			Folder.CName.Value = NameBioTable.Name
			Folder.CBio.Value = NameBioTable.Bio
			Folder.CImage.Value = NameBioTable.Image
			wait()
			return NameBioTable
		end
	end,

	Empowerment = function(self, Player, EmpowermentTable, filter)
		if self[Player.Name] then
			warn(Player, EmpowermentTable, filter)
			local Folder = ReplicatedStorage.Info[Player.Name]

			if filter then
				EmpowermentTable.Description = FilterBroadcastText(EmpowermentTable.Description, Player.UserId, "Empowerment.Description")
				EmpowermentTable.Title = FilterBroadcastText(EmpowermentTable.Title, Player.UserId, "Empowerment.Title")
				if EmpowermentTable.Description == false or EmpowermentTable.Title == false then return false end
			end

			Folder.EmpowermentType.Value = EmpowermentTable.Type
			Folder.Empowerment.Value = EmpowermentTable.Description
			Folder.EmpowermentTitle.Value = EmpowermentTable.Title
			return EmpowermentTable
		end
	end,

	Skill = function(self, Player, SkillTable, filter, slot)
		local Folder = ReplicatedStorage.Info[Player.Name]

		if filter then
			SkillTable.Description = FilterBroadcastText(SkillTable.Description, Player.UserId, "Skill.Description")
			SkillTable.Title = FilterBroadcastText(SkillTable.Title, Player.UserId, "Skill.Title")
			if SkillTable.Description == false or SkillTable.Title == false then return false end
		end

		Folder["Skill" .. tostring(slot) .. "Type"].Value = SkillTable.Type
		Folder["Skill" .. tostring(slot) .. "Description"].Value = SkillTable.Description
		Folder["Skill" .. tostring(slot) .. "Title"].Value = SkillTable.Title
		return SkillTable
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

			local function isRealFace(Pantsid)
				local suc, ass = pcall(function()
					local ass1 = LoadAssetWithRetry(Pantsid, "Face2 LoadAsset")
					if not ass1 then return false end
					ass1.Parent = workspace
					if ass1 then
						if ass1:FindFirstChildOfClass("Decal") then
							print("ITS A FACE")
							local b = ass1:FindFirstChildOfClass("Decal").Texture
							ass1:Destroy()
							return b
						else
							return false
						end
					else
						return false
					end
				end)

				if suc then
					if ass then
						return ass
					else

						return false
					end
				else
					return false
				end
			end
			local result = isRealFace(ID)

			if result == false or result == nil then return false end
			Player.Character.Head.face.Texture = result
			return result
		end
	end,

	Face = function(self, Player, ID)
		if self[Player.Name] then

			local newID = "rbxthumb://type=Asset&id=" .. tostring(ID) .. "&w=420&h=420"

			Player.Character.Head.face.Texture = newID
			return ID
		end
	end,

	Color = function(self, Player, BodyPart, Color)
		print(Player, BodyPart, Color)
		if self[Player.Name] then

			local bc = Player.Character:FindFirstChild("Body Colors")
			if BodyPart == "All" then
				bc["HeadColor3"] = Color
				bc["TorsoColor3"] = Color
				bc["LeftLegColor3"] = Color
				bc["RightLegColor3"] = Color
				bc["LeftArmColor3"] = Color
				bc["RightArmColor3"] = Color
			else
				bc[BodyPart .. "Color3"] = Color
			end

			return Color
		end
	end,

	AColor = function(self, Player : Player, UpdateTable : table, ColorInput : Color3)

		if self[Player.Name] then
			local Color = Vector3.new(ColorInput.R, ColorInput.G, ColorInput.B)
			for i, AccessoryTable in pairs(UpdateTable) do
				if not AccessoryTable.IsItemPack then
					print(Player, AccessoryTable.Accessory, Color)
					local Accessory : Accessory = AccessoryTable.Object
					if not ValidateAccessoryOwner(Player, Accessory) then return end
					if AccessoryTable.ColorMode == "VertexColor" then
						if not AccessoryTable.IsMeshPart then
							Accessory.Handle:FindFirstChildOfClass("SpecialMesh").VertexColor = Color
							Accessory.Handle.Color = Color3.new(Color.X, Color.Y, Color.Z)
						end
					elseif AccessoryTable.ColorMode == "Overlay" then
						ChangeOverlay(Accessory, AccessoryTable.OTransparency, ColorInput)
						if not AccessoryTable.IsMeshPart then
							--Accessory.Handle:FindFirstChildOfClass("SpecialMesh").VertexColor = Vector3.new(1,1,1)
							Accessory.Handle.Color = Color3.new(Color.X, Color.Y, Color.Z)
						end
						Accessory.Handle.Color = Color3.new(Color.X, Color.Y, Color.Z)
					end
				end
			end

			return Color
		end
	end,

	PColor = function(self, Player, SelectedAccessories)
		if self[Player.Name] then
			for i, AccessoryTable in ipairs(SelectedAccessories) do
				local Accessory : Accessory = AccessoryTable.Object
				if not ValidateAccessoryOwner(Player, Accessory) then return end

				local Effect = Accessory.Handle:FindFirstChildOfClass("ParticleEmitter")
				if Effect then
					ApplyParticleColor(AccessoryTable, Effect)
				end
			end
			return true
		end
	end,

	Height = function(self, Player, Value, CharacterTable)
		print(Player, Value)
		if self[Player.Name] then

			local Character = Player.Character
			local Humanoid = Character.Humanoid
			if Humanoid.BodyHeightScale.Value ~= Value then
				Humanoid.BodyHeightScale.Value = Value
				CharacterTable.Scale.Height = Value
				local NewTable = self:FixAccessories(Player, CharacterTable)
				return NewTable
			else
				return CharacterTable
			end

		end
	end,

	Body = function(self, Player, Width, Depth, Head, CharacterTable)
		print(Player, Width, Depth, Head)
		if self[Player.Name] then
			local Character = Player.Character
			local Humanoid = Character.Humanoid
			local Change = false
			if Humanoid.BodyWidthScale.Value ~= Width or Humanoid.BodyDepthScale.Value ~= Depth or Humanoid.HeadScale.Value ~= Head then
				Change = true
				print("Change detected")
			end
			if Change then
				Humanoid.BodyWidthScale.Value = Width
				Humanoid.BodyDepthScale.Value = Depth
				Humanoid.HeadScale.Value = Head

				CharacterTable.Scale.Head = Head
				CharacterTable.Scale.Width = Width
				CharacterTable.Scale.Depth = Depth

				local NewTable = self:FixAccessories(Player, CharacterTable)

				return NewTable

			else
				return CharacterTable
			end
		end
	end,

	Proportionalize = function(self, Player, CharacterTable)
		print(Player, "Proportionalize")
		local Character = Player.Character
		local Humanoid = Character.Humanoid
		local heightv = Humanoid.BodyHeightScale.Value
		local width = Humanoid.BodyWidthScale
		local depth = Humanoid.BodyDepthScale
		local head = Humanoid.HeadScale

		if depth.Value == heightv * 0.88 and head.Value == heightv * 0.9 and width.Value == heightv*0.86 then return CharacterTable end

		local btype = 0.8
		local ptype = 1

		width.Value = heightv * 0.86
		CharacterTable.Scale.Width = width.Value
		depth.Value = heightv * 0.88
		CharacterTable.Scale.Depth = depth.Value
		head.Value = heightv * 0.90
		CharacterTable.Scale.Head = head.Value
		Humanoid.BodyProportionScale.Value = DefaultProportion
		Humanoid.BodyTypeScale.Value = DefaultType


		local NewTable = self:FixAccessories(Player, CharacterTable)

		return NewTable

	end,

	Animations = function(self, Player, IdleID, WalkID, RunID, CharacterTable)
		print(Player, IdleID, WalkID, RunID)
		if self[Player.Name] then

			local function isRealAnimation(shirtid)
				local suc, ass = pcall(function()
					local ass1 = LoadAssetWithRetry(shirtid, "Animations LoadAsset")
					if not ass1 then return false end
					ass1.Parent = workspace
					if ass1 then
						if ass1:FindFirstChildOfClass("Animation") then
							return true
						else
							return false
						end
					else
						return false
					end
				end)
			end

			local success, returned = pcall(function()

				local realIdle, realWalk, realRun = isRealAnimation(IdleID), isRealAnimation(WalkID), isRealAnimation(RunID)

				if realIdle == false or realWalk == false or realRun == false then error("One of the assets are not a real Asset ID.") end
				local Character = Player.Character

				local Description = Player.Character.Humanoid:GetAppliedDescription()
				Description.IdleAnimation = IdleID
				Description.WalkAnimation = WalkID
				Description.RunAnimation = RunID
				Description.HeightScale = CharacterTable.Scale.Height
				Description.HeadScale = CharacterTable.Scale.Head
				Description.WidthScale = CharacterTable.Scale.Width
				Description.DepthScale = CharacterTable.Scale.Depth
				Description.BodyTypeScale = DefaultType
				Description.ProportionScale = DefaultProportion
				Description.HeadColor = Character["Body Colors"].HeadColor3
				Description.TorsoColor = Character["Body Colors"].TorsoColor3
				Description.LeftArmColor = Character["Body Colors"].LeftArmColor3
				Description.RightArmColor = Character["Body Colors"].RightArmColor3
				Description.LeftLegColor = Character["Body Colors"].LeftLegColor3
				Description.RightLegColor = Character["Body Colors"].RightLegColor3

				Player.Character.Humanoid:ApplyDescription(Description)

				CharacterTable["Animations"]["RunAnimation"] = RunID
				CharacterTable["Animations"]["IdleAnimation"] = IdleID
				CharacterTable["Animations"]["WalkAnimation"] = WalkID
				CharacterTable = self:FixAccessories(Player, CharacterTable)
			end)

			if not success then warn(returned) return false end

			return CharacterTable
		end
	end,
	ATransparency = function(self,Player,UpdateTable,Value)

		if self[Player.Name] then
			for i, AccessoryTable in pairs(UpdateTable) do
				local Accessory : Accessory = AccessoryTable.Object
				if not ValidateAccessoryOwner(Player, Accessory) then return end
				Accessory.Handle.Transparency = Value
			end
			return Value
		end
	end,
	Material = function(self,Player,SelectedAccessories)


		if self[Player.Name] then
			for i, AccessoryTable in ipairs(SelectedAccessories) do
				--print("MATERIAL", Player, AccessoryTable.Material)
				local Accessory : Accessory = AccessoryTable.Object
				if not ValidateAccessoryOwner(Player, Accessory) then return end
				Accessory.Handle.Material = AccessoryTable.Material
			end

			return true
		end
	end,
	MeshId = function(self,Player,SelectedAccessories)

		for i, AccessoryTable in pairs(SelectedAccessories) do
			local Accessory : Accessory = AccessoryTable.Object
			if not ValidateAccessoryOwner(Player, Accessory) then return end
			if not AccessoryTable.IsMeshPart and not AccessoryTable.IsItemPack then
				Accessory.Handle:FindFirstChildOfClass("SpecialMesh").MeshId = AccessoryTable.MeshId
			end
		end
		return true
	end,
	Particle = function(self,Player,SelectedAccessories,ParticleType)
		if self[Player.Name] then
			for index, AccessoryTable in ipairs(SelectedAccessories) do
				local Accessory : Accessory = AccessoryTable.Object
				if not ValidateAccessoryOwner(Player, Accessory) then return end

				local P = Accessory.Handle:FindFirstChildOfClass("ParticleEmitter")
				if P then P:Destroy() end

				if ParticleType ~= "None" then
					local Found = ParticlesFolder:FindFirstChild(ParticleType)
					if Found then
						Found = Found:Clone()
						Found.Parent = Accessory.Handle
						Found.Enabled = true
						ApplyParticleColor(AccessoryTable, Found)
					end
				end
			end
		end
	end,

	ParticleAdjust = function(self,Player,SelectedAccessories)
		if self[Player.Name] then
			for index, AccessoryTable in ipairs(SelectedAccessories) do
				local Accessory : Accessory = AccessoryTable.Object
				if not ValidateAccessoryOwner(Player, Accessory) then return end

				local P = Accessory.Handle:FindFirstChildOfClass("ParticleEmitter")
				if P then
					ConfigureParticleEmitter(AccessoryTable, P)
				end
			end
			return true
		end
	end,

	Texture = function(self,Player,UpdateTable, Value)
		if self[Player.Name] then
			local ToApply = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=" .. tostring(Value)
			for i, AccessoryTable in pairs(UpdateTable) do
				local Accessory : Accessory = AccessoryTable.Object
				if not ValidateAccessoryOwner(Player, Accessory) then return end
				if AccessoryTable.IsMeshPart then
					Accessory.Handle.TextureID = ToApply
				elseif not AccessoryTable.IsMeshPart and not AccessoryTable.IsItemPack then
					Accessory.Handle:FindFirstChildOfClass("SpecialMesh").TextureId = ToApply
				end

			end

			return ToApply
		end

	end,
	Position = function(self,Player,TableOfAccessories)
		if self[Player.Name] then
			for i, accessorytable in ipairs(TableOfAccessories) do
				local Accessory : Accessory = accessorytable.Object
				if not ValidateAccessoryOwner(Player, Accessory) then return end
				if accessorytable.IsItemPack then
					local Obj = accessorytable.Object
					local Handle = Obj.Handle
					local Weld = Handle:FindFirstChild("AccessoryWeld")
					Weld.C0 = accessorytable.AccessoryWeld.C0
					Weld.C1 = accessorytable.AccessoryWeld.C1
				else
					local Obj = accessorytable.Object
					local Handle = Obj.Handle
					local Weld = Handle:FindFirstChildOfClass("Weld")
					Weld.C0 = accessorytable.AccessoryWeld.C0
					Weld.C1 = accessorytable.AccessoryWeld.C1
				end

			end
			return true
		end
	end,
	Size = function(self,Player,TableOfAccessories)
		if self[Player.Name] then
			for i, accessorytable in ipairs(TableOfAccessories) do
				local Accessory : Accessory = accessorytable.Object
				if not ValidateAccessoryOwner(Player, Accessory) then return end
				if not accessorytable.IsItemPack then
					local Obj = accessorytable.Object
					local Handle = Obj.Handle
					local Mesh = Handle:FindFirstChildOfClass("SpecialMesh")
					if Mesh then
						-- accessorytable.Scale is now the actual visual size.
						-- Do NOT shrink it again here.
						Mesh.Scale = accessorytable.Scale

						if accessorytable.WeldPart == "Head" then
							Accessory:SetAttribute("HeadScaleHandledByCustomizer", true)
						end
					else
						Handle.Size = Handle.Size
					end
				end
			end
			return true
		end
	end,
	Rotation = function(self,Player,TableOfAccessories)
		if self[Player.Name] then
			for i, accessorytable in ipairs(TableOfAccessories) do
				local Accessory : Accessory = accessorytable.Object
				if not ValidateAccessoryOwner(Player, Accessory) then return end
				if accessorytable.IsItemPack then
					local Obj = accessorytable.Object
					local Handle = Obj.Handle
					local Weld = Handle:FindFirstChild("AccessoryWeld")
					Weld.C0 = accessorytable.AccessoryWeld.C0
					Weld.C1 = accessorytable.AccessoryWeld.C1
				else
					local Obj = accessorytable.Object
					local Handle = Obj.Handle
					local Weld = Handle:FindFirstChildOfClass("Weld")
					Weld.C0 = accessorytable.AccessoryWeld.C0
					Weld.C1 = accessorytable.AccessoryWeld.C1
				end
			end
			return true
		end
	end,
	WeldPart = function(self, Player, SelectedAccessories, PartName)
		if self[Player.Name] then
			for i, tableAssociated in ipairs(SelectedAccessories) do
				local Accessory : Accessory = tableAssociated.Object
				if not ValidateAccessoryOwner(Player, Accessory) then return end
				if tableAssociated["IsItemPack"] then
					tableAssociated.Object.Handle:FindFirstChild("AccessoryWeld").Part1 = Player.Character:FindFirstChild(PartName)
				elseif not tableAssociated.IsItemPack and not tableAssociated.IsMeshPart then
					tableAssociated.Object.Handle:FindFirstChildOfClass("Weld").Part1 = Player.Character:FindFirstChild(PartName)
				end


			end
			return true
		end
	end,
	MirrorAccessory = function(self, Player, SelectedAccessories)
		if self[Player.Name] then
			local character = Player.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			if not rootPart then return false end

			local mirroredAny = false

			for i, accessoryTable in ipairs(SelectedAccessories) do
				if not accessoryTable.IsMeshPart then
					local Accessory : Accessory = accessoryTable.Object
					if not ValidateAccessoryOwner(Player, Accessory) then return end

					local currentPartName = accessoryTable.WeldPart
					local targetPartName = OppositeBodyParts[currentPartName]
					local targetPart = targetPartName and character:FindFirstChild(targetPartName)
					local sourcePart = currentPartName and character:FindFirstChild(currentPartName)
					local handle = Accessory and Accessory:FindFirstChild("Handle")
					local weld = handle and (handle:FindFirstChild("AccessoryWeld") or handle:FindFirstChildOfClass("Weld"))

					if targetPart and sourcePart and handle and weld then
						local currentHandleWorld = sourcePart.CFrame * accessoryTable.AccessoryWeld.C0:Inverse()
						local rootRelative = rootPart.CFrame:ToObjectSpace(currentHandleWorld)
						local mirroredRootRelative = MirrorCFrameAcrossCharacter(rootRelative)
						local mirroredHandleWorld = rootPart.CFrame * mirroredRootRelative

						weld.Part1 = targetPart
						weld.C0 = mirroredHandleWorld:ToObjectSpace(targetPart.CFrame)
						weld.C1 = CFrame.new(0, 0, 0)

						accessoryTable.WeldPart = targetPartName
						accessoryTable.AccessoryWeld.C0 = weld.C0
						accessoryTable.AccessoryWeld.C1 = weld.C1
						RecalculateAccessoryTransformData(accessoryTable, character)
						mirroredAny = true
					end
				end
			end

			return mirroredAny and SelectedAccessories or false
		end
	end,
	LimbRemover = function(self, Player, LimbName, SetType)
		if self[Player.Name] then
			local Limb = Player.Character:FindFirstChild(LimbName)
			if Limb then
				Limb.Transparency = SetType
			end
		end
		return true
	end,
	AddAccessory = function(self,Player,Id)
		if self[Player.Name] then
			print(Player,Id)

			local function isRealAccessory(accessoryid)
				local suc, ass = pcall(function()
					local ass1 = LoadAssetWithRetry(accessoryid, "AddAccessory LoadAsset")

					if ass1 then
						if ass1:FindFirstChildOfClass("Accessory") then
							return ass1:FindFirstChildOfClass("Accessory")
						else
							print(ass1:FindFirstChild())
							return false
						end
					else
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
		if Value == "Overlay" then -- turn it on
			for i, AccessoryTable in pairs(SelectedAccessories) do
				if not AccessoryTable.IsItemPack then
					AccessoryTable.ColorMode = "Overlay"
					local Accessory : Accessory = AccessoryTable.Object
					if not ValidateAccessoryOwner(Player, Accessory) then return end
					CreateOverlay(Accessory, AccessoryTable.OTransparency, AccessoryTable.OColor)
					if not AccessoryTable.IsMeshPart then
						--Accessory.Handle:FindFirstChildOfClass("SpecialMesh").VertexColor = Vector3.new(1,1,1)
					end
				end
			end
		elseif Value == "VertexColor" then
			for i, AccessoryTable in pairs(SelectedAccessories) do
				if not AccessoryTable.IsItemPack then
					AccessoryTable.ColorMode = "VertexColor"
					local Accessory : Accessory = AccessoryTable.Object
					if not ValidateAccessoryOwner(Player, Accessory) then return end
					DeleteOverlay(Accessory)
					if not AccessoryTable.IsMeshPart then
						Accessory.Handle:FindFirstChildOfClass("SpecialMesh").VertexColor = AccessoryTable.Color
					end
				end
			end
		end
		return SelectedAccessories
	end,

	OTransparency = function(self, Player, SelectedAccessories, Value)
		for i, AccessoryTable in pairs(SelectedAccessories) do
			local Accessory : Accessory = AccessoryTable.Object
			if not ValidateAccessoryOwner(Player, Accessory) then return end

			ChangeOverlay(Accessory, Value, AccessoryTable.OColor)

		end
		return true
	end,

	OColor = function(Self, Player, SelectedAccessories, Value)
		for i, AccessoryTable in pairs(SelectedAccessories) do
			local Accessory : Accessory = AccessoryTable.Object
			if not ValidateAccessoryOwner(Player, Accessory) then return end

			ChangeOverlay(Accessory, AccessoryTable.OTransparency, Value)

		end
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
					local InsertedAccessory = LoadAssetWithRetry(AccessoryId, "Copy MeshPart")
					if not InsertedAccessory then return false end
					InsertedAccessory.Parent = workspace
					InsertedAccessory = InsertedAccessory:FindFirstChildOfClass("Accessory")
					if not InsertedAccessory then return false end
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
		print("OUTFIT ID:", OutfitID)
		if OutfitID then

			if CharacterTable["LockedID"] then
				if CharacterTable["LockedID"] ~= Player.UserId then
					warn("Outfit is locked, denying changes.")
					return false
				end
			end

			local success, result = pcall(function()


				local NewSlot = { 
					["SlotName"] = OutfitID,
					["Data"] = CharacterTable

				}

				local newS = SerializeTable(NewSlot)
				SetAsyncInBackground(OutfitIDsDataStore, tostring(OutfitID), newS, "OutfitIDsDataStore:SetAsync")
				return
			end)

			if success then return OutfitID else warn(result) return false end

		else

			if LockID then CharacterTable["LockedID"] = Player.UserId else CharacterTable.LockedID = nil end

			local function CheckIfUsedAndFindNew()
				local seed = tick()
				math.randomseed(seed)
				local random = math.random(100000, 999999)
				print("New OutfitID:", random)

				local success, found = GetAsyncWithBudget(OutfitIDsDataStore, tostring(random), "OutfitIDsDataStore:GetAsync")
				if not success then
					return false
				end

				if found then
					return CheckIfUsedAndFindNew()
				else
					return random
				end
			end

			OutfitID = CheckIfUsedAndFindNew()
			if not OutfitID then return false end

			local success, result = pcall(function()

				local NewSlot = { 
					["SlotName"] = OutfitID,
					["Data"] = CharacterTable

				}

				local newS = SerializeTable(NewSlot)
				SetAsyncInBackground(OutfitIDsDataStore, tostring(OutfitID), newS, "OutfitIDsDataStore:SetAsync")
				return
			end)
			if success then return OutfitID, Player.UserId else warn(result) return false end
		end

	end,

	LoadOutfitID = function(self, Player, OutfitID)
		if OutfitID then
			local success, result = GetAsyncWithBudget(OutfitIDsDataStore, tostring(OutfitID), "OutfitIDsDataStore:GetAsync")

			if success then
				if result then

					result = DeserializeTable(result)
					result = LoadCharacter(Player, result)
					return result
				else
					warn("ID", OutfitID, "doesn't exist.")
					return result

				end
			else
				warn(result)
				return false
			end

		else
			warn("No Outfit ID provided.")
			return false
		end
	end,

	SaveAccessoryID = function(self, Player, ID, SelectedAccessories, LockID)
		print("OUTFIT ID:", ID)
		if typeof(SelectedAccessories) ~= "table" or #SelectedAccessories > GetMaxAccessoriesForPlayer(Player) then return false end
		if ID then


			local success, result = pcall(function()


				local NewSlot = { 
					["SlotName"] = ID,
					["Data"] = SelectedAccessories
				}

				local newS = SerializeTable(NewSlot)
				SetAsyncInBackground(AccessoryIDsDataStore, tostring(ID), newS, "AccessoryIDsDataStore:SetAsync")
				return
			end)

			if success then return ID else warn(result) return false end

		else

			local function CheckIfUsedAndFindNew()
				local seed = tick()
				math.randomseed(seed)
				local random = math.random(100000, 999999)
				print("New AccessoryID:", random)

				local success, found = GetAsyncWithBudget(AccessoryIDsDataStore, tostring(random), "AccessoryIDsDataStore:GetAsync")
				if not success then
					return false
				end

				if found then
					return CheckIfUsedAndFindNew()
				else
					return random
				end
			end

			ID = CheckIfUsedAndFindNew()
			if not ID then return false end

			local success, result = pcall(function()

				local NewSlot = { 
					["SlotName"] = ID,
					["Data"] = SelectedAccessories,
					["Locked"] = true,

				}
				local newS = SerializeAccessoryTable(NewSlot)
				SetAsyncInBackground(AccessoryIDsDataStore, tostring(ID), newS, "AccessoryIDsDataStore:SetAsync")
				return
			end)
			if success then return ID, Player.UserId else warn(result) return false end
		end

	end,

	LoadAccessoryID = function(self, player, ID)

		warn("Getting Accessory ID thingy", ID)
		local success, result = GetAsyncWithBudget(AccessoryIDsDataStore, tostring(ID), "AccessoryIDsDataStore:GetAsync")
		warn("results:", success, result)
		if success and result then
			warn(result)
			local SlotData = DeserializeAccessoryTable(result)
			local Character = player.Character
			local AccCount = 0
			for i, v in pairs(Character:GetChildren()) do
				if v:IsA("Accessory") then
					AccCount = AccCount + 1
				end
			end

			local max = GetMaxAccessoriesForPlayer(player)


			warn("MAX:", max)
			if (AccCount + #SlotData["Data"]) > max then return false end
			for i, AccessoryTable in pairs(SlotData["Data"]) do
				--print("i:", i, "table:", AccessoryTable)
				if not AccessoryTable.IsMeshPart then
					if AccessoryTable.DistanceFromOriginC0 then
						AccessoryTable.DistanceFromOrigin = AccessoryTable.DistanceFromOriginC0
						AccessoryTable.DistanceFromOriginC0 = nil
					end
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
					NewMesh.VertexColor = AccessoryTable["Color"]
					NewMesh.Offset = AccessoryTable.Offset
					NewMesh.Scale = AccessoryTable.Scale

					NewAccessory.Handle.Transparency = AccessoryTable["Transparency"]
					NewAccessory.Handle.Material = AccessoryTable.Material

					Character.Humanoid:AddAccessory(NewAccessory)

					local NewWeld = NewAccessory.Handle:FindFirstChildOfClass("Weld")
					NewWeld.Part1 = Character:FindFirstChild(AccessoryTable["WeldPart"])

					NewMesh.Offset = AccessoryTable.Offset
					NewMesh.Scale = AccessoryTable.Scale


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
				else -- meshparts
					local Humanoid = player.Character.Humanoid
					warn("Meshpart loading found!", AccessoryTable.AccessoryId)
					local AccessoryId = AccessoryTable.AccessoryId
					local InsertedAccessory = LoadAssetWithRetry(AccessoryId, "LoadAccessoryID MeshPart")
					if not InsertedAccessory then return false end
					InsertedAccessory.Parent = workspace
					InsertedAccessory = InsertedAccessory:FindFirstChildOfClass("Accessory")
					if not InsertedAccessory then return false end
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

			return SlotData["Data"]
		else
			return false
		end


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
		local success, res = GetAsyncWithBudget(TutorialDataStore, Player.UserId, "TutorialDataStore:GetAsync")
		if success then
			if res == nil then res = false end
			return res
		else
			return true
		end
	end,
	SetTutorial = function(self, Player, val)
		SetAsyncInBackground(TutorialDataStore, Player.UserId, val, "TutorialDataStore:SetAsync")
		return true
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
	if Customization[player.Name] == player and CachedCharacterData[tostring(player.UserId)] ~= nil and CachedPlayerSlotNames[player.UserId] ~= nil then warn("ALREADY HAS SOMEHOW") return end
	print("Loading character information for new player:", player)
	Customization[player.Name] = player
	CachedCharacterData[tostring(player.UserId)] = {}
	local bigtable = {}
	local Slots = Constants.BaseSaveSlots
	local SaveSlots1 = UserOwnsGamePassWithCache(player, 21918073)
	local SaveSlots2 = UserOwnsGamePassWithCache(player, 53597806)
	local SaveSlots3 = UserOwnsGamePassWithCache(player, 144388696)
	if SaveSlots1 then
		Slots = math.clamp(Slots * 2, Slots, Constants.SpecialMaxSaveSlots)
	end
	if SaveSlots2 then
		Slots = math.clamp(Slots * 2, Slots, Constants.SpecialMaxSaveSlots)
	end
	if SaveSlots3 then
		Slots = math.clamp(Slots * 2, Slots, Constants.SpecialMaxSaveSlots)
	end
	if vipwhitelist[player.UserId] or GroupVerif.CheckRank(player, "Gamemaster") or RunService:IsStudio() then
		Slots = Constants.SpecialMaxSaveSlots
	end

	local success, res = GetAsyncWithBudget(SlotNameDS, player.UserId, "SlotNameDS:GetAsync")
	if success then
		if res == nil then
			warn("Player is not using the more efficient PlayerSlotName Datastore. Converting now.")
			for i = 1, Slots do
				local returnedTable = GETSaveFromSlot(player.UserId, true, i)
				if returnedTable ~= nil then
					bigtable[tostring(i)] = nil
				end
				bigtable[tostring(i)] = returnedTable
				wait()
			end
			local newTable = {}
			for i, v in pairs(bigtable) do
				newTable[i] = v.SlotName
			end
			wait(2)
			SetAsyncInBackground(SlotNameDS, player.UserId, newTable, "SlotNameDS:SetAsync")
			CachedPlayerSlotNames[player.UserId] = newTable
		else
			warn("Player is using the PlayerSlotName Datastore. Updating cache.")
			CachedPlayerSlotNames[player.UserId] = res
			-- this is just for today


		end
	else
		warn("Data stores are down!")
		local gui = script.DatastoresDown:Clone()
		gui.Parent = player.PlayerGui
	end


	--CachedCharacterData[tostring(player.UserId)] = deepCopy(bigtable)
	--warn("SAVE DATA:", CachedCharacterData[player.UserId])
	local returnedLegacySave = GetAllLegacyData(player)
	if returnedLegacySave then
		print(player, " has legacy data")
		CachedLegacyCharacterData[tostring(player.UserId)] = returnedLegacySave
	end

	player.CharacterAdded:Connect(function(character)
		task.wait(0.3)
		warn("CUSTOMIZATON : ", "CHARACTER ADDED", player.Name)
		NormalizeCharacterAccessories(character)
	end)

	local function executeRegardless()
		task.wait(0.3)
		warn("CUSTOMIZATON : ", "EXECUTE REG.", player.Name)
		NormalizeCharacterAccessories(player.Character)
	end

	repeat task.wait() until player.Character
	executeRegardless()
end

game.Players.PlayerRemoving:Connect(function(player)
	Customization[player.Name] = false
	Customization[player.Name] = nil
	CachedCharacterData[tostring(player.UserId)] = nil
	CachedLegacyCharacterData[player.UserId] = nil
	for cacheKey in pairs(CachedGamePassOwnership) do
		if string.match(cacheKey, "^" .. tostring(player.UserId) .. "_") then
			CachedGamePassOwnership[cacheKey] = nil
		end
	end
	SetAsyncInBackground(SlotNameDS, player.UserId, CachedPlayerSlotNames[player.UserId], "SlotNameDS:SetAsync")
	CachedPlayerSlotNames[player.UserId] = nil
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
