local AccessoryTransform = {}

AccessoryTransform.OppositeBodyParts = {
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

function AccessoryTransform.MirrorVectorAcrossCharacter(vector)
	return Vector3.new(-vector.X, vector.Y, vector.Z)
end

function AccessoryTransform.MirrorCFrameAcrossCharacter(cframe)
	local position = AccessoryTransform.MirrorVectorAcrossCharacter(cframe.Position)
	local right = cframe.RightVector
	local up = cframe.UpVector
	local back = -cframe.LookVector

	return CFrame.fromMatrix(
		position,
		Vector3.new(right.X, -right.Y, -right.Z),
		AccessoryTransform.MirrorVectorAcrossCharacter(up),
		AccessoryTransform.MirrorVectorAcrossCharacter(back)
	)
end

function AccessoryTransform.RecalculateAccessoryTransformData(accessoryTable, character)
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

return AccessoryTransform
