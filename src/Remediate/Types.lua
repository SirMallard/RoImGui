export type Flags = number

export type InternalPointer<T, K> = { [number]: { [K]: T } | K }
export type Pointer<T, K> = { [number]: T }
export type Key = number | string

--[[
	either we have a direct pointer { false }
	or we want to pass a table with a key or index. { { index = false }, "index" }
	
	We can then check
]]

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

	Frame: number,

	Properties: {
		Size: Vector2,
		[any]: any,
	},
	Values: {
		[any]: any,
	},

	[any]: (Element, ...any) -> ...any,
}

export type Window = {
	Id: Id,
	Flags: Flags,
	Name: string,

	Instance: Frame,
	SkipElements: boolean,
	DrawCursor: DrawCursor,

	Frame: number,
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
		Open: { boolean },
		_open: boolean,
		Key: number,
	},

	[any]: any,
}

export type Text = Element & {
	Text: string,

	Instance: Frame,
}

export type Checkbox = Element & {
	Label: string,

	Instance: Frame,

	Values: {
		Value: Pointer<boolean, Key>,
		_value: boolean,
		Key: Key,
	},
}

export type RadioButton = Element & {
	Label: string,

	Instance: Frame,

	Values: {
		Value: Pointer<number, Key>,
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
		Value: Pointer<string, Key>,
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
		Value: Pointer<string, Key>,
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
	WindowFocusOrder: { Window },
	WindowStack: { Window },

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
	[any]: any,
}

export type Internal = {
	FrameData: FrameData,
	MouseData: MouseData,
	ElementData: ElementData,

	Screen: ScreenGui,

	[any]: (Internal, ...any) -> ...any,
}

return {}
