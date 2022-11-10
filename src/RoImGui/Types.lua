export type Color4 = {
	Color: Color3,
	Transparency: number,
	Alpha: number,
	R: number,
	G: number,
	B: number,
	Lerp: (Color4, Color4, number) -> (Color4),

	[any]: any,
}

type Color4Object = {
	["new"]: (number, number, number, number) -> (Color4),
	["fromAlpha"]: (number, number, number, number) -> (Color4),
	["fromColor3"]: (Color3, number?) -> (Color4),
}

type ButtonStyle = { [number]: Color4 }

export type ImGuiStyleSize = {
	WindowPadding: Vector2,
	FramePadding: Vector2,
	ItemSpacing: Vector2,
	ItemInnerSpacing: Vector2,
	CellPadding: Vector2,

	IndentSpacing: number,
	ScrollbarSize: number,
	GrabMinSize: number,

	TextMinHeight: number,
	TextSize: number,
}

export type ImGuiStyleColour = {
	Text: Color4,
	TextDisabled: Color4,
	WindowBg: Color4,
	ChildBg: Color4,
	PopupBg: Color4,
	Border: Color4,
	BorderShadow: Color4,
	FrameBg: Color4,
	FrameBgHovered: Color4,
	FrameBgActive: Color4,
	TitleBg: Color4,
	TitleBgActive: Color4,
	TitleBgCollapsed: Color4,
	MenuBarBg: Color4,
	ScrollbarBg: Color4,
	ScrollbarGrab: Color4,
	ScrollbarGrabHovered: Color4,
	ScrollbarGrabActive: Color4,
	CheckMark: Color4,
	SliderGrab: Color4,
	SliderGrabActive: Color4,
	Button: Color4,
	ButtonHovered: Color4,
	ButtonActive: Color4,
	Header: Color4,
	HeaderHovered: Color4,
	HeaderActive: Color4,
	SeparatorHovered: Color4,
	SeparatorActive: Color4,
	ResizeGrip: Color4,
	ResizeGripHovered: Color4,
	ResizeGripActive: Color4,
	PlotLines: Color4,
	PlotLinesHovered: Color4,
	PlotHistogram: Color4,
	PlotHistogramHovered: Color4,
	TableHeaderBg: Color4,
	TableBorderStrong: Color4,
	TableRowBgAlt: Color4,
	TextSelectedBg: Color4,
	DragDropTarget: Color4,
	NavHighlight: Color4,
	NavWindowingHighlight: Color4,
	NavWindowingDimBg: Color4,
	ModalWindowDimBg: Color4,
	Separator: Color4,
	Tab: Color4,
	TabHovered: Color4,
	TabActive: Color4,
	TabUnfocused: Color4,
	TabUnfocusedActive: Color4,

	Transparent: Color4,
}

export type ImGuiButtonStyles = {
	TitleButton: ButtonStyle,
	Checkbox: ButtonStyle,
	Button: ButtonStyle,

	[string]: ButtonStyle,
}

export type ImGuiId = string | number
export type ImGuiHash = string

export type Class = "Window" | "Title" | "Menubar" | "Menu" | "ElementFrame" | "Text" | "Checkbox" | "Button" | ""

export type WindowFlags = {
	type: "WindowFlags",

	NoTitleBar: boolean,
	NoResize: boolean,
	NoMove: boolean,
	NoScrollBar: boolean,
	NoMouseScroll: boolean,
	Collapsed: boolean,
	NoBackground: boolean,
	MenuBar: boolean,
	NoClose: boolean,
	NoCollapse: boolean,

	ChildWindow: boolean,
	Tooltip: boolean,
	Popup: boolean,
	Modal: boolean,
	ChildMenu: boolean,
}

export type DrawCursor = {
	Position: Vector2,
	PreviousPosition: Vector2,

	StartPosition: Vector2,
	MaximumPosition: Vector2,
}

--[[
	The Internal ButtonState used by all buttons:
		0 - None
		1 - Hovered
		2 - Held
		3 - Active
]]
export type ButtonState = number

export type Button = {
	Id: ImGuiId,
	Hash: ImGuiHash,
	Class: Class,
	Instance: GuiBase2d?,
	State: ButtonState,
	PreviousState: ButtonState,
}

