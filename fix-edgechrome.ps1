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

# Get SID for current user
$sid = (([Security.Principal.WindowsIdentity]::GetCurrent()).User.Value)
# in ps file add code for setting chrome and edge registry keys to reset newtab and homepage to default
Clear-Content $FileName
Add-Content $FileName "if (!(test-path ""HKU:\"")) {New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS}
Set-ItemProperty -Path 'HKU:\$sid\Software\Policies\Google\Chrome' -Name 'NewTabPageLocation' -Value ''
Set-ItemProperty -Path 'HKU:\$sid\Software\Policies\Google\Chrome' -Name 'HomepageLocation' -Value ''
Set-ItemProperty -Path 'HKU:\$sid\Software\Policies\Microsoft\Edge' -Name 'NewTabPageLocation' -Value ''
Set-ItemProperty -Path 'HKU:\$sid\Software\Policies\Microsoft\Edge' -Name 'HomepageLocation' -Value ''"

# create scheduled task to run ps file every hour to reset chrome and edge registry keys
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $($FolderName)\set-ChromePolicies.ps1"
$taskTrigger = New-ScheduledTaskTrigger -AtLogOn
$taskTrigger2 = New-ScheduledTaskTrigger -Daily -At 12am
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$task = Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger, $taskTrigger2 -Settings $settings -Principal $principal -Force -TaskName "ResetChromeEdgePolicies" -Description "Reset Chrome and Edge Policies"
$task.Triggers[1].Repetition.Duration = "P1D"
$task.Triggers[1].Repetition.Interval = "PT1H"
$task | Set-ScheduledTask