:realstart
if exist "C:\Program Files (x86)\Thunderbird\version.txt" goto :check

goto :startInstall

:check
find "78.10.0" "C:\Program Files (x86)\Thunderbird\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "C:\Program Files (x86)\Thunderbird" mkdir "C:\Program Files (x86)\Thunderbird"
"%programfiles%\Unowhy\TO_INSTALL\thunderbird\thunderbird_installer.exe" /S && echo "78.10.0" > "C:\Program Files (x86)\Thunderbird\version.txt"

if exist "C:\Program Files (x86)\Thunderbird\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "78.10.0" "C:\Program Files (x86)\Thunderbird\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\thunderbird\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\thunderbird\KO.ps1"
goto :done

:alreadyInstalled

:done
