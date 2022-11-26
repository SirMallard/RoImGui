return function(hashString: string): (string)
	if typeof(hashString) == "number" then
		return ""
	end

	local function split(int: number): (number)
		return bit32.lshift(bit32.band(15, int), 4) + bit32.rshift(bit32.band(240, int), 4)
	end

	local hash_table = {}
	for index = 1, #hashString do
		table.insert(hash_table, string.char(split(string.byte(hashString, index))))
	end

	return table.concat(hash_table)
end
