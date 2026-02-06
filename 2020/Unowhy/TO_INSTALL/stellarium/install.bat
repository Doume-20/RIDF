:realstart
if exist "C:\Program Files (x86)\Stellarium\version.txt" goto :check

goto :startInstall

:check
find "0.20.4.1" "C:\Program Files (x86)\Stellarium\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "C:\Program Files (x86)\Stellarium" mkdir "C:\Program Files (x86)\Stellarium"
"%programfiles%\Unowhy\TO_INSTALL\stellarium\stellarium_installer.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- && echo "0.20.4.1" > "C:\Program Files (x86)\Stellarium\version.txt"

if exist "C:\Program Files (x86)\Stellarium\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "0.20.4.1" "C:\Program Files (x86)\Stellarium\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\stellarium\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\stellarium\KO.ps1"
goto :done

:alreadyInstalled

:done
