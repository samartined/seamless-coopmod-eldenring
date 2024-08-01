function Main {
    Add-Type -AssemblyName System.Windows.Forms
    $DebugPreference = "Continue"
    
    $configFileName = ".\eldencoop2.json"
    $config = Initialize-Config -configFileName $configFileName
    
    if (-not $config.GamePath) {
        $config.GamePath = Show-GamePathForm
        if ($config.GamePath) {
            Save-Config -config $config -configFileName $configFileName
        } else {
            Write-Output "Game path selection was canceled or no path was entered."
            return
        }
    }
    
    Update-Version -serverPassword $config.ServerPassword -gamePath $config.GamePath
    Execute-Game -gamePath $config.GamePath
}

function Initialize-Config {
    param ([string]$configFileName)
    
    $defaultConfig = @{
        ServerPassword = "123456Pi."
        GamePath = "C:\Program Files (x86)\Steam\steamapps\common\ELDEN RING\Game"
    }
    
    if (Test-Path $configFileName) {
        return Get-Content -Path $configFileName | ConvertFrom-Json
    } else {
        return $defaultConfig
    }
}

function Save-Config {
    param (
        [hashtable]$config,
        [string]$configFileName
    )
    $config | ConvertTo-Json | Set-Content -Path $configFileName
}

function Show-GamePathForm {
    Add-Type -AssemblyName System.Windows.Forms

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Select Game Path"
    $form.Size = New-Object System.Drawing.Size(400, 250)
    
    $labelGamePath = New-Object System.Windows.Forms.Label
    $labelGamePath.Text = "Game Path:"
    $labelGamePath.Size = New-Object System.Drawing.Size(350, 20)
    $labelGamePath.Location = New-Object System.Drawing.Point(20, 20)
    $form.Controls.Add($labelGamePath)
    
    $textboxGamePath = New-Object System.Windows.Forms.TextBox
    $textboxGamePath.Size = New-Object System.Drawing.Size(350, 20)
    $textboxGamePath.Location = New-Object System.Drawing.Point(20, 50)
    $form.Controls.Add($textboxGamePath)
    
    $buttonBrowse = New-Object System.Windows.Forms.Button
    $buttonBrowse.Text = "Browse"
    $buttonBrowse.Size = New-Object System.Drawing.Size(75, 23)
    $buttonBrowse.Location = New-Object System.Drawing.Point(20, 80)
    $form.Controls.Add($buttonBrowse)
    
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $buttonBrowse.Add_Click({
        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $textboxGamePath.Text = $folderBrowser.SelectedPath
        }
    })
    
    $labelServerName = New-Object System.Windows.Forms.Label
    $labelServerName.Text = "Server name:"
    $labelServerName.Size = New-Object System.Drawing.Size(350, 20)
    $labelServerName.Location = New-Object System.Drawing.Point(20, 120)
    $form.Controls.Add($labelServerName)
    
    $textboxServerName = New-Object System.Windows.Forms.TextBox
    $textboxServerName.Text = "MyServername"
    $textboxServerName.ForeColor = [System.Drawing.Color]::Gray
    $textboxServerName.Size = New-Object System.Drawing.Size(350, 20)
    $textboxServerName.Location = New-Object System.Drawing.Point(20, 150)
    $form.Controls.Add($textboxServerName)
    
    $textboxServerName.Add_GotFocus({
        if ($textboxServerName.Text -eq "MyServername") {
            $textboxServerName.Text = ""
            $textboxServerName.ForeColor = [System.Drawing.Color]::Black
        }
    })
    
    $textboxServerName.Add_LostFocus({
        if ($textboxServerName.Text -eq "") {
            $textboxServerName.Text = "MyServername"
            $textboxServerName.ForeColor = [System.Drawing.Color]::Gray
        }
    })
    
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Size = New-Object System.Drawing.Size(75, 23)
    $okButton.Location = New-Object System.Drawing.Point(295, 180)
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($okButton)
    
    $form.AcceptButton = $okButton
    $form.StartPosition = "CenterScreen"
    $result = $form.ShowDialog()
    
    if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $textboxGamePath.Text -ne "") {
        return $textboxGamePath.Text
    } else {
        return $null
    }
}

