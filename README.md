# WindowsTuningScripts

A collection of PowerShell scripts for customizing and optimizing Windows user experience, system behavior, and desktop appearance. These scripts are designed to help with both personal customization and enterprise-level tuning.

---

## Included Scripts

### [Disable-LiveCaption.ps1](./Disable-LiveCaption.ps1)
Disables the Live Captions accessibility feature in Windows to reduce resource usage and visual noise.

### [Disable-AutoMicMute.ps1](./Disable-AutoMicMute.ps1)
Prevents automatic microphone muting when switching audio devices or joining calls.

### [ModifyDO.ps1](./ModifyDO.ps1)
Toggles Delivery Optimization settings to reduce bandwidth usage on updates and app downloads.

### [BGWallpaper.ps1](./BGWallpaper.ps1)
Applies or sets a specific background wallpaper system-wide using a config path.

### [WallpaperInfoUpdate.ps1](./WallpaperInfoUpdate.ps1)
Updates the desktop wallpaper dynamically with overlays (hostname, IP, system info).

### [Get-Monitor-Serial.ps1](./Get-Monitor-Serial.ps1)
Retrieves monitor serial numbers from WMI queries — useful for inventory tracking.

### [Get-LocalUsers.ps1](./Get-LocalUsers.ps1)
Lists all local user accounts on the device, with enabled/disabled status.

### [Get-ChromeExperiments.ps1](./Get-ChromeExperiments.ps1)
Reads Chrome flags from the user’s configuration to report on active experiments.

### [Set-ChromeExperiments.ps1](./Set-ChromeExperiments.ps1)
Sets Chrome flags to tune performance and visual settings across multiple users.

---

## Usage

Each script is self-contained. Open PowerShell as Administrator and run:

```powershell 
.\ScriptName.ps1
```
Some scripts may prompt for elevated permissions or restart requirements.

---

## Notes
These scripts are tested on Windows 10 and 11.
Use responsibly in production environments. Always test before deploying broadly.

---

## Contributions
Pull requests are welcome! If you have additional tuning scripts or improvements, feel free to contribute.

---

## License
MIT License

