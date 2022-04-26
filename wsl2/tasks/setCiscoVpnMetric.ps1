# Administrator permissions are required to update an IP interface
# Thus, we start a new elevated PowerShell process
# (unfortunately, this can't be done by configuring the scheduled task on company computers...)
Start-Process -FilePath powershell.exe -Verb runAs -ArgumentList (
"Write-Host 'Reconfiguring Cisco VPN interface...'; " +
"Get-NetAdapter " +
"  | Where-Object {`$_.InterfaceDescription -Match 'Cisco AnyConnect'} " +
"  | Set-NetIPInterface -InterfaceMetric 6000; " +
"Write-Host 'Cisco VPN interface reconfigured.'; "
)
