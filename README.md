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
   .\ps1-to-exe.ps1
   ```  