function Update-Version {
    param (
        [string]$serverPassword,
        [string]$gamePath
    )
    try {
        $destPath = $gamePath
        $seamlessCoopPath = "$destPath\SeamlessCoop"
        $settingsFilePath = "$seamlessCoopPath\ersc_settings.ini"
        $apiUrl = "https://api.github.com/repos/LukeYui/EldenRingSeamlessCoopRelease/releases/latest"
        $tempZipPath = "$env:TEMP\ersc.zip"
        $tempExtractPath = "$env:TEMP\ersc"

        $releaseInfo = Get-ReleaseInfo -apiUrl $apiUrl
        $version = $releaseInfo.tag_name
        $downloadUrl = Get-DownloadUrl -assets $releaseInfo.assets

        Download-File -url $downloadUrl -outputPath $tempZipPath
        Extract-ZipFile -zipPath $tempZipPath -extractPath $tempExtractPath
        Copy-File -source "$tempExtractPath\ersc_launcher.exe" -destination "$destPath\ersc_launcher.exe"
        Copy-Folder -source "$tempExtractPath\SeamlessCoop" -destination $seamlessCoopPath

        Update-SettingsFile -filePath $settingsFilePath -password $serverPassword

        $shortcutName = "EldenCoop$version.lnk"
        $desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), $shortcutName)
        Create-Shortcut -targetPath "$destPath\ersc_launcher.exe" -shortcutPath $desktopPath -startInPath $destPath

        Show-MessageBox -message "Updated to version: $version.`nStart game" -caption "Starting Server: $serverPassword" -icon Information
    } catch {
        Show-MessageBox -message "An unexpected error occurred: $_" -caption "Starting Server: $serverPassword" -icon Error
    }
}

function Execute-Game {
    param ([string]$gamePath)
    
    $gameExecutable = "$gamePath\ersc_launcher.exe"
    if (-Not (Test-Path $gameExecutable)) {
        Write-Output "Game executable not found at $gameExecutable"
        return
    }

    try {
        Start-Process -FilePath $gameExecutable -WorkingDirectory $gamePath
    } catch {
        Write-Error "Failed to start the game: $_"
    }
}

function Get-ReleaseInfo {
    param ([string]$apiUrl)
    Invoke-RestMethod -Uri $apiUrl -Headers @{"User-Agent" = "Mozilla/5.0"}
}

function Get-DownloadUrl {
    param ([array]$assets)
    
    foreach ($asset in $assets) {
        if ($asset.name -eq "ersc.zip") {
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
    Invoke-WebRequest -Uri $url -OutFile $outputPath
}

function Extract-ZipFile {
    param (
        [string]$zipPath,
        [string]$extractPath
    )
    if (Test-Path $extractPath) {
        Remove-Item -Recurse -Force $extractPath
    }
    Expand-Archive -Path $zipPath -DestinationPath $extractPath
}

function Copy-File {
    param (
        [string]$source,
        [string]$destination
    )
    Copy-Item -Path $source -Destination $destination -Force
}

function Copy-Folder {
    param (
        [string]$source,
        [string]$destination
    )
    Remove-Item -Recurse -Force $destination
    Copy-Item -Path $source -Destination $destination -Recurse -Force
}

function Update-SettingsFile {
    param (
        [string]$filePath,
        [string]$password
    )
    $settingsContent = Get-Content -Path $filePath
    $updatedContent = $settingsContent -replace '(cooppassword\s*=\s*).*', "cooppassword = $password"
    Set-Content -Path $filePath -Value $updatedContent
}

function Create-Shortcut {
    param (
        [string]$targetPath,
        [string]$shortcutPath,
        [string]$startInPath
    )
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $targetPath
    $shortcut.WorkingDirectory = $startInPath
    $shortcut.Save()
}

function Show-MessageBox {
    param (
        [string]$message,
        [string]$caption,
        [System.Windows.Forms.MessageBoxIcon]$icon
    )
    [System.Windows.Forms.MessageBox]::Show($message, $caption, [System.Windows.Forms.MessageBoxButtons]::OK, $icon)
}

# Call the main function
Main

# Close script
exit
