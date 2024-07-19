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

# Define paths for the script and output executable
$scriptPath = "eldencoop-updater.ps1"
$outputExePath = "eldencoop-updater.exe"

# Configuration values previously in config.psd1
$config = @{
    ServerPassword = "your_password_here"  # Replace with your actual password
}

# Read the original script content
$scriptContent = Get-Content -Path $scriptPath -Raw

# Embed the configuration values into the script
$configPlaceholder = '$config = @{}'
$configEmbedded = "`$config = @{`n    ServerPassword = `"your_password_here`"  # Replace with your actual password`n}"
$updatedScriptContent = $scriptContent -replace [regex]::Escape($configPlaceholder), $configEmbedded

# Save the updated script to a temporary file
$tempUpdatedScriptPath = [System.IO.Path]::GetTempFileName()
Set-Content -Path $tempUpdatedScriptPath -Value $updatedScriptContent

# Convert the updated script to an executable using PS2EXE
Invoke-Expression -Command "Invoke-ps2exe $tempUpdatedScriptPath $outputExePath"

# Clean up the temporary file
Remove-Item -Path $tempUpdatedScriptPath

Write-Host "Conversion complete. The executable is saved as $outputExePath"
