@echo off
setlocal ENABLEDELAYEDEXPANSION

REM ============================================================
REM Run-Install-Cortex-Client-NoKB.bat (Version serveur corrigée)
REM - Détecte OS (Win7/8/8.1 vers W7-8, tout le reste vers nouveau script)
REM - Gère correctement les serveurs Windows
REM ============================================================

REM ---------- Initialisation des logs ----------
set "LOGDIR=C:\Windows\Cortex\Logs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>&1
set "DT=%DATE:/=-%_%TIME::=-%"
set "DT=%DT: =0%"
set "LOG=%LOGDIR%\Run-Install-Cortex-%DT%.log"

echo [BAT] ===== Début d'exécution ===== > "%LOG%"
echo [BAT] Hôte: %COMPUTERNAME% >> "%LOG%"
echo [BAT] Utilisateur: %USERNAME% >> "%LOG%"

REM ---------- Vérification Cortex/Traps ----------
set "TRAPS_X64=C:\Program Files\Palo Alto Networks\Traps\cyserver.exe"
set "TRAPS_X86=C:\Program Files (x86)\Palo Alto Networks\Traps\cyserver.exe"
if exist "%TRAPS_X64%" (
  echo [BAT] Cortex/Traps déjà présent: "%TRAPS_X64%". Arrêt.
  echo [BAT] Cortex/Traps déjà présent: "%TRAPS_X64%". Arrêt. >> "%LOG%"
  exit /b 0
)
if exist "%TRAPS_X86%" (
  echo [BAT] Cortex/Traps déjà présent: "%TRAPS_X86%". Arrêt.
  echo [BAT] Cortex/Traps déjà présent: "%TRAPS_X86%". Arrêt. >> "%LOG%"
  exit /b 0
)

REM ---------- Configuration domaine ----------
set "LOGONSRV=%LOGONSERVER:~2%"
set "DOMAIN=%USERDNSDOMAIN%"
if not defined DOMAIN for /F "tokens=2 delims==" %%D in ('wmic computersystem get domain /value ^| find "="') do set "DOMAIN=%%D"

if not defined LOGONSRV (
  echo [BAT] ERREUR: LOGONSERVER non trouvé.
  echo [BAT] ERREUR: LOGONSERVER non trouvé. >> "%LOG%"
  exit /b 10
)
if not defined DOMAIN (
  echo [BAT] ERREUR: DOMAIN non trouvé.
  echo [BAT] ERREUR: DOMAIN non trouvé. >> "%LOG%"
  exit /b 11
)

set "ROOT=\\%LOGONSRV%\SYSVOL\%DOMAIN%\scripts\Cortex"
if not exist "%ROOT%" set "ROOT=\\%DOMAIN%\SYSVOL\%DOMAIN%\scripts\Cortex"

REM Attendre disponibilité
set "WAITSEC=60"
set /a _elapsed=0
:WAIT_ROOT
if exist "%ROOT%" goto ROOT_OK
if %_elapsed% GEQ %WAITSEC% (
  echo [BAT] ERREUR: Partage SYSVOL Cortex non trouvé: %ROOT%
  echo [BAT] ERREUR: Partage SYSVOL Cortex non trouvé: %ROOT% >> "%LOG%"
  exit /b 12
)
ping -n 2 127.0.0.1 >nul
set /a _elapsed+=2
goto WAIT_ROOT

:ROOT_OK
echo [BAT] ROOT: %ROOT%
echo [BAT] ROOT: %ROOT% >> "%LOG%"

REM ---------- Détection OS avec gestion serveur ----------
set "MAJOR="
set "MINOR="
set "OS_TYPE="

REM Détection du type d'OS (Workstation vs Server)
for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\ProductOptions" /v ProductType 2^>nul ^| findstr "ProductType"') do (
    set "OS_TYPE=%%a"
)

REM Détection de version avec wmic
wmic os get version /format:list > "%TEMP%\osver.tmp" 2>nul
for /f "tokens=2 delims==" %%a in ('type "%TEMP%\osver.tmp" ^| findstr "Version="') do (
    set "FULLVERSION=%%a"
)
del "%TEMP%\osver.tmp" 2>nul

