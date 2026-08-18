local OverlayService = {}

function OverlayService.CreateOverlay(accessory: Accessory, transparency: number, color: Color3, serverAssets: Folder)
	if typeof(color) == "Vector3" then
		color = Color3.new(color.X, color.Y, color.Z)
	end

	local handle = accessory.Handle
	local specialMesh = handle:FindFirstChildOfClass("SpecialMesh")

	if specialMesh then
		for i, descendant in pairs(handle:GetDescendants()) do
			if descendant:IsA("Texture") then
				descendant:Destroy()
			end
		end
	else
		if handle:FindFirstChildOfClass("Texture") then
			for i, descendant in pairs(handle:GetDescendants()) do
				if descendant:IsA("Texture") then
					descendant:Destroy()
				end
			end
		end
	end

	local overlay = serverAssets.Overlay
	local faces = {
		"Front",
		"Back",
		"Left",
		"Right",
		"Top",
		"Bottom"
	}

	if specialMesh then
		local newOverlay = overlay:Clone()
		newOverlay.Color3 = color
		newOverlay.Transparency = transparency
		newOverlay.Face = "Front"
		newOverlay.Parent = handle
	else
		for i, face in pairs(faces) do
			local newOverlay = overlay:Clone()
			newOverlay.Color3 = color
			newOverlay.Transparency = transparency
			newOverlay.Face = face
			newOverlay.Parent = handle
		end
	end
end

function OverlayService.DeleteOverlay(accessory: Accessory)
	for i, descendant in pairs(accessory:GetDescendants()) do
		if descendant:IsA("Texture") then
			descendant:Destroy()
		end
	end
end

function OverlayService.ChangeOverlay(accessory: Accessory, transparency: number, color: Color3)
	if typeof(color) == "Vector3" then
		color = Color3.new(color.X, color.Y, color.Z)
	end

	local textures = {}
	for i, texture in pairs(accessory:GetDescendants()) do
		if texture:IsA("Texture") then
			table.insert(textures, texture)
		end
	end

	if #textures > 0 then
		for i, texture in pairs(textures) do
			texture.Transparency = transparency
			texture.Color3 = color
		end
	end
end

return OverlayService
