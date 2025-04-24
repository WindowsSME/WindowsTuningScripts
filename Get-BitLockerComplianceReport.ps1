<#
.SYNOPSIS
    Generates a BitLocker compliance report for all drives on the system.

.DESCRIPTION
    This script retrieves the BitLocker volume status for all mounted drives.
    It checks whether each drive is encrypted, the encryption method used,
    and whether a recovery key is present. The output is displayed in a table,
    and optionally exported to a CSV file.

.PARAMETER CsvPath
    Optional. The path to a CSV file where the results will be exported.

.EXAMPLE
    Get-BitLockerComplianceReport -CsvPath "C:\Temp\BitLocker_Audit.csv"

.NOTES
    Author: James Romeo Gaspar
    Date: 24 April 2025
#>

function Get-BitLockerComplianceReport {
    [CmdletBinding()]
    param(
        [string]$CsvPath = ""
    )

    # Initialize an array to store report results
    $results = @()

    # Get all BitLocker volumes on the system
    $volumes = Get-BitLockerVolume

    foreach ($vol in $volumes) {
        # Extract key volume details
        $mountPoint = $vol.MountPoint
        $status = $vol.ProtectionStatus
        $encryptionMethod = $vol.EncryptionMethod
        $keyProtector = $vol.KeyProtector
        $recoveryKey = $null

        # Check for the presence of a recovery key
        foreach ($protector in $keyProtector) {
            if ($protector.KeyProtectorType -eq 'RecoveryPassword') {
                $recoveryKey = $protector.RecoveryPassword
            }
        }

        # Determine encryption and recovery key availability
        $isEncrypted = if ($status -eq 'On') { $true } else { $false }
        $recoveryAvailable = if ($recoveryKey) { $true } else { $false }

        # Create and store a report object for the current volume
        $results += [PSCustomObject]@{
            Drive              = $mountPoint
            Encrypted          = $isEncrypted
            EncryptionMethod   = $encryptionMethod
            RecoveryKeyFound   = $recoveryAvailable
            RecoveryKey        = $recoveryKey
        }
    }

    # Display the results as a formatted table in the console
    $results | Format-Table -AutoSize

    # Export the results to a CSV file if a path is provided
    if ($CsvPath -ne "") {
        try {
            $results | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8
            Write-Output "Results exported to $CsvPath"
        } catch {
            Write-Error "Failed to export to CSV: $_"
        }
    }
}

# Example usage
Get-BitLockerComplianceReport -CsvPath "C:\Temp\BitLocker_Audit.csv"
