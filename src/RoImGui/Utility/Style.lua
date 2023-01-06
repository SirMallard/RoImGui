local Types = require(script.Parent.Parent.Types)
local Colour4 = require(script.Parent.Colour4)

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

	ResizeOuterPadding = 4,
	ResizeInnerPadding = 10,
}

local Colours: Types.ImGuiStyleColour = {} :: Types.ImGuiStyleColour

Colours.Text = Colour4.new(1.0, 1.0, 1.0, 0.0)
Colours.TextDisabled = Colour4.new(0.5, 0.5, 0.5, 0.0)
Colours.WindowBg = Colour4.new(0.06, 0.06, 0.06, 0.06)
Colours.ChildBg = Colour4.new(0.0, 0.0, 0.0, 1.0)
Colours.PopupBg = Colour4.new(0.08, 0.08, 0.08, 0.06)
Colours.Border = Colour4.new(0.43, 0.43, 0.5, 0.5)
Colours.BorderShadow = Colour4.new(0.0, 0.0, 0.0, 1.0)
Colours.FrameBg = Colour4.new(0.16, 0.29, 0.48, 0.46)
Colours.FrameBgHovered = Colour4.new(0.26, 0.59, 0.98, 0.6)
Colours.FrameBgActive = Colour4.new(0.26, 0.59, 0.98, 0.33)
Colours.TitleBg = Colour4.new(0.04, 0.04, 0.04, 0.0)
Colours.TitleBgActive = Colour4.new(0.16, 0.29, 0.48, 0.0)
Colours.TitleBgCollapsed = Colour4.new(0.0, 0.0, 0.0, 0.49)
Colours.MenuBarBg = Colour4.new(0.14, 0.14, 0.14, 0.0)
Colours.ScrollbarBg = Colour4.new(0.02, 0.02, 0.02, 0.47)
Colours.ScrollbarGrab = Colour4.new(0.31, 0.31, 0.31, 0.0)
Colours.ScrollbarGrabHovered = Colour4.new(0.41, 0.41, 0.41, 0.0)
Colours.ScrollbarGrabActive = Colour4.new(0.51, 0.51, 0.51, 0.0)
Colours.CheckMark = Colour4.new(0.26, 0.59, 0.98, 0.0)
Colours.SliderGrab = Colour4.new(0.24, 0.52, 0.88, 0.0)
Colours.SliderGrabActive = Colour4.new(0.26, 0.59, 0.98, 0.0)
Colours.Button = Colour4.new(0.26, 0.59, 0.98, 0.6)
Colours.ButtonHovered = Colour4.new(0.26, 0.59, 0.98, 0.0)
Colours.ButtonActive = Colour4.new(0.06, 0.53, 0.98, 0.0)
Colours.Header = Colour4.new(0.26, 0.59, 0.98, 0.69)
Colours.HeaderHovered = Colour4.new(0.26, 0.59, 0.98, 0.2)
Colours.HeaderActive = Colour4.new(0.26, 0.59, 0.98, 0.0)
Colours.Separator = Colour4.new(0.43, 0.43, 0.50, 0.5)
Colours.SeparatorHovered = Colour4.new(0.1, 0.4, 0.75, 0.22)
Colours.SeparatorActive = Colour4.new(0.1, 0.4, 0.75, 0.0)
Colours.ResizeGrip = Colour4.new(0.26, 0.59, 0.98, 0.8)
Colours.ResizeGripHovered = Colour4.new(0.26, 0.59, 0.98, 0.33)
Colours.ResizeGripActive = Colour4.new(0.26, 0.59, 0.98, 0.05)
Colours.PlotLines = Colour4.new(0.61, 0.61, 0.61, 0.0)
Colours.PlotLinesHovered = Colour4.new(1.0, 0.43, 0.35, 0.0)
Colours.PlotHistogram = Colour4.new(0.9, 0.7, 0.0, 0.0)
Colours.PlotHistogramHovered = Colour4.new(1.0, 0.6, 0.0, 0.0)
Colours.TableHeaderBg = Colour4.new(0.19, 0.19, 0.2, 0.0)
Colours.TableBorderStrong = Colour4.new(0.31, 0.31, 0.35, 0.0)
Colours.TableRowBgAlt = Colour4.new(1.0, 1.0, 1.0, 0.94)
Colours.TextSelectedBg = Colour4.new(0.26, 0.59, 0.98, 0.65)
Colours.DragDropTarget = Colour4.new(1.0, 1.0, 0.0, 0.1)
Colours.NavHighlight = Colour4.new(0.26, 0.59, 0.98, 0.0)
Colours.NavWindowingHighlight = Colour4.new(1.0, 1.0, 1.0, 0.3)
Colours.NavWindowingDimBg = Colour4.new(0.8, 0.8, 0.8, 0.8)
Colours.ModalWindowDimBg = Colour4.new(0.8, 0.8, 0.8, 0.65)

Colours.Transparent = Colour4.new(1, 1, 1, 1)

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
	Frame = {
		[0] = Colours.FrameBg,
		[1] = Colours.FrameBgHovered,
		[2] = Colours.FrameBgActive,
	},
	Button = {
		[0] = Colours.Button,
		[1] = Colours.ButtonHovered,
		[2] = Colours.ButtonActive,
	},
	SideResize = {
		[0] = Colours.Transparent,
		[1] = Colours.Transparent,
		[2] = Colours.SeparatorActive,
	},
	CornerResize = {
		[0] = Colours.Transparent,
		[1] = Colours.ResizeGripHovered,
		[2] = Colours.ResizeGripActive,
	},
	CornerResizeVisible = {
		[0] = Colours.ResizeGrip,
		[1] = Colours.ResizeGripHovered,
		[2] = Colours.ResizeGripActive,
	},
	Menu = {
		[0] = Colours.Transparent,
		[1] = Colours.HeaderHovered,
		[2] = Colours.Header,
	},
	TreeNode = {
		[0] = Colours.Transparent,
		[1] = Colours.HeaderHovered,
		[2] = Colours.HeaderActive,
	},
	CollapsingHeader = {
		[0] = Colours.Header,
		[1] = Colours.HeaderHovered,
		[2] = Colours.HeaderActive,
	},
}

local backup = {
	Colours = {},
}

for index: string, colour: Types.Colour4 in Colours do
	backup.Colours[index] = table.clone(colour)
end

return {
	Sizes = Sizes,
	Colours = Colours,
	ButtonStyles = ButtonStyles,
	Font = Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),

	Images = {
		Circle = "rbxassetid://4673889148",
		Dropdown = "rbxassetid://11523280019",
		Cross = "rbxassetid://11506648985",
	},

	Backup = backup,
}
