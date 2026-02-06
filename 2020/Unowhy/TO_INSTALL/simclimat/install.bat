:realstart
if exist "C:\Program Files (x86)\SimClimat\version.txt" goto :check

goto :startInstall

:check
find "1.0.4" "C:\Program Files (x86)\SimClimat\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "C:\Program Files (x86)\SimClimat" mkdir "C:\Program Files (x86)\SimClimat"
"%programfiles%\Unowhy\TO_INSTALL\simclimat\simclimat_installer.exe" /S && echo "1.0.4" > "C:\Program Files (x86)\SimClimat\version.txt"

if exist "C:\Program Files (x86)\SimClimat\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "1.0.4" "C:\Program Files (x86)\SimClimat\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\simclimat\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\simclimat\KO.ps1"
goto :done

:alreadyInstalled

:done
