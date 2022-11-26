--[[
		=<>= COLOUR4 =<>=
]]
export type Colour4 = typeof(setmetatable(
	{} :: {
		Colour: Color3,
		Transparency: number,
		Alpha: number,
		R: number,
		G: number,
		B: number,
	},
	{} :: {
		ClassName: string,
		__index: any,

		new: (red: number, green: number, blue: number, transparency: number) -> (Colour4),
		fromAlpha: (red: number, green: number, blue: number, alpha: number) -> (Colour4),
		fromColor3: (colour: Color3, transparency: number?) -> (Colour4),

		Lerp: (other_colour4: Colour4, alpha: number) -> (),
	}
))

export type ButtonStyle = { [number]: Colour4 }

--[[
		=<>= STYLES =<>=
]]
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
	Text: Colour4,
	TextDisabled: Colour4,
	WindowBg: Colour4,
	ChildBg: Colour4,
	PopupBg: Colour4,
	Border: Colour4,
	BorderShadow: Colour4,
	FrameBg: Colour4,
	FrameBgHovered: Colour4,
	FrameBgActive: Colour4,
	TitleBg: Colour4,
	TitleBgActive: Colour4,
	TitleBgCollapsed: Colour4,
	MenuBarBg: Colour4,
	ScrollbarBg: Colour4,
	ScrollbarGrab: Colour4,
	ScrollbarGrabHovered: Colour4,
	ScrollbarGrabActive: Colour4,
	CheckMark: Colour4,
	SliderGrab: Colour4,
	SliderGrabActive: Colour4,
	Button: Colour4,
	ButtonHovered: Colour4,
	ButtonActive: Colour4,
	Header: Colour4,
	HeaderHovered: Colour4,
	HeaderActive: Colour4,
	SeparatorHovered: Colour4,
	SeparatorActive: Colour4,
	ResizeGrip: Colour4,
	ResizeGripHovered: Colour4,
	ResizeGripActive: Colour4,
	PlotLines: Colour4,
	PlotLinesHovered: Colour4,
	PlotHistogram: Colour4,
	PlotHistogramHovered: Colour4,
	TableHeaderBg: Colour4,
	TableBorderStrong: Colour4,
	TableRowBgAlt: Colour4,
	TextSelectedBg: Colour4,
	DragDropTarget: Colour4,
	NavHighlight: Colour4,
	NavWindowingHighlight: Colour4,
	NavWindowingDimBg: Colour4,
	ModalWindowDimBg: Colour4,
	Separator: Colour4,
	Tab: Colour4,
	TabHovered: Colour4,
	TabActive: Colour4,
	TabUnfocused: Colour4,
	TabUnfocusedActive: Colour4,

	Transparent: Colour4,
}

export type ImGuiButtonStyles = {
	TitleButton: ButtonStyle,
	Checkbox: ButtonStyle,
	Button: ButtonStyle,

	[string]: ButtonStyle,
}

--[[
		=<>= VALUES =<>=
]]
export type ImGuiId = string
export type ImGuiHash = string

--[[
	The Internal ButtonState used by all buttons:
		0 - None
		1 - Hovered
		2 - Held
		3 - Active
]]
export type ButtonState = number

export type Class = "Window" | "Title" | "Menubar" | "Menu" | "ElementFrame" | "Text" | "Checkbox" | "Button" | ""

--[[
		=<>= FLAGS =<>=
]]
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
		=<>= BUTTON TYPE =<>=
]]

export type WindowTitleButton = {
	Class: Class,
	Id: ImGuiId,
	Hash: ImGuiHash,
	Instance: GuiBase2d?,
	State: ButtonState,
	PreviousState: ButtonState,
	Instance: ImageLabel?,
}

