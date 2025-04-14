# Script Name: Get-ChromeExperiments.ps1
# Author: James Romeo Gaspar
# Date: March 11, 2025
# Description: This script scans user profiles for enabled Chrome experiments and reports their status.
# Purpose: To identify which user profiles have Chrome experiments enabled and report if any unauthorized experiments are active.
# Scope: This script checks all user profiles in the specified base directory and analyzes their Chrome "Local State" file to determine experiment settings.


function Get-ChromeExperiments {
    param (
        [string]$BasePath = "C:\Users"  # Define the base directory where user profiles are stored
    )

    # Get a list of all user profile directories
    $user_profiles = Get-ChildItem -Path $BasePath -Directory
    
    # Initialize flags and arrays to track experiment statuses
    $all_ok = $true
    $any_experiments = $false 
    $profiles_with_other_experiments = @()  # Stores profiles with experiments other than the allowed one
    $empty_profiles = @()  # Stores profiles with no experiments enabled
    
    foreach ($user_profile in $user_profiles) {
        # Construct the path to the Chrome user profile data directory
        $chrome_user_profile_path = Join-Path -Path $user_profile.FullName -ChildPath "AppData\Local\Google\Chrome\User Data"

        # Check if the Chrome profile exists
        if (Test-Path $chrome_user_profile_path) {
            # Construct the path to the "Local State" file, which contains experiment settings
            $local_state_path = Join-Path -Path $chrome_user_profile_path -ChildPath "Local State"
            
            try {
                # Read the Local State JSON file and parse it
                $local_state = Get-Content $local_state_path -ErrorAction Stop | ConvertFrom-Json
                
                # Check if experiments are enabled in the browser settings
                if ($local_state.browser -and $local_state.browser.enabled_labs_experiments) {
                    $enabled_experiments = $local_state.browser.enabled_labs_experiments
                    
                    # If no experiments are enabled, add profile to empty list and continue
                    if ($enabled_experiments.Count -eq 0) {
                        $empty_profiles += $user_profile.Name
                        continue
                    } 
                    
                    $any_experiments = $true  # Mark that at least one profile has experiments enabled
                    
                    # Check if the enabled experiments are different from "enable-webusb-device-detection@2"
                    if ($enabled_experiments -ne @("enable-webusb-device-detection@2")) {
                        $profiles_with_other_experiments += $user_profile.Name  # Store profile name
                        $all_ok = $false  # Flag as not all okay
                    }
                } else {
                    # If no experiment data is found, consider it an empty profile
                    $empty_profiles += $user_profile.Name
                }
            } catch {
                # Catch any errors while reading or parsing the Local State file
                $errorMessage = $_.Exception.Message
                Write-Verbose "Failed to read Local State file for user $($user_profile.Name). Error message: $errorMessage"
            }
        }
    }
    
    # Prepare output messages based on collected data
    $output = @()
    
    if ($empty_profiles.Count -eq $user_profiles.Count) {
        $output += "Experiments: Empty"  # No experiments enabled in any profiles
    } else {
        if ($profiles_with_other_experiments.Count -gt 0) {
            # List profiles that have experiments other than the allowed one
            $output += "Profiles with other flags active: $($profiles_with_other_experiments -join ", ")"
        }
        if ($empty_profiles.Count -gt 0) {
            # List profiles that have no experiments enabled
            $output += "Profiles with no experiments: $($empty_profiles -join ", ")"
        }
        if ($all_ok -and $profiles_with_other_experiments.Count -eq 0) {
            $output += "Experiments: OK"  # All profiles have only the allowed experiment enabled
        }
    }
    
    # Output the results
    Write-Output ($output -join " | ")
}

# Execute the function
Get-ChromeExperiments
