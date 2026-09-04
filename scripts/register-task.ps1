# register-task.ps1 - one-time: registers the Windows Task Scheduler job from config. Run in your own terminal.
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "..\config.ps1")
$rd = Join-Path $PSScriptRoot "run-daily.ps1"
$days = $Config.Days | ForEach-Object { [System.DayOfWeek]$_ }
$action  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument ('-NoProfile -ExecutionPolicy Bypass -File "' + $rd + '"')
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $days -At ([datetime]$Config.Time)
Register-ScheduledTask -TaskName "LinkedInEngagementAgent" -Action $action -Trigger $trigger -Description "Daily LinkedIn engagement digest" -Force | Out-Null
$t = Get-ScheduledTask -TaskName "LinkedInEngagementAgent"
$t.Settings.StartWhenAvailable = $true          # catch up if the machine was off at run time
Set-ScheduledTask -TaskName "LinkedInEngagementAgent" -Settings $t.Settings | Out-Null
Write-Output ("Registered 'LinkedInEngagementAgent' for " + ($Config.Days -join "/") + " at " + $Config.Time + " (catches up if the machine was off).")
