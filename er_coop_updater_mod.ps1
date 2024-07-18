# Importar el archivo de configuración
$configPath = ".\config.psd1"
$config = Import-PowerShellDataFile -Path $configPath

# Ruta de destino
$destPath = "C:\Program Files (x86)\Steam\steamapps\common\ELDEN RING\Game"
$seamlessCoopPath = "$destPath\SeamlessCoop"
$settingsFilePath = "$seamlessCoopPath\ersc_settings.ini"

# URL del último release de GitHub
$apiUrl = "https://api.github.com/repos/LukeYui/EldenRingSeamlessCoopRelease/releases/latest"
$downloadUrl = ""
$version = ""

# Obtener el URL de descarga del archivo ersc.zip y la versión del release
Write-Output "Obteniendo la información del último release de GitHub..."
try {
    $releaseInfo = Invoke-RestMethod -Uri $apiUrl -Headers @{"User-Agent" = "Mozilla/5.0" }
    Write-Output "Información del release obtenida correctamente."
    $version = $releaseInfo.tag_name
    $assets = $releaseInfo.assets
    foreach ($asset in $assets) {
        if ($asset.name -eq "ersc.zip") {
            $downloadUrl = $asset.browser_download_url
            break
        }
    }

    if ($downloadUrl -eq "") {
        throw "No se pudo encontrar el archivo ersc.zip en el último release."
    }
}
catch {
    Write-Error "Error al obtener la información del último release: $_"
    exit 1
}

# Descargar el archivo ersc.zip
$tempZipPath = "$env:TEMP\ersc.zip"
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZipPath
}
catch {
    Write-Error "Error al descargar el archivo ersc.zip: $_"
    exit 1
}

# Descomprimir el archivo ersc.zip
$tempExtractPath = "$env:TEMP\ersc"
if (Test-Path $tempExtractPath) {
    Remove-Item -Recurse -Force $tempExtractPath
}
Expand-Archive -Path $tempZipPath -DestinationPath $tempExtractPath

# Copiar y sobrescribir el ejecutable ersc_launcher
try {
    Copy-Item -Path "$tempExtractPath\ersc_launcher.exe" -Destination "$destPath\ersc_launcher.exe" -Force
}
catch {
    Write-Error "Error al copiar el ejecutable ersc_launcher.exe: $_"
    exit 1
}

# Sobrescribir la carpeta SeamlessCoop
try {
    Remove-Item -Recurse -Force $seamlessCoopPath
    Copy-Item -Path "$tempExtractPath\SeamlessCoop" -Destination $destPath -Recurse -Force
}
catch {
    Write-Error "Error al sobrescribir la carpeta SeamlessCoop: $_"
    exit 1
}

# Modificar el archivo ersc_settings.ini
try {
    $settingsContent = Get-Content -Path $settingsFilePath
    $updatedContent = $settingsContent -replace '(cooppassword\s*=\s*).*', "cooppassword = $($config.ServerPassword)"
    Set-Content -Path $settingsFilePath -Value $updatedContent
    Write-Output "Archivo ersc_settings.ini modificado correctamente."
}
catch {
    Write-Error "Error al modificar el archivo ersc_settings.ini: $_"
    exit 1
}

Write-Output "Actualizacion completada exitosamente. Version actualizada a: $version."
