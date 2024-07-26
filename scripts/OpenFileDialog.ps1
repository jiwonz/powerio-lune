param (
	[string]$Filter = "All files (*.*)|*.*",
	[string]$InitialDirectory = "",
	[bool]$Multiselect = 0,
	[int]$FilterIndex = 1
)

Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
	InitialDirectory = $InitialDirectory
	Filter = $Filter
	Multiselect = $Multiselect
	FilterIndex = $FilterIndex
}
$Result = $FileBrowser.ShowDialog()

if ($Result -eq 'OK') {
	$FileBrowser.FileNames | ForEach-Object { Write-Output $_ }
}
