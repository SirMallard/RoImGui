local Types = require(script.Parent.Parent.Types)

local Colour4 = {}
Colour4.__index = Colour4
Colour4.ClassName = "Colour4"

Colour4.__newindex = function(self: Types.Colour4, index: any, value: any)
	if (index == "Colour") and (typeof(value) == "Color3") then
		self.Colour = value
		self.R = value.R
		self.G = value.G
		self.B = value.B
	elseif (index == "R") and (typeof(value) == "number") then
		self.Colour = Color3.new(value, self.G, self.B)
		self.R = value
	elseif (index == "G") and (typeof(value) == "number") then
		self.Colour = Color3.new(self.R, value, self.B)
		self.G = value
	elseif (index == "B") and (typeof(value) == "number") then
		self.Colour = Color3.new(self.R, self.G, value)
		self.B = value
	elseif (index == "Transparency") and (typeof(value) == "number") then
		self.Transparency = value
		self.Alpha = 1 - value
	elseif (index == "Alpha") and (typeof(value) == "number") then
		self.Transparency = 1 - value
		self.Alpha = value
	end
end

local function Lerp(a: number, b: number, t: number): (number)
	return a * (1 - t) + b * t
end

function Colour4.new(red: number, green: number, blue: number, transparency: number): (Types.Colour4)
	local self: Types.Colour4 = setmetatable({
		Colour = Color3.new(red, green, blue),
		Transparency = transparency,
		Alpha = 1 - transparency,
		R = red,
		G = green,
		B = blue,
	}, Colour4) :: Types.Colour4

	return self
end

function Colour4.fromAlpha(red: number, green: number, blue: number, alpha: number): (Types.Colour4)
	return Colour4.new(red, green, blue, 1 - alpha)
end

function Colour4.fromColour3(colour: Color3, transparency: number?): (Types.Colour4)
	return Colour4.new(colour.R, colour.G, colour.B, transparency or 0)
end

function Colour4:Lerp(other_Colour4: Types.Colour4, alpha: number)
	local r: number = Lerp(self.R, other_Colour4.R, alpha)
	local g: number = Lerp(self.G, other_Colour4.G, alpha)
	local b: number = Lerp(self.B, other_Colour4.B, alpha)
	local t: number = Lerp(self.Transparency, other_Colour4.Transparency, alpha)

	return Colour4.new(r, g, b, t)
end

return Colour4
