local Types = require(script.Parent.Parent.Types)
local Style = require(script.Parent.Parent.Utility.Style)
local Utility = require(script.Parent.Parent.Utility.Utility)

local TreeNode = {}
TreeNode.__index = TreeNode
TreeNode.ClassName = "TreeNode"

-- local COLOUR3_WHITE: Color3 = Color3.fromRGB(255, 255, 255)
local COLOUR3_BLACK: Color3 = Color3.fromRGB(0, 0, 0)

function TreeNode.new(text: string, value: { boolean }, window: Types.ImGuiWindow, elementFrame: Types.ElementFrame)
	local self = setmetatable({}, TreeNode)

	self.Text = text
	self.Class = "TreeNode"
	self.Id = elementFrame.Id .. ">" .. self.Text
	self.Value = value
	self.InternalValue = value[1]

	self.State = 0

	self.ElementFrame = elementFrame
	self.Window = window
	self.LastFrameActive = 0

	self.Active = false

	self.Size = Vector2.zero

	return self
end

function TreeNode:DrawTreeNode(position: Vector2)
	if self.Instance ~= nil then
		self.Instance:Destroy()
		self.Instance = nil
	end

	if self.ElementFrame.Instance == nil then
		return
	end
end
