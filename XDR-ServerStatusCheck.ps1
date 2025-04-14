#sensor_xdr_check_server_status
#Author : James Romeo Gaspar
#OG 1.0 01Jul2023
#Revision 2.0 20Jul2023 : Revised to handle null values

$trapsPath = "C:\Program Files\Palo Alto Networks\Traps"
if (-not (Test-Path $trapsPath)) {
    Write-Output "XDR not Installed : $(Get-Date)"
    exit
}

$cytoolPath = Join-Path $trapsPath "cytool.exe"
$commandOutput = & $cytoolPath websocket query
$checkinOutput = & $cytoolPath checkin

function Get-ValueFromCommandOutput {
    param([string]$pattern)
    $match = $commandOutput | Select-String -Pattern $pattern
    if ($match) {
        return $match.Matches.Groups[1].Value
    }
    return "Null|Error"
}

$serverResult = Get-ValueFromCommandOutput -pattern 'server: (.+)'
if (![string]::IsNullOrEmpty($serverResult)) {
    $serverResult = $serverResult -replace '^wss://|^https://|^http://'
    $serverResult = $serverResult -replace '/operations/socket$'
}

$connected = Get-ValueFromCommandOutput -pattern "connected: (.+)"
$enabled = Get-ValueFromCommandOutput -pattern "enabled: (.+)"

Write-Output "Server: $serverResult | Connection: $connected | Enabled: $enabled : $(Get-Date)"
