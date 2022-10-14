# Create tools folder
$FolderName = "C:\Tools"
if (!(Test-Path $FolderName)) {
    New-Item $FolderName -ItemType Directory    
}
$FolderName = "$($FolderName)\RegistryHacks"
if (!(Test-Path $FolderName)) {
    New-Item $FolderName -ItemType Directory
}

# create ps file in tools folder
$FileName = "$($FolderName)\set-ChromePolicies.ps1"
if(!(Test-Path $FileName)) {
    New-Item $FileName -ItemType File
    
}
Clear-Content $FileName
# in ps file add code for setting chrome and edge registry keys to reset newtab and homepage to default
Add-Content $FileName "Set-ItemProperty -Path 'HKCU:\Software\Policies\Google\Chrome' -Name 'NewTabPageLocation' -Value ''
`nSet-ItemProperty -Path 'HKCU:\Software\Policies\Google\Chrome' -Name 'HomepageLocation' -Value ''
`nSet-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Edge' -Name 'NewTabPageLocation' -Value ''
`nSet-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Edge' -Name 'HomepageLocation' -Value ''"
# $FileName = "$($FolderName)\runPS.vbs"
# if(!(Test-Path $FileName)) {
#     New-Item $FileName -ItemType File
#     Clear-Content $FileName
# }

# # Create vbs file to run ps file
# Add-Content $FileName "Set WshShell = CreateObject(""WScript.Shell"")`nWshShell.Run ""powershell.exe -ExecutionPolicy Bypass -File $($FolderName)\set-ChromePolicies.ps1"", 0, False"

# create scheduled task to run ps file every hour cmd /c start /min "" powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File $($FolderName)\set-ChromePolicies.ps1
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -noProfile -noInteractive -File $($FolderName)\set-ChromePolicies.ps1"
$taskTrigger = New-ScheduledTaskTrigger -AtLogOn
$taskTrigger2 = New-ScheduledTaskTrigger -Daily -At 12am
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType "S4U" -RunLevel Highest
$task = Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger, $taskTrigger2 -Settings $settings -Principal $principal -Force -TaskName "ResetChromeEdgePolicies" -Description "Reset Chrome and Edge Policies"
$task.Triggers[1].Repetition.Duration = "P1D"
$task.Triggers[1].Repetition.Interval = "PT1H"
$task | Set-ScheduledTask