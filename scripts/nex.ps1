[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001
$Part1Url = "https://raw.githubusercontent.com/nexoptimizer/nex/main/NexA.dph"
$Part2Url = "https://raw.githubusercontent.com/nexoptimizer/nex/main/NexB.dph"
$Part3Url = "https://raw.githubusercontent.com/nexoptimizer/nex/main/NexC.dph"
$Part4Url = "https://raw.githubusercontent.com/nexoptimizer/nex/main/NexD.dph"
$Part5Url = "https://raw.githubusercontent.com/nexoptimizer/nex/main/NexE.dph"
$Part6Url = "https://raw.githubusercontent.com/nexoptimizer/nex/main/NexF.dph"
$Part7Url = "https://raw.githubusercontent.com/nexoptimizer/nex/main/NexG.dph"
$Part8Url = "https://raw.githubusercontent.com/nexoptimizer/nex/main/NexH.dph"
$Part9Url = "https://raw.githubusercontent.com/nexoptimizer/nex/main/NexI.dph"
$HashUrl = "https://raw.githubusercontent.com/nexoptimizer/nex/main/scripts/hash"
$OutputPath = "$env:TEMP\nex-setup.exe"
$Retries = 3
$RetryDelaySeconds = 2
# ------------------------------------------------------------------
$Global:Messages = @{}
$Global:CurrentLanguage = "en"

$AsciiArt = @"
 __   __     ______     __  __    
/\ "-.\ \   /\  ___\   /\_\_\_\   
\ \ \-.  \  \ \  __\   \/_/\_\/_  
 \ \_\\"\_\  \ \_____\   /\_\/\_\ 
  \/_/ \/_/   \/_____/   \/_/\/_/                                  
"@


# Mensajes en inglés
$Messages_EN = @{
    'WelcomeTitle' = ''
    'SelectLanguage' = 'select language / seleccionar idioma:'
    'English' = '1. english'
    'Spanish' = '2. spanish'
    'LanguagePrompt' = 'enter choice (1-2)'
    'InvalidChoice' = 'invalid choice. using english as default.'
    'StartingInstallation' = 'starting nex optimizer installation...'
    'DownloadingPart' = 'downloading'
    'DownloadCompleted' = 'component downloaded successfully'
    'DownloadingHash' = 'downloading hash verification...'
    'AssemblingInstaller' = 'assembling installer components...'
    'VerifyingIntegrity' = 'verifying installer integrity...'
    'IntegrityVerified' = 'installer integrity verified successfully'
    'LaunchingInstaller' = 'launching nex optimizer installer...'
    'InstallationStarted' = 'installation started successfully'
    'InstallationComplete' = 'nex optimizer installation process initiated'
    'ErrorInvalidUrls' = 'error: all urls must use https and be valid'
    'ErrorHashDownloadFailed' = 'error: failed to download hash file'
    'ErrorDownloadFailed' = 'error: failed to download component'
    'ErrorAssemblyFailed' = 'error: failed to assemble installer components'
    'ErrorIntegrityFailed' = 'error: installer integrity verification failed'
    'ErrorInstallerLaunchFailed' = 'error: failed to launch installer'
    'Retrying' = 'retrying in'
    'Seconds' = 'seconds...'
    'Attempt' = 'attempt'
    'Of' = 'of'
    'Progress' = 'progress'
    'Bytes' = 'bytes'
    'Transferred' = 'transferred'
}

# Mensajes en español
$Messages_ES = @{
    'WelcomeTitle' = ''
    'SelectLanguage' = 'select language / seleccionar idioma:'
    'English' = '1. english'
    'Spanish' = '2. spanish'
    'LanguagePrompt' = 'ingrese opción (1-2)'
    'InvalidChoice' = 'opción invalida. usando ingles por defecto.'
    'StartingInstallation' = 'iniciando instalacion de nex optimizer...'
    'DownloadingPart' = 'descargando'
    'DownloadCompleted' = 'componente descargado exitosamente'
    'DownloadingHash' = 'descargando verificación hash...'
    'AssemblingInstaller' = 'ensamblando componentes del instalador...'
    'VerifyingIntegrity' = 'verificando integridad del instalador...'
    'IntegrityVerified' = 'integridad del instalador verificada exitosamente'
    'LaunchingInstaller' = 'lanzando instalador nex optimizer...'
    'InstallationStarted' = 'instalacion iniciada exitosamente'
    'InstallationComplete' = 'proceso de instalacion nex optimizer iniciado'
    'ErrorInvalidUrls' = 'error: todas las urls deben usar https y ser válidas'
    'ErrorHashDownloadFailed' = 'error: fallo al descargar archivo hash'
    'ErrorDownloadFailed' = 'error: fallo al descargar componente'
    'ErrorAssemblyFailed' = 'error: fallo al ensamblar componentes del instalador'
    'ErrorIntegrityFailed' = 'error: verificación de integridad del instalador falló'
    'ErrorInstallerLaunchFailed' = 'error: fallo al lanzar el instalador'
    'Retrying' = 'reintentando en'
    'Seconds' = 'segundos...'
    'Attempt' = 'intento'
    'Of' = 'de'
    'Progress' = 'progreso'
    'Bytes' = 'bytes'
    'Transferred' = 'transferidos'
}

function Get-Message($key) {
    return $Global:Messages[$key]
}

function Write-ColorText($text, $color = "White") {
    try {
        Write-Host $text -ForegroundColor $color
    } catch {
        Write-Host $text
    }
}

function Show-Welcome {
    Clear-Host
    Write-Host $AsciiArt -ForegroundColor Magenta
    Write-Host ""
}

function Write-WithAscii {
    param(
        [string]$Message,
        [ConsoleColor]$Color = "Magenta"
    )
    Clear-Host
    Show-Welcome
    Write-Host $Message -ForegroundColor $Color
}

function Select-Language {
    Write-ColorText (Get-Message 'SelectLanguage') -color "Magenta"
    Write-Host ""
    Write-Host (Get-Message 'English') -ForegroundColor Magenta
    Write-Host (Get-Message 'Spanish') -ForegroundColor Magenta
    Write-Host ""
    
    $choice = Read-Host (Get-Message 'LanguagePrompt')
    
    switch ($choice.Trim()) {
        "1" { 
            $Global:CurrentLanguage = "en"
            $Global:Messages = $Messages_EN
        }
        "2" { 
            $Global:CurrentLanguage = "es"
            $Global:Messages = $Messages_ES
        }
        default { 
            Write-ColorText (Get-Message 'InvalidChoice') -color "Yellow"
            $Global:CurrentLanguage = "en"
            $Global:Messages = $Messages_EN
        }
    }
    
    Start-Sleep -Seconds 1
    Show-Welcome
}

function Throw-And-Exit($msgKey, $code=1) {
    Write-ColorText (Get-Message $msgKey) -color "DarkRed"
    exit $code
}

function Validate-Https($url) {
    try {
        $u = [Uri]::new($url)
    } catch {
        return $false
    }
    return $u.Scheme -eq 'https'
}

function Download-File {
    param(
        [string]$Url,
        [string]$Destination,
        [string]$ComponentName,
        [int]$MaxRetries = 3,
        [int]$DelaySeconds = 2
    )

    if (-not (Validate-Https $Url)) {
        Write-ColorText "error: invalid url - $Url" -color "Magenta"
        return $false
    }

    $client = New-Object System.Net.Http.HttpClient
    $client.Timeout = [System.TimeSpan]::FromMinutes(30)

    $attempt = 0
    while ($attempt -lt $MaxRetries) {
        try {
            $attempt++
            Write-WithAscii "$(Get-Message 'DownloadingPart') $ComponentName ($(Get-Message 'Attempt') $attempt $(Get-Message 'Of') $MaxRetries)..." 
            
            $req = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Get, $Url)
            $responseTask = $client.SendAsync($req, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead)
            $responseTask.Wait()
            $response = $responseTask.Result

            if (-not $response.IsSuccessStatusCode) {
                throw "HTTP $($response.StatusCode)"
            }

            $contentLength = $response.Content.Headers.ContentLength
            $streamTask = $response.Content.ReadAsStreamAsync()
            $streamTask.Wait()
            $responseStream = $streamTask.Result

            $buffer = New-Object byte[] 81920
            $fs = [System.IO.File]::Open($Destination, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
            try {
                $totalRead = 0
                while (($read = $responseStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                    $fs.Write($buffer, 0, $read)
                    $totalRead += $read
                    if ($contentLength) {
                        $pct = [math]::Round(($totalRead / $contentLength) * 100, 1)
                        Write-Progress -Activity "$(Get-Message 'DownloadingPart') $ComponentName" -Status "$pct% ($totalRead / $contentLength $(Get-Message 'Bytes'))" -PercentComplete $pct
                    } else {
                        Write-Progress -Activity "$(Get-Message 'DownloadingPart') $ComponentName" -Status "$totalRead $(Get-Message 'Bytes') $(Get-Message 'Transferred')"
                    }
                }
                Write-ColorText "$(Get-Message 'DownloadCompleted')" -color "Green"
                return $true
            } finally {
                $fs.Close()
                $responseStream.Close()
                $response.Dispose()
            }
        } catch {
            Write-ColorText "error downloading $ComponentName ($(Get-Message 'Attempt') $attempt): $_" -color "Yellow"
            if ($attempt -lt $MaxRetries) {
                $backoff = $DelaySeconds * ([math]::Pow(2, $attempt-1))
                Write-Host "$(Get-Message 'Retrying') $backoff $(Get-Message 'Seconds')"
                Start-Sleep -Seconds $backoff
            } else {
                return $false
            }
        }
    }
    
    $client.Dispose()
    return $false
}

function Download-HashFile {
    param([string]$Url, [string]$Destination)
    
    try {
        Write-ColorText (Get-Message 'DownloadingHash') -color "Magenta"
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
        return $true
    } catch {
        return $false
    }
}

function Assemble-InstallerComponents {
    param(
        [string[]]$Parts,
        [string]$OutFile
    )
    
    Write-ColorText (Get-Message 'AssemblingInstaller') -color "Cyan"
    
    $dir = [System.IO.Path]::GetDirectoryName($OutFile)
    if (-not [string]::IsNullOrEmpty($dir) -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $outFs = [System.IO.File]::Open($OutFile, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
    try {
        $buf = New-Object byte[] 81920
        $partNum = 1
        foreach ($p in $Parts) {
            Write-Progress -Activity (Get-Message 'AssemblingInstaller') -Status "$(Get-Message 'Progress') $partNum/9" -PercentComplete (($partNum / 9) * 100)
            $inFs = [System.IO.File]::Open($p, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
            try {
                while (($r = $inFs.Read($buf, 0, $buf.Length)) -gt 0) {
                    $outFs.Write($buf, 0, $r)
                }
            } finally {
                $inFs.Close()
            }
            $partNum++
        }
    } finally {
        $outFs.Close()
    }
}

function Launch-Installer {
    param(
        [Parameter(Mandatory=$true)][string]$InstallerPath
    )

    if (-not (Test-Path $InstallerPath)) {
        Throw-And-Exit 'ErrorInstallerLaunchFailed'
    }

    try {
        Write-ColorText (Get-Message 'LaunchingInstaller') -color "Magenta"
        Start-Process -FilePath $InstallerPath
        Write-ColorText (Get-Message 'InstallationStarted') -color "Magenta"
        return $true
    } catch {
        Write-ColorText "$(Get-Message 'ErrorInstallerLaunchFailed'): $_" -color "DarkRed"
        return $false
    }
}



# --- INICIO DEL INSTALADOR ---

# Configurar idioma inicial para la selección
$Global:Messages = $Messages_EN


# Mostrar bienvenida y seleccionar idioma
Show-Welcome
Select-Language

# Array de todas las URLs para validación
$allUrls = @($Part1Url, $Part2Url, $Part3Url, $Part4Url, $Part5Url, $Part6Url, $Part7Url, $Part8Url, $Part9Url, $HashUrl)

# Validar que todas las URLs sean HTTPS
$invalidUrls = $allUrls | Where-Object { -not (Validate-Https $_) }
if ($invalidUrls.Count -gt 0) {
    Throw-And-Exit 'ErrorInvalidUrls'
}

Write-ColorText (Get-Message 'StartingInstallation') -color "Green"
Write-Host ""

# Crear directorio temporal
$tmpDir = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ("nex_installer_{0}" -f ([System.Guid]::NewGuid().ToString().Substring(0,8)))
New-Item -ItemType Directory -Path $tmpDir | Out-Null

# Crear rutas para las 9 partes
$nexA = Join-Path $tmpDir "NexA.dph"
$nexB = Join-Path $tmpDir "NexB.dph"
$nexC = Join-Path $tmpDir "NexC.dph"
$nexD = Join-Path $tmpDir "NexD.dph"
$nexE = Join-Path $tmpDir "NexE.dph"
$nexF = Join-Path $tmpDir "NexF.dph"
$nexG = Join-Path $tmpDir "NexG.dph"
$nexH = Join-Path $tmpDir "NexH.dph"
$nexI = Join-Path $tmpDir "NexI.dph"
$hashFile = Join-Path $tmpDir "hash"

# Descargar archivo hash
$hashSuccess = Download-HashFile -Url $HashUrl -Destination $hashFile
if (-not $hashSuccess) {
    Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
    Throw-And-Exit 'ErrorHashDownloadFailed'
}

$expectedHash = (Get-Content $hashFile -Raw).Trim()

# Array de descargas (URL, Destino, Nombre)
$downloads = @(
    @($Part1Url, $nexA, "NexA.dph"),
    @($Part2Url, $nexB, "NexB.dph"),
    @($Part3Url, $nexC, "NexC.dph"),
    @($Part4Url, $nexD, "NexD.dph"),
    @($Part5Url, $nexE, "NexE.dph"),
    @($Part6Url, $nexF, "NexF.dph"),
    @($Part7Url, $nexG, "NexG.dph"),
    @($Part8Url, $nexH, "NexH.dph"),
    @($Part9Url, $nexI, "NexI.dph")
)

# Descargar todas las partes
foreach ($download in $downloads) {
    $success = Download-File -Url $download[0] -Destination $download[1] -ComponentName $download[2] -MaxRetries $Retries -DelaySeconds $RetryDelaySeconds
    if (-not $success) {
        Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
        Throw-And-Exit 'ErrorDownloadFailed'
    }
}

# Ensamblar instalador
try {
    Assemble-InstallerComponents -Parts @($nexA, $nexB, $nexC, $nexD, $nexE, $nexF, $nexG, $nexH, $nexI) -OutFile $OutputPath
} catch {
    Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
    Throw-And-Exit 'ErrorAssemblyFailed'
}

# Verificar integridad y ejecutar instalador
try {
    Write-ColorText (Get-Message 'VerifyingIntegrity') -color "Magenta"
    $computed = (Get-FileHash -Path $OutputPath -Algorithm SHA256).Hash
    
    if ($computed.ToLower() -ne $expectedHash.ToLower()) {
        Remove-Item -Force $OutputPath -ErrorAction SilentlyContinue
        Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
        Throw-And-Exit 'ErrorIntegrityFailed'
    } else {
        Write-ColorText (Get-Message 'IntegrityVerified') -color "Green"
        
        # Limpiar temporales
        Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue

        Write-Host ""
        
        # Lanzar instalador automáticamente
        $launchOk = Launch-Installer -InstallerPath $OutputPath
        if ($launchOk) {
            Write-Host ""
            Write-ColorText (Get-Message 'InstallationComplete') -color "Green"
            # Pequeña pausa para que el usuario vea el mensaje antes de que se cierre
            Start-Sleep -Seconds 2
            exit 0
        } else {
            Throw-And-Exit 'ErrorInstallerLaunchFailed'
        }
    }
} catch {
    Remove-Item -Force $OutputPath -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
    Throw-And-Exit 'ErrorIntegrityFailed'
}
