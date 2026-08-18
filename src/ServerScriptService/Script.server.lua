local Players = game:GetService("Players")

local HEAD_SCALE_FACTOR = 1.058
local ACCESSORY_COUNTER_SCALE = 1 / HEAD_SCALE_FACTOR

local function isHeadAccessory(accessory, character)
	if not accessory:IsA("Accessory") then
		return false
	end

	local head = character:FindFirstChild("Head")
	local handle = accessory:FindFirstChild("Handle")

	if not head or not handle then
		return false
	end

	-- Best check: if the accessory has an attachment that matches one in the Head,
	-- then Roblox is attaching it to the head.
	for _, child in ipairs(handle:GetChildren()) do
		if child:IsA("Attachment") and head:FindFirstChild(child.Name) then
			return true
		end
	end

	-- Fallback for normal avatar accessories
	local accessoryType = accessory.AccessoryType

	return accessoryType == Enum.AccessoryType.Hat
		or accessoryType == Enum.AccessoryType.Hair
		or accessoryType == Enum.AccessoryType.Face
		or accessoryType == Enum.AccessoryType.Eyebrow
		or accessoryType == Enum.AccessoryType.Eyelash
end

local function counterScaleAccessory(accessory, character)
	if not isHeadAccessory(accessory, character) then
		return
	end

	-- Prevent scaling the same accessory twice
	if accessory:GetAttribute("CounterScaledForHeadBoost") then
		return
	end

	accessory:SetAttribute("CounterScaledForHeadBoost", true)

	local handle = accessory:FindFirstChild("Handle")
	if not handle then
		return
	end

	local specialMesh = handle:FindFirstChildOfClass("SpecialMesh")

	if specialMesh then
		specialMesh.Scale *= Vector3.new(
			ACCESSORY_COUNTER_SCALE,
			ACCESSORY_COUNTER_SCALE,
			ACCESSORY_COUNTER_SCALE
		)
	else
		handle.Size *= Vector3.new(
			ACCESSORY_COUNTER_SCALE,
			ACCESSORY_COUNTER_SCALE,
			ACCESSORY_COUNTER_SCALE
		)
	end
end

local function counterScaleExistingAccessories(character)
	if accessory:GetAttribute("HeadScaleHandledByCustomizer") then
		return
	end
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Accessory") then
			counterScaleAccessory(child, character)
		end
	end
end

local function scaleHead(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid then return end

	if character:GetAttribute("HeadScaled") then return end
	character:SetAttribute("HeadScaled", true)

	local headScale = humanoid:FindFirstChild("HeadScale")

	if headScale then
		headScale.Value *= HEAD_SCALE_FACTOR
	else
		-- R6 fallback
		local head = character:WaitForChild("Head", 10)
		if not head then return end

		local mesh = head:FindFirstChildOfClass("SpecialMesh")

		if mesh then
			mesh.Scale *= Vector3.new(
				HEAD_SCALE_FACTOR,
				HEAD_SCALE_FACTOR,
				HEAD_SCALE_FACTOR
			)
		else
			head.Size *= Vector3.new(
				HEAD_SCALE_FACTOR,
				HEAD_SCALE_FACTOR,
				HEAD_SCALE_FACTOR
			)
		end
	end

	-- Give Roblox a moment to finish applying avatar scaling/accessories
	task.wait(0.2)

	counterScaleExistingAccessories(character)

	-- Handles accessories added after the character already loaded
	character.ChildAdded:Connect(function(child)
		if child:IsA("Accessory") then
			task.wait(0.2)
			counterScaleAccessory(child, character)
		end
	end)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(scaleHead)

	if player.Character then
		scaleHead(player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end