export type WindowTitleButton = Button & {
	Instance: ImageLabel?,
}

export type WindowMenu = {
	Class: Class,
	Id: ImGuiId,
	Hash: ImGuiHash,
	Instance: Frame?,
	WasUpdated: boolean,
}

export type WindowTitle = {
	Class: Class,
	Id: ImGuiId,
	Hash: ImGuiHash,
	Instance: Frame?,
	Text: string?,
	Collapse: WindowTitleButton,
	Close: WindowTitleButton,
	MinimumSize: Vector2,
}

export type WindowMenubar = {
	Class: Class,
	Id: ImGuiId,
	Hash: ImGuiHash,
	Instance: Frame?,
	Menus: {
		[string]: WindowMenu,
	},
	MinimumSize: Vector2,
}

export type ElementFrame = {
	Class: Class,
	Id: ImGuiId,
	Hash: ImGuiHash,
	Instance: Frame?,
	MinimumSize: Vector2,
	Elements: { ImGuiText },
	DrawCursor: DrawCursor,
}

export type ImGuiWindow = {
	Class: Class,
	Name: string,
	Id: ImGuiId,
	Hash: ImGuiHash,
	Flags: WindowFlags,

	ParentWindow: ImGuiWindow?, -- the parent window
	RootWindow: ImGuiWindow?, -- the top most window in the window stack
	PopupRootWindow: ImGuiWindow?, -- the popup parent of the window
	PopupParentRootWindow: ImGuiWindow?, -- the parent window which initiated the popup for title highlighting
	ParentWindowFromStack: ImGuiWindow?, -- the stacked parent, may be different to the parentWindow

	ChildWindows: { ImGuiWindow },

	LastFrameActive: number,
	FocusOrder: number,

	Position: Vector2,
	Size: Vector2,
	MinimumSize: Vector2,

	State: ButtonState,
	Active: boolean,
	WasActive: boolean,
	Appearing: boolean,
	Collapsed: boolean,
	Open: { boolean },

	RedrawNextFrame: boolean, -- DO NOT SET, changed internally based on .RedrawNextFrame
	RedrawThisFrame: boolean, -- Calls a complete redraw for the next frame. Everything gets wiped. Used when collapsing a window.

	Window: {
		Instance: Frame?,
		Title: WindowTitle,
		Menubar: WindowMenubar,
		Frame: ElementFrame,
	},

	new: (windowName: string, parentWindow: ImGuiWindow?, flags: WindowFlags) -> (ImGuiWindow),

	UpdateTitleColour: (ImGuiWindow) -> (),
	UpdatePosition: (ImGuiWindow) -> (),
	UpdateSize: (ImGuiWindow) -> (),

	SetAllStates: (ImGuiWindow, ButtonState) -> (),

	DrawWindow: (self: ImGuiWindow, stack: number?) -> (),
	DrawTitle: (self: ImGuiWindow) -> (),
	DrawFrame: (self: ImGuiWindow) -> (),

	Destroy: (ImGuiWindow) -> (),

	[any]: any,
}

export type ImGuiText = {
	Class: Class,
	Text: string,
	Id: ImGuiId,
	Hash: ImGuiHash,
	ElementFrame: ElementFrame,
	Window: ImGuiWindow,

	Active: boolean,

	Position: Vector2,
	Size: Vector2,
	Instance: TextLabel,

	new: (text: string, window: ImGuiWindow, parentInstance: ElementFrame) -> (),
	DrawText: (self: ImGuiText, position: Vector2) -> (),
	UpdatePosition: (self: ImGuiText, position: Vector2) -> (),
	Destroy: (self: ImGuiText) -> (),
}

export type ImGuiCheckbox = {
	Class: Class,
	Text: string,
	Id: ImGuiId,
	Hash: ImGuiHash,
	ElementFrame: ElementFrame,
	Window: ImGuiWindow,
	Value: { boolean },
	InternalValue: boolean,

	State: ButtonState,
	PreviousState: ButtonState,

	Active: boolean,

	Position: Vector2,
	Size: Vector2,
	Instance: Frame,

	new: (text: string, value: { boolean }, window: ImGuiWindow, parentInstance: ElementFrame) -> (),
	DrawCheckbox: (self: ImGuiCheckbox, position: Vector2) -> (),
	UpdatePosition: (self: ImGuiCheckbox, position: Vector2) -> (),

	UpdateCheckmark: (self: ImGuiCheckbox, pressed: boolean) -> (),
	Destroy: (self: ImGuiCheckbox) -> (),
}

