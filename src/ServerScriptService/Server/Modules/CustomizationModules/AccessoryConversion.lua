local AccessoryConversion = {}

local function GetMeshPartTextureId(handle)
	local textureId = handle.TextureID or ""
	if textureId ~= "" then
		return textureId
	end

	for i, descendant in pairs(handle:GetDescendants()) do
		if descendant:IsA("Texture") or descendant:IsA("Decal") then
			if descendant.Texture and descendant.Texture ~= "" then
				return descendant.Texture
			end
		end
	end

	return ""
end

function AccessoryConversion.ConvertToSpecialMesh(playerCharacter, accessory, defaultAccessory)
	warn(playerCharacter, "converting to specialmesh attempt!", accessory)
	local accessoryHandle = accessory:WaitForChild("Handle")
	warn("going!")

	local newAccessory = defaultAccessory:Clone()
	newAccessory.Name = accessory.Name

	local accessoryIdValue = accessory:FindFirstChild("AccessoryId")
	local newAttachment = newAccessory.Handle.HairAttachment
	local currentAttachment = accessoryHandle:FindFirstChildOfClass("Attachment")
	if not currentAttachment then
		warn("Could not convert MeshPart accessory without an attachment:", accessory.Name)
		accessory:Destroy()
		newAccessory:Destroy()
		return nil
	end

	newAttachment.Name = currentAttachment.Name
	newAttachment.Position = currentAttachment.Position

	local mesh = newAccessory.Handle:FindFirstChildOfClass("SpecialMesh")
	local currentMesh = accessory.Handle.MeshId
	local currentTexture = GetMeshPartTextureId(accessory.Handle)

	newAccessory.AttachmentForward = accessory.AttachmentForward
	newAccessory.AttachmentPos = accessory.AttachmentPos
	newAccessory.AttachmentRight = accessory.AttachmentRight
	newAccessory.AttachmentUp = accessory.AttachmentUp

	local clonedAttachment = newAccessory.Handle:FindFirstChildOfClass("Attachment")
	clonedAttachment.Name = currentAttachment.Name
	clonedAttachment.Axis = currentAttachment.Axis
	clonedAttachment.SecondaryAxis = currentAttachment.SecondaryAxis
	clonedAttachment.Position = currentAttachment.Position
	clonedAttachment.Orientation = currentAttachment.Orientation

	mesh.MeshId = currentMesh
	if currentTexture ~= "" then
		mesh.TextureId = currentTexture
	end
	warn("Converted MeshPart accessory values:", accessory.Name, currentMesh, currentTexture)

	if accessoryIdValue then
		accessoryIdValue:Clone().Parent = newAccessory
	end

	accessory:Destroy()
	newAccessory.Parent = workspace
	playerCharacter.Humanoid:AddAccessory(newAccessory)
	return newAccessory
end

return AccessoryConversion
