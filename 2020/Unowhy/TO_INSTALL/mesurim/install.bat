:realstart
if exist "%userprofile%\AppData\Local\Programs\Mesurim\version.txt" goto :check

goto :startInstall

:check
find "3.4.4" "%userprofile%\AppData\Local\Programs\Mesurim\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "%userprofile%\AppData\Local\Programs\Mesurim" mkdir "%userprofile%\AppData\Local\Programs\Mesurim"
"%programfiles%\Unowhy\TO_INSTALL\mesurim\mesurim_installer.exe" /VERYSILENT && echo "3.4.4" > "%userprofile%\AppData\Local\Programs\Mesurim\version.txt"

if exist "%userprofile%\AppData\Local\Programs\Mesurim\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "3.4.4" "%userprofile%\AppData\Local\Programs\Mesurim\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\mesurim\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\mesurim\KO.ps1"
goto :done

:alreadyInstalled

:done
