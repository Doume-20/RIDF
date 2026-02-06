:realstart
if exist "%userprofile%\AppData\Local\Programs\Unowhy\Lelivrescolaire\version.txt" goto :check

goto :startInstall

:check
find "4.0.6" "%userprofile%\AppData\Local\Programs\Unowhy\Lelivrescolaire\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "%userprofile%\AppData\Local\Programs\Unowhy\Lelivrescolaire" mkdir "%userprofile%\AppData\Local\Programs\Unowhy\Lelivrescolaire"
"%programfiles%\Unowhy\TO_INSTALL\lelivrescolaire\lelivrescolaire_installer.exe" /S && echo "4.0.6" > "%userprofile%\AppData\Local\Programs\Unowhy\Lelivrescolaire\version.txt"

if exist "%userprofile%\AppData\Local\Programs\Unowhy\Lelivrescolaire\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "4.0.6" "%userprofile%\AppData\Local\Programs\Unowhy\Lelivrescolaire\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\lelivrescolaire\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\lelivrescolaire\KO.ps1"
goto :done

:alreadyInstalled

:done
