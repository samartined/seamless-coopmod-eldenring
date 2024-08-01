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

# Convert the updated script to an executable using PS2EXE with no console
Invoke-Expression -Command "Invoke-ps2exe -noConsole $scriptPath $outputExePath"

Write-Host "Conversion complete. The executable is saved as $outputExePath"
