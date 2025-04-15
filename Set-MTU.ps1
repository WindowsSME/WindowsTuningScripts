# SetMTU.ps1
# Author: James Romeo Gaspar
# Date 04November2024
# Script to set MTU to preferred value

$targetMTU = 1300
$adapterDescriptionKeyword = "PANGP"
$adapter = Get-NetAdapter | Where-Object { $_.InterfaceDescription -like "*$adapterDescriptionKeyword*" }

if ($adapter) {
    $ipv4Interface = Get-NetIPInterface -InterfaceAlias Ethernet 3 -AddressFamily IPv4
    $ipv6Interface = Get-NetIPInterface -InterfaceAlias $adapter.Name -AddressFamily IPv6
    
    if ($ipv4Interface.NlMtu -ne $targetMTU) {
        Set-NetIPInterface -InterfaceAlias $adapter.Name -AddressFamily IPv4 -NlMtu $targetMTU
    }

    if ($ipv6Interface.NlMtu -ne $targetMTU) {
        Set-NetIPInterface -InterfaceAlias $adapter.Name -AddressFamily IPv6 -NlMtu $targetMTU
    }

    $updatedIPv4Interface = Get-NetIPInterface -InterfaceAlias $adapter.Name -AddressFamily IPv4
    $updatedIPv6Interface = Get-NetIPInterface -InterfaceAlias $adapter.Name -AddressFamily IPv6

    Write-Output "Updated MTU for $($adapter.Name) - IPv4: $($updatedIPv4Interface.NlMtu) | IPv6: $($updatedIPv6Interface.NlMtu)"
} else {
    Write-Output "No adapter found with description containing '$adapterDescriptionKeyword'."
}
