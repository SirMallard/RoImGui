local Types = require(script.Parent.Types)

local Flags = {}

local function BitFlags(flags: { [string]: boolean })
	return function()
		local self = {}

		for flag: string, value: boolean in flags do
			self[flag] = value
		end

		return self
	end
end

local WindowFlags: () -> (Types.WindowFlags) = BitFlags({
	NoTitleBar = false,
	NoResize = false,
	NoMove = false,
	NoScrollBar = false,
	NoMouseScroll = false,
	Collapsed = false,
	NoBackground = false,
	MenuBar = true,
	NoClose = false,
	NoCollapse = false,

	ChildWindow = false,
	Tooltip = false,
	Popup = false,
	Modal = false,
	ChildMenu = false,
}) :: () -> (Types.WindowFlags)

Flags.WindowFlags = WindowFlags

return Flags
