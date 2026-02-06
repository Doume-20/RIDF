:realstart
if exist "%userprofile%\AppData\Local\Programs\PhotoFiltre\version.txt" goto :check

goto :startInstall

:check
find "7.2.1" "%userprofile%\AppData\Local\Programs\PhotoFiltre\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "%userprofile%\AppData\Local\Programs\PhotoFiltre" mkdir "%userprofile%\AppData\Local\Programs\PhotoFiltre"
"%programfiles%\Unowhy\TO_INSTALL\photofiltre\photofiltre_installer.exe" /VERYSILENT && echo "7.2.1" > "%userprofile%\AppData\Local\Programs\PhotoFiltre\version.txt"

if exist "%userprofile%\AppData\Local\Programs\PhotoFiltre\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "7.2.1" "%userprofile%\AppData\Local\Programs\PhotoFiltre\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\photofiltre\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\photofiltre\KO.ps1"
goto :done

:alreadyInstalled

:done
