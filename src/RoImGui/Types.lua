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

export type ImGuiId = string | number

export type BitFlag<T> = {
	type: string,
	[string]: boolean,
}

export type WindowFlags = BitFlag<"WindowFlags"> & {
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
	StartPosition: Vector2,
	MaximumPosition: Vector2,
	PreviousPosition: Vector2,
}

export type WindowTitleButton = {
	Instance: ImageLabel?,
	Id: ImGuiId,
	Active: boolean,
	Hovered: boolean,
	WasUpdated: boolean,
}

export type WindowMenu = {
	Instance: Frame?,
	Id: ImGuiId,
	Active: boolean,
	WasActive: boolean,
}

export type ImGuiWindow = {
	Name: string,
	Id: ImGuiId,
	Flags: WindowFlags,

	ParentWindow: ImGuiWindow?, -- the parent window
	RootWindow: ImGuiWindow?, -- the top most window in the window stack
	PopupRootWindow: ImGuiWindow?, -- the popup parent of the window
	PopupParentRootWindow: ImGuiWindow?, -- the parent window which initiated the popup for title highlighting
	ParentWindowFromStack: ImGuiWindow?, -- the stacked parent, may be different to the parentWindow

	ChildWindows: { ImGuiWindow },

	LastFrameActive: number,
	FocusOrder: number,

	DrawCursor: DrawCursor,

	Postion: Vector2,
	Size: Vector2,
	MinimumSize: Vector2,

	Active: boolean,
	WasActive: boolean,
	Appearing: boolean,
	CanCollapse: boolean,
	CanClose: boolean,
	Collapsed: boolean,
	Open: { boolean },

	Window: {
		Instance: Frame?,
		Title: {
			Instance: Frame?,
			Text: string?,
			Collapse: WindowTitleButton,
			Close: WindowTitleButton,
			MinimumSize: Vector2,
		},
		Menubar: {
			Instance: Frame?,
			Menus: {
				[string]: WindowMenu,
			},
			MinimumSize: Vector2,
		},
		Frame: {
			Instance: Frame?,
			MinimumSize: Vector2,
		},
	},

	new: (windowName: string, parentWindow: ImGuiWindow?, flags: WindowFlags) -> (ImGuiWindow),
	DrawWindow: (ImGuiWindow, stack: number?) -> (),
	DrawTitle: (ImGuiWindow) -> (),
	Destroy: (ImGuiWindow) -> (),

	[any]: any,
}

export type ImGuiInternal = {
	Frame: number,
	ElapsedTime: number,
	GuiInset: Vector2,

	Status: string,

	HoverId: ImGuiId,
	ActiveId: ImGuiId,

	ActiveIdClickOffset: Vector2?,

	Viewport: ScreenGui,

	ActiveWindow: ImGuiWindow?,
	HoveredWindow: ImGuiWindow?,
	MovingWindow: ImGuiWindow?,
	CurrentWindow: ImGuiWindow?,
	Windows: { [string]: ImGuiWindow }, -- all windows
	WindowStack: { ImGuiWindow },
	WindowOrder: { ImGuiWindow },
	WindowFocusOrder: { ImGuiWindow }, -- root windows in focus order of back to front. (highest index is highest zindex)

	ChildWindowCount: number,

	MouseButton1: {
		Down: boolean,
		DownOnThisFrame: boolean,
		DownFrames: number,
		Up: boolean,
		UpOnThisFrame: boolean,
		UpFrames: number,
		DownId: string,
		UpId: string,
	},
	MouseButton2: {
		Down: boolean,
		DownOnThisFrame: boolean,
		DownFrames: number,
		Up: boolean,
		UpOnThisFrame: boolean,
		UpFrames: number,
		DownId: string,
		UpId: string,
	},

	MouseCursor: {
		MousePosition: Vector2,
		MouseDelta: Vector2,
	},

	RemoveHoverId: (ImGuiInternal, ImGuiId) -> (),
	SetHoverId: (ImGuiInternal, ImGuiId, Instance?) -> (),

	[any]: any,
}

return {}
