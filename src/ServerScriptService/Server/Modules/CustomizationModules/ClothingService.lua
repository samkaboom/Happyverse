local ClothingService = {}

function ClothingService.GetClassicClothingTemplate(assetId, className, templateProperty, insertService)
	local success, template = pcall(function()
		local asset = insertService:LoadAsset(assetId)
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

return ClothingService
