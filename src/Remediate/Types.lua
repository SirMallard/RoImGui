export type Flags = number

export type BooleanVariable = { [number]: boolean | string | number }
export type NumberVariable = { number }
export type StringVariable = { string }
export type Key = number | string

export type Id = string
export type Class = string

--[[
	The Internal ButtonState used by all buttons:
		0 - None
		1 - Hovered
		2 - Held
		3 - Active
]]
export type ButtonState = number

export type DrawCursor = {
	Position: Vector2,
	PreviousPosition: Vector2,
	MaximumPosition: Vector2,

	LineHeight: number,
	TextLineOffset: number,

	Indent: number,
	SameLine: boolean,
}

export type Element = {
	Id: Id,
	Flags: Flags,

	Size: Vector2,

	Frame: number,

	Properties: {
		[any]: any,
	},
	Values: {
		[any]: any,
	},

	[any]: any,
}

export type Window = Element & {
	Name: string,

	Instance: Frame,
	SkipElements: boolean,
	DrawCursor: DrawCursor,

	RedrawFrame: number,

	Elements: { [Id]: Element },

	Properties: {
		Collapsed: boolean,
		CanClose: boolean,
		Position: Vector2,
		ScrollPosition: number,
		Size: Vector2,
		MinimumSize: Vector2,

		CloseState: ButtonState,
		CollapseState: ButtonState,
	},
	Values: {
		Open: BooleanVariable,
		_open: boolean,
		Key: Key,
	},
}

export type Text = Element & {
	Text: string,

	Instance: Frame,
}

export type Checkbox = Element & {
	Label: string,

	Instance: Frame,

	Values: {
		Value: BooleanVariable,
		_value: boolean,
		Key: Key,
	},
}

export type RadioButton = Element & {
	Label: string,

	Instance: Frame,

	Values: {
		Value: NumberVariable,
		_value: number,
		Key: Key,
	},
}

export type LabelText = Element & {
	Label: string,
	Value: string,

	Instance: Frame,
}

export type StringInput = Element & {
	Label: string,

	Instance: Frame,

	Values: {
		Value: StringVariable,
		_value: string,
		Key: Key,
	},
}

export type NumberInput = Element & {
	Label: string,

	Instance: Frame,

	Values: {
		Value: NumberValue,
		_value: number,
		Key: Key,
	},
}

export type DragInput = Element & {
	Label: string,

	Instance: Frame,

	Values: {
		Value: NumberValue,
		_value: number,
		Key: Key,
	},
}

export type SliderInput = Element & {
	Label: string,

	Instance: Frame,

	Values: {
		Value: NumberValue,
		_value: number,
		Key: Key,
	},
}

export type ComboInput = Element & {
	Label: string,

	Instance: Frame,

	Properties: {
		Values: { string },
	},
	Values: {
		Value: StringVariable,
		_value: string,
		Key: Key,
	},
}

export type TreeNode = Element & {
	Name: string,

	Instance: Frame,

	Values: {
		Open: NumberValue,
		_open: number,
		Key: Key,
	},
}

export type CollapsingHeader = Element & {
	Name: string,

	Instance: Frame,

	Values: {
		Open: NumberValue,
		_open: number,
		Key: Key,
	},
}

export type Seperator = Element & {
	Instance: Frame,
}

type FrameData = {
	Frame: number,
	Time: number,

	Windows: { [Id]: Window },
	WindowFocusOrder: { [number]: Window },

	WindowData: {
		Current: Window?,
		Hovered: Window?,
		Active: Window?,
		Moving: Window?,
		Resizing: Window?,
		Scrolling: Window?,
	},

	ElementData: {
		HoverId: Id,
		ActiveId: Id,
		HoverClass: Class,
		ActiveClass: Class,

		HoldOffset: Vector2,
		ResizeAxis: Vector2,
	},

	ScreenSize: Vector2,
	GuiInset: Vector2,
}

type MouseData = {
	Cursor: {
		Position: Vector2,
		Delta: Vector2,
		Magnitude: number,
	},

	LeftButton: {
		State: boolean,
		Changed: boolean,
		Frames: number,
		Time: number,

		Clicks: number,
	},
	RightButton: {
		State: boolean,
		Changed: boolean,
		Frames: number,
		Time: number,

		Clicks: number,
	},

	DoubleClickTime: number,
	DoubleClickMagnitude: number,
}

type ElementData = {
	RedrawElement: boolean,
}

type RenderData = {}

export type Remediate = {
	-- FrameData: FrameData,
	-- MouseData: MouseData,
	-- ElementData: ElementData,

	-- Screen: ScreenGui,

	[any]: any,
}

return {}
