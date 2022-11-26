local ProximityPromptService = game:GetService("ProximityPromptService")
type Base = {
	Id: string,
	Class: string,
}

type Object = Base & {
	Name: string,
}

local x: Object = {
	Id = "",
	Class = "",
	Name = "",
}
