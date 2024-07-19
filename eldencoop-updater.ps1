function Import-Config {
    param (
        [string]$configPath
    )
    Write-Debug "Importing configuration from $configPath"
    return Import-PowerShellDataFile -Path $configPath
}

function Get-ReleaseInfo {
    param (
        [string]$apiUrl
    )
    Write-Output "Obtaining the latest release information from GitHub..."
    Write-Debug "Fetching release information from $apiUrl"
    $releaseInfo = Invoke-RestMethod -Uri $apiUrl -Headers @{"User-Agent" = "Mozilla/5.0"}
    Write-Output "Release information obtained successfully."
    Write-Debug "Release information: $($releaseInfo | ConvertTo-Json -Depth 3)"
    return $releaseInfo
}

function Get-DownloadUrl {
    param (
        [array]$assets
    )
    Write-Debug "Searching for ersc.zip in the release assets"
    foreach ($asset in $assets) {
        if ($asset.name -eq "ersc.zip") {
            Write-Debug "Found ersc.zip with URL: $($asset.browser_download_url)"
            return $asset.browser_download_url
        }
    }
    throw "Could not find ersc.zip file in the latest release."
}

function Download-File {
    param (
        [string]$url,
        [string]$outputPath
    )
    Write-Debug "Downloading ersc.zip from $url to $outputPath"
    Invoke-WebRequest -Uri $url -OutFile $outputPath
    Write-Debug "Download completed"
}

function Extract-ZipFile {
    param (
        [string]$zipPath,
        [string]$extractPath
    )
    Write-Debug "Extracting $zipPath to $extractPath"
    if (Test-Path $extractPath) {
        Write-Debug "Removing existing directory $extractPath"
        Remove-Item -Recurse -Force $extractPath
    }
    Expand-Archive -Path $zipPath -DestinationPath $extractPath
    Write-Debug "Extraction completed"
}

function Copy-File {
    param (
        [string]$source,
        [string]$destination
    )
    Write-Debug "Copying file from $source to $destination"
    Copy-Item -Path $source -Destination $destination -Force
    Write-Debug "File copy completed"
}

function Copy-Folder {
    param (
        [string]$source,
        [string]$destination
    )
    Write-Debug "Copying folder from $source to $destination"
    Remove-Item -Recurse -Force $destination
    Copy-Item -Path $source -Destination $destination -Recurse -Force
    Write-Debug "Folder copy completed"
}

function Update-SettingsFile {
    param (
        [string]$filePath,
        [string]$password
    )
    Write-Debug "Updating settings file $filePath"
    $settingsContent = Get-Content -Path $filePath
    $updatedContent = $settingsContent -replace '(cooppassword\s*=\s*).*', "cooppassword = $password"
    Set-Content -Path $filePath -Value $updatedContent
    Write-Output "ersc_settings.ini file updated successfully."
    Write-Debug "Settings file updated with new password"
}

function Main {
    try {
        Write-Debug "Main function started"
        
        # Config paths and URLs
        $configPath = ".\config.psd1"
        $destPath = "C:\Program Files (x86)\Steam\steamapps\common\ELDEN RING\Game"
        $seamlessCoopPath = "$destPath\SeamlessCoop"
        $settingsFilePath = "$seamlessCoopPath\ersc_settings.ini"
        $apiUrl = "https://api.github.com/repos/LukeYui/EldenRingSeamlessCoopRelease/releases/latest"
        $tempZipPath = "$env:TEMP\ersc.zip"
        $tempExtractPath = "$env:TEMP\ersc"
        
        Write-Debug "Paths and URLs configured"
        
        # Import config
        $config = Import-Config -configPath $configPath

        # Get release info
        $releaseInfo = Get-ReleaseInfo -apiUrl $apiUrl
        $version = $releaseInfo.tag_name

        # Get download URL
        $downloadUrl = Get-DownloadUrl -assets $releaseInfo.assets

        # Download, extract, copy files and folders
        Download-File -url $downloadUrl -outputPath $tempZipPath
        Extract-ZipFile -zipPath $tempZipPath -extractPath $tempExtractPath
        Copy-File -source "$tempExtractPath\ersc_launcher.exe" -destination "$destPath\ersc_launcher.exe"
        Copy-Folder -source "$tempExtractPath\SeamlessCoop" -destination $seamlessCoopPath

        # Update settings file
        Update-SettingsFile -filePath $settingsFilePath -password $config.ServerPassword

        # Success message
        Write-Output "Update completed successfully. Updated version: $version."
        [System.Windows.Forms.MessageBox]::Show("Update completed successfully. Updated version: $version.", "Update Status", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        Write-Debug "Main function completed successfully"
    } catch {
        # Error message
        Write-Error "An unexpected error occurred: $_"
        [System.Windows.Forms.MessageBox]::Show("An unexpected error occurred: $_", "Update Status", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        Write-Debug "Main function encountered an error: $_"
    }
}

# Load Windows Forms assembly for message boxes
Add-Type -AssemblyName System.Windows.Forms

# Enable script debugging
$DebugPreference = "Continue"

# Run the main function
Main

# Close script
exit
