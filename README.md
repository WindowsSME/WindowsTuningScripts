# WindowsTuningScripts

A collection of PowerShell scripts for customizing and optimizing Windows user experience, system behavior, and desktop appearance. These scripts are designed to help with both personal customization and enterprise-level tuning.

---

## Included Scripts

### [Disable-LiveCaption.ps1](./Disable-LiveCaption.ps1)
Disables the Live Captions accessibility feature in Windows.

### [Disable-AutoMicMute.ps1](./Disable-AutoMicMute.ps1)
Prevents automatic microphone muting under specific Windows scenarios (e.g., switching audio devices).

### [ModifyDO.ps1](./ModifyDO.ps1)
Adjusts Delivery Optimization settings to reduce bandwidth usage and improve update performance.

### [BGWallpaper.ps1](./BGWallpaper.ps1)
Applies or sets a system-wide desktop wallpaper based on specified configuration.

### [WallpaperInfoUpdate.ps1](./WallpaperInfoUpdate.ps1)
Dynamically updates wallpaper with information overlays such as hostname, IP address, or system status.

### [Get-Monitor-Serial.ps1](./Get-Monitor-Serial.ps1)
Retrieves serial numbers for connected monitors using WMI queries. Useful for asset management.

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

