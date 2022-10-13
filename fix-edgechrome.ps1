# Create tools folder
$FolderName = "C:\Tools"
if (!(Test-Path $FolderName)) {
    New-Item $FolderName -ItemType Directory
    New-Item "$($FolderName)\RegistryHacks" -ItemType Directory
}
# create ps file in tools folder
New-Item -Path $FolderName -Name "set-ChromePolicies.ps1" -ItemType File
# in ps file add code for setting chrome and edge registry keys to reset newtab and homepage to default

# create scheduled task to run ps file every hour
