#######################################################
# Update AnyConnect Adapter Interface Metric for WSL2 #
#######################################################

$taskName = 'WSL Update Interface Metric'
$taskExists = Get-ScheduledTask | Where-Object {$_.TaskPath -eq '\WSL\' -and $_.TaskName -eq "$taskName"}

If ($taskExists) {
  Unregister-ScheduledTask -TaskPath '\WSL\' -TaskName "$taskName" -Confirm:$false
}

$action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
  -Argument '-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File %USERPROFILE%\wsl\scripts\setCiscoVpnMetric.ps1'

$eventIDs = 2039,2041
$triggers = Foreach ($eventID in $eventIDs) {
  $CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger `
    -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
  $trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
  $trigger.Subscription = @"
<QueryList>
  <Query Id="0" Path="Cisco AnyConnect Secure Mobility Client">
    <Select Path="Cisco AnyConnect Secure Mobility Client">*[System[Provider[@Name='acvpnagent'] and EventID=$eventID]]</Select>
  </Query>
</QueryList>
"@
  $trigger.Enabled = $True
  $trigger
}

$userId = (New-Object System.Security.Principal.NTAccount($env:Username)).Translate([System.Security.Principal.SecurityIdentifier]).value
$principal = New-ScheduledTaskPrincipal -RunLevel Highest -UserId $userId
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
  
Register-ScheduledTask -Action $action -Trigger $triggers -TaskName "WSL\$taskName" `
  -Principal $principal -Settings $settings `
  -Description "Update AnyConnect Adapter Interface Metric for WSL2"


################################
# Update DNS in WSL2 Linux VMs #
################################

$taskName = 'WSL Update DNS'
$taskExists = Get-ScheduledTask | Where-Object {$_.TaskPath -eq '\WSL\' -and $_.TaskName -eq "$taskName"}

If ($taskExists) {
  Unregister-ScheduledTask -TaskPath '\WSL\' -TaskName "$taskName" -Confirm:$false
}

$action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
  -Argument '-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File %USERPROFILE%\wsl\scripts\setWslDns.ps1'

$eventIDs = 2039,2010,2061,2041
$triggers = Foreach ($eventID in $eventIDs) {
  $CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger `
    -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
  $trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
  $trigger.Subscription = @"
<QueryList>
  <Query Id="0" Path="Cisco AnyConnect Secure Mobility Client">
    <Select Path="Cisco AnyConnect Secure Mobility Client">*[System[Provider[@Name='acvpnagent'] and EventID=$eventID]]</Select>
  </Query>
</QueryList>
"@
  $trigger.Enabled = $True
  $trigger
}

$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
  
Register-ScheduledTask -Action $action -Trigger $triggers -TaskName "WSL\$taskName" -Settings $settings `
  -Description "Update DNS in WSL2 Linux VMs"

