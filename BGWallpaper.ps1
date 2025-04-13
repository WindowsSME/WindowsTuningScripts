<#
Set BG Wallpaper with System Information
Author: James Romeo Gaspar
Version: 1.0 : Original code : | 22 March 2023
Revision: 2.0 : Added DNS and Current User, enhanced display | 10 August 2023
#>

$currentWallpaperPath = (Get-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'Wallpaper').Wallpaper
$directoryPath = 'C:\BGWallpaper'
if (-not (Test-Path $directoryPath)) {
    New-Item -ItemType Directory -Path $directoryPath | Out-Null
}
$originalPath = Join-Path $directoryPath 'OriginalWallpaper.jpg'
if (-not (Test-Path $originalPath)) {
    if ($currentWallpaperPath.StartsWith('C:\Windows\Web\Wallpaper\Windows\')) {
        $sourcePath = $currentWallpaperPath.Substring(0, $currentWallpaperPath.LastIndexOf('\'))
        $imagename = Split-Path -Path $currentWallpaperPath -Leaf
        robocopy $sourcePath $directoryPath $imagename OriginalWallpaper.jpg /NFL /NDL /NJH /NJS /nc /ns /np > $null
        Join-Path -Path $directoryPath -ChildPath $imagename | Rename-Item -NewName "OriginalWallpaper.jpg"

    }
    else {
        Copy-Item -Path $currentWallpaperPath -Destination $originalPath -Force
    }
} elseif (-not (Test-Path $currentWallpaperPath)) {
    Copy-Item -Path $originalPath -Destination $currentWallpaperPath -Force -ErrorAction SilentlyContinue
}
$destinationPath = Join-Path $directoryPath 'CurrentWallpaper.jpg'
Copy-Item -Path $currentWallpaperPath -Destination $destinationPath -Force
$imagePath = "C:\BGWallpaper\CurrentWallpaper.jpg"
$outputPath = "C:\BGWallpaper\ModifiedWallpaper.jpg"
if (-not ([System.Management.Automation.PSTypeName]'Wallpaper').Type) {
    Add-Type @"
        using System.Runtime.InteropServices;
        public class Wallpaper
        {
            [DllImport("user32.dll", CharSet=CharSet.Auto)]
            static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
            public static void SetWallpaper(string path)
            {
                SystemParametersInfo(20, 0, path, 10);
            }
        }
"@
}
$image = [System.Drawing.Image]::FromFile($imagePath)
$maxWidth = 1920
$maxHeight = 1080
$newWidth = $image.Width
$newHeight = $image.Height
if ($newWidth -gt $maxWidth) {
    $newWidth = $maxWidth
    $newHeight = [int]($image.Height * ($maxWidth / $image.Width))
}
if ($newHeight -gt $maxHeight) {
    $newHeight = $maxHeight
    $newWidth = [int]($image.Width * ($maxHeight / $image.Height))
}
$bitmap = New-Object System.Drawing.Bitmap $newWidth, $newHeight
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.DrawImage($image, 0, 0, $newWidth, $newHeight)
$hostname = hostname
$serial = (Get-WmiObject win32_bios).serialnumber
$ipAddress = (($getIPaddresses = (Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -ne $null -and $_.IPEnabled }).IPAddress -match '\d+\.\d+\.\d+\.\d+') -join ' | ')
$dns = (Get-DnsClientServerAddress | Select-Object -ExpandProperty ServerAddresses | Where-Object { $_ -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' }) -join ' | '
$mac = (Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -ne $null }).MACAddress -join ' | '
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$text = "Hostname: $hostname`r`nSerial: $serial`r`nIP address: $ipAddress`r`nDNS: $dns`r`nMAC: $mac`r`nCurrent User: $currentUser"
$font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$textSize = $graphics.MeasureString($text, $font)
$x = ($newWidth - $textSize.Width) - 50
$y = 50
$point = New-Object System.Drawing.PointF($x, $y)
$textToRemove = "Hostname:"
if ($currentWallpaperPath -match $textToRemove) {
    $pattern = "($textToRemove).*(\r\n){3}"
    $newContent = $text + "`r`n"
    $currentContent = Get-Content $currentWallpaperPath -Raw
    $newWallpaperContent = $currentContent -replace $pattern, $newContent
    Set-Content $currentWallpaperPath -Value $newWallpaperContent
}
else {
    $graphics.DrawString($text, $font, $brush, $point)
    $bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)

    <# **** CRITICAL LINES AHEAD :) **** #>

    #Remove # below and add # to next line to SET Wallpaper
        [Wallpaper]::SetWallpaper($outputPath)

    #Remove # below and add # to previous line to REVERT Wallpaper
        #[Wallpaper]::SetWallpaper($originalPath)

    <# ************ BREAK ************ #>
}
$graphics.Dispose()
$image.Dispose()
$bitmap.Dispose()
$font.Dispose()
$brush.Dispose()
