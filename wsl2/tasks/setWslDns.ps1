$wslInterfaceIdx = Get-NetAdapter |
  Where-Object Name -Like "*WSL*" |
  Select-Object -ExpandProperty InterfaceIndex

$ciscoVpnInterfaceIdx = Get-NetAdapter |
  Where-Object {$_.InterfaceDescription -Match "Cisco AnyConnect"} |
  Select-Object -ExpandProperty InterfaceIndex

$windowsHostReachableIp = Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object InterfaceIndex -eq $ciscoVpnInterfaceIdx

if ($windowsHostReachableIp) {
  $mainInterfaceIdx = $ciscoVpnInterfaceIdx
  $mainInterfaceIp = Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $mainInterfaceIdx |
    Select-Object -ExpandProperty IPAddress
  $dnsServers = Get-DnsClientServerAddress -InterfaceIndex $mainInterfaceIdx |
    Select-Object -ExpandProperty ServerAddresses
} else {
  $mainInterfaceIdx = $wslInterfaceIdx
  $mainInterfaceIp = Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $mainInterfaceIdx |
    Select-Object -ExpandProperty IPAddress
  $dnsServers = $mainInterfaceIp
}

wsl.exe -d Ubuntu-20.04 -u root bash -c "
set -e;
chattr -i /etc/resolv.conf;
printf 'nameserver %s\n' $dnsServers > /etc/resolv.conf;
chattr +i /etc/resolv.conf"

wsl.exe -d Ubuntu-20.04 bash -c "
set -e;
mkdir -p ~/.bash_aliases;
echo 'export DISPLAY=${mainInterfaceIp}:0' > ~/.bash_aliases/wsl_x11.sh"
