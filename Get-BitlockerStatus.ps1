#Author : James Romeo Gaspar
#Revision : 1.0 : 26August2022
#Revision : 1.1 : 13Mar2023 : Added encryption percentage (%)
#Revision : 1.2 : 3Jul2023 : Added Protection Status, enhanced code
$encryptionStatus = Get-BitLockerVolume -MountPoint C:
$encryptionPercentage = [math]::Round(($encryptionStatus.EncryptionPercentage),2)
Write-Output "$($encryptionStatus.VolumeStatus) ($encryptionPercentage%) Protection Status: $($encryptionStatus.ProtectionStatus) | $(Get-Date)"
