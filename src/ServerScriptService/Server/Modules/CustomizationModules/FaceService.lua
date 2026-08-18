local FaceService = {}

function FaceService.GetFaceTextureFromDecalAsset(faceId, insertService)
	local success, asset = pcall(function()
		local loadedAsset = insertService:LoadAsset(faceId)
		loadedAsset.Parent = workspace
		if loadedAsset then
			if loadedAsset:FindFirstChildOfClass("Decal") then
				print("ITS A FACE")
				local texture = loadedAsset:FindFirstChildOfClass("Decal").Texture
				loadedAsset:Destroy()
				return texture
			else
				return false
			end
		else
			return false
		end
	end)

	if success then
		if asset then
			return asset
		else
			return false
		end
	else
		return false
	end
end

function FaceService.SetFaceTexture(character, texture)
	character.Head.face.Texture = texture
end

function FaceService.GetThumbnailFaceTexture(faceId)
	return "rbxthumb://type=Asset&id=" .. tostring(faceId) .. "&w=420&h=420"
end

return FaceService
