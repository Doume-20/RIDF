:realstart
if exist "C:\Program Files (x86)\Texmaker\version.txt" goto :check

goto :startInstall

:check
find "5.0.4" "C:\Program Files (x86)\Texmaker\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "C:\Program Files (x86)\Texmaker" mkdir "C:\Program Files (x86)\Texmaker"
msiexec /i "%programfiles%\Unowhy\TO_INSTALL\texmaker\texmaker_installer.msi" /qn && echo "5.0.4" > "C:\Program Files (x86)\Texmaker\version.txt"

if exist "C:\Program Files (x86)\Texmaker\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "5.0.4" "C:\Program Files (x86)\Texmaker\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\texmaker\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\texmaker\KO.ps1"
goto :done

:alreadyInstalled

:done
