param (
	[string]$Message = "This is a message",
	[string]$Title = "Message Box Text",
	[string]$Buttons = "OK",
	[string]$Icon = "None"
)

Add-Type -AssemblyName System.Windows.Forms

$Buttons = $Buttons -as [System.Windows.Forms.MessageBoxButtons]
$Icon = $Icon -as [System.Windows.Forms.MessageBoxIcon]

[System.Windows.Forms.MessageBox]::Show($Message, $Title, $Buttons, $Icon)
