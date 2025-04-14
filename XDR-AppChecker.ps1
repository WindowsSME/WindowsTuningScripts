#Author : James Romeo Gaspar
#OG 1.0 28Feb2023
#Revision 2.0 29Jun2023 : Added Last successful checkin Date/Time ; Force checkin
$XDRsnifferUn = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -like "*Cortex XDR*" | Select-Object -First 1 DisplayVersion, InstallDate
$XDRsnifferDeux = Get-WmiObject -Class Win32_Product | where Name -like '*Cortex XDR*' | select -First 1 Version, InstallDate
$service = Get-Service -Name cyserver -ErrorAction SilentlyContinue

if (($XDRsnifferUn -ne $null) -and ($XDRsnifferUn.DisplayVersion -ne $null)) {
    $version = $XDRsnifferUn.DisplayVersion
    $instdate = $XDRsnifferUn.InstallDate
} elseif (($XDRsnifferDeux -ne $null) -and ($XDRsnifferDeux.Version -ne $null)) {
    $version = $XDRsnifferDeux.Version
    $instdate = $XDRsnifferDeux.InstallDate
} else {
    Write-Output "No XDR Installed : $(Get-Date)"
    return
}

if ($service -eq $null) {
    Write-Output "Version $version, Installed $instdate, Service is not found : $(Get-Date)"
    return
}

$servstatus = $service.Status
$servtype = $service.StartType

if ($servstatus -eq 'Stopped') {
    Start-Service -Name cyserver
    $servstatus = 'Running'
    $servtype = $service.StartType
} elseif ($servstatus -eq 'Disabled') {
    Set-Service -Name cyserver -StartupType Automatic
    Start-Service -Name cyserver
    $servstatus = 'Running'
    $servtype = $service.StartType
}

$trapsPath = "C:\Program Files\Palo Alto Networks\Traps"
$cytoolPath = Join-Path $trapsPath "cytool.exe"

if (Test-Path $cytoolPath) {
    $lastCheckinOutput = (& $cytoolPath last_checkin)[1]

    if ($lastCheckinOutput -match '(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)') {
        $lastCheckinTime = [DateTime]::ParseExact($matches[0], "yyyy-MM-ddTHH:mm:ssZ", $null)
        $timeSinceLastCheckin = (Get-Date) - $lastCheckinTime

    } else {
        Write-Output "Traps last check-in time: $lastCheckinOutput"
    }
    $checkinOutput = & $cytoolPath checkin
} else {
    Write-Output "Traps not found at $trapsPath"
}

if ($servstatus -eq 'Running') {
    Write-Output "Version $version, Installed $instdate, Service Running, LCheckIn $($matches[0])UTC : $(Get-Date)"
} elseif ($servstatus -eq 'Paused') {
    Write-Output "Version $version, Installed $instdate, Service Paused, LCheckIn $$($matches[0])UTC : $(Get-Date)"
} else {
    Write-Output "Version $version, Installed $instdate, Service is in an unknown state, LCheckIn $($matches[0]) UTC : $(Get-Date)"
}
