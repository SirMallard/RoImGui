local BitFlags = {}

function BitFlags.new(...: string)
	local args: { n: number, [number]: string } = table.pack(...)

	for index: number, flag: string in args do
	end
end
