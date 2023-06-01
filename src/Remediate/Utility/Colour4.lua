local Colour4 = {}
Colour4.__index = Colour4
Colour4.ClassName = "Colour4"

function Colour4.new(r: number, g: number, b: number, transparency: number?)
	local self = setmetatable({
		Colour = Color3.fromRGB(r, g, b),
		Transparency = transparency or 0,
	}, Colour4)

	return self
end

return Colour4
