:realstart
if exist "C:\Program Files (x86)\musescore\version.txt" goto :check

goto :startInstall

:check
find "3.6.2.548021805" "C:\Program Files (x86)\musescore\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "C:\Program Files (x86)\musescore" mkdir "C:\Program Files (x86)\musescore"
msiexec /i "%programfiles%\Unowhy\TO_INSTALL\musescore\musescore_installer.msi" /qb-! /norestart ALLUSERS=1 TARGETDIR="C:\Program Files (x86)\MuseScore" && echo "3.6.2.548021805" > "C:\Program Files (x86)\musescore\version.txt"

if exist "C:\Program Files (x86)\musescore\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "3.6.2.548021805" "C:\Program Files (x86)\musescore\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\musescore\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\musescore\KO.ps1"
goto :done

:alreadyInstalled

:done
