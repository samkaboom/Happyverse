local AccessoryEditService = {}

function AccessoryEditService.ApplyAccessoryColor(player, updateTable, colorInput, validateAccessoryOwner, changeOverlay)
	local color = Vector3.new(colorInput.R, colorInput.G, colorInput.B)
	for _, accessoryTable in pairs(updateTable) do
		if not accessoryTable.IsItemPack then
			print(player, accessoryTable.Accessory, color)
			local accessory : Accessory = accessoryTable.Object
			if not validateAccessoryOwner(player, accessory) then return end
			if accessoryTable.ColorMode == "VertexColor" then
				if not accessoryTable.IsMeshPart then
					accessory.Handle:FindFirstChildOfClass("SpecialMesh").VertexColor = color
					accessory.Handle.Color = Color3.new(color.X, color.Y, color.Z)
				end
			elseif accessoryTable.ColorMode == "Overlay" then
				changeOverlay(accessory, accessoryTable.OTransparency, colorInput)
				if not accessoryTable.IsMeshPart then
					accessory.Handle.Color = Color3.new(color.X, color.Y, color.Z)
				end
				accessory.Handle.Color = Color3.new(color.X, color.Y, color.Z)
			end
		end
	end

	return color
end

function AccessoryEditService.ApplyParticleColor(player, selectedAccessories, validateAccessoryOwner, applyParticleColor)
	for _, accessoryTable in ipairs(selectedAccessories) do
		local accessory : Accessory = accessoryTable.Object
		if not validateAccessoryOwner(player, accessory) then return end

		local effect = accessory.Handle:FindFirstChildOfClass("ParticleEmitter")
		if effect then
			applyParticleColor(accessoryTable, effect)
		end
	end
	return true
end

function AccessoryEditService.SetTransparency(player, updateTable, value, validateAccessoryOwner)
	for _, accessoryTable in pairs(updateTable) do
		local accessory : Accessory = accessoryTable.Object
		if not validateAccessoryOwner(player, accessory) then return end
		accessory.Handle.Transparency = value
	end
	return value
end

function AccessoryEditService.SetMaterial(player, selectedAccessories, validateAccessoryOwner)
	for _, accessoryTable in ipairs(selectedAccessories) do
		local accessory : Accessory = accessoryTable.Object
		if not validateAccessoryOwner(player, accessory) then return end
		accessory.Handle.Material = accessoryTable.Material
	end

	return true
end

function AccessoryEditService.SetMeshId(player, selectedAccessories, validateAccessoryOwner)
	for _, accessoryTable in pairs(selectedAccessories) do
		local accessory : Accessory = accessoryTable.Object
		if not validateAccessoryOwner(player, accessory) then return end
		if not accessoryTable.IsMeshPart and not accessoryTable.IsItemPack then
			accessory.Handle:FindFirstChildOfClass("SpecialMesh").MeshId = accessoryTable.MeshId
		end
	end
	return true
end

function AccessoryEditService.SetParticle(player, selectedAccessories, particleType, particlesFolder, validateAccessoryOwner, applyParticleColor)
	for _, accessoryTable in ipairs(selectedAccessories) do
		local accessory : Accessory = accessoryTable.Object
		if not validateAccessoryOwner(player, accessory) then return end

		local particle = accessory.Handle:FindFirstChildOfClass("ParticleEmitter")
		if particle then particle:Destroy() end

		if particleType ~= "None" then
			local found = particlesFolder:FindFirstChild(particleType)
			if found then
				found = found:Clone()
				found.Parent = accessory.Handle
				found.Enabled = true
				applyParticleColor(accessoryTable, found)
			end
		end
	end
end

function AccessoryEditService.AdjustParticle(player, selectedAccessories, validateAccessoryOwner, configureParticleEmitter)
	for _, accessoryTable in ipairs(selectedAccessories) do
		local accessory : Accessory = accessoryTable.Object
		if not validateAccessoryOwner(player, accessory) then return end

		local particle = accessory.Handle:FindFirstChildOfClass("ParticleEmitter")
		if particle then
			configureParticleEmitter(accessoryTable, particle)
		end
	end
	return true
end

