local Types = require(script.Parent.Parent.Types)

local Color4 = {}

local function Lerp(a: number, b: number, t: number): (number)
	return a * (1 - t) + b * t
end

function Color4.new(red: number, green: number, blue: number, transparency: number): (Types.Color4)
	local color: Types.Color4 = {
		Color = Color3.new(red, green, blue),
		Transparency = transparency,
		Alpha = 1 - transparency,
		R = red,
		G = green,
		B = blue,

		Lerp = function(self: Types.Color4, other_color4: Types.Color4, alpha: number)
			local r: number = Lerp(self.R, other_color4.R, alpha)
			local g: number = Lerp(self.G, other_color4.G, alpha)
			local b: number = Lerp(self.B, other_color4.B, alpha)
			local t: number = Lerp(self.Transparency, other_color4.Transparency, alpha)

			return Color4.new(r, g, b, t)
		end,
	}

	setmetatable(color, {
		__newindex = function(_, index: any, value: any)
			if (index == "Color") and (typeof(value) == "Color3") then
				color.Color = value
				color.R = value.R
				color.G = value.G
				color.B = value.B
			elseif (index == "R") and (typeof(value) == "number") then
				color.Color = Color3.new(value, color.G, color.B)
				color.R = value
			elseif (index == "G") and (typeof(value) == "number") then
				color.Color = Color3.new(color.R, value, color.B)
				color.G = value
			elseif (index == "B") and (typeof(value) == "number") then
				color.Color = Color3.new(color.R, color.G, value)
				color.B = value
			elseif (index == "Transparency") and (typeof(value) == "number") then
				color.Transparency = value
				color.Alpha = 1 - value
			elseif (index == "Alpha") and (typeof(value) == "number") then
				color.Transparency = 1 - value
				color.Alpha = value
			end
		end,
	})

	return color :: Types.Color4
end

function Color4.fromAlpha(red: number, green: number, blue: number, alpha: number): (Types.Color4)
	return Color4.new(red, green, blue, 1 - alpha)
end

function Color4.fromColor3(colour: Color3, transparency: number?): (Types.Color4)
	return Color4.new(colour.R, colour.G, colour.B, transparency or 0)
end

return Color4
