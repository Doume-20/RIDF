:realstart
if exist "%userprofile%\AppData\Local\Programs\edupython\version.txt" goto :check

goto :startInstall

:check
find "3.0" "%userprofile%\AppData\Local\Programs\edupython\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "%userprofile%\AppData\Local\Programs\edupython" mkdir "%userprofile%\AppData\Local\Programs\edupython"
"%programfiles%\Unowhy\TO_INSTALL\edupython\edupython_installer.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- && echo "3.0" > "%userprofile%\AppData\Local\Programs\edupython\version.txt"

if exist "%userprofile%\AppData\Local\Programs\edupython\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "3.0" "%userprofile%\AppData\Local\Programs\edupython\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\edupython\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\edupython\KO.ps1"
goto :done

:alreadyInstalled

:done
