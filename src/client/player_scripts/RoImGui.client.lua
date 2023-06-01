local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoImGui = require(replicatedStorage:WaitForChild("Modules"):WaitForChild("RoImGui"))

RoImGui:ShowDemoWindow(true)
RoImGui:ShowDebugWindow(true)
RoImGui:Start()

local Iris = require(game.ReplicatedStorage.Iris)
Iris.Init()
Iris:Connect(Iris.ShowDemoWindow)

function PJWHash(key: string)
	local hash: number = 0
	local highbits: number = bit32.lshift(0xffffffff, 28)
	for _, s: string in key:split("") do
		hash = bit32.lshift(hash, 4) + string.byte(s)
		local test: number = bit32.band(hash, highbits)
		if test ~= 0 then
			hash = bit32.band(bit32.bxor(hash, bit32.rshift(test, 24)), bit32.bnot(highbits))
		end
	end

	return bit32.band(hash, 0x7fffffff)
end

function JenkinsHash(key: string)
	local hash: number = 0
	for _, s: string in key:split("") do
		hash += s:byte()
		hash = bit32.band(hash, 0xffffffff)
		hash += bit32.lshift(hash, 10)
		hash = bit32.band(hash, 0xffffffff)
		hash = bit32.bxor(hash, bit32.rshift(hash, 6))
		hash = bit32.band(hash, 0xffffffff)
	end
	hash += bit32.lshift(hash, 3)
	hash = bit32.band(hash, 0xffffffff)
	hash = bit32.bxor(hash, bit32.lshift(hash, 11))
	hash = bit32.band(hash, 0xffffffff)
	hash += bit32.lshift(hash, 15)
	hash = bit32.band(hash, 0xffffffff)

	return ("%08x"):format(hash)
end

function generateId()
	local i = 1
	local ID = ""
	local levelInfo = debug.info(i, "l")
	while levelInfo ~= -1 and levelInfo ~= nil do
		ID ..= "+" .. levelInfo
		i += 1
		levelInfo = debug.info(i, "l")
	end

	print(ID)
end

function layerOne()
	generateId()
end

function layerTwo()
	layerOne()
end

function layerThree()
	layerTwo()
end

function layerFour()
	layerThree()
end

while task.wait() do
	layerFour()
end
