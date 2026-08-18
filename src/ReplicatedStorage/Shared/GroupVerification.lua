-- Unified GroupVerification module (works on both server and client)
-- Uses PermissionGroupId from Constants for rank checks

local Constants = require(script.Parent.Constants)
local GroupId = Constants.PermissionGroupId
local Ranks = Constants.Ranks

local GroupVerification = {}

function GroupVerification.CheckRank(player: Player, rankName: string): boolean
	local requiredRank = Ranks[rankName]
	if not requiredRank then
		return false
	end

	local success, playerRank = pcall(function()
		return player:GetRankInGroup(GroupId)
	end)

	if not success or not playerRank then
		return false
	end

	return playerRank >= requiredRank
end

function GroupVerification.GetRank(player: Player): number
	local success, rank = pcall(function()
		return player:GetRankInGroup(GroupId)
	end)
	return success and rank or 0
end

return GroupVerification
