export type Color4Type = {
	Color: Color3,
	Transparency: number,
	Alpha: number,
	R: number,
	G: number,
	B: number,
	Lerp: (any, Color4Type, number) -> (Color4Type),
} & typeof(setmetatable({}, { __newIndex = function(_, _, _) end }))

type Color4ObjectType = {
	["new"]: (number, number, number, number) -> (Color4Type),
	["fromAlpha"]: (number, number, number, number) -> (Color4Type),
	["fromColor3"]: (Color3, number?) -> (Color4Type),
}

export type ImGuiType_Style_Size = {
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

export type ImGuiType_Style_Colour = {
	Text: Color4Type,
	TextDisabled: Color4Type,
	WindowBg: Color4Type,
	ChildBg: Color4Type,
	PopupBg: Color4Type,
	Border: Color4Type,
	BorderShadow: Color4Type,
	FrameBg: Color4Type,
	FrameBgHovered: Color4Type,
	FrameBgActive: Color4Type,
	TitleBg: Color4Type,
	TitleBgActive: Color4Type,
	TitleBgCollapsed: Color4Type,
	MenuBarBg: Color4Type,
	ScrollbarBg: Color4Type,
	ScrollbarGrab: Color4Type,
	ScrollbarGrabHovered: Color4Type,
	ScrollbarGrabActive: Color4Type,
	CheckMark: Color4Type,
	SliderGrab: Color4Type,
	SliderGrabActive: Color4Type,
	Button: Color4Type,
	ButtonHovered: Color4Type,
	ButtonActive: Color4Type,
	Header: Color4Type,
	HeaderHovered: Color4Type,
	HeaderActive: Color4Type,
	SeparatorHovered: Color4Type,
	SeparatorActive: Color4Type,
	ResizeGrip: Color4Type,
	ResizeGripHovered: Color4Type,
	ResizeGripActive: Color4Type,
	PlotLines: Color4Type,
	PlotLinesHovered: Color4Type,
	PlotHistogram: Color4Type,
	PlotHistogramHovered: Color4Type,
	TableHeaderBg: Color4Type,
	TableBorderStrong: Color4Type,
	TableRowBgAlt: Color4Type,
	TextSelectedBg: Color4Type,
	DragDropTarget: Color4Type,
	NavHighlight: Color4Type,
	NavWindowingHighlight: Color4Type,
	NavWindowingDimBg: Color4Type,
	ModalWindowDimBg: Color4Type,
	Separator: Color4Type,
	Tab: Color4Type,
	TabHovered: Color4Type,
	TabActive: Color4Type,
	TabUnfocused: Color4Type,
	TabUnfocusedActive: Color4Type,

	Transparent: Color4Type,
}

export type ImGuiId = string

export type DrawCursor = {
	Position: Vector2,
	StartPosition: Vector2,
	MaximumPosition: Vector2,
	PreviousPosition: Vector2,
}

export type ImGuiWindow = {
	Name: string,
	Id: string,
	Flags: any,

	ParentWindow: ImGuiWindow?,
	RootWindow: ImGuiWindow?,
	WriteAccessed: boolean,

	LastFrameActive: number,
	FocusOrder: number,

	DrawCursor: DrawCursor,

	Postion: Vector2,
	Size: Vector2,
	MinimumSize: Vector2,

	Active: boolean,
	WasActive: boolean,
	CanCollapse: boolean,
	CanClose: boolean,
	Collapsed: boolean,
	Closed: { boolean },
	Open: { boolean },

	new: (windowName: string, flags: any) -> (ImGuiWindow),
	Update: (ImGuiWindow, stack: number) -> (),
	Draw: (ImGuiWindow, stack: number) -> (),
	Destroy: (ImGuiWindow) -> (),

	[any]: any,
}

export type ImGuiInternal = {
	Frame: number,

	Status: string,

	HoverId: ImGuiId?,
	Hover: any?,
	ActiveId: ImGuiId?,
	Active: any?,

	ActiveIdClickOffset: Vector2?,

	ActiveWindow: ImGuiWindow?,
	HoveredWindow: ImGuiWindow?,
	MovingWindow: ImGuiWindow?,
	Windows: { [string]: ImGuiWindow }, -- all windows
	WindowStack: { ImGuiWindow },
	WindowOrder: { ImGuiWindow },
	WindowFocusOrder: { ImGuiWindow }, -- root windows in focus order of back to front. (highest index is highest zindex)

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
