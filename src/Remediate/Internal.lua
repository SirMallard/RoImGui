local Internal = {}

Internal.FrameData = {
	Frame = 0,
	Time = 0,

	Windows = {},
	WindowFocusOrder = {},

	WindowData = {
		Current = nil,
		Hovered = nil,
		Active = nil,
		Moving = nil,
		Resizing = nil,
		Scrolling = nil,
	},

	ElementData = {
		HoverId = "",
		ActiveId = "",
		HoverClass = "",
		ActiveClass = "",

		HoldOffset = Vector2.zero,
		ResizeAxis = Vector2.zero,
	},

	ScreenSize = Vector2.zero,
	GuiInset = Vector2.zero,
}

Internal.MouseData = {
	Cursor = {
		Position = Vector2.zero,
		Delta = Vector2.zero,
		Magnitude = 0,
	},

	LeftButton = {
		State = false,
		Changed = false,
		Frames = 0,
		Time = 0,
		Clicks = 0,
	},

	RightButton = {
		State = false,
		Changed = false,
		Frames = 0,
		Time = 0,
		Clicks = 0,
	},

	DoubleClickTime = 0.3,
	DoubleClickMagnitude = 6,
}

Internal.ElementData = {
	RedrawElement = false,
}

return Internal
