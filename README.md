# Elden Ring Seamless Coop Updater V1.7.9

This script automates the process of updating the Elden Ring Seamless Coop mod. It fetches the latest release from GitHub, downloads and extracts the necessary files, and updates the game directory accordingly.

## Prerequisites to Use

- Windows 11
- Steam Accout Open
- Elden Ring Game buyed in library
- Elden Ring Game intalled
- Internet connection 

## Prerequisites to Compile

- Windows PowerShell Admin
- Win-PS2EXE intalled
- Internet connection

## How Use
   Double click in .exe file or execute it (with default password)
   ```powershell
   .\eldencoop-updater.exe
   ```

## How compile exe

1. **Modify the Script Path**:
   Update the `ServerPassword` in the config.psd1 file:

   ```powershell
   ServerPassword = "YourSecurePassword123"
   ```

2. **Convert the Script to an Executable**:
   Do you nedd tool `Win-PS2EXE` installed in the OS.

   Ececute script
   ```powershell
   Invoke-ps2exe .\eldencoop-updater.ps1 .\eldencoop-updater.exe
   ```

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