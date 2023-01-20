local TextService = game:GetService("TextService")
local Types = require(script.Parent.Types)

local Flags = {}

local function BitFlags(flags: { [string]: boolean })
	return function()
		return table.clone(flags)
	end
end

local WindowFlags: () -> Types.WindowFlags = BitFlags({
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
}) :: () -> Types.WindowFlags

local TextFlags: () -> Types.TextFlags = BitFlags({
	BulletText = false,
}) :: () -> Types.TextFlags

Flags.WindowFlags = WindowFlags
Flags.TextFlags = TextFlags

return Flags
