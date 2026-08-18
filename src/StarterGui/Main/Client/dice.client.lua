local ui = game.Players.LocalPlayer.PlayerGui
local player = game.Players.LocalPlayer
local modifer = 0
local dices = 1
local rollCooldown = 12 -- Cooldown duration in seconds
local isCooldownActive = false

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Event for displaying roll result on player head (add this in ReplicatedStorage)
local displayRollEvent = ReplicatedStorage:WaitForChild("DisplayRollEvent")

local function rollDice(diceSides)
	local rollResults = {}
	if dices <= 0 then return {0} end  -- Return {0} if no dice to roll

	-- Roll each die and store each result individually
	for i = 1, dices do
		local rollResult = math.random(1, diceSides)
		table.insert(rollResults, rollResult)
	end

	-- Debugging: Print rollResults to verify modifier addition
	print("Roll results with modifier:", rollResults)

	return rollResults
end

local function triggerCooldown()
	isCooldownActive = true
	wait(rollCooldown)
	isCooldownActive = false
end

-- Dice roll function with cooldown check
local function onDiceRoll(diceSides)
	if isCooldownActive then
		print("Roll is on cooldown!")
		return
	end

	local result = rollDice(diceSides)
	displayRollEvent:FireServer(result, diceSides, modifer)
	triggerCooldown()
end

-- Dice buttons with cooldown
ui:WaitForChild("Main").Dice.d2.MouseButton1Down:Connect(function()
	onDiceRoll(2)
end)

ui:WaitForChild("Main").Dice.d4.MouseButton1Down:Connect(function()
	onDiceRoll(4)
end)

ui:WaitForChild("Main").Dice.d6.MouseButton1Down:Connect(function()
	onDiceRoll(6)
end)

ui:WaitForChild("Main").Dice.d8.MouseButton1Down:Connect(function()
	onDiceRoll(8)
end)

ui:WaitForChild("Main").Dice.d10.MouseButton1Down:Connect(function()
	onDiceRoll(10)
end)

ui:WaitForChild("Main").Dice.d12.MouseButton1Down:Connect(function()
	onDiceRoll(12)
end)

ui:WaitForChild("Main").Dice.d20.MouseButton1Down:Connect(function()
	onDiceRoll(20)
end)

-- Modifier and Dice count adjustments
ui:WaitForChild("Main").Dice.Modifer.TextButton.MouseButton1Down:Connect(function()
	modifer = math.min(modifer + 1, 10)
	ui:WaitForChild("Main").Dice.Modifer.Text = "Modifier: " .. modifer
end)

ui:WaitForChild("Main").Dice.Modifer.TextButton.MouseButton2Down:Connect(function()
	modifer = math.max(modifer - 1, -10)  -- Updated minimum to -10
	ui:WaitForChild("Main").Dice.Modifer.Text = "Modifier: " .. modifer
end)

ui:WaitForChild("Main").Dice.Dies.TextButton.MouseButton1Down:Connect(function()
	dices = math.min(dices + 1, 10)
	ui:WaitForChild("Main").Dice.Dies.Text = "Dice: " .. dices
end)

ui:WaitForChild("Main").Dice.Dies.TextButton.MouseButton2Down:Connect(function()
	dices = math.max(dices - 1, 0)
	ui:WaitForChild("Main").Dice.Dies.Text = "Dice: " .. dices
end)
