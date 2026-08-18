local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants"))

local GroupId = Constants.PermissionGroupId
local groupRank = Constants.Ranks
local rankCache = {}

local module = {}

function module.CheckRank(Player : Player, rank : string)
	local requiredRank = groupRank[rank]
	if not requiredRank then return false end

	local cachedRank = rankCache[Player.UserId]
	if cachedRank == nil then
		local success, result = pcall(function()
			return Player:GetRankInGroup(GroupId)
		end)

		cachedRank = success and result or 0
		rankCache[Player.UserId] = cachedRank
	end

	return cachedRank >= requiredRank
end

return module
