local Serialization = {}

function Serialization.SerializeVector3(Value)
	return {
		["X"] = Value.X,
		["Y"] = Value.Y,
		["Z"] = Value.Z
	}
end

function Serialization.DeserializeVector3(Value)
	return Vector3.new(Value.X, Value.Y, Value.Z)
end

function Serialization.SerializeColor3(Value)
	return {
		["R"] = Value.R,
		["G"] = Value.G,
		["B"] = Value.B
	}
end

function Serialization.DeserializeColor3(Value)
	return Color3.new(Value.R, Value.G, Value.B)
end

function Serialization.SerializeCFrame(Value)
	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Value:GetComponents()
	return {
		["X"] = x,
		["Y"] = y,
		["Z"] = z,
		["R00"] = R00,
		["R01"] = R01,
		["R02"] = R02,
		["R10"] = R10,
		["R11"] = R11,
		["R12"] = R12,
		["R20"] = R20,
		["R21"] = R21,
		["R22"] = R22
	}
end

function Serialization.DeserializeCFrame(Value)
	return CFrame.new(
		Value.X, Value.Y, Value.Z,
		Value.R00, Value.R01, Value.R02,
		Value.R10, Value.R11, Value.R12,
		Value.R20, Value.R21, Value.R22
	)
end

function Serialization.SerializeMaterial(Value)
	if Value == Enum.Material.ForceField then
		return "Electric"
	elseif Value == Enum.Material.Metal then
		return "Metal"
	else
		return "Default"
	end
end

function Serialization.DeserializeMaterial(Value)
	if Value == "Electric" then
		return Enum.Material.ForceField
	elseif Value == "Metal" then
		return Enum.Material.Metal
	else
		return Enum.Material.Plastic
	end
end

return Serialization