if defined FULLVERSION (
    for /f "tokens=1,2,3 delims=." %%a in ("%FULLVERSION%") do (
        set "MAJOR=%%a"
        set "MINOR=%%b"
    )
)

REM Fallback si wmic échoue
if not defined MAJOR (
    reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentVersion > "%TEMP%\regver.tmp" 2>nul
    for /f "tokens=3" %%a in ('type "%TEMP%\regver.tmp" ^| findstr "CurrentVersion"') do (
        for /f "tokens=1,2 delims=." %%b in ("%%a") do (
            set "MAJOR=%%b"
            set "MINOR=%%c"
        )
    )
    del "%TEMP%\regver.tmp" 2>nul
)

if not defined MAJOR (
    echo [BAT] ERREUR: Impossible de détecter la version OS
    echo [BAT] ERREUR: Impossible de détecter la version OS >> "%LOG%"
    exit /b 13
)

echo [BAT] Version détectée: %MAJOR%.%MINOR% (Type: %OS_TYPE%)
echo [BAT] Version détectée: %MAJOR%.%MINOR% (Type: %OS_TYPE%) >> "%LOG%"

REM ---------- Logique de sélection du script ----------
REM Seuls Windows 7 et 8/8.1 WORKSTATION utilisent le vieux script
REM Tout le reste (serveurs, Windows 10+) utilise le nouveau script

set "USE_OLD_SCRIPT=0"

REM Windows 7 Workstation
if "%MAJOR%.%MINOR%"=="6.1" (
    if /i "%OS_TYPE%"=="WinNT" set "USE_OLD_SCRIPT=1"
)

REM Windows 8/8.1 Workstation  
if "%MAJOR%.%MINOR%"=="6.2" (
    if /i "%OS_TYPE%"=="WinNT" set "USE_OLD_SCRIPT=1"
)
if "%MAJOR%.%MINOR%"=="6.3" (
    if /i "%OS_TYPE%"=="WinNT" set "USE_OLD_SCRIPT=1"
)

REM ---------- Sélection et exécution du script ----------
set "PS_W78=%ROOT%\Install-Cortex-Client-W7-8.ps1"
set "PS_NEW=%ROOT%\Install-Cortex-Client.ps1"
set "PS64=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%PS64%" set "PS64=powershell.exe"

if "%USE_OLD_SCRIPT%"=="1" (
    echo [BAT] OS cible = Windows 7/8/8.1 Workstation -> Script W7-8
    echo [BAT] OS cible = Windows 7/8/8.1 Workstation -> Script W7-8 >> "%LOG%"
    if not exist "%PS_W78%" (
        echo [BAT] ERREUR: Script W7-8 non trouvé: %PS_W78%
        echo [BAT] ERREUR: Script W7-8 non trouvé: %PS_W78% >> "%LOG%"
        exit /b 20
    )
    "%PS64%" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "& '%PS_W78%'" >> "%LOG%" 2>&1
    set "RC=!ERRORLEVEL!"
    echo [BAT] Fin script W7-8, code: !RC!
    echo [BAT] Fin script W7-8, code: !RC! >> "%LOG%"
) else (
    echo [BAT] OS cible = Windows 10+/Serveur -> Script moderne
    echo [BAT] OS cible = Windows 10+/Serveur -> Script moderne >> "%LOG%"
    if not exist "%PS_NEW%" (
        echo [BAT] ERREUR: Script moderne non trouvé: %PS_NEW%
        echo [BAT] ERREUR: Script moderne non trouvé: %PS_NEW% >> "%LOG%"
        exit /b 21
    )
    "%PS64%" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "& '%PS_NEW%'" >> "%LOG%" 2>&1
    set "RC=!ERRORLEVEL!"
    echo [BAT] Fin script moderne, code: !RC!
    echo [BAT] Fin script moderne, code: !RC! >> "%LOG%"
)

exit /b !RC!

endlocal