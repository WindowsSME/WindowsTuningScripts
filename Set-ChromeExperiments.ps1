# ===============================
# Script Information
# ===============================
# Script Name: Set-ChromeExperiments.ps1
# Author: James Romeo Gaspar
# Date: 2025-03-12
# Version: 4.1.2
# 
# Changelog:
# - 2023-10-26 (v1.1) - Script derived from Live Caption disablement
# - 2024-10-16 (v3.0) - Revised to disable flag: enable-webusb-device-detection.
# - 2023-10-26 (v2.0) - Added 2 additional flags for disablement: enable-lens-image-translate and enable-lens-standalone.
# - 2024-10-16 (v3.0) - Revised to disable flag: enable-webusb-device-detection.
# - 2024-11-29 (v4.0) - Created two functions to split tasks: 1. Reset all flags, 2. Disable target experimental flags.
# - 2024-12-03 (v4.1.1) - Fixed JSON serialization, added validation points, and made code enhancements (g).
# - 2025-03-12 (V4.1.2) - Added inline comments and purpose & scope
# ===============================


# ===============================
# Purpose and Scope
# ===============================
# 
# Purpose:
# This PowerShell script manages Google experimental features across multiple user profiles.
# It includes the following functionalities:
# 
# 1. Start-ChromeMinimized - Launches Chrome in minimized mode and stops it after a specified timeout. This is for new profiles logging in to a machine.
# 2. Reset-ChromeExperiments - Resets all experimental Chrome flags (from chrome://flags) to default values for all user profiles.
# 3. Disable-ChromeExperiments - Disables specific experimental Chrome flags across all user profiles. In this case, it's enable-webusb-device-detection. 
# 
# Scope:
# - Target: All User Profiles on target machine
# - System Compatibility: Windows-based systems with Google Chrome installed.
# - Features:
#   - Ensuring Chrome starts in minimized mode
#   - Resetting all experimental Chrome experimental features to start with a clean slate.
#   - Disabling specific experimental flag enable-webusb-device-detection for security compliance.
# - Limitations:
#   - Does not work if Chrome is currently open upon script execution. 
#   - Does not work if Chrome is not installed
# 
# ===============================


