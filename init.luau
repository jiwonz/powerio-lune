--!strict

local process = require("@lune/process")
local stdio = require("@lune/stdio")
local getScriptPath = require("submodules/getScriptPath")
local pathfs = require("submodules/pathfs")
local powerio = {}

local scriptPath = pathfs.Path.from(getScriptPath())
scriptPath = scriptPath:parent() or error("parent not found")

local POWERSHELL_PROGRAM = "powershell"

local powershellScriptsPath do
	if process.os == "windows" then
		local success, result = pcall(function()
			return process.spawn(POWERSHELL_PROGRAM, { "-Help" })
		end)
		if success and result.ok then
			local path = scriptPath:join("scripts")
			if pathfs.isDir(path) then
				powershellScriptsPath = path
			end
		end
	end
end

if powershellScriptsPath == nil then
	print("\nnotice: Could not find windows powershell so we continue with standard I/O\n")
end

local function toPSParameter(v: any): string
	if type(v) == "string" then
		if not v:find(" ") then
			return v
		end
		return "'" .. v .. "'"
	end
	if type(v) == "boolean" then
		return ({
			[false] = "0",
			[true] = "1"
		})[v]
	end
	error(`Failed to convert '{v}' into PowerShell Parameter`)
end

local function toFilter(fileTypeFilter: { name: string, extensions: { string } }): string
	if #fileTypeFilter.extensions < 1 then
		return `{fileTypeFilter.name} (*.*)|*.*`
	end
	for i, v in fileTypeFilter.extensions do
		fileTypeFilter.extensions[i] = "*." .. v
	end
	local fileTypes = table.concat(fileTypeFilter.extensions, ";")
	return `{fileTypeFilter.name} ({fileTypes})|{fileTypes}`
end

function powerio.runScript(nameOrPath: string, args: { [string]: any }): { string }
	local validScriptPath
	local scriptFile = pathfs.Path.from(nameOrPath):withExtension("ps1")
	local path = powershellScriptsPath:join(scriptFile)
	if pathfs.isFile(path) then
		validScriptPath = path:toString()
	end
	if pathfs.isFile(scriptFile) then
		validScriptPath = scriptFile:toString()
	end
	if not validScriptPath then
		error("Could not find script")
	end
	local PSCommand = validScriptPath
	for k, v in args do
		PSCommand ..= " -" .. k
		PSCommand ..= " "
		PSCommand ..= toPSParameter(v)
	end
	local result = process.spawn(POWERSHELL_PROGRAM, { "-Command", PSCommand })
	if result.ok then
		local out = result.stdout:split("\r\n")
		out[#out] = nil
		return out
	end
	return {}
end

function powerio.promptFile(fileTypeFilters: { { name: string, extensions: { string } } }, multiselect: boolean?, initialDirectory: string?, filterIndex: number?): { string }
	local filters = {}
	for _, fileTypeFilter in fileTypeFilters do
		table.insert(filters, toFilter(fileTypeFilter))
	end
	local filter = table.concat(filters, "|")
	if powershellScriptsPath then
		return powerio.runScript("OpenFileDialog", { Filter = filter, InitialDirectory = initialDirectory, FilterIndex = filterIndex, Multiselect = multiselect })
	else
		local files = {}
		print("Drag file here and press enter (answer with blank to finish)")
		while true do
			local answer = stdio.prompt("text", filter)
			if answer == "" then
				break
			end
			if pathfs.isFile(answer) then
				table.insert(files, answer)
			else
				error(`The given file at '{answer}' is not a valid file.`)
			end
		end
		return files
	end
end

-- https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.messageboxbuttons?view=windowsdesktop-8.0#fields
type MessageBoxButtons = "AbortRetryIgnore"
| "CancelTryContinue"
| "OK"
| "OKCancel"
| "RetryCancel"
| "YesNo"
| "YesNoCancel"
-- https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.messageboxicon?view=windowsdesktop-8.0#fields
type MessageBoxIcon = "Asterisk"
| "Error"
| "Exclamation"
| "Hand"
| "Information"
| "None"
| "Question"
| "Stop"
| "Warning"

function powerio.promptMessageBox(title: string?, message: string?, buttons: MessageBoxButtons?, icon: MessageBoxIcon?)
	if powershellScriptsPath then
		return powerio.runScript("MessageBox", { Title = title, Message = message, Buttons = buttons, Icon = icon })[1]
	else
		print(title)
		return stdio.prompt("select", message, {
			"Yes",
			"No"
		})
	end
end

return powerio
