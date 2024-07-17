# Elden Ring Seamless Coop Updater

This script automates the process of updating the Elden Ring Seamless Coop mod. It fetches the latest release from GitHub, downloads and extracts the necessary files, and updates the game directory accordingly.

## Prerequisites

- Windows PowerShell
- Internet connection

## How to Use

1. **Modify the Script Path**:
    Ensure the destination path in the script matches your game's executable location. Update the `$destPath` variable if the path varies:
    ```powershell
    # Destination Path
    $destPath = "C:\Program Files (x86)\Steam\steamapps\common\ELDEN RING\Game"
    ```

2. **Convert the Script to an Executable**:
    Follow the steps below to convert the PowerShell script into an executable using `Win-PS2EXE`.

## Conversion to Executable

### Step 1: Install Win-PS2EXE

1. **Open PowerShell as Administrator**:
    Right-click on the Start menu and select "Windows PowerShell (Admin)".

2. **Install the Module**:
    Run the following command to install `ps2exe`:
    ```powershell
    Install-Module -Name ps2exe -Scope CurrentUser
    ```

### Step 2: Convert the Script

1. **Download and Extract PS2EXE**:
    - Go to the [PS2EXE GitHub repository](https://github.com/MScholtes/PS2EXE).
    - Download and extract the ZIP file to a convenient location.

2. **Convert the Script**:
    Navigate to the directory where you extracted `PS2EXE` and run the conversion command:
    ```powershell
    cd "path\to\PS2EXE-master"
    .\ps2exe.ps1 -inputFile "C:\Users\edgar\OneDrive\Desktop\update_mod.ps1" -outputFile "C:\Users\edgar\OneDrive\Desktop\update_mod.exe"
    ```


## Conclusion

This script ensures your Elden Ring Seamless Coop mod is always up to date with the latest release. Follow the instructions carefully to modify the script path if necessary and convert it into an executable for ease of use.

For more information and troubleshooting, visit the [PS2EXE GitHub repository](https://github.com/MScholtes/PS2EXE).