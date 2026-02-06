:realstart
if exist "C:\Program Files (x86)\openshot\version.txt" goto :check

goto :startInstall

:check
find "2.5.1" "C:\Program Files (x86)\openshot\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "C:\Program Files (x86)\openshot" mkdir "C:\Program Files (x86)\openshot"
"%programfiles%\Unowhy\TO_INSTALL\openshot\openshot_installer.exe" /VERYSILENT && echo "2.5.1" > "C:\Program Files (x86)\openshot\version.txt"

if exist "C:\Program Files (x86)\openshot\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "2.5.1" "C:\Program Files (x86)\openshot\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\openshot\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\openshot\KO.ps1"
goto :done

:alreadyInstalled

:done
