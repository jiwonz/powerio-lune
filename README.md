# powerio-lune
PowerShell powered I/O library for lune

## Installation
Use git submodule.
```sh
git submodule add
```

## Usage
```lua
local filePaths = powerio.promptFile({
	{ name = "Roblox Model Files", extensions = { "rbxm" } }
})

local answer = powerio.promptMessageBox("Title", "Message", "YesNo", "Information")

```

## TODO
- Support no-powershell environment for prompts
