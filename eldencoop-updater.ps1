function main {
    # Load Windows Forms assembly for message boxes
    Add-Type -AssemblyName System.Windows.Forms

    # Enable script debugging
    $DebugPreference = "Continue"

    # Configuration
    $config = @{
        ServerPassword = "123456Pi."  # Replace with your actual password
    }
    Write-Debug "Server password set!"

    # Show form to select game path
    $global:game_path = Show-Form
    if ($global:game_path) {
        Write-Debug "Game path set to $global:game_path"

        # Run the update version function with the password and game path parameters
        update_version -serverPassword $config.ServerPassword -gamePath $global:game_path

        # Run the game execution function
        ejecute_game -gamePath $global:game_path
    } else {
        Write-Output "Game path selection was canceled or no path was entered."
    }
}

function Show-Form {
    # Load Windows Forms assembly for message boxes and form components
    Add-Type -AssemblyName System.Windows.Forms

    # Create and configure the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Select Game Path"
    $form.Size = New-Object System.Drawing.Size(400, 200)

    # Create and configure the label
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Game Path:"
    $label.Size = New-Object System.Drawing.Size(350, 20)
    $label.Location = New-Object System.Drawing.Point(20, 20)
    $form.Controls.Add($label)

    # Create and configure the text box with default value
    $textbox = New-Object System.Windows.Forms.TextBox
    $textbox.Text = "C:\Program Files (x86)\Steam\steamapps\common\ELDEN RING\Game"
    $textbox.Size = New-Object System.Drawing.Size(350, 20)
    $textbox.Location = New-Object System.Drawing.Point(20, 50)
    $form.Controls.Add($textbox)

    # Create and configure the browse button
    $button = New-Object System.Windows.Forms.Button
    $button.Text = "Browse"
    $button.Size = New-Object System.Drawing.Size(75, 23)
    $button.Location = New-Object System.Drawing.Point(20, 80)
    $form.Controls.Add($button)

    # Add a folder browser dialog
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

    # Add an event handler for the button click event
    $button.Add_Click({
        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $textbox.Text = $folderBrowser.SelectedPath
        }
    })

    # Create and configure the OK button
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Size = New-Object System.Drawing.Size(75, 23)
    $okButton.Location = New-Object System.Drawing.Point(295, 80)
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($okButton)

    # Show the form
    $form.AcceptButton = $okButton
    $form.StartPosition = "CenterScreen"
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $textbox.Text -ne "") {
        return $textbox.Text
    } else {
        return $null
    }
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

function Create-Shortcut {
    param (
        [string]$targetPath,
        [string]$shortcutPath,
        [string]$startInPath
    )
    Write-Debug "Creating shortcut for $targetPath at $shortcutPath"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $targetPath
    $shortcut.WorkingDirectory = $startInPath
    $shortcut.Save()
    Write-Debug "Shortcut created successfully"
}

function update_version {
    param (
        [string]$serverPassword,
        [string]$gamePath
    )
    try {
        Write-Debug "Update version function started"
        
        # Config paths and URLs
        $destPath = $gamePath
        $seamlessCoopPath = "$destPath\SeamlessCoop"
        $settingsFilePath = "$seamlessCoopPath\ersc_settings.ini"
        $apiUrl = "https://api.github.com/repos/LukeYui/EldenRingSeamlessCoopRelease/releases/latest"
        $tempZipPath = "$env:TEMP\ersc.zip"
        $tempExtractPath = "$env:TEMP\ersc"
        
        Write-Debug "Paths and URLs configured"
        
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
        Update-SettingsFile -filePath $settingsFilePath -password $serverPassword

        # Create shortcut on desktop
        $shortcutName = "EldenCoop$version.lnk"
        $desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), $shortcutName)
        Create-Shortcut -targetPath "$destPath\ersc_launcher.exe" -shortcutPath $desktopPath -startInPath $destPath

        # Success message
        [System.Windows.Forms.MessageBox]::Show("Updated to version: $version.`nStart game", "Starting Server: $serverPassword", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        Write-Debug "Update version function completed successfully"
    } catch {
        # Error message
        Write-Error "An unexpected error occurred: $_"
        [System.Windows.Forms.MessageBox]::Show("An unexpected error occurred: $_", "Starting Server: $serverPassword", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        Write-Debug "Update version function encountered an error: $_"
    }
}

function ejecute_game {
    param (
        [string]$gamePath
    )

    # Define the path to the game executable
    $gameExecutable = "$gamePath\ersc_launcher.exe"
    $startPath = $gamePath

    # Check if the game executable exists
    if (-Not (Test-Path $gameExecutable)) {
        Write-Output "Game executable not found at $gameExecutable"
        return
    }

    try {
        # Run the game executable with the start path set
        Write-Output "Starting the game..."
        Start-Process -FilePath $gameExecutable -WorkingDirectory $startPath
        Write-Output "Game started successfully."
    } catch {
        Write-Error "Failed to start the game: $_"
    }
}

# Call the main function
main

# Close script
exit
