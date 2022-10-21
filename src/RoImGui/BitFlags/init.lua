local Types = require(script.Parent.Types)

local BitFlags = {}

function BitFlags(type: string, flags: { [string]: boolean })
	return {
		new = function(): (Types.BitFlag)
			local self: Types.BitFlag = {
				type = type,
			}

			for flag: string, value: boolean in flags do
				self[flag] = value
			end

			return self
		end,
	}
end

return BitFlags
