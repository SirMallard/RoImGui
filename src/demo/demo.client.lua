local players: Players = game:GetService("Players")
local player = players.LocalPlayer or players:GetPropertyChangedSignal("LocalPlayer"):Wait()

local foo = { player.AccountAge, player.DisplayName, player.FollowUserId, player.UserId, player.CharacterAppearanceId }

local function doSomething()
	return "I did something!"
end

doSomething()

export type IDoSomething = () -> (string)

print(foo)
