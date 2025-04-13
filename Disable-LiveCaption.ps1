#Disable_Live_Caption_1_7.ps1
#Author: James Romeo Gaspar
#OG: 1.0 5May2023
#Revision: 1.3 24Apr2023 : Updated to include all current (and future) Windows profiles.
#Revision: 1.4 24Apr2023 : Added error checking for profiles that do not have the local state file.
#Revision: 1.5 26Apr2023 : Added error checking if browser property in the local state file is incomplete.
#Revision: 1.6a 10May2023 : Added line to start chrome to force create the appdata folders for new user logins to machine
#Revision: 1.7 17May2023 : Changed path/file to check and added line to add browser property on last state file

$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$chrome_laststate_path = Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data\Local State'

Start-Sleep -Seconds 10
if(!(Test-Path -Path $chrome_laststate_path -PathType Leaf)){
    Start-Process -FilePath $chromePath -ArgumentList "--start-minimized"
    Start-Sleep -Seconds 10
    if(Get-Process -Name "chrome" -ErrorAction SilentlyContinue){
        Stop-Process -Name chrome -Force
    }
}

$user_profiles = Get-ChildItem "C:\Users" -Directory
$successCount = 0
$disabledCount = 0
$errorCount = 0

foreach ($user_profile in $user_profiles) {
    $chrome_user_profile_path = Join-Path -Path $user_profile.FullName -ChildPath "AppData\Local\Google\Chrome\User Data"

    if (Test-Path $chrome_user_profile_path) {
        $local_state_path = Join-Path -Path $chrome_user_profile_path -ChildPath "Local State"

        try {
            $local_state = Get-Content $local_state_path -ErrorAction Stop | ConvertFrom-Json
        } catch {
            $errorMessage = $_.Exception.Message
            #Write-Output "Failed to read Local State file for user $($user_profile.Name). Error message: $errorMessage"
            $errorCount++
            continue
        }

        if (-not $local_state.browser) {
            $local_state | Add-Member -MemberType NoteProperty -Name browser -Value @{enabled_labs_experiments=@()} -Force
        }
        elseif (-not $local_state.browser.enabled_labs_experiments) {
            $local_state.browser | Add-Member -MemberType NoteProperty -Name enabled_labs_experiments -Value @() -Force
        }

        $enabled_experiments = $local_state.browser.enabled_labs_experiments
        $experiment_to_disable = "enable-accessibility-live-caption@2"

        if ($enabled_experiments -contains $experiment_to_disable) {
            #Write-Output "Live Caption is already Disabled for user $($user_profile.Name)."
            $disabledCount++
        } else {
            $local_state.browser.enabled_labs_experiments += $experiment_to_disable
            $local_state_json = ConvertTo-Json $local_state -Depth 100
            try {
                Set-Content $local_state_path $local_state_json -ErrorAction Stop
                #Write-Output "Live Caption has been set to Disabled for user $($user_profile.Name). GChrome restart required."
                $successCount++
            } catch {
                $errorMessage = $_.Exception.Message
                #Write-Output "Failed to write to Local State file for user $($user_profile.Name). Error message: $errorMessage"
                $errorCount++
            }
        }
    }
}

Write-Output "Live Caption: newly disabled on $successCount, skipped on $errorCount, & already disabled on $disabledCount profile/s"