export type WindowMenu = {
	Class: Class,
	Id: ImGuiId,
	Hash: ImGuiHash,
	Instance: Frame?,
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

export type ImGuiWindow = typeof(setmetatable(
	{} :: {
		Class: Class,
		Id: ImGuiId,
		Hash: ImGuiHash,
		Name: string,
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

		SkipElements: boolean,

		RedrawNextFrame: boolean, -- DO NOT SET, changed internally based on .RedrawNextFrame
		RedrawThisFrame: boolean, -- Calls a complete redraw for the next frame. Everything gets wiped. Used when collapsing a window.

		Window: {
			Instance: Frame?,
			Title: WindowTitle,
			Menubar: WindowMenubar,
			Frame: ElementFrame,
		},
	},
	{} :: {
		ClassName: string,
		__index: any,

		new: (windowName: string, parentWindow: ImGuiWindow?, flags: WindowFlags) -> (ImGuiWindow),

		UpdateTitleColour: (self: ImGuiWindow) -> (),
		UpdatePosition: (self: ImGuiWindow) -> (),
		UpdateSize: (self: ImGuiWindow) -> (),
		SetAllStates: (self: ImGuiWindow, state: ButtonState) -> (),
		DrawWindow: (self: ImGuiWindow, stack: number?) -> (),
		DrawTitle: (self: ImGuiWindow) -> (),
		DrawFrame: (self: ImGuiWindow) -> (),

		Destroy: (self: ImGuiWindow) -> (),
	}
))

export type ImGuiText = typeof(setmetatable(
	{} :: {
		Class: Class,
		Text: string,
		Id: ImGuiId,
		Hash: ImGuiHash,
		ElementFrame: ElementFrame,
		Window: ImGuiWindow,

		Active: boolean,

		Size: Vector2,
		Instance: TextLabel,
	},
	{} :: {
		ClassName: string,
		__index: any,

		new: (text: string, window: ImGuiWindow, parentInstance: ElementFrame) -> (),

		DrawText: (self: ImGuiText, position: Vector2) -> (),
		UpdatePosition: (self: ImGuiText, position: Vector2) -> (),
		UpdateColour: (self: ImGuiText) -> (),

		Destroy: (self: ImGuiText) -> (),
	}
))

export type ImGuiCheckbox = typeof(setmetatable(
	{} :: {
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

		Size: Vector2,
		Instance: Frame,
	},
	{} :: {
		ClassName: string,
		__index: any,

		new: (text: string, value: { boolean }, window: ImGuiWindow, parentInstance: ElementFrame) -> (),

		DrawCheckbox: (self: ImGuiCheckbox, position: Vector2) -> (),
		UpdatePosition: (self: ImGuiCheckbox, position: Vector2) -> (),
		UpdateCheckmark: (self: ImGuiCheckbox, pressed: boolean) -> (),

		Destroy: (self: ImGuiCheckbox) -> (),
	}
))

export type ImGuiButton = typeof(setmetatable(
	{} :: {
		Class: Class,
		Text: string,
		Id: ImGuiId,
		Hash: ImGuiHash,
		ElementFrame: ElementFrame,
		Window: ImGuiWindow,

		State: ButtonState,
		PreviousState: ButtonState,

		Active: boolean,

		Size: Vector2,
		Instance: TextLabel,
	},
	{} :: {
		ClassName: string,
		__index: any,

		new: (text: string, window: ImGuiWindow, parentInstance: ElementFrame) -> (boolean),

		DrawButton: (self: ImGuiButton, position: Vector2) -> (),
		UpdatePosition: (self: ImGuiButton, position: Vector2) -> (),

		Destroy: (self: ImGuiButton) -> (),
	}
))

export type Element = ImGuiText | ImGuiCheckbox | ImGuiButton

export type Button = WindowTitleButton | ImGuiButton | ImGuiCheckbox

export type ImGui = {
	Start: (ImGui) -> (),
	Stop: (ImGui) -> (),
	Pause: (ImGui) -> (),

	Begin: (self: ImGui, windowName: string, open: { boolean }?, flags: WindowFlags?) -> (boolean),
	End: (self: ImGui) -> (),

	Text: (self: ImGui, text: string, ...any) -> (),
	TextDisabled: (self: ImGui, text: string, ...any) -> (),
	TextColoured: (self: ImGui, colour: Colour4, string, ...any) -> (),

	Checkbox: (self: ImGui, text: string, value: { boolean }) -> (),
	Button: (self: ImGui, text: string) -> (boolean),

	Indent: (self: ImGui) -> (),
	Unindent: (self: ImGui) -> (),

	DebugWindow: (self: ImGui) -> (),

	Flags: {
		WindowFlags: () -> (WindowFlags),
	},
	Types: ModuleScript,
	Colour4: ModuleScript,

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

	PushColour: (self: ImGui, index: string, colours: Colour4) -> (),
	PopColour: (self: ImGui, index: string) -> (),
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

	NextItemData: {
		Style: {
			Colours: { [string]: Colour4 },
			Sizes: { [string]: Vector2 | number },
		},
	},

	UpdateTime: (ImGuiInternal, number) -> (),

	[any]: any,
}

return {}
