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

# Define paths for the script, output executable, and icon
$scriptPath = "eldencoop-updater.ps1"
$outputExePath = "eldencoop.exe"
$iconPath = "eldencoop.ico"  # Replace with the actual path to your .ico file

# Convert the updated script to an executable using PS2EXE with no console and an icon
Invoke-Expression -Command "Invoke-ps2exe -noConsole -icon $iconPath $scriptPath $outputExePath"

Write-Host "Conversion complete. The executable is saved as $outputExePath"
