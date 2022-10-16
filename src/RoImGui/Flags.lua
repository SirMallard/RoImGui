local Flags = {}

WindowFlags = 0
Flags.WindowFlags = {
	NoTitleBar = bit32.lshift(WindowFlags, 1) == 1,
}

return Flags