export type Element = ImGuiText | ImGuiCheckbox

export type ImGui = {
	Start: (ImGui) -> (),
	Stop: (ImGui) -> (),
	Pause: (ImGui) -> (),

	Begin: (self: ImGui, windowName: string, open: { boolean }?, flags: WindowFlags?) -> (boolean),
	End: (self: ImGui) -> (),

	Text: (self: ImGui, text: string, ...any) -> (),

	Checkbox: (self: ImGui, text: string, value: { boolean }) -> (),

	Indent: (self: ImGui) -> (),
	Unindent: (self: ImGui) -> (),

	DebugWindow: (self: ImGui) -> (),

	Flags: {
		WindowFlags: () -> (WindowFlags),
	},
	Types: ModuleScript,

	CleanWindowElements: (ImGui) -> (),
	UpdateWindowFocusOrder: (ImGui, ImGuiWindow?) -> (),
	FindHoveredWindow: (ImGui) -> (),
	UpdateWindowLinks: (ImGui, ImGuiWindow, WindowFlags, ImGuiWindow?) -> (),
	EndFrameMouseUpdate: (ImGui) -> (),

	GetActiveElementFrame: (self: ImGui) -> (),
	GetElementById: (self: ImGui, id: ImGuiId, class: string, elementFrame: ElementFrame) -> (Element?),
	GetWindowById: (ImGui, string) -> (ImGuiWindow?),
	CreateWindow: (ImGui, string, WindowFlags) -> (ImGuiWindow),
	HandleWindowTitleBar: (ImGui, ImGuiWindow) -> (),

	StartWindowMove: (ImGui, ImGuiWindow) -> (),
	UpdateWindowMove: (ImGui) -> (),

	SetActive: (self: ImGui, id: ImGuiId, class: Class, window: ImGuiWindow?) -> (),
	SetHover: (self: ImGui, id: ImGuiId, class: Class) -> (),
	SetNavWindow: (self: ImGui, window: ImGuiWindow?) -> (),
}

export type MouseButtonData = {
	Down: boolean,
	DownOnThisFrame: boolean,
	DownFrames: number,
	DownTime: number,

	Up: boolean,
	UpOnThisFrame: boolean,
	UpFrames: number,
	UpTime: number,

	LastClickFrame: number,
	LastClickTime: number,
	Clicks: number,
	ClicksThisFrame: number,
}

export type ImGuiInternal = {
	Frame: number,
	ElapsedTime: number,
	DeltaTime: number,
	GuiInset: Vector2,

	Status: string,

	HoverId: ImGuiId,
	HoverClass: Class,
	ActiveId: ImGuiId,
	ActiveClass: Class,

	HoldOffset: Vector2?,

	Viewport: ScreenGui,

	ActiveWindow: ImGuiWindow?,
	HoveredWindow: ImGuiWindow?,
	MovingWindow: ImGuiWindow?,
	CurrentWindow: ImGuiWindow?,
	NavWindow: ImGuiWindow?,

	Windows: { [string]: ImGuiWindow }, -- all windows
	WindowStack: { ImGuiWindow }, -- most recently created window in order for parenting reasons. window removed on :End(), so will be empty at the end
	WindowFocusOrder: { ImGuiWindow }, -- root windows in focus order of back to front. (highest index is highest zindex)

	ElementFrameStack: { ElementFrame }, -- the stack of element frames which are where content is put. Contains the DrawCursor

	ChildWindowCount: number,

	MouseButton1: MouseButtonData,
	MouseButton2: MouseButtonData,

	MouseCursor: {
		Position: Vector2,
		Delta: Vector2,
		Magnitude: number,
	},

	UpdateTime: (ImGuiInternal, number) -> (),

	[any]: any,
}

return {}
