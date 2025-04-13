##SetJabraDefault.ps1
#Install the AudioDeviceCmdlets Powershell module from PowerShell Gallery
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module -Name AudioDeviceCmdlets -Force -Verbose
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted
#Disable Realtek Audio device/s (OPTIONAL)
Get-PnpDevice | where FriendlyName -like "*Realtek*Audio*" | where Class -eq "AudioEndPoint" | Disable-PnpDevice
#Search for Jabra headset and set it as default speakers and microphone
Get-AudioDevice -List | where Type -like "Playback" | where name -like "*Jabra*" | Set-AudioDevice -Verbose
Get-AudioDevice -List | where Type -like "Recording" | where name -like "*Jabra*" | Set-AudioDevice -Verbose
#Ensure that microphone is not muted
Set-AudioDevice -RecordingMute -0
