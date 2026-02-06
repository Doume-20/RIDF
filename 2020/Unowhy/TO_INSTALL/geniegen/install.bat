:realstart
if exist "%userprofile%\AppData\Local\Programs\GenieGen\version.txt" goto :check

goto :startInstall

:check
find "1.2.3.2" "%userprofile%\AppData\Local\Programs\GenieGen\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "%userprofile%\AppData\Local\Programs\GenieGen" mkdir "%userprofile%\AppData\Local\Programs\GenieGen"
"%programfiles%\Unowhy\TO_INSTALL\geniegen\geniegen_installer.exe" /VERYSILENT && echo "1.2.3.2" > "%userprofile%\AppData\Local\Programs\GenieGen\version.txt"

if exist "%userprofile%\AppData\Local\Programs\GenieGen\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "1.2.3.2" "%userprofile%\AppData\Local\Programs\GenieGen\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\geniegen\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\geniegen\KO.ps1"
goto :done

:alreadyInstalled

:done
