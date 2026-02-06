:realstart
if exist "C:\Program Files (x86)\Unowhy\Drive monlycee.net\version.txt" goto :check

goto :startInstall

:check
find "3.12.1.20241004" "C:\Program Files (x86)\Unowhy\Drive monlycee.net\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "C:\Program Files (x86)\Unowhy\Drive monlycee.net" mkdir "C:\Program Files (x86)\Unowhy\Drive monlycee.net"
"%programfiles%\Unowhy\TO_INSTALL\drivemonlycee\drivemonlycee_installer.exe" --default-answer --confirm-command install AllUsers=true && echo "3.12.1.20241004" > "C:\Program Files (x86)\Unowhy\Drive monlycee.net\version.txt"

if exist "C:\Program Files (x86)\Unowhy\Drive monlycee.net\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "3.12.1.20241004" "C:\Program Files (x86)\Unowhy\Drive monlycee.net\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\drivemonlycee\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\drivemonlycee\KO.ps1"
goto :done

:alreadyInstalled

:done
