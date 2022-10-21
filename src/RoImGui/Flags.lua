local BitFlags = require(script.Parent.BitFlags)
local Flags = {}

local WindowFlags = BitFlags("WindowFlags", {
	NoTitleBar = false,
	NoResize = false,
	NoMove = false,
	NoScrollBar = false,
	NoMouseScroll = false,
	NoDropdown = false,
	NoBackground = false,
	MenuBar = true,

	ChildWindow = false,
	Tooltip = false,
	Popup = false,
	Modal = false,
	ChildMenu = false,
})

Flags.WindowFlags = WindowFlags

return Flags
