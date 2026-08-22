local AccessorySaveSerialization = {}

function AccessorySaveSerialization.new(HttpService, Serialization)
	local SerializeVector3 = Serialization.SerializeVector3
	local DeserializeVector3 = Serialization.DeserializeVector3
	local SerializeColor3 = Serialization.SerializeColor3
	local DeserializeColor3 = Serialization.DeserializeColor3
	local SerializeCFrame = Serialization.SerializeCFrame
	local DeserializeCFrame = Serialization.DeserializeCFrame
	local SerializeMaterial = Serialization.SerializeMaterial
	local DeserializeMaterial = Serialization.DeserializeMaterial

	local serializers = {}

	local function SetDefaultSerializedParticleData(AccessoryTable)
		AccessoryTable.Particle = "None"
		AccessoryTable.ParticleColor = { ["R"] = 1, ["G"] = 1, ["B"] = 1 }
		AccessoryTable.ParticleSize = 0
		AccessoryTable.ParticleTransparency = 0
		AccessoryTable.ParticleRate = 0
	end

	local function SetDefaultParticleData(AccessoryTable)
		AccessoryTable.Particle = "None"
		AccessoryTable.ParticleColor = Color3.fromRGB(255, 255, 255)
		AccessoryTable.ParticleSize = 0
		AccessoryTable.ParticleTransparency = 0
		AccessoryTable.ParticleRate = 0
	end

	local function GetRootRotationFromC0(C0)
		local X, Y, Z = C0:Inverse():ToEulerAnglesXYZ()
		return X, Y, Z
	end

	local function SerializeOverlayColorData(AccessoryTable)
		if not AccessoryTable.OColor then
			AccessoryTable.OColor = Color3.new(1, 1, 1)
		end
		AccessoryTable.OColor = SerializeColor3(AccessoryTable.OColor)

		if not AccessoryTable.OriginalOColor then
			AccessoryTable.OriginalOColor = Color3.new(1, 1, 1)
		end
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
			AccessoryTable.RootRotation = { ["X"] = X, ["Y"] = Y, ["Z"] = Z }
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
			AccessoryTable.RootRotation = Vector3.new(X, Y, Z)
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

		if not AccessoryTable.ColorMode then
			AccessoryTable.ColorMode = "VertexColor"
		end
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

	function serializers.SerializeTable(Table)
		print("Serializer")
		if type(Table) == "string" then
			warn("Table is already serialized.")
			return Table
		end

		local SlotValue = Table
		for _, AccessoryTable in pairs(SlotValue["Data"]["Accessories"]) do
			if not AccessoryTable.IsItemPack and not AccessoryTable.IsMeshPart then
				if typeof(AccessoryTable.AccessoryWeld.C0) == "table" then
					warn("Already serialized, breaking off.")
					break
				end
				SerializeStandardAccessoryData(AccessoryTable, true)
			elseif AccessoryTable.IsItemPack then
				SerializeItemPackData(AccessoryTable)
			elseif AccessoryTable.IsMeshPart then
				if typeof(AccessoryTable.OColor) == "table" then
					warn("Already serialized, breaking off.")
					break
				end
				SerializeMeshPartData(AccessoryTable)
			end
		end

		Table = HttpService:JSONEncode(Table)
		warn("TABLE SIZE:", #Table)
		return Table
	end

	function serializers.SerializeAccessoryTable(Table)
		print("Serializer", Table)
		if type(Table) == "string" then
			warn("Table is already serialized.")
			return Table
		end

		for _, AccessoryTable in pairs(Table["Data"]) do
			if not AccessoryTable.IsMeshPart then
				if typeof(AccessoryTable.AccessoryWeld.C0) == "table" then
					warn("Already serialized, breaking off.")
					break
				end
				SerializeStandardAccessoryData(AccessoryTable, false)
			else
				if typeof(AccessoryTable.OColor) == "table" then
					warn("Already serialized, breaking off.")
					break
				end
				SerializeMeshPartData(AccessoryTable)
			end
		end

		Table = HttpService:JSONEncode(Table)
		return Table
	end

	local function DeserializeStandardAccessoryData(AccessoryTable, IncludeRevertC0)
		if not AccessoryTable.OColor then
			AccessoryTable.OColor = { R = 1, G = 1, B = 1 }
		end
		AccessoryTable.OColor = DeserializeColor3(AccessoryTable.OColor)

		if not AccessoryTable.ColorMode then
			AccessoryTable.ColorMode = "VertexColor"
		end
		if not AccessoryTable.OTransparency then
			AccessoryTable.OTransparency = 0.5
		end

		if not AccessoryTable.OriginalOColor then
			AccessoryTable.OriginalOColor = { R = 1, G = 1, B = 1 }
		end
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
		if not AccessoryTable.OColor then
			AccessoryTable.OColor = { R = 1, G = 1, B = 1 }
		end
		AccessoryTable.OColor = DeserializeColor3(AccessoryTable.OColor)

		if SetColorMode and not AccessoryTable.ColorMode then
			AccessoryTable.ColorMode = "VertexColor"
		end

		if not AccessoryTable.OriginalOColor then
			AccessoryTable.OriginalOColor = { R = 1, G = 1, B = 1 }
		end
		AccessoryTable.OriginalOColor = DeserializeColor3(AccessoryTable.OriginalOColor)

		AccessoryTable.Material = DeserializeMaterial(AccessoryTable.Material)
		AccessoryTable.OriginalMaterial = DeserializeMaterial(AccessoryTable.OriginalMaterial)
		DeserializeParticleData(AccessoryTable)
	end

	function serializers.DeserializeTable(Table)
		print("DESERIALIZING TABLE")
		if not Table then
			return
		end
		if type(Table) == "string" then
			print("Have to decode it.")
			Table = HttpService:JSONDecode(Table)
		end

		local SlotValue = Table
		if SlotValue["Data"] == nil and #SlotValue > 0 then
			SlotValue = SlotValue[1]
		end -- outfit ids used to have a bug where it was a table inside a table rather than just a table like every other save

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
				["Skills"] = { {}, {}, {}, {}, {} },
			}
		end

		for _, AccessoryTable in pairs(SlotValue["Data"]["Accessories"]) do
			if not AccessoryTable.IsItemPack and not AccessoryTable.IsMeshPart then
				if typeof(AccessoryTable.AccessoryWeld.C0) == "CFrame" then
					warn("Already deserialized, breaking off.")
					return Table
				end
				DeserializeStandardAccessoryData(AccessoryTable, true)
			elseif AccessoryTable.IsItemPack then
				DeserializeItemPackData(AccessoryTable)
			elseif AccessoryTable.IsMeshPart then
				if typeof(AccessoryTable.OColor) == "Color3" then
					warn("Already deserialized, breaking off.")
					return Table
				end
				DeserializeMeshPartData(AccessoryTable, true)
			end
		end

		warn("STILL EXISTS?", SlotValue)
		return SlotValue
	end

	function serializers.DeserializeAccessoryTable(Table)
		if not Table then
			return
		end
		if type(Table) == "string" then
			print("Have to decode it.")
			Table = HttpService:JSONDecode(Table)
		end

		for _, AccessoryTable in pairs(Table["Data"]) do
			if not AccessoryTable.IsMeshPart then
				if typeof(AccessoryTable.AccessoryWeld.C0) == "CFrame" then
					warn("Already deserialized, breaking off.")
					return Table
				end
				DeserializeStandardAccessoryData(AccessoryTable, false)
			else
				if typeof(AccessoryTable.OColor) == "Color3" then
					warn("Already deserialized, breaking off.")
					return Table
				end
				DeserializeMeshPartData(AccessoryTable, false)
			end
		end

		return Table
	end

	return serializers
end

return AccessorySaveSerialization
