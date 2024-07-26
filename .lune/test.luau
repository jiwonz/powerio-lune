local powerprompt = require("..")

if false then
	local result = powerprompt.promptFile({
		{ name = "ROBLOX SHIT", extensions = { "rbxm" } }
	}, true)
end

local result = powerprompt.promptMessageBox("lol", "xd", "YesNo", "Information")

print(result)
