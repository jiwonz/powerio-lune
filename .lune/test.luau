local powerio = require("..")

if false then
	local result = powerio.promptFile({
		{ name = "ROBLOX SHIT", extensions = { "rbxm" } }
	}, true)
end

local result = powerio.promptMessageBox("lol", "xd", "YesNo", "Information")

print(result)
