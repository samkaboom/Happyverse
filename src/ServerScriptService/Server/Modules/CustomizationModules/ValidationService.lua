local ValidationService = {}

function ValidationService.ValidateAccessoryOwner(player, accessory)
	if accessory:FindFirstAncestorOfClass("Model") ~= player.Character then
		player:Kick("Invalid request")
		return false
	end
	return true
end

function ValidationService.GetMaxAccessoriesForPlayer(player, constants, marketplaceService, runService, groupVerification, vipWhitelist)
	local maxAccessories = constants.MaxAccessories
	local ownsMoreAccessories = false

	pcall(function()
		ownsMoreAccessories = marketplaceService:UserOwnsGamePassAsync(player.UserId, 179828905)
	end)

	if ownsMoreAccessories then
		maxAccessories = constants.MoreAccessoriesGamepassMaxAccessories
	end

	if vipWhitelist[player.UserId] or groupVerification.CheckRank(player, "Gamemaster") or runService:IsStudio() then
		maxAccessories = constants.SpecialMaxAccessories
	end

	return maxAccessories
end

function ValidationService.GetFilteredBroadcastText(textObject)
	local filteredMessage
	local success, errorMessage = pcall(function()
		filteredMessage = textObject:GetNonChatStringForBroadcastAsync()
	end)

	if success then
		return filteredMessage
	elseif errorMessage then
		print("Error filtering message:", errorMessage)
	end

	return false
end

return ValidationService
