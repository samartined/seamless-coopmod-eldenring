function Main {
    Add-Type -AssemblyName System.Windows.Forms
    $configFileName = [System.IO.Path]::Combine($env:USERPROFILE, "eldencoop", "config.json")
    $config = Initialize-Config -configFileName $configFileName
    
    Show-MainMenu -config $config -configFileName $configFileName
}

function Initialize-Config {
    param ([string]$configFileName)
    
    $defaultConfig = @{
        GamePath = "C:\Program Files (x86)\Steam\steamapps\common\ELDEN RING\Game"
        ServerPassword = "123456Pi."
        Version = "1.0"
    }

    if (-Not (Test-Path $configFileName)) {
        New-Item -ItemType Directory -Path (Split-Path $configFileName) -Force | Out-Null
        $defaultConfig | ConvertTo-Json | Set-Content -Path $configFileName
        return $defaultConfig
    } else {
        $config = Get-Content -Path $configFileName | ConvertFrom-Json
        $configHashTable = @{}
        foreach ($key in $config.PSObject.Properties.Name) {
            $configHashTable[$key] = $config.$key
        }
        return $configHashTable
    }
}

function Save-Config {
    param (
        [hashtable]$config,
        [string]$configFileName
    )
    $config | ConvertTo-Json | Set-Content -Path $configFileName
}

function Show-MainMenu {
    param (
        [hashtable]$config,
        [string]$configFileName
    )
    Add-Type -AssemblyName System.Windows.Forms

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "EldenCoop Configuration"
    $form.Size = New-Object System.Drawing.Size(400, 200)
    $form.StartPosition = "CenterScreen"
    
    $labelGamePath = New-Object System.Windows.Forms.Label
    $labelGamePath.Text = "Game Path:"
    $labelGamePath.Size = New-Object System.Drawing.Size(350, 20)
    $labelGamePath.Location = New-Object System.Drawing.Point(20, 20)
    $form.Controls.Add($labelGamePath)
    
    $textboxGamePath = New-Object System.Windows.Forms.TextBox
    $textboxGamePath.Text = $config.GamePath
    $textboxGamePath.Size = New-Object System.Drawing.Size(350, 20)
    $textboxGamePath.Location = New-Object System.Drawing.Point(20, 50)
    $form.Controls.Add($textboxGamePath)
    
    $labelServerPassword = New-Object System.Windows.Forms.Label
    $labelServerPassword.Text = "Server Password:"
    $labelServerPassword.Size = New-Object System.Drawing.Size(350, 20)
    $labelServerPassword.Location = New-Object System.Drawing.Point(20, 80)
    $form.Controls.Add($labelServerPassword)
    
    $textboxServerPassword = New-Object System.Windows.Forms.TextBox
    $textboxServerPassword.Text = $config.ServerPassword
    $textboxServerPassword.Size = New-Object System.Drawing.Size(350, 20)
    $textboxServerPassword.Location = New-Object System.Drawing.Point(20, 110)
    $form.Controls.Add($textboxServerPassword)
    
    $buttonUpdate = New-Object System.Windows.Forms.Button
    $buttonUpdate.Text = "Update"
    $buttonUpdate.Size = New-Object System.Drawing.Size(75, 23)
    $buttonUpdate.Location = New-Object System.Drawing.Point(20, 140)
    $buttonUpdate.Add_Click({
        $config.GamePath = $textboxGamePath.Text
        $config.ServerPassword = $textboxServerPassword.Text
        Save-Config -config $config -configFileName $configFileName
        Update-Version -config $config -configFileName $configFileName
    })
    $form.Controls.Add($buttonUpdate)
    
    $buttonPlay = New-Object System.Windows.Forms.Button
    $buttonPlay.Text = "Play"
    $buttonPlay.Size = New-Object System.Drawing.Size(75, 23)
    $buttonPlay.Location = New-Object System.Drawing.Point(110, 140)
    $buttonPlay.Add_Click({
        $config.GamePath = $textboxGamePath.Text
        $config.ServerPassword = $textboxServerPassword.Text
        Save-Config -config $config -configFileName $configFileName
        Play-Game -gamePath $textboxGamePath.Text
    })
    $form.Controls.Add($buttonPlay)
    
    $form.ShowDialog() | Out-Null
}

function Update-Version {
    param (
        [hashtable]$config,
        [string]$configFileName
    )
    try {
        $gamePath = $config.GamePath
        $seamlessCoopPath = "$gamePath\SeamlessCoop"
        $settingsFilePath = "$seamlessCoopPath\ersc_settings.ini"
        $apiUrl = "https://api.github.com/repos/LukeYui/EldenRingSeamlessCoopRelease/releases/latest"
        $tempZipPath = "$env:TEMP\ersc.zip"
        $tempExtractPath = "$env:TEMP\ersc"

        $releaseInfo = Get-ReleaseInfo -apiUrl $apiUrl
        $version = $releaseInfo.tag_name
        $downloadUrl = Get-DownloadUrl -assets $releaseInfo.assets

        Download-File -url $downloadUrl -outputPath $tempZipPath
        Extract-ZipFile -zipPath $tempZipPath -extractPath $tempExtractPath
        Copy-File -source "$tempExtractPath\ersc_launcher.exe" -destination "$gamePath\ersc_launcher.exe"
        Copy-Folder -source "$tempExtractPath\SeamlessCoop" -destination $seamlessCoopPath

        Update-SettingsFile -filePath $settingsFilePath -password $config.ServerPassword

        $config.Version = $version
        Save-Config -config $config -configFileName $configFileName

        $shortcutName = "EldenCoop$version.lnk"
        $desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), $shortcutName)
        Create-Shortcut -targetPath "$gamePath\ersc_launcher.exe" -shortcutPath $desktopPath -startInPath $gamePath -iconPath "$gamePath\ersc_launcher.exe"

        Show-MessageBox -message "Updated to version: $version." -caption "Update Successful" -icon Information
    } catch {
        Show-MessageBox -message "An error occurred: $_" -caption "Update Failed" -icon Error
    }
}

function Play-Game {
    param ([string]$gamePath)
    
    $steamPath = "C:\Program Files (x86)\Steam\Steam.exe"
    if (-Not (Test-Path $steamPath)) {
        Show-MessageBox -message "Steam is not installed at $steamPath" -caption "Error" -icon Error
        return
    }

    try {
        Start-Process -FilePath $steamPath
        Start-Sleep -Seconds 10
        Start-Process -FilePath "$gamePath\ersc_launcher.exe" -WorkingDirectory $gamePath
    } catch {
        Show-MessageBox -message "Failed to start the game: $_" -caption "Error" -icon Error
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
        [string]$startInPath,
        [string]$iconPath
    )
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $targetPath
    $shortcut.WorkingDirectory = $startInPath
    $shortcut.IconLocation = $iconPath
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
