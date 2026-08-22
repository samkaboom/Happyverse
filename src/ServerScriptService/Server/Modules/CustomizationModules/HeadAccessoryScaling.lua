local HeadAccessoryScaling = {}

HeadAccessoryScaling.TargetHeadAssetId = "2432102561"
HeadAccessoryScaling.HeadScaleMultiplier = 1

local EXTERNAL_HEAD_BOOST = 1.058
local HEAD_ACCESSORY_COUNTER_SCALE = 1 / EXTERNAL_HEAD_BOOST

function HeadAccessoryScaling.MeshIdMatches(meshId, targetId)
	return tostring(meshId):find(targetId, 1, true) ~= nil
end

local function ScaleVector3(v, multiplier)
	return Vector3.new(v.X * multiplier, v.Y * multiplier, v.Z * multiplier)
end

function HeadAccessoryScaling.ApplyHeadBoostAccessoryScale(AccessoryTable, NewAccessory, NewMesh)
	if not AccessoryTable or not NewAccessory or not NewMesh then
		return
	end

	local savedMeshScale = AccessoryTable.Scale
	local savedHandleSize = AccessoryTable.HandleSize

	if not savedMeshScale or not savedHandleSize then
		return
	end

	-- This still tells the other server script not to shrink it again.
	NewAccessory:SetAttribute("HeadScaleHandledByCustomizer", true)

	-- IMPORTANT:
	-- On load, use the saved visual size directly.
	-- Do NOT counter-scale here.
	NewAccessory.Handle.Size = savedHandleSize
	NewMesh.Scale = savedMeshScale

	if HeadAccessoryScaling.MeshIdMatches(AccessoryTable["MeshId"], HeadAccessoryScaling.TargetHeadAssetId) then
		-- Keep custom head unmodified here because the other server script handles actual head boost.
		NewAccessory.Handle.Size = savedHandleSize
		NewMesh.Scale = savedMeshScale
	end
end

local function GetAccessoryMeshId(accessory)
	if not accessory then
		return ""
	end

	local handle = accessory:FindFirstChild("Handle")
	if not handle then
		return ""
	end

	local specialMesh = handle:FindFirstChildOfClass("SpecialMesh")
	if specialMesh then
		return specialMesh.MeshId
	end

	if handle:IsA("MeshPart") then
		return handle.MeshId
	end

	return ""
end

local function IsLiveHeadAccessory(accessory, character)
	if not accessory or not character then
		return false
	end

	local handle = accessory:FindFirstChild("Handle")
	local head = character:FindFirstChild("Head")

	if not handle or not head then
		return false
	end

	-- If this accessory is the custom head itself, do NOT shrink it.
	if HeadAccessoryScaling.MeshIdMatches(GetAccessoryMeshId(accessory), HeadAccessoryScaling.TargetHeadAssetId) then
		return false
	end

	-- Check the weld after Humanoid:AddAccessory.
	local weld = handle:FindFirstChildOfClass("Weld")
	if weld then
		if weld.Part0 == head or weld.Part1 == head then
			return true
		end

		if weld.Part0 and weld.Part0.Name == "Head" then
			return true
		end

		if weld.Part1 and weld.Part1.Name == "Head" then
			return true
		end
	end

	-- Attachment fallback.
	for _, child in ipairs(handle:GetChildren()) do
		if child:IsA("Attachment") and head:FindFirstChild(child.Name) then
			return true
		end
	end

	return false
end

function HeadAccessoryScaling.ApplyLiveInsertedHeadAccessoryCounterScale(accessory, character)
	if not accessory or not character then
		return
	end

	if accessory:GetAttribute("HeadScaleHandledByCustomizer") then
		return
	end

	if not IsLiveHeadAccessory(accessory, character) then
		return
	end

	local handle = accessory:FindFirstChild("Handle")
	if not handle then
		return
	end

	local specialMesh = handle:FindFirstChildOfClass("SpecialMesh")

	-- Store the original/base scale before visually counter-scaling.
	-- This helps prevent save/load from treating the shrunken scale as the new original.
	if specialMesh then
		if not accessory:GetAttribute("BaseMeshScaleX") then
			accessory:SetAttribute("BaseMeshScaleX", specialMesh.Scale.X)
			accessory:SetAttribute("BaseMeshScaleY", specialMesh.Scale.Y)
			accessory:SetAttribute("BaseMeshScaleZ", specialMesh.Scale.Z)
		end

		specialMesh.Scale = ScaleVector3(
			Vector3.new(
				accessory:GetAttribute("BaseMeshScaleX"),
				accessory:GetAttribute("BaseMeshScaleY"),
				accessory:GetAttribute("BaseMeshScaleZ")
			),
			HEAD_ACCESSORY_COUNTER_SCALE
		)
	else
		if not accessory:GetAttribute("BaseHandleSizeX") then
			accessory:SetAttribute("BaseHandleSizeX", handle.Size.X)
			accessory:SetAttribute("BaseHandleSizeY", handle.Size.Y)
			accessory:SetAttribute("BaseHandleSizeZ", handle.Size.Z)
		end

		handle.Size = ScaleVector3(
			Vector3.new(
				accessory:GetAttribute("BaseHandleSizeX"),
				accessory:GetAttribute("BaseHandleSizeY"),
				accessory:GetAttribute("BaseHandleSizeZ")
			),
			HEAD_ACCESSORY_COUNTER_SCALE
		)
	end

	accessory:SetAttribute("HeadCounterScaledLiveInsert", true)
	accessory:SetAttribute("HeadScaleHandledByCustomizer", true)
end

return HeadAccessoryScaling
