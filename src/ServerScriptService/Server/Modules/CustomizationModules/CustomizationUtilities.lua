local CustomizationUtilities = {}

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

function CustomizationUtilities.LimbRemover(Client, LimbToRemove, Transparency)
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

function CustomizationUtilities.DeepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = CustomizationUtilities.DeepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

function CustomizationUtilities.Round(n)
	return math.round(n * 100) / 100
end

function CustomizationUtilities.ValidateAccessoryOwner(Player, Accessory)
	if Accessory:FindFirstAncestorOfClass("Model") ~= Player.Character then
		Player:Kick("Invalid request")
		return false
	end
	return true
end

function CustomizationUtilities.MirrorVectorAcrossCharacter(vector)
	return Vector3.new(-vector.X, vector.Y, vector.Z)
end

function CustomizationUtilities.MirrorCFrameAcrossCharacter(cframe)
	local position = CustomizationUtilities.MirrorVectorAcrossCharacter(cframe.Position)
	local right = cframe.RightVector
	local up = cframe.UpVector
	local back = -cframe.LookVector

	return CFrame.fromMatrix(
		position,
		Vector3.new(right.X, -right.Y, -right.Z),
		CustomizationUtilities.MirrorVectorAcrossCharacter(up),
		CustomizationUtilities.MirrorVectorAcrossCharacter(back)
	)
end

function CustomizationUtilities.RecalculateAccessoryTransformData(accessoryTable, _character)
	if accessoryTable.IsMeshPart then
		return
	end
	local accessory = accessoryTable.Object
	local handle = accessory and accessory:FindFirstChild("Handle")
	if not handle then
		return
	end

	local weld = handle:FindFirstChild("AccessoryWeld") or handle:FindFirstChildOfClass("Weld")
	if not weld or not weld.Part1 then
		return
	end

	local originCF = accessoryTable.OriginalC0:Inverse()
	local currentCF = handle.CFrame
	local referenceCF = weld.Part1.CFrame * CFrame.new(originCF.Position)
	local accCF = referenceCF:ToObjectSpace(CFrame.new() + currentCF.Position)
	accessoryTable.DistanceFromOrigin = Vector3.new(-accCF.Position.X, -accCF.Position.Y, -accCF.Position.Z)

	local originalRx, originalRy, originalRz =
		accessoryTable.RootRotation.X, accessoryTable.RootRotation.Y, accessoryTable.RootRotation.Z
	local currentCFInverse = accessoryTable.AccessoryWeld.C0:Inverse()
	local currentRx, currentRy, currentRz = currentCFInverse:ToEulerAnglesXYZ()
	accessoryTable.RotationsApplied =
		Vector3.new(currentRx - originalRx, currentRy - originalRy, currentRz - originalRz)
end

function CustomizationUtilities.CreateTextFiltering(FilterStringWithRetry, GetFilteredBroadcastTextWithRetry)
	local textFiltering = {}

	function textFiltering.GetFilteredBroadcastText(textObject)
		local filteredMessage = GetFilteredBroadcastTextWithRetry(textObject, "GetFilteredBroadcastText")

		if filteredMessage then
			return filteredMessage
		end

		return false
	end

	function textFiltering.FilterBroadcastText(text, userId, label)
		local textObject = FilterStringWithRetry(text, userId, label)
		if not textObject then
			return false
		end

		return GetFilteredBroadcastTextWithRetry(textObject, label)
	end

	return textFiltering
end

CustomizationUtilities.OppositeBodyParts = OppositeBodyParts

return CustomizationUtilities
