local Types = require(script.Parent.Parent.Types)
local Color4 = require(script.Parent.Color4)

local Sizes: Types.ImGuiStyleSize = {
	WindowPadding = Vector2.new(8, 8),
	FramePadding = Vector2.new(4, 3),
	ItemSpacing = Vector2.new(8, 4),
	ItemInnerSpacing = Vector2.new(4, 4),
	CellPadding = Vector2.new(4, 2),

	IndentSpacing = 21,
	ScrollbarSize = 14,
	GrabMinSize = 12,

	TextMinHeight = 13,
	TextSize = 13, -- best size we can use.
}

local Colours: Types.ImGuiStyleColour = {} :: Types.ImGuiStyleColour

Colours.Text = Color4.new(1.0, 1.0, 1.0, 0.0)
Colours.TextDisabled = Color4.new(0.5, 0.5, 0.5, 0.0)
Colours.WindowBg = Color4.new(0.06, 0.06, 0.06, 0.06)
Colours.ChildBg = Color4.new(0.0, 0.0, 0.0, 1.0)
Colours.PopupBg = Color4.new(0.08, 0.08, 0.08, 0.06)
Colours.Border = Color4.new(0.43, 0.43, 0.5, 0.5)
Colours.BorderShadow = Color4.new(0.0, 0.0, 0.0, 1.0)
Colours.FrameBg = Color4.new(0.16, 0.29, 0.48, 0.46)
Colours.FrameBgHovered = Color4.new(0.26, 0.59, 0.98, 0.6)
Colours.FrameBgActive = Color4.new(0.26, 0.59, 0.98, 0.33)
Colours.TitleBg = Color4.new(0.04, 0.04, 0.04, 0.0)
Colours.TitleBgActive = Color4.new(0.16, 0.29, 0.48, 0.0)
Colours.TitleBgCollapsed = Color4.new(0.0, 0.0, 0.0, 0.49)
Colours.MenuBarBg = Color4.new(0.14, 0.14, 0.14, 0.0)
Colours.ScrollbarBg = Color4.new(0.02, 0.02, 0.02, 0.47)
Colours.ScrollbarGrab = Color4.new(0.31, 0.31, 0.31, 0.0)
Colours.ScrollbarGrabHovered = Color4.new(0.41, 0.41, 0.41, 0.0)
Colours.ScrollbarGrabActive = Color4.new(0.51, 0.51, 0.51, 0.0)
Colours.CheckMark = Color4.new(0.26, 0.59, 0.98, 0.0)
Colours.SliderGrab = Color4.new(0.24, 0.52, 0.88, 0.0)
Colours.SliderGrabActive = Color4.new(0.26, 0.59, 0.98, 0.0)
Colours.Button = Color4.new(0.26, 0.59, 0.98, 0.6)
Colours.ButtonHovered = Color4.new(0.26, 0.59, 0.98, 0.0)
Colours.ButtonActive = Color4.new(0.06, 0.53, 0.98, 0.0)
Colours.Header = Color4.new(0.26, 0.59, 0.98, 0.69)
Colours.HeaderHovered = Color4.new(0.26, 0.59, 0.98, 0.2)
Colours.HeaderActive = Color4.new(0.26, 0.59, 0.98, 0.0)
Colours.Separator = Color4.new(0.43, 0.43, 0.50, 0.5)
Colours.SeparatorHovered = Color4.new(0.1, 0.4, 0.75, 0.22)
Colours.SeparatorActive = Color4.new(0.1, 0.4, 0.75, 0.0)
Colours.ResizeGrip = Color4.new(0.26, 0.59, 0.98, 0.8)
Colours.ResizeGripHovered = Color4.new(0.26, 0.59, 0.98, 0.33)
Colours.ResizeGripActive = Color4.new(0.26, 0.59, 0.98, 0.05)
Colours.PlotLines = Color4.new(0.61, 0.61, 0.61, 0.0)
Colours.PlotLinesHovered = Color4.new(1.0, 0.43, 0.35, 0.0)
Colours.PlotHistogram = Color4.new(0.9, 0.7, 0.0, 0.0)
Colours.PlotHistogramHovered = Color4.new(1.0, 0.6, 0.0, 0.0)
Colours.TableHeaderBg = Color4.new(0.19, 0.19, 0.2, 0.0)
Colours.TableBorderStrong = Color4.new(0.31, 0.31, 0.35, 0.0)
Colours.TableRowBgAlt = Color4.new(1.0, 1.0, 1.0, 0.94)
Colours.TextSelectedBg = Color4.new(0.26, 0.59, 0.98, 0.65)
Colours.DragDropTarget = Color4.new(1.0, 1.0, 0.0, 0.1)
Colours.NavHighlight = Color4.new(0.26, 0.59, 0.98, 0.0)
Colours.NavWindowingHighlight = Color4.new(1.0, 1.0, 1.0, 0.3)
Colours.NavWindowingDimBg = Color4.new(0.8, 0.8, 0.8, 0.8)
Colours.ModalWindowDimBg = Color4.new(0.8, 0.8, 0.8, 0.65)

Colours.Transparent = Color4.new(1, 1, 1, 1)

Colours.Tab = Colours.Header:Lerp(Colours.TitleBgActive, 0.8)
Colours.TabHovered = Colours.HeaderHovered
Colours.TabActive = Colours.HeaderActive:Lerp(Colours.TitleBgActive, 0.6)
Colours.TabUnfocused = Colours.Tab:Lerp(Colours.TitleBg, 0.8)
Colours.TabUnfocusedActive = Colours.TabActive:Lerp(Colours.TitleBg, 0.4)

local ButtonStyles: Types.ImGuiButtonStyles = {
	TitleButton = {
		[0] = Colours.Transparent,
		[1] = Colours.ButtonHovered,
		[2] = Colours.ButtonActive,
	},
	Checkbox = {
		[0] = Colours.FrameBg,
		[1] = Colours.FrameBgHovered,
		[2] = Colours.FrameBgActive,
	},
	Button = {
		[0] = Colours.Button,
		[1] = Colours.ButtonHovered,
		[2] = Colours.ButtonActive,
	},
}

return {
	Sizes = Sizes,
	Colours = Colours,
	ButtonStyles = ButtonStyles,
	Font = Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
}
