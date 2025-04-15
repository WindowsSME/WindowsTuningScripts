# WindowsTuningScripts

A collection of PowerShell scripts for customizing and optimizing Windows user experience, system behavior, and desktop appearance. These scripts are designed to help with both personal customization and enterprise-level tuning.

---

## Included Scripts

### System Tweaks & Performance

- [Disable-AutoMicMute.ps1](./Disable-AutoMicMute.ps1)  
  Prevents automatic microphone muting when switching audio devices or joining calls.

- [ModifyDO.ps1](./ModifyDO.ps1)  
  Toggles Delivery Optimization settings to reduce bandwidth usage during updates and app downloads.

- [Set-MTU.ps1](./Set-MTU.ps1)  
  Sets a custom MTU value (e.g. 1300) for VPN interfaces to optimize network performance and prevent fragmentation.

### Desktop Customization

- [BGWallpaper.ps1](./BGWallpaper.ps1)    
  Applies or sets a specific desktop wallpaper system-wide using a configuration path.

- [WallpaperInfoUpdate.ps1](./WallpaperInfoUpdate.ps1)    
  Updates the desktop wallpaper dynamically with overlays such as hostname, IP address, and other system info.

### Device & User Inventory

- [Get-Monitor-Serial.ps1](./Get-Monitor-Serial.ps1)  
  Retrieves monitor serial numbers via WMI — useful for inventory or asset tracking.

### Browser Configuration

- [Disable-LiveCaption.ps1](./Disable-LiveCaption.ps1)  
  Disables the Live Captions accessibility feature in Windows to reduce resource usage and visual noise.
  
- [Get-ChromeExperiments.ps1](./Get-ChromeExperiments.ps1)  
  Reads Chrome’s experimental flags from user config files and reports current settings.

- [Set-ChromeExperiments.ps1](./Set-ChromeExperiments.ps1)  
  Modifies Chrome flags to tune performance and visuals across multiple users or profiles.

### Security Checks

- [XDR-AppChecker.ps1](./XDR-AppChecker.ps1)  
  Verifies that required security applications or XDR agents are installed and running on the system.

- [XDR-ServerStatusCheck.ps1](./XDR-ServerStatusCheck.ps1)  
  Checks communication status or health of XDR/EDR services or backend endpoints.

- [Get-BitlockerStatus.ps1](./Get-BitlockerStatus.ps1)  
  Audits the BitLocker status of system drives and outputs recovery or encryption info for compliance tracking.

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