function Start-ChromeMinimized {
    param (
        [string]$ChromePath = (Join-Path $env:ProgramFiles "Google\Chrome\Application\chrome.exe"),
        [string]$ChromeLastStatePath = (Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data\Local State'),
        [int]$TimeoutSeconds = 10
    )

    # Check if the Local State file exists to determine if Chrome has been launched before
    if (!(Test-Path -Path $ChromeLastStatePath -PathType Leaf)) {
        try {
            # Start Chrome in minimized mode
            Start-Process -FilePath $ChromePath -ArgumentList "--start-minimized"
            Write-Output "Chrome started minimized."
        } catch {
            Write-Error "Failed to start Chrome: $_"
            return
        }

        # Wait for the specified timeout before terminating Chrome
        Start-Sleep -Seconds $TimeoutSeconds

        # Find and stop the Chrome process
        $chromeProcess = Get-Process -Name "chrome" -ErrorAction SilentlyContinue
        if ($chromeProcess) {
            Stop-Process -Name "chrome" -Force
            Write-Output "Chrome stopped."
        }
    } else {
        # Optional logging for testing purposes
        Write-Output ""
        Write-Output "Chrome's Local State file already exists. [Test Mode]"
    }
}

function Reset-ChromeExperiments {
    $user_profiles = Get-ChildItem "C:\Users" -Directory
    $resetCount = 0
    $errorCount = 0

    foreach ($user_profile in $user_profiles) {
        # Construct path to the Chrome user profile directory
        $chrome_user_profile_path = Join-Path -Path $user_profile.FullName -ChildPath "AppData\Local\Google\Chrome\User Data"
        if (Test-Path $chrome_user_profile_path) {
            $local_state_path = Join-Path -Path $chrome_user_profile_path -ChildPath "Local State"

            if (Test-Path $local_state_path) {
                try {
                    # Read and parse the Local State JSON file
                    $local_state = Get-Content $local_state_path -ErrorAction Stop | ConvertFrom-Json
                } catch {
                    Write-Warning "Error reading Local State file for profile: $($user_profile.Name). Error: $($_.Exception.Message)"
                    $errorCount++
                    continue
                }

                # Reset experimental flags if they exist
                if ($local_state.browser -and $local_state.browser.enabled_labs_experiments) {
                    $local_state.browser.enabled_labs_experiments = @()
                }

                try {
                    # Convert back to JSON and save changes
                    $local_state_json = $local_state | ConvertTo-Json -Depth 10 -Compress
                    Set-Content -Path $local_state_path -Value $local_state_json -Encoding UTF8 -Force
                    $resetCount++
                } catch {
                    Write-Warning "Error writing to Local State file for profile: $($user_profile.Name). Error: $($_.Exception.Message)"
                    $errorCount++
                }
            } else {
                Write-Warning "Local State file not found for profile: $($user_profile.Name)"
                $errorCount++
            }
        }
    }

    # Optional logging for testing purposes
    Write-Output ""
    Write-Output "Chrome flags reset to default values for $resetCount profile(s). Errors occurred in $errorCount profile(s). [Test Mode]"
}

function Disable-ChromeExperiments {
    param (
        [string]$BasePath = "C:\Users",
        [string[]]$ExperimentsToDisable = @("enable-webusb-device-detection@2")
    )

    $user_profiles = Get-ChildItem -Path $BasePath -Directory
    $successCount = 0
    $disabledCount = 0
    $errorCount = 0

    foreach ($user_profile in $user_profiles) {
        $chrome_user_profile_path = Join-Path -Path $user_profile.FullName -ChildPath "AppData\Local\Google\Chrome\User Data"
        if (Test-Path $chrome_user_profile_path) {
            $local_state_path = Join-Path -Path $chrome_user_profile_path -ChildPath "Local State"

            try {
                # Read Local State JSON file
                $local_state = Get-Content $local_state_path -ErrorAction Stop | ConvertFrom-Json
            } catch {
                Write-Verbose "Failed to read Local State file for user $($user_profile.Name). Error: $($_.Exception.Message)"
                $errorCount++
                continue
            }

            # Ensure experimental flags property exists in the JSON structure
            if (-not $local_state.browser) {
                $local_state | Add-Member -MemberType NoteProperty -Name browser -Value @{enabled_labs_experiments=@()} -Force
            } elseif (-not $local_state.browser.enabled_labs_experiments) {
                $local_state.browser | Add-Member -MemberType NoteProperty -Name enabled_labs_experiments -Value @() -Force
            }

            $enabled_experiments = $local_state.browser.enabled_labs_experiments

            # Iterate through each experiment to disable
            $ExperimentsToDisable | ForEach-Object {
                $experiment_to_disable = $_

                if ($enabled_experiments -contains $experiment_to_disable) {
                    Write-Verbose "$experiment_to_disable is already disabled for user $($user_profile.Name)."
                    $disabledCount++
                } else {
                    $local_state.browser.enabled_labs_experiments += $experiment_to_disable
                    $local_state_json = ConvertTo-Json $local_state -Depth 100
                    try {
                        Set-Content -Path $local_state_path -Value $local_state_json -ErrorAction Stop
                        Write-Verbose "$experiment_to_disable has been set to disabled for user $($user_profile.Name). Google Chrome restart required."
                        $successCount++
                    } catch {
                        Write-Verbose "Failed to write to Local State file for user $($user_profile.Name). Error: $($_.Exception.Message)"
                        $errorCount++
                    }
                }
            }
        }
    }

    # Display results summary
    Write-Output ""
    Write-Output "Experimental Flags: newly disabled on $successCount, skipped on $errorCount, & already disabled on $disabledCount profile(s)."
    Write-Output ""
}

# Execute the functions in order
Start-ChromeMinimized
Reset-ChromeExperiments 
Disable-ChromeExperiments
