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

2. **Convert the Script to an Executable if neccesary**:
   Follow the steps below to convert the PowerShell script into an executable using `Win-PS2EXE`.

## Conversion to Executable

### Alternative:

 If you find the following steps difficult, open the terminal in the folder path of the .ps1 file and simply type:

   ```powershell
   .\er_coop_updater_mod.ps1
   ```

   
### Step 1: Install Win-PS2EXE

1. **Open PowerShell as Administrator**:
   Right-click on the Start menu and select "Windows PowerShell (Admin)".

2. **Install the Module**:
   Run the following command to install `ps2exe`:

   ```powershell
   Install-Module -Name ps2exe -Scope CurrentUser
   ```

### Step 2: Convert the Script

1. **Download and Install Win-PS2EXE**:

   - Run the following command to download and install Win-PS2EXE:

   ```powershell
   Install-Module -Name Win-PS2EXE -Scope CurrentUser
   ```

2. **Use the GUI to Convert the Script**:

- In the Win-PS2EXE GUI, for the Source File, browse and select the path to update_mod.ps1.
- For the Target File, set the desired path and change the extension to .exe.
- Click Compile to convert the script to an executable.

## Conclusion

This script ensures your Elden Ring Seamless Coop mod is always up to date with the latest release. Follow the instructions carefully to modify the script path if necessary and convert it into an executable for ease of use.