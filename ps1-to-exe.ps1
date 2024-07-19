# Ensure required modules are installed
$modules = @("PS2EXE")
foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing module $module..."
        Install-Module -Name $module -Scope CurrentUser -Force -ErrorAction Stop
    } else {
        Write-Host "Module $module is already installed."
    }
}

# Define paths for the scripts and config file
$scriptPath = "eldencoop-updater.ps1"
$configPath = "config.psd1"
$updatedScriptPath = "eldencoop-updater_with_config.ps1"
$outputExePath = "eldencoop-updater.exe"

# Function to convert a file to a Base64 string
function Convert-FileToBase64 {
    param (
        [string]$filePath
    )
    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
    $base64String = [System.Convert]::ToBase64String($fileBytes)
    return $base64String
}

# Convert the config.psd1 file to a Base64 string
$configBase64 = Convert-FileToBase64 -filePath $configPath

# Read the original script content
$scriptContent = Get-Content -Path $scriptPath -Raw

# Embed the Base64 string in the script
$base64Placeholder = '$ConfigBase64 = ""'
$base64Embedded = "`$ConfigBase64 = '$configBase64'"
$updatedScriptContent = $scriptContent -replace [regex]::Escape($base64Placeholder), $base64Embedded

# Save the updated script
Set-Content -Path $updatedScriptPath -Value $updatedScriptContent

# Convert the updated script to an executable using PS2EXE
Invoke-Expression -Command "Invoke-ps2exe $updatedScriptPath $outputExePath"

Write-Host "Conversion complete. The executable is saved as $outputExePath"
