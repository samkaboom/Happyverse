local Client = game.Players.LocalPlayer
local GroupId = 295131561

local groupRank = {

	Community = 245,
	Gamemaster = 246,
	Executives = 247,
	Staff = 248,
	Developer = 250,
	HeadDeveloper = 251,
	Manager = 253,
	Founder = 255

}

local module = {}

function module.CheckRank(Player : Player, rank : string)


	print("CHECK OUT", Player:GetRankInGroup(GroupId))
	local rank = groupRank[rank]
	print("RANK?", rank)
	if not rank then
		return false
	end
	local TrueRank = nil
	repeat 
		pcall(function()
			wait(0.3)
			TrueRank = Player:GetRankInGroup(GroupId)
		end)
	until TrueRank
	if TrueRank >= rank then
		print("it work?")
		return true
	else
		return false
	end

end

return module