function AccessoryEditService.SetTexture(player, updateTable, value, validateAccessoryOwner)
	local toApply = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=" .. tostring(value)
	for _, accessoryTable in pairs(updateTable) do
		local accessory : Accessory = accessoryTable.Object
		if not validateAccessoryOwner(player, accessory) then return end
		if accessoryTable.IsMeshPart then
			accessory.Handle.TextureID = toApply
		elseif not accessoryTable.IsMeshPart and not accessoryTable.IsItemPack then
			accessory.Handle:FindFirstChildOfClass("SpecialMesh").TextureId = toApply
		end
	end

	return toApply
end

function AccessoryEditService.SetWeldTransform(player, tableOfAccessories, validateAccessoryOwner)
	for _, accessoryTable in ipairs(tableOfAccessories) do
		local accessory : Accessory = accessoryTable.Object
		if not validateAccessoryOwner(player, accessory) then return end
		local object = accessoryTable.Object
		local handle = object.Handle
		local weld
		if accessoryTable.IsItemPack then
			weld = handle:FindFirstChild("AccessoryWeld")
		else
			weld = handle:FindFirstChildOfClass("Weld")
		end
		weld.C0 = accessoryTable.AccessoryWeld.C0
		weld.C1 = accessoryTable.AccessoryWeld.C1
	end
	return true
end

function AccessoryEditService.SetSize(player, tableOfAccessories, validateAccessoryOwner)
	for _, accessoryTable in ipairs(tableOfAccessories) do
		local accessory : Accessory = accessoryTable.Object
		if not validateAccessoryOwner(player, accessory) then return end
		if not accessoryTable.IsItemPack then
			local object = accessoryTable.Object
			local handle = object.Handle
			local mesh = handle:FindFirstChildOfClass("SpecialMesh")
			if mesh then
				mesh.Scale = accessoryTable.Scale

				if accessoryTable.WeldPart == "Head" then
					accessory:SetAttribute("HeadScaleHandledByCustomizer", true)
				end
			else
				handle.Size = handle.Size
			end
		end
	end
	return true
end

function AccessoryEditService.SetWeldPart(player, selectedAccessories, partName, validateAccessoryOwner)
	for _, tableAssociated in ipairs(selectedAccessories) do
		local accessory : Accessory = tableAssociated.Object
		if not validateAccessoryOwner(player, accessory) then return end
		if tableAssociated["IsItemPack"] then
			tableAssociated.Object.Handle:FindFirstChild("AccessoryWeld").Part1 = player.Character:FindFirstChild(partName)
		elseif not tableAssociated.IsItemPack and not tableAssociated.IsMeshPart then
			tableAssociated.Object.Handle:FindFirstChildOfClass("Weld").Part1 = player.Character:FindFirstChild(partName)
		end
	end
	return true
end

function AccessoryEditService.MirrorAccessories(player, selectedAccessories, validateAccessoryOwner, oppositeBodyParts, mirrorCFrameAcrossCharacter, recalculateAccessoryTransformData)
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return false end

	local mirroredAny = false

	for _, accessoryTable in ipairs(selectedAccessories) do
		if not accessoryTable.IsMeshPart then
			local accessory : Accessory = accessoryTable.Object
			if not validateAccessoryOwner(player, accessory) then return end

			local currentPartName = accessoryTable.WeldPart
			local targetPartName = oppositeBodyParts[currentPartName]
			local targetPart = targetPartName and character:FindFirstChild(targetPartName)
			local sourcePart = currentPartName and character:FindFirstChild(currentPartName)
			local handle = accessory and accessory:FindFirstChild("Handle")
			local weld = handle and (handle:FindFirstChild("AccessoryWeld") or handle:FindFirstChildOfClass("Weld"))

			if targetPart and sourcePart and handle and weld then
				local currentHandleWorld = sourcePart.CFrame * accessoryTable.AccessoryWeld.C0:Inverse()
				local rootRelative = rootPart.CFrame:ToObjectSpace(currentHandleWorld)
				local mirroredRootRelative = mirrorCFrameAcrossCharacter(rootRelative)
				local mirroredHandleWorld = rootPart.CFrame * mirroredRootRelative

				weld.Part1 = targetPart
				weld.C0 = mirroredHandleWorld:ToObjectSpace(targetPart.CFrame)
				weld.C1 = CFrame.new(0, 0, 0)

				accessoryTable.WeldPart = targetPartName
				accessoryTable.AccessoryWeld.C0 = weld.C0
				accessoryTable.AccessoryWeld.C1 = weld.C1
				recalculateAccessoryTransformData(accessoryTable, character)
				mirroredAny = true
			end
		end
	end

	return mirroredAny and selectedAccessories or false
end

return AccessoryEditService
