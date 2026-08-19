local Serialization = {}

function Serialization.SerializeVector3(Value)
	return {
		["X"] = Value.X,
		["Y"] = Value.Y,
		["Z"] = Value.Z
	}
end

function Serialization.DeserializeVector3(Value)
	return Vector3.new(Value.X, Value.Y, Value.Z)
end

function Serialization.SerializeColor3(Value)
	return {
		["R"] = Value.R,
		["G"] = Value.G,
		["B"] = Value.B
	}
end

function Serialization.DeserializeColor3(Value)
	return Color3.new(Value.R, Value.G, Value.B)
end

function Serialization.SerializeCFrame(Value)
	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Value:GetComponents()
	return {
		["X"] = x,
		["Y"] = y,
		["Z"] = z,
		["R00"] = R00,
		["R01"] = R01,
		["R02"] = R02,
		["R10"] = R10,
		["R11"] = R11,
		["R12"] = R12,
		["R20"] = R20,
		["R21"] = R21,
		["R22"] = R22
	}
end

function Serialization.DeserializeCFrame(Value)
	return CFrame.new(
		Value.X, Value.Y, Value.Z,
		Value.R00, Value.R01, Value.R02,
		Value.R10, Value.R11, Value.R12,
		Value.R20, Value.R21, Value.R22
	)
end

function Serialization.SerializeMaterial(Value)
	if Value == Enum.Material.ForceField then
		return "Electric"
	elseif Value == Enum.Material.Metal then
		return "Metal"
	else
		return "Default"
	end
end

function Serialization.DeserializeMaterial(Value)
	if Value == "Electric" then
		return Enum.Material.ForceField
	elseif Value == "Metal" then
		return Enum.Material.Metal
	else
		return Enum.Material.Plastic
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

function Serialization.SerializeTable(Table, httpService) -- makes it so datastores can use them
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

	Table = httpService:JSONEncode(Table)
	warn("TABLE SIZE:", #Table)
	return Table
end

function Serialization.SerializeAccessoryTable(Table, httpService) -- makes it so datastores can use them
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

	Table = httpService:JSONEncode(Table)
	return Table
end

function Serialization.DeserializeTable_Old(Table, httpService)
	print("DESERIALIZING TABLE")
	if not Table then return end
	if type(Table) == "string" then print("Have to decode it."); Table = httpService:JSONDecode(Table) end


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

function Serialization.DeserializeTable(Table, httpService)
	print("DESERIALIZING TABLE")
	if not Table then return end
	if type(Table) == "string" then print("Have to decode it."); Table = httpService:JSONDecode(Table) end

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

function Serialization.DeserializeAccessoryTable(Table, httpService)
	if not Table then return end
	if type(Table) == "string" then print("Have to decode it."); Table = httpService:JSONDecode(Table) end

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


return Serialization