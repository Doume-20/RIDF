:realstart
if exist "%userprofile%\AppData\Local\Programs\mu\version.txt" goto :check

goto :startInstall

:check
find "1.0.3" "%userprofile%\AppData\Local\Programs\mu\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "%userprofile%\AppData\Local\Programs\mu" mkdir "%userprofile%\AppData\Local\Programs\mu"
"%programfiles%\Unowhy\TO_INSTALL\mu\mu_installer.exe" /S && echo "1.0.3" > "%userprofile%\AppData\Local\Programs\mu\version.txt"

if exist "%userprofile%\AppData\Local\Programs\mu\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "1.0.3" "%userprofile%\AppData\Local\Programs\mu\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\mu\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\mu\KO.ps1"
goto :done

:alreadyInstalled

:done
