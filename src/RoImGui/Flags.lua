local Types = require(script.Parent.Types)

local Flags = {}

-- local function BitFlags(flags: { [string]: boolean })
-- 	return function()
-- 		return table.clone(flags)
-- 	end
-- end

function Flags.Enabled(flag: Types.Flag, otherFlag: Types.Flag)
	return bit32.band(flag, otherFlag) ~= 0
end

local WindowFlags: { [string]: Types.Flag } = {
	NoTitleBar = 1,
	NoResize = 2,
	NoMove = 4,
	NoScrollBar = 8,
	NoMouseScroll = 16,
	Collapsed = 32,
	NoBackground = 64,
	MenuBar = 128,
	NoClose = 256,
	NoCollapse = 512,

	ChildWindow = 1024,
	Tooltip = 2048,
	Popup = 4096,
	Modal = 8192,
	ChildMenu = 16384,
}

local TextFlags: { [string]: Types.Flag } = {
	BulletText = 1,
}

-- local WindowFlags: () -> Types.WindowFlags = BitFlags({
-- 	NoTitleBar = false,
-- 	NoResize = false,
-- 	NoMove = false,
-- 	NoScrollBar = false,
-- 	NoMouseScroll = false,
-- 	Collapsed = false,
-- 	NoBackground = false,
-- 	NoMenuBar = true,
-- 	NoClose = false,
-- 	NoCollapse = false,

-- 	ChildWindow = false,
-- 	Tooltip = false,
-- 	Popup = false,
-- 	Modal = false,
-- 	ChildMenu = false,
-- }) :: () -> Types.WindowFlags

-- local TextFlags: () -> Types.TextFlags = BitFlags({
-- 	BulletText = false,
-- }) :: () -> Types.TextFlags

Flags.WindowFlags = WindowFlags
Flags.TextFlags = TextFlags

return Flags
