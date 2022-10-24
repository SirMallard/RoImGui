local BitFlags = require(script.Parent.BitFlags)
local Flags = {}

local WindowFlags = BitFlags("WindowFlags", {
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
})

Flags.WindowFlags = WindowFlags

return Flags